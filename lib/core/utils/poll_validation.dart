// ============================================================================
// POLL VALIDATION UTILITY
// ============================================================================
// Comprehensive validation untuk polling system
// Mencegah invalid data dan security issues
// ============================================================================

class PollValidation {
  // ===== POLL VALIDATION =====

  /// Validate poll title
  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Judul harus diisi';
    }
    if (title.trim().length < 10) {
      return 'Judul minimal 10 karakter';
    }
    if (title.trim().length > 100) {
      return 'Judul maksimal 100 karakter';
    }
    // Check for potentially malicious characters
    if (RegExp(r'[<>{}]').hasMatch(title)) {
      return 'Judul mengandung karakter tidak valid';
    }
    return null;
  }

  /// Validate poll description
  static String? validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      return 'Deskripsi harus diisi';
    }
    if (description.trim().length < 20) {
      return 'Deskripsi minimal 20 karakter';
    }
    if (description.trim().length > 500) {
      return 'Deskripsi maksimal 500 karakter';
    }
    return null;
  }

  /// Validate poll type
  static String? validatePollType(String? type) {
    const validTypes = ['election', 'decision', 'survey'];
    if (type == null || !validTypes.contains(type)) {
      return 'Tipe polling tidak valid';
    }
    return null;
  }

  /// Validate poll dates
  static String? validateDates(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Tanggal harus diisi';
    }
    if (endDate.isBefore(startDate)) {
      return 'Tanggal berakhir harus setelah tanggal mulai';
    }
    if (endDate.isBefore(DateTime.now())) {
      return 'Tanggal berakhir tidak boleh di masa lalu';
    }
    // Max duration 1 year
    if (endDate.difference(startDate).inDays > 365) {
      return 'Durasi polling maksimal 1 tahun';
    }
    return null;
  }

  /// Validate target RT
  static String? validateTargetRT(String? rt, String visibilityScope) {
    if (visibilityScope == 'specific_rt' || visibilityScope == 'specific_rw') {
      if (rt == null || rt.trim().isEmpty) {
        return 'Nomor RT harus diisi';
      }
      // Validate RT format (e.g., 001, 002)
      if (!RegExp(r'^\d{3}$').hasMatch(rt)) {
        return 'Format RT tidak valid (contoh: 001)';
      }
    }
    return null;
  }

  // ===== OPTION VALIDATION =====

  /// Validate poll options
  static String? validateOptions(List<String> options) {
    if (options.isEmpty) {
      return 'Minimal harus ada opsi';
    }
    if (options.length < 2) {
      return 'Minimal harus ada 2 opsi';
    }
    if (options.length > 10) {
      return 'Maksimal 10 opsi';
    }

    // Check for empty options
    for (var i = 0; i < options.length; i++) {
      if (options[i].trim().isEmpty) {
        return 'Opsi ${i + 1} tidak boleh kosong';
      }
      if (options[i].trim().length < 2) {
        return 'Opsi ${i + 1} minimal 2 karakter';
      }
      if (options[i].trim().length > 100) {
        return 'Opsi ${i + 1} maksimal 100 karakter';
      }
    }

    // Check for duplicate options
    final uniqueOptions = options.map((o) => o.trim().toLowerCase()).toSet();
    if (uniqueOptions.length != options.length) {
      return 'Opsi tidak boleh duplikat';
    }

    return null;
  }

  /// Validate single option text
  static String? validateOptionText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Teks opsi harus diisi';
    }
    if (text.trim().length < 2) {
      return 'Teks opsi minimal 2 karakter';
    }
    if (text.trim().length > 100) {
      return 'Teks opsi maksimal 100 karakter';
    }
    return null;
  }

  // ===== VOTE VALIDATION =====

  /// Validate vote data
  static String? validateVote({
    required String pollId,
    required String optionId,
    required String userId,
  }) {
    if (pollId.trim().isEmpty) {
      return 'Poll ID tidak valid';
    }
    if (optionId.trim().isEmpty) {
      return 'Opsi tidak valid';
    }
    if (userId.trim().isEmpty) {
      return 'User ID tidak valid';
    }
    return null;
  }

  // ===== SECURITY VALIDATION =====

  /// Check for SQL injection attempts
  static bool containsSQLInjection(String input) {
    final sqlPatterns = [
      RegExp(r"('|(\\')|(--)|(/\\*)|(\\*/)|(@)|;", caseSensitive: false),
      RegExp(r"\b(ALTER|CREATE|DELETE|DROP|EXEC(UTE)?|INSERT( +INTO)?|MERGE|SELECT|UPDATE|UNION( +ALL)?)\b",
          caseSensitive: false),
    ];

    for (var pattern in sqlPatterns) {
      if (pattern.hasMatch(input)) {
        return true;
      }
    }
    return false;
  }

  /// Check for XSS attempts
  static bool containsXSS(String input) {
    final xssPatterns = [
      RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
    ];

    for (var pattern in xssPatterns) {
      if (pattern.hasMatch(input)) {
        return true;
      }
    }
    return false;
  }

  /// Sanitize input string
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<script.*?>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<.*?>'), '')
        .replaceAll(RegExp(r'[<>{}]'), '')
        .trim();
  }

  // ===== RATE LIMITING HELPERS =====

  /// Check if user is creating too many polls (rate limiting)
  static bool exceedsRateLimit({
    required int pollsCreatedToday,
    required bool isAdmin,
  }) {
    if (isAdmin) {
      return pollsCreatedToday > 50; // Admin: 50 per day
    } else {
      return pollsCreatedToday > 5; // Warga: 5 per day
    }
  }

  /// Check if user is voting too fast (spam prevention)
  static bool isTooFast(DateTime? lastVoteTime) {
    if (lastVoteTime == null) return false;
    final diff = DateTime.now().difference(lastVoteTime);
    return diff.inSeconds < 2; // Min 2 seconds between votes
  }

  // ===== COMPREHENSIVE VALIDATION =====

  /// Validate entire poll data before creation
  static List<String> validatePollData({
    required String title,
    required String description,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String visibilityScope,
    String? targetRT,
    required List<String> options,
  }) {
    final errors = <String>[];

    // Validate each field
    final titleError = validateTitle(title);
    if (titleError != null) errors.add(titleError);

    final descError = validateDescription(description);
    if (descError != null) errors.add(descError);

    final typeError = validatePollType(type);
    if (typeError != null) errors.add(typeError);

    final dateError = validateDates(startDate, endDate);
    if (dateError != null) errors.add(dateError);

    final rtError = validateTargetRT(targetRT, visibilityScope);
    if (rtError != null) errors.add(rtError);

    final optionsError = validateOptions(options);
    if (optionsError != null) errors.add(optionsError);

    // Security checks
    if (containsSQLInjection(title) || containsSQLInjection(description)) {
      errors.add('Input mengandung karakter tidak valid');
    }

    if (containsXSS(title) || containsXSS(description)) {
      errors.add('Input mengandung script tidak aman');
    }

    return errors;
  }
}

