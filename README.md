<div align="left">

# WargaGo — Community Management App for RT/RW
<img width="3168" height="1344" alt="banner_WARGAGO 1" src="https://github.com/user-attachments/assets/2e8dbad4-45c3-4897-a6c7-ed52b44c9939" />

WARGAGO adalah aplikasi mobile yang powerful namun mudah digunakan, dirancang khusus untuk sistem RT/RW di Indonesia. Aplikasi ini membantu warga dan pengurus lokal untuk mengelola administrasi lingkungan, komunikasi, dan aktivitas sehari-hari—semua dalam satu platform. Baik Anda seorang Ketua RT/RW, pengurus komunitas, atau warga biasa, WARGAGO memudahkan Anda untuk mengelola:

- 🧾 Dokumen dan data administrasi warga
- 💰 Keuangan komunitas dan pembayaran iuran
- 📅 Agenda, rapat, dan pengumuman penting
- 🗳️ Polling dan voting untuk keputusan bersama
- 🛒 Marketplace internal untuk jual-beli antar warga
- 📊 Dashboard dan laporan keuangan transparan

Dibangun dengan pengalaman mobile-first yang lengkap, WARGAGO memberdayakan setiap rumah tangga untuk tetap terinformasi, berkolaborasi, dan mengambil tindakan tanpa kertas atau sistem yang rumit.

</div>

🚀 Coba sekarang<p>
Coba WargaGo sekarang untuk merasakan pengelolaan RT/RW yang lebih praktis, rapi, dan transparan dalam satu aplikasi.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

<img width="3168" height="1344" alt="banner_WARGAGO 2" src="https://github.com/user-attachments/assets/b65e332f-4a3a-4dd5-84c4-469a25c2630d" />

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

## System Architecture
<img width="2240" height="1920" alt="banner_WARGAGO 3" src="https://github.com/user-attachments/assets/e8b48fe4-75e1-498e-bc67-21dc805ca381" />

Sistem ini dibangun dengan arsitektur berbasis cloud yang menggabungkan layanan Firebase dan Azure untuk memastikan pengembangan yang efisien dan performa yang handal.

- Flutter (Frontend) Aplikasi seluler dikembangkan menggunakan Flutter untuk dukungan lintas platform (Android & iOS), memastikan pengalaman pengguna yang konsisten dan responsif.

- Firebase (Backend Services) Menyediakan fungsionalitas backend inti yang ringan dan cepat, mencakup Authentication untuk keamanan login pengguna, Database untuk pengelolaan data, Notifications untuk pemberitahuan real-time, dan App Distribution untuk rilis versi aplikasi.

- Microsoft Azure (Storage & ML Services) Digunakan sebagai infrastruktur komputasi utama untuk menyimpan aset file skala besar melalui Cloud Storage dan men-deploy model Machine Learning kustom untuk pemrosesan data cerdas.

Seluruh komponen berkomunikasi secara mulus, menghubungkan aplikasi Flutter dengan layanan Firebase dan Azure, menciptakan sistem yang skalabel dengan infrastruktur yang terorganisir rapi.

## App Demo
silakan coba app melalui link ini:

👉🏻 [![Android App](https://img.shields.io/badge/Android-App-green?logo=android&logoColor=white)](https://appdistribution.firebase.google.com/pub/i/e13668bbf9f7f66c)

## Problem
Pengelolaan komunitas/perumahan secara tradisional sering menghadapi tantangan berikut:
- Administrasi masih manual (buku/spreadsheet) sehingga rawan duplikasi dan tidak konsisten.
- Transparansi keuangan sulit dipantau secara real-time.
- Informasi/pengumuman tidak selalu tersampaikan ke seluruh warga.
- Verifikasi pembayaran, data, dan pelaporan membutuhkan waktu.
- Data tersebar dan sulit diakses (chat, kertas, file berbeda).
- Risiko keamanan data (hilang, tidak ter-backup, atau mudah dimanipulasi).

---

## Solution
WargaGo hadir sebagai solusi terintegrasi:
- Digitalisasi proses: data warga, iuran, agenda, polling, marketplace dalam satu aplikasi.
- Transparansi real-time: ringkasan pemasukan/pengeluaran, status tagihan, dan laporan.
- Notifikasi otomatis: pengumuman, agenda, dan reminder langsung ke perangkat warga.
- Database terpusat: data tersinkron, mudah diakses sesuai hak akses.
- Keamanan berlapis: autentikasi, kontrol akses berbasis role, dan pengelolaan data yang terstruktur.

---

## Fitur Utama

### 1) Manajemen Data Warga dan KYC
- Upload dan verifikasi dokumen (KTP, KK) dengan OCR
- Face detection untuk dukungan proses verifikasi
- Database penduduk terstruktur per rumah dan keluarga

### 2) Manajemen Keuangan (Iuran, Tagihan, Mutasi)
- Kelola iuran warga dan tagihan
- Pemasukan dan pengeluaran dengan kategori
- Laporan otomatis dan visualisasi grafik
- Riwayat mutasi lengkap
- Ekspor data (Excel, PDF, CSV)

### 3) Agenda dan Kegiatan
- Pembuatan dan pengelolaan agenda komunitas
- Reminder otomatis
- Pencatatan partisipasi/kegiatan (opsional sesuai implementasi)

### 4) Polling dan Voting
- Polling untuk keputusan komunitas
- Hasil real-time
- Riwayat dan transparansi hasil

### 5) Marketplace Warga
- Jual beli antar warga (contoh: sayuran)
- Keranjang belanja dan manajemen pesanan
- Verifikasi transaksi (sesuai rancangan sistem)

### 6) Dashboard dan Reporting
- Ringkasan aktivitas dan informasi penting
- Dashboard berbasis role
- Monitoring data inti: warga, keuangan, agenda, dan transaksi

---

## Roles & Hak Akses
WargaGo mendukung role berikut. Jika implementasi kamu saat ini masih 4 role, kamu bisa menggabungkan Ketua RT/Ketua RW ke role Admin.

| Role | Fokus | Contoh Akses Utama |
|------|------|---------------------|
| Warga | Pengguna komunitas | Profil keluarga, bayar iuran, marketplace, agenda, polling, pengumuman |
| Bendahara | Keuangan | Kelola iuran/tagihan, verifikasi pembayaran, laporan, ekspor data |
| Sekretaris | Administrasi & komunikasi | Kelola agenda, broadcast pengumuman, polling/voting, dokumen |
| Admin | Sistem & data master | Kelola pengguna/role, verifikasi KYC, data rumah/keluarga, monitoring |
| Ketua RT (opsional) | Operasional RT | Pengumuman RT, validasi data, monitoring kegiatan RT |
| Ketua RW (opsional) | Operasional RW | Pengumuman RW, monitoring lintas RT, rekap dan validasi |

---
## Our Team
Kami adalah Tim WargaGo, sekelompok developer yang berkolaborasi membangun WargaGo dengan misi bersama untuk mendukung transformasi digital di lingkungan RT/RW di Indonesia.

| No. | Name | GitHub | Role | 
| --- | --- | --- | --- |
| 1. | Petrus Tyang Agung Rosario | https://github.com/petrusthelastking | Project lead, Fullstack developer |
| 2. | Hidayat Widi Saputra | https://github.com/Raruu| Fullstack developer, Machine Learning engineer |
| 3. | Damar Galih Fitrianto | https://github.com/DmarGalee | Frontend developer |
| 4. | Rafa Fadil Aras | https://github.com/rafafadilaras | Frontend developer |

## 🙏 Acknowledgements

Kami ingin mengucapkan terima kasih kepada semua pihak yang telah berkontribusi dalam pengembangan **WARGAGO**:

### 💙 Special Thanks To:

- **Flutter Team** - Untuk framework yang powerful dan ecosystem yang luar biasa
- **Firebase Team** - Untuk backend services yang reliable dan mudah diintegrasikan
- **Google Fonts** - Untuk typography yang mempercantik aplikasi kami
- **Material Design** - Untuk design system yang konsisten dan modern
- **Open Source Community** - Untuk packages dan libraries yang membantu development kami

### 📚 Inspired By:

- **Indonesia's RT/RW System** - Sistem gotong royong yang menjadi fondasi aplikasi ini

### 🎓 Educational Support:

- **Stack Overflow Community** - Untuk solusi teknis dan best practices
- **Flutter Documentation** - Untuk panduan lengkap dan referensi development
- **GitHub** - Untuk version control dan collaboration platform

### 🌟 Community & Users:

- **Beta Testers** - Yang telah memberikan feedback berharga
- **Early Adopters** - Yang percaya dengan visi WARGAGO sejak awal
- **RT/RW Leaders** - Yang memberikan insight tentang kebutuhan administrasi lingkungan

### 💼 Development Tools:

- **Android Studio** - IDE yang powerful untuk Flutter development
- **Visual Studio Code** - Editor yang ringan dan extensible
- **Git** - Version control system yang reliable
- **Postman** - Untuk API testing dan development

---

<div align="center">

**Made with ❤️ by WARGAGO Team**

*Empowering Indonesian Communities Through Technology*

**© 2024 WARGAGO. All Rights Reserved.**

</div>
