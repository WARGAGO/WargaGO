"""
Dataset Balancing Script
Balances image dataset by class using undersampling, oversampling, or augmentation
"""

import os
import shutil
from pathlib import Path
from collections import Counter
import random
from PIL import Image
import numpy as np
from typing import Literal

class DatasetBalancer:
    def __init__(self, dataset_dir: str, output_dir: str = None):
        """
        Initialize dataset balancer
        
        Args:
            dataset_dir: Path to dataset directory (contains train/val folders with class subfolders)
            output_dir: Path to output directory (if None, creates balanced version in same parent)
        """
        self.dataset_dir = Path(dataset_dir)
        self.output_dir = Path(output_dir) if output_dir else self.dataset_dir.parent / f"{self.dataset_dir.name}_balanced"
        
    def count_images(self, split: str = "train") -> dict:
        """Count images per class in a split"""
        split_path = self.dataset_dir / split
        if not split_path.exists():
            print(f"Warning: {split_path} does not exist")
            return {}
        
        class_counts = {}
        for class_dir in split_path.iterdir():
            if class_dir.is_dir():
                images = list(class_dir.glob("*.[jp][pn]g")) + list(class_dir.glob("*.jpeg"))
                class_counts[class_dir.name] = len(images)
        
        return class_counts
    
    def print_statistics(self):
        """Print dataset statistics"""
        print("\n" + "="*60)
        print("DATASET STATISTICS")
        print("="*60)
        
        for split in ["train", "val"]:
            counts = self.count_images(split)
            if counts:
                print(f"\n{split.upper()} SET:")
                print("-" * 40)
                total = sum(counts.values())
                for class_name, count in sorted(counts.items()):
                    percentage = (count / total * 100) if total > 0 else 0
                    print(f"  {class_name:20s}: {count:5d} images ({percentage:5.2f}%)")
                print(f"  {'TOTAL':20s}: {total:5d} images")
                
                if len(counts) > 0:
                    avg = total / len(counts)
                    max_count = max(counts.values())
                    min_count = min(counts.values())
                    imbalance_ratio = max_count / min_count if min_count > 0 else float('inf')
                    print(f"\n  Average per class: {avg:.1f}")
                    print(f"  Imbalance ratio: {imbalance_ratio:.2f}:1")
        print("="*60 + "\n")
    
    def balance_by_undersampling(self, split: str = "train", target_count: int = None):
        """
        Balance dataset by randomly removing images from over-represented classes
        
        Args:
            split: Dataset split to balance ('train' or 'val')
            target_count: Target number of images per class (if None, uses minimum class count)
        """
        print(f"\nBalancing {split} set by UNDERSAMPLING...")
        
        split_path = self.dataset_dir / split
        output_split_path = self.output_dir / split
        
        # Get class counts
        counts = self.count_images(split)
        if not counts:
            print(f"No classes found in {split_path}")
            return
        
        # Determine target count
        if target_count is None:
            target_count = min(counts.values())
        
        print(f"Target count per class: {target_count}")
        
        # Process each class
        for class_name in counts.keys():
            class_src = split_path / class_name
            class_dst = output_split_path / class_name
            class_dst.mkdir(parents=True, exist_ok=True)
            
            # Get all images
            images = list(class_src.glob("*.[jp][pn]g")) + list(class_src.glob("*.jpeg"))
            
            # Randomly sample target_count images
            if len(images) > target_count:
                selected_images = random.sample(images, target_count)
                print(f"  {class_name}: {len(images)} -> {target_count} (removed {len(images) - target_count})")
            else:
                selected_images = images
                print(f"  {class_name}: {len(images)} (no change)")
            
            # Copy selected images
            for img_path in selected_images:
                shutil.copy2(img_path, class_dst / img_path.name)
    
    def balance_by_oversampling(self, split: str = "train", target_count: int = None):
        """
        Balance dataset by duplicating images from under-represented classes
        
        Args:
            split: Dataset split to balance ('train' or 'val')
            target_count: Target number of images per class (if None, uses maximum class count)
        """
        print(f"\nBalancing {split} set by OVERSAMPLING (duplication)...")
        
        split_path = self.dataset_dir / split
        output_split_path = self.output_dir / split
        
        # Get class counts
        counts = self.count_images(split)
        if not counts:
            print(f"No classes found in {split_path}")
            return
        
        # Determine target count
        if target_count is None:
            target_count = max(counts.values())
        
        print(f"Target count per class: {target_count}")
        
        # Process each class
        for class_name in counts.keys():
            class_src = split_path / class_name
            class_dst = output_split_path / class_name
            class_dst.mkdir(parents=True, exist_ok=True)
            
            # Get all images
            images = list(class_src.glob("*.[jp][pn]g")) + list(class_src.glob("*.jpeg"))
            
            # Copy all original images first
            for img_path in images:
                shutil.copy2(img_path, class_dst / img_path.name)
            
            # Duplicate images to reach target
            if len(images) < target_count:
                needed = target_count - len(images)
                duplicates = random.choices(images, k=needed)
                
                for idx, img_path in enumerate(duplicates):
                    # Create unique filename for duplicate
                    stem = img_path.stem
                    suffix = img_path.suffix
                    new_name = f"{stem}_dup{idx:04d}{suffix}"
                    shutil.copy2(img_path, class_dst / new_name)
                
                print(f"  {class_name}: {len(images)} -> {target_count} (added {needed} duplicates)")
            else:
                print(f"  {class_name}: {len(images)} (no change)")
    
    def balance_by_augmentation(self, split: str = "train", target_count: int = None):
        """
        Balance dataset by augmenting images from under-represented classes
        
        Args:
            split: Dataset split to balance ('train' or 'val')
            target_count: Target number of images per class (if None, uses maximum class count)
        """
        print(f"\nBalancing {split} set by AUGMENTATION...")
        
        split_path = self.dataset_dir / split
        output_split_path = self.output_dir / split
        
        # Get class counts
        counts = self.count_images(split)
        if not counts:
            print(f"No classes found in {split_path}")
            return
        
        # Determine target count
        if target_count is None:
            target_count = max(counts.values())
        
        print(f"Target count per class: {target_count}")
        
        # Process each class
        for class_name in counts.keys():
            class_src = split_path / class_name
            class_dst = output_split_path / class_name
            class_dst.mkdir(parents=True, exist_ok=True)
            
            # Get all images
            images = list(class_src.glob("*.[jp][pn]g")) + list(class_src.glob("*.jpeg"))
            
            # Copy all original images first
            for img_path in images:
                shutil.copy2(img_path, class_dst / img_path.name)
            
            # Augment images to reach target
            if len(images) < target_count:
                needed = target_count - len(images)
                
                for idx in range(needed):
                    # Select random image to augment
                    source_img_path = random.choice(images)
                    img = Image.open(source_img_path)
                    
                    # Apply random augmentation
                    augmented = self._augment_image(img)
                    
                    # Save augmented image
                    stem = source_img_path.stem
                    suffix = source_img_path.suffix
                    new_name = f"{stem}_aug{idx:04d}{suffix}"
                    augmented.save(class_dst / new_name)
                
                print(f"  {class_name}: {len(images)} -> {target_count} (added {needed} augmented images)")
            else:
                print(f"  {class_name}: {len(images)} (no change)")
    
    def _augment_image(self, img: Image.Image) -> Image.Image:
        """Apply random augmentation to an image"""
        # Random horizontal flip
        if random.random() > 0.5:
            img = img.transpose(Image.FLIP_LEFT_RIGHT)
        
        # Random rotation (-15 to 15 degrees)
        if random.random() > 0.5:
            angle = random.uniform(-15, 15)
            img = img.rotate(angle, fillcolor=(255, 255, 255))
        
        # Random brightness adjustment
        if random.random() > 0.5:
            from PIL import ImageEnhance
            enhancer = ImageEnhance.Brightness(img)
            factor = random.uniform(0.8, 1.2)
            img = enhancer.enhance(factor)
        
        # Random contrast adjustment
        if random.random() > 0.5:
            from PIL import ImageEnhance
            enhancer = ImageEnhance.Contrast(img)
            factor = random.uniform(0.8, 1.2)
            img = enhancer.enhance(factor)
        
        return img
    
    def balance(
        self, 
        method: Literal["undersample", "oversample", "augment"] = "undersample",
        target_count: int = None,
        splits: list = ["train"]
    ):
        """
        Balance dataset using specified method
        
        Args:
            method: Balancing method ('undersample', 'oversample', or 'augment')
            target_count: Target number of images per class (method-specific default if None)
            splits: List of splits to balance (default: ['train'])
        """
        print(f"\n{'='*60}")
        print(f"BALANCING DATASET: {self.dataset_dir.name}")
        print(f"Method: {method.upper()}")
        print(f"Output: {self.output_dir}")
        print(f"{'='*60}")
        
        # Show original statistics
        self.print_statistics()
        
        # Balance each split
        for split in splits:
            if method == "undersample":
                self.balance_by_undersampling(split, target_count)
            elif method == "oversample":
                self.balance_by_oversampling(split, target_count)
            elif method == "augment":
                self.balance_by_augmentation(split, target_count)
            else:
                raise ValueError(f"Unknown method: {method}")
        
        # Copy validation set if not balanced
        if "val" not in splits and (self.dataset_dir / "val").exists():
            print("\nCopying validation set (not balanced)...")
            shutil.copytree(
                self.dataset_dir / "val",
                self.output_dir / "val",
                dirs_exist_ok=True
            )
        
        print(f"\n{'='*60}")
        print("BALANCING COMPLETE!")
        print(f"{'='*60}")
        
        # Show new statistics
        print("\nNew dataset statistics:")
        balancer_new = DatasetBalancer(str(self.output_dir))
        balancer_new.print_statistics()


def main():
    """Main function with example usage"""
    
    # Configuration
    DATASET_DIR = "r3_prepared_70_auto_clahe_preparebalance"  # Change this to your dataset directory
    OUTPUT_DIR = None  # Will create "{DATASET_DIR}_balanced" if None
    METHOD = "undersample"  # Options: 'undersample', 'oversample', 'augment'
    TARGET_COUNT = None  # None = auto (min for undersample, max for oversample/augment)
    SPLITS = ["train"]  # Which splits to balance
    
    # Create balancer
    balancer = DatasetBalancer(DATASET_DIR, OUTPUT_DIR)
    
    # Balance dataset
    balancer.balance(
        method=METHOD,
        target_count=TARGET_COUNT,
        splits=SPLITS
    )


if __name__ == "__main__":
    # Set random seed for reproducibility
    random.seed(42)
    np.random.seed(42)
    
    main()
