# 🎯 QUICK START GUIDE - CHECKOUT FLOW

## 🚀 Cara Menggunakan Fitur Checkout

### 1. Dari Halaman Keranjang (Cart Page)

**Langkah:**
1. Buka aplikasi WargaGo
2. Navigasi ke **Marketplace** → **Keranjang Saya**
3. Pilih item yang ingin dibeli (checkbox)
4. Klik tombol **"Checkout"** di bottom bar

**Screenshot Flow:**
```
┌─────────────────────┐
│   KERANJANG SAYA    │
│                     │
│  ☑ Sayur Wortel     │
│  ☑ Cabai Merah      │
│  □ Tomat            │
│                     │
│  Total: Rp 25.000   │
│  [   Checkout   ]   │
└─────────────────────┘
```

### 2. Halaman Checkout

**Fitur yang Tersedia:**
- ✅ Alamat pengiriman otomatis terisi dari profil
- ✅ Pilih metode pengiriman (Reguler/Express/Ambil Sendiri)
- ✅ Tambahkan catatan untuk penjual
- ✅ Pilih metode pembayaran (Transfer/QRIS/E-Wallet)
- ✅ Lihat ringkasan total

**Screenshot:**
```
┌─────────────────────────────┐
│       CHECKOUT              │
├─────────────────────────────┤
│ 📍 Alamat Pengiriman        │
│   Nama: Budi Santoso        │
│   Telp: 08123456789         │
│   Alamat: Jl. Malang...     │
├─────────────────────────────┤
│ 🛒 Produk Pesanan           │
│   • Sayur Wortel (1 kg)     │
│   • Cabai Merah (0.5 kg)    │
├─────────────────────────────┤
│ 🚚 Metode Pengiriman        │
│   ○ Reguler (Gratis)        │
│   ● Express (Rp 10.000)     │
│   ○ Ambil Sendiri (Gratis)  │
├─────────────────────────────┤
│ 💳 Metode Pembayaran        │
│   ● Transfer Bank           │
│   ○ QRIS                    │
│   ○ E-Wallet                │
├─────────────────────────────┤
│ 📊 Ringkasan                │
│   Subtotal: Rp 25.000       │
│   Ongkir:   Rp 10.000       │
│   ─────────────────         │
│   Total:    Rp 35.000       │
│                             │
│   [  Bayar Sekarang  ]      │
└─────────────────────────────┘
```

### 3. Halaman Pembayaran (Payment)

**Fitur:**
- ⏱️ Timer countdown 10 menit
- 📱 QR Code untuk scan (dummy)
- 📝 Instruksi pembayaran lengkap
- ✅ Tombol konfirmasi setelah bayar

**Screenshot:**
```
┌─────────────────────────────┐
│       PEMBAYARAN            │
├─────────────────────────────┤
│ ⏱️ Selesaikan dalam          │
│      09:45                  │
├─────────────────────────────┤
│ 💳 Transfer Bank            │
├─────────────────────────────┤
│   ┌─────────────────┐       │
│   │                 │       │
│   │   [QR CODE]     │       │
│   │                 │       │
│   └─────────────────┘       │
│   Total: Rp 35.000          │
├─────────────────────────────┤
│ Cara Pembayaran:            │
│ 1. Buka mobile banking      │
│ 2. Pilih menu Scan QR       │
│ 3. Scan QR Code di atas     │
│ 4. Konfirmasi pembayaran    │
├─────────────────────────────┤
│ [ Konfirmasi Pembayaran ]   │
└─────────────────────────────┘
```

### 4. Dialog Sukses & Struk

**Setelah Konfirmasi:**
```
┌─────────────────────────────┐
│     ✅ Pembayaran            │
│        Berhasil!            │
│                             │
│ Pesanan Anda telah dibuat   │
│ dan sedang diproses         │
│                             │
│ [ Lihat Struk ]  [ Pesanan ]│
└─────────────────────────────┘
```

**Struk Digital:**
```
┌─────────────────────────────┐
│    STRUK PEMBAYARAN         │
├─────────────────────────────┤
│ ✅ Pembayaran Berhasil       │
│ 07 Des 2025, 14:30          │
│ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─      │
│ ID: TRX1733561234567        │
│ Pembayaran: Transfer Bank   │
│ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─      │
│ Info Pembeli:               │
│ Nama: Budi Santoso          │
│ Telp: 08123456789           │
│ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─      │
│ Detail Pesanan:             │
│ Sayur Wortel                │
│   1 kg x Rp 15.000          │
│             Rp 15.000       │
│ Cabai Merah                 │
│   0.5 kg x Rp 20.000        │
│             Rp 10.000       │
│ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─      │
│ Subtotal:    Rp 25.000      │
│ Ongkir:      Rp 10.000      │
│ ═════════════════════       │
│ TOTAL:       Rp 35.000      │
│ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─      │
│ Terima kasih!               │
│ Marketplace WargaGo         │
│                             │
│ [Beranda]    [Lihat Pesanan]│
└─────────────────────────────┘
```

### 5. Pesanan Saya (My Orders)

**Akses:**
- Dari menu Marketplace → Pesanan Saya
- Atau klik "Lihat Pesanan" dari struk

**Fitur:**
- 📋 List semua pesanan
- 🔍 Filter by tab: Semua, Diproses, Dikirim, Selesai
- 👆 Tap card untuk lihat detail

```
┌─────────────────────────────┐
│     PESANAN SAYA            │
├─────────────────────────────┤
│ [Semua][Diproses][Dikirim]  │
│           [Selesai]         │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 🏪 Toko Sayur Rafcol     │ │
│ │          [⏳ Diproses]    │ │
│ │ ORD-2025-001             │ │
│ │ 07 Des 2025              │ │
│ │                          │ │
│ │ • Sayur Wortel (1 kg)    │ │
│ │ • Cabai Merah (0.5 kg)   │ │
│ │                          │ │
│ │ Total: Rp 35.000         │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

### 6. Detail Pesanan (Order Detail)

**Akses:** Tap pada card pesanan

**Fitur:**
- 📊 Status timeline visual
- ℹ️ Info lengkap pesanan
- 🎯 Action buttons:
  - **Batalkan Pesanan** (jika pending/processing)
  - **Pesanan Diterima** (jika shipped)

```
┌─────────────────────────────┐
│    DETAIL PESANAN           │
├─────────────────────────────┤
│      ⏳ Sedang Diproses      │
│                             │
│ ●───●───○───○              │
│ Pending Processing Shipped  │
│             Selesai         │
├─────────────────────────────┤
│ 📋 Informasi Pesanan        │
│ No: ORD-2025-001            │
│ Tanggal: 07 Des 2025        │
│ Penjual: Toko Sayur Rafcol  │
├─────────────────────────────┤
│ 📦 Produk Pesanan           │
│ [img] Sayur Wortel          │
│       1 kg x Rp 15.000      │
│                             │
│ [img] Cabai Merah           │
│       0.5 kg x Rp 20.000    │
├─────────────────────────────┤
│ 📍 Info Pengiriman          │
│ Budi Santoso                │
│ 08123456789                 │
│ Jl. Malang Raya No 123      │
├─────────────────────────────┤
│ 💰 Ringkasan                │
│ Subtotal:    Rp 25.000      │
│ Ongkir:      Rp 10.000      │
│ ─────────────────           │
│ Total:       Rp 35.000      │
│                             │
│ [Batalkan] [Terima Pesanan] │
└─────────────────────────────┘
```

## 🎯 STATUS PESANAN

| Status | Keterangan | Aksi Tersedia |
|--------|------------|---------------|
| **Pending** | Menunggu konfirmasi penjual | Batalkan |
| **Processing** | Sedang dikemas penjual | Batalkan |
| **Shipped** | Dalam pengiriman | Terima Pesanan |
| **Completed** | Pesanan selesai | Beli Lagi, Beri Ulasan |
| **Cancelled** | Dibatalkan | - |

## 🔄 BACKEND AUTO-PROCESS

Sistem otomatis melakukan:
1. ✅ **Create Order** di Firestore
2. ✅ **Update Stock** produk
3. ✅ **Remove Cart Items** yang sudah checkout
4. ✅ **Generate Order ID** unik (ORD-YYYY-NNNN)
5. ✅ **Save Transaction** history

## 💡 TIPS

1. **Multiple Sellers:** Jika cart berisi produk dari beberapa penjual, sistem otomatis membuat order terpisah per seller.

2. **Validation:** Sistem otomatis validasi stock sebelum checkout.

3. **Real-time:** Perubahan status langsung terlihat di halaman pesanan.

4. **Notification:** User akan tahu jika ada update status (via refresh).

## 🐛 TROUBLESHOOTING

**Problem:** Tombol checkout disabled
- **Solution:** Pastikan ada item yang dicentang (selected) di cart

**Problem:** Error saat pembayaran
- **Solution:** Cek koneksi internet dan coba lagi

**Problem:** Pesanan tidak muncul
- **Solution:** Pull to refresh di halaman Pesanan Saya

## 📞 SUPPORT

Jika ada masalah, hubungi:
- Email: support@wargago.com
- WhatsApp: 08123456789

---

**Selamat Berbelanja! 🛍️**

_Marketplace WargaGo - Belanja Mudah, Tetangga Senang_

