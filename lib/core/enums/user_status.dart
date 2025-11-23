/// Enum untuk status verifikasi user (Admin & Warga)
///
/// Status flow:
/// - unverified: Baru register, belum upload KYC
/// - pending: Sudah upload KYC, menunggu approval admin
/// - approved: Sudah disetujui admin, bisa akses penuh
/// - rejected: Ditolak admin
enum UserStatus {
  unverified,
  pending,
  approved,
  rejected,
}

/// Extension untuk convert string ke UserStatus
extension UserStatusExtension on UserStatus {
  String get value {
    switch (this) {
      case UserStatus.unverified:
        return 'unverified';
      case UserStatus.pending:
        return 'pending';
      case UserStatus.approved:
        return 'approved';
      case UserStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case UserStatus.unverified:
        return 'Belum Terverifikasi';
      case UserStatus.pending:
        return 'Menunggu Persetujuan';
      case UserStatus.approved:
        return 'Disetujui';
      case UserStatus.rejected:
        return 'Ditolak';
    }
  }
}

/// Convert string ke UserStatus
UserStatus userStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'unverified':
      return UserStatus.unverified;
    case 'pending':
      return UserStatus.pending;
    case 'approved':
      return UserStatus.approved;
    case 'rejected':
      return UserStatus.rejected;
    default:
      return UserStatus.unverified;
  }
}

