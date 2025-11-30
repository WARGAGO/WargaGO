# ============================================================================
# CREATE DUMMY PENGUMUMAN DATA
# ============================================================================
# Script untuk menambahkan data dummy pengumuman ke Firestore
# ============================================================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  CREATE DUMMY PENGUMUMAN DATA" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Deploy Firestore rules terlebih dahulu
Write-Host "1. Deploying Firestore Rules..." -ForegroundColor Yellow
firebase deploy --only firestore:rules

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Failed to deploy Firestore rules!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Firestore rules deployed successfully!" -ForegroundColor Green
Write-Host ""

# Buat file JavaScript untuk menambahkan data dummy
$jsScript = @"
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const dummyPengumuman = [
  {
    judul: 'Gotong Royong Minggu Depan',
    konten: 'Diinformasikan kepada seluruh warga bahwa akan diadakan gotong royong bersama pada hari Minggu, 8 Desember 2025 mulai pukul 07.00 WIB. Diharapkan semua kepala keluarga dapat hadir. Terima kasih.',
    prioritas: 'tinggi',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-12-01T08:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
  {
    judul: 'Pembayaran Iuran Bulan Desember',
    konten: 'Batas pembayaran iuran RT bulan Desember adalah tanggal 15 Desember 2025. Mohon untuk segera melakukan pembayaran melalui bendahara RT atau transfer ke rekening yang telah ditentukan.',
    prioritas: 'menengah',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-11-28T10:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
  {
    judul: 'Peringatan 17 Agustus',
    konten: 'Dalam rangka memperingati HUT RI ke-80, RT kami akan mengadakan lomba-lomba tradisional pada tanggal 17 Agustus 2025. Pendaftaran dibuka mulai sekarang. Info lebih lanjut hubungi ketua RT.',
    prioritas: 'rendah',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-11-25T09:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
  {
    judul: 'Pemadaman Listrik Terjadwal',
    konten: 'PLN akan melakukan pemadaman listrik terjadwal pada tanggal 5 Desember 2025 dari pukul 09.00 - 15.00 WIB untuk maintenance. Harap persiapkan diri dengan baik.',
    prioritas: 'tinggi',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-11-27T14:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
  {
    judul: 'Rapat Koordinasi RT',
    konten: 'Akan diadakan rapat koordinasi RT pada hari Rabu, 4 Desember 2025 pukul 19.30 WIB di rumah Ketua RT. Diharapkan hadir semua ketua RW dan ketua RT.',
    prioritas: 'menengah',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-11-26T16:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
  {
    judul: 'Jadwal Posyandu Balita',
    konten: 'Posyandu balita akan dilaksanakan pada tanggal 10 Desember 2025 di Balai RT mulai pukul 08.00 WIB. Diharapkan ibu-ibu yang memiliki balita untuk hadir.',
    prioritas: 'rendah',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-11-24T11:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
  {
    judul: 'Pengaspalan Jalan RT',
    konten: 'Akan dilakukan pengaspalan jalan di lingkungan RT kita pada tanggal 12-14 Desember 2025. Mohon kerja samanya untuk tidak parkir kendaraan di area yang akan diaspal.',
    prioritas: 'tinggi',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-11-29T13:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
  {
    judul: 'Lomba Kebersihan Antar RT',
    konten: 'RT kita akan mengikuti lomba kebersihan tingkat kelurahan. Mari kita jaga kebersihan lingkungan kita bersama-sama agar bisa menjadi juara.',
    prioritas: 'rendah',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-11-23T10:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
  {
    judul: 'Perbaikan Sistem Air Bersih',
    konten: 'Akan dilakukan perbaikan sistem air bersih pada tanggal 6 Desember 2025 pukul 08.00 - 17.00 WIB. Selama perbaikan, air akan terhenti sementara. Mohon maaf atas ketidaknyamanannya.',
    prioritas: 'menengah',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-11-30T07:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
  {
    judul: 'Kegiatan Senam Pagi Rutin',
    konten: 'Mulai bulan Desember, akan diadakan senam pagi rutin setiap hari Minggu pukul 06.30 WIB di lapangan RT. Ayo ikut senam untuk hidup sehat!',
    prioritas: 'rendah',
    tanggal: admin.firestore.Timestamp.fromDate(new Date('2025-11-22T15:00:00')),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: 'Admin RT',
  },
];

async function createPengumuman() {
  try {
    console.log('📢 Creating dummy pengumuman data...\n');

    const batch = db.batch();
    const pengumumanRef = db.collection('pengumuman');

    dummyPengumuman.forEach((pengumuman) => {
      const docRef = pengumumanRef.doc();
      batch.set(docRef, pengumuman);
      console.log('✅ Added:', pengumuman.judul);
    });

    await batch.commit();

    console.log('\n✨ Success! All dummy pengumuman data created!');
    console.log('���� Total:', dummyPengumuman.length, 'pengumuman\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating pengumuman:', error);
    process.exit(1);
  }
}

createPengumuman();
"@

# Simpan script JavaScript
$jsScript | Out-File -FilePath "create_dummy_pengumuman.js" -Encoding UTF8

Write-Host "2. Creating dummy pengumuman data..." -ForegroundColor Yellow
Write-Host ""

# Cek apakah serviceAccountKey.json ada
if (-not (Test-Path "serviceAccountKey.json")) {
    Write-Host "❌ Error: serviceAccountKey.json not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download your Firebase service account key:" -ForegroundColor Yellow
    Write-Host "1. Go to Firebase Console > Project Settings > Service Accounts" -ForegroundColor Cyan
    Write-Host "2. Click 'Generate New Private Key'" -ForegroundColor Cyan
    Write-Host "3. Save as 'serviceAccountKey.json' in project root" -ForegroundColor Cyan
    Write-Host ""
    Remove-Item "create_dummy_pengumuman.js" -Force
    exit 1
}

# Jalankan script Node.js
node create_dummy_pengumuman.js

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  ✅ DUMMY PENGUMUMAN CREATED!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Restart your Flutter app" -ForegroundColor Yellow
    Write-Host "2. Check home page - you should see 5 latest announcements" -ForegroundColor Yellow
    Write-Host "3. Click 'Lihat Semua Pengumuman' to see all" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Failed to create dummy pengumuman!" -ForegroundColor Red
    Write-Host ""
}

# Cleanup
Remove-Item "create_dummy_pengumuman.js" -Force

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

