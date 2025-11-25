# 🚀 PANDUAN CEPAT UNTUK TIM

## Skenario: 3 Orang dengan 3 HP Berbeda

### 🎯 CARA TERCEPAT - SETIAP ORANG LANGSUNG TAMBAH SENDIRI

```
ORANG 1 (DI HP 1):               ORANG 2 (DI HP 2):               ORANG 3 (DI HP 3):
├─ Step 1: Jalankan             ├─ Step 1: Jalankan             ├─ Step 1: Jalankan
│  cd android                   │  cd android                   │  cd android
│  ./gradlew signingReport      │  ./gradlew signingReport      │  ./gradlew signingReport
│                                │                                │
├─ Step 2: Copy SHA-1 sendiri   ├─ Step 2: Copy SHA-1 sendiri   ├─ Step 2: Copy SHA-1 sendiri
│                                │                                │
├─ Step 3: Login Firebase       ├─ Step 3: Login Firebase       ├─ Step 3: Login Firebase
│  Tambah SHA-1 HP 1            │  Tambah SHA-1 HP 2            │  Tambah SHA-1 HP 3
│                                │                                │
└─ Step 4: flutter run          └─ Step 4: flutter run          └─ Step 4: flutter run
   ✅ BISA LOGIN!                  ✅ BISA LOGIN!                  ✅ BISA LOGIN!
```

**Waktu:** ~5 menit per orang (PARALEL, bisa bersamaan!)

**Keuntungan:**
- ✅ Tidak perlu nunggu yang lain
- ✅ Tidak perlu share file
- ✅ Langsung bisa coba
- ✅ Cepat!

---

### 🔄 CARA ALTERNATIF - KUMPUL DULU BARU TAMBAH

```
TAHAP 1: SEMUA ORANG
├─ Orang 1: Dapat SHA-1 HP 1
├─ Orang 2: Dapat SHA-1 HP 2
└─ Orang 3: Dapat SHA-1 HP 3

TAHAP 2: KIRIM KE 1 ORANG
├─ Orang 1: Kirim SHA-1 HP 1 ───┐
├─ Orang 2: Kirim SHA-1 HP 2 ───┼──→ Orang yang kelola Firebase
└─ Orang 3: Kirim SHA-1 HP 3 ───┘

TAHAP 3: 1 ORANG TAMBAHKAN SEMUA
└─ Login Firebase
   ├─ Tambah SHA-1 HP 1
   ├─ Tambah SHA-1 HP 2
   └─ Tambah SHA-1 HP 3

TAHAP 4: SEMUA ORANG
└─ flutter run
   ✅ SEMUA BISA LOGIN!
```

**Waktu:** ~15 menit total (HARUS SEQUENTIAL, harus nunggu)

**Keuntungan:**
- ✅ Lebih terorganisir
- ✅ Satu orang yang kelola

**Kekurangan:**
- ❌ Harus nunggu orang yang kelola Firebase
- ❌ Lebih lama

---

## 💡 REKOMENDASI

**Gunakan CARA TERCEPAT** jika:
- ✅ Semua anggota tim punya akses Firebase Console
- ✅ Ingin cepat selesai
- ✅ Tidak mau nunggu

**Gunakan CARA ALTERNATIF** jika:
- ✅ Hanya 1 orang yang punya akses Firebase
- ✅ Ingin lebih terorganisir
- ✅ Tidak buru-buru

---

## ❓ FAQ

### Q: Apakah perlu download google-services.json baru?
**A:** **TIDAK PERLU!** Setelah tambah SHA-1 ke Firebase, server otomatis update. File lama tetap bisa dipakai.

### Q: Apakah harus flutter clean setelah tambah SHA-1?
**A:** **YA!** Minimal `flutter clean` dan `flutter run` ulang. Kadang perlu restart HP juga.

### Q: Berapa lama Firebase update setelah tambah SHA-1?
**A:** **Langsung!** Maksimal 1-2 menit. Tapi kadang perlu restart app.

### Q: Apakah SHA-1 bisa dihapus setelah ditambahkan?
**A:** **BISA!** Tapi jangan dihapus kalau masih mau pakai HP tersebut.

### Q: Berapa maksimal SHA-1 yang bisa ditambahkan?
**A:** **UNLIMITED!** Bisa tambahkan sebanyak yang dibutuhkan.

---

## 🎯 RINGKASAN

| Aspek | Cara Tercepat | Cara Alternatif |
|-------|---------------|-----------------|
| Waktu | ~5 menit/orang (paralel) | ~15 menit total (sequential) |
| Perlu Akses Firebase | Semua orang | 1 orang saja |
| Perlu Share File | ❌ Tidak | ❌ Tidak |
| Perlu Nunggu | ❌ Tidak | ✅ Ya |
| Kesulitan | ⭐ Mudah | ⭐⭐ Sedang |

---

**Kesimpulan:** Gunakan **CARA TERCEPAT** kalau bisa! 🚀

