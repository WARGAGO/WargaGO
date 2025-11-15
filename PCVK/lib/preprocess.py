# @markdown ### Preprocess.py - Preprocess, Feature Extraction untuk model

from torch.utils.data import Dataset
import torchvision.transforms as T
import cv2
import torch
from extract_features import extract_all_features
from segment import auto_segment
from concurrent.futures import ThreadPoolExecutor, as_completed
from multiprocessing import cpu_count
import gc


class FeatureDataset(Dataset):
    def __init__(
        self,
        img_paths,
        labels,
        img_size,
        use_segmentation=False,
        seg_method="hsv",
        cache_features=True,
        num_workers=None,
        max_cache_size_gb=4.0,  # Limit cache size to prevent memory issues
    ):
        self.img_paths = img_paths
        self.labels = labels
        self.img_size = img_size
        self.use_segmentation = use_segmentation
        self.seg_method = seg_method
        self.cache_features = cache_features
        self.feature_cache = {}
        self.max_cache_size_gb = max_cache_size_gb

        # Auto-detect number of workers if not specified
        if num_workers is None:
            # For I/O bound: 2x CPUs, but cap it to avoid thread overhead
            num_workers = min(cpu_count() * 2, 12)
        self.num_workers = num_workers

        # Image transformation
        self.transform = T.Compose(
            [
                T.ToTensor(),
                T.Resize((img_size, img_size), antialias=True),
                T.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
            ]
        )

        # Preprocess all features if caching is enabled
        if self.cache_features:
            seg_status = (
                f"with {seg_method} segmentation"
                if use_segmentation
                else "without segmentation"
            )
            print(
                f"Preprocessing {len(img_paths)} images ({seg_status}, ALL 44 features)"
            )
            print(f"Using {self.num_workers} parallel workers")

            self._parallel_preprocess()
            print(f"✅ All features cached!")

    def _process_single_image(self, idx):
        """
        Worker function - processes image and extracts features
        """
        try:
            # Read image
            img = cv2.imread(self.img_paths[idx])
            
            if img is None:
                raise ValueError(f"Failed to load image at {self.img_paths[idx]}")

            # Apply segmentation if enabled
            if self.use_segmentation and self.seg_method != "none":
                img_processed = auto_segment(img.copy(), method=self.seg_method)
            else:
                img_processed = img

            # Extract features
            combined_feat = extract_all_features(
                img_processed,
                use_segmentation=False,
                seg_method="none",
            )

            # Store only features to save memory
            # We'll re-read images in __getitem__ (fast operation)
            
            return idx, combined_feat, None
            
        except Exception as e:
            return idx, None, str(e)

    def _parallel_preprocess(self):
        """Optimized parallel preprocessing with strategic memory cleanup at 25% intervals"""
        from tqdm import tqdm
        
        total_images = len(self.img_paths)
        failed_images = []
        processed_count = 0
        
        # Calculate cleanup checkpoints at 25%, 50%, 75%
        cleanup_intervals = [int(total_images * p) for p in [0.25, 0.5, 0.75]]
        
        # Use ThreadPoolExecutor with context manager for proper cleanup
        with ThreadPoolExecutor(
            max_workers=self.num_workers,
            thread_name_prefix="ImgPreproc"
        ) as executor:
            
            # Submit all tasks
            futures = {
                executor.submit(self._process_single_image, idx): idx 
                for idx in range(total_images)
            }
            
            # Process results as they complete
            with tqdm(total=total_images, desc="Caching features", smoothing=0.1) as pbar:
                for future in as_completed(futures):
                    try:
                        idx, result, error = future.result()
                        
                        if error is None and result is not None:
                            # Store only features, not images
                            self.feature_cache[idx] = result
                            processed_count += 1
                        else:
                            failed_images.append((idx, error))
                            print(f"\n⚠️ Failed to process image {idx}: {error}")
                        
                        pbar.update(1)
                        
                        # Strategic cleanup at 25%, 50%, 75% progress
                        if processed_count in cleanup_intervals:
                            progress = (processed_count / total_images) * 100
                            print(f"\n🧹 Cleanup at {progress:.0f}% ({processed_count}/{total_images})")
                            gc.collect()
                            
                    except Exception as e:
                        print(f"\n⚠️ Error retrieving result: {e}")
                        failed_images.append((futures[future], str(e)))
                        pbar.update(1)
            
            # Final cleanup
            futures.clear()
            gc.collect()
        
        # Report failures
        if failed_images:
            print(f"\n⚠️ {len(failed_images)}/{total_images} images failed to process")
            print("Failed indices:", [idx for idx, _ in failed_images[:10]])
            if len(failed_images) > 10:
                print(f"... and {len(failed_images) - 10} more")
        
        success_rate = (total_images - len(failed_images)) / total_images * 100
        print(f"Success rate: {success_rate:.1f}%")
        print(f"Cached {len(self.feature_cache)} feature vectors")

    def _preprocess_and_cache(self, idx):
        """On-demand preprocessing (fallback)"""
        if idx in self.feature_cache:
            return self.feature_cache[idx]

        # Read image
        img = cv2.imread(self.img_paths[idx])
        
        if img is None:
            raise ValueError(f"Failed to load image at {self.img_paths[idx]}")

        # Apply segmentation if enabled
        if self.use_segmentation and self.seg_method != "none":
            img_processed = auto_segment(img.copy(), method=self.seg_method)
        else:
            img_processed = img

        combined_feat = extract_all_features(
            img_processed,
            use_segmentation=False,
            seg_method="none",
        )

        # Cache only features
        self.feature_cache[idx] = combined_feat

        return combined_feat

    def __len__(self):
        return len(self.img_paths)

    def __getitem__(self, idx):
        """
        CRITICAL FIX: Read images fresh each time to avoid memory bloat.
        Only cache the expensive feature extraction, not images.
        """
        
        # Get features (from cache or compute)
        if self.cache_features:
            if idx not in self.feature_cache:
                combined_feat = self._preprocess_and_cache(idx)
            else:
                combined_feat = self.feature_cache[idx]
            
            # Read image fresh (fast operation)
            img = cv2.imread(self.img_paths[idx])
            if img is None:
                raise ValueError(f"Failed to load image at {self.img_paths[idx]}")
            
            # Apply segmentation if needed
            if self.use_segmentation and self.seg_method != "none":
                img = auto_segment(img, method=self.seg_method)
            
            img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            
        else:
            # No caching - compute everything fresh
            img = cv2.imread(self.img_paths[idx])
            
            if img is None:
                raise ValueError(f"Failed to load image at {self.img_paths[idx]}")

            combined_feat = extract_all_features(
                img, use_segmentation=self.use_segmentation, seg_method=self.seg_method
            )

            img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # Transform image to tensor
        img_tensor = self.transform(img_rgb)

        # Convert to tensors
        features_tensor = torch.tensor(combined_feat, dtype=torch.float32)
        label_tensor = torch.tensor(self.labels[idx], dtype=torch.long)

        return img_tensor, features_tensor, label_tensor
    
    def clear_cache(self):
        """Manually clear cache if needed"""
        self.feature_cache.clear()
        gc.collect()
        print("✅ Cache cleared")


