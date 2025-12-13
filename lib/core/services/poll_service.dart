import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/poll_model.dart';
import '../models/poll_option_model.dart';
import '../models/poll_vote_model.dart';
import '../models/poll_result_model.dart';

/// Service untuk handle operasi polling RT/RW
/// Menggunakan Firestore dengan real-time snapshots
/// SHARED DATABASE - Admin dan Warga gunakan collection yang sama!
class PollService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references - SEMUA USER AKSES COLLECTION YANG SAMA
  CollectionReference get _pollsCollection => _firestore.collection('polls');

  CollectionReference _pollOptionsCollection(String pollId) =>
      _pollsCollection.doc(pollId).collection('options');

  CollectionReference _pollVotesCollection(String pollId) =>
      _pollsCollection.doc(pollId).collection('votes');

  CollectionReference get _pollResultsCollection =>
      _firestore.collection('poll_results');

  // ===== CREATE OPERATIONS =====

  /// Membuat polling baru
  Future<String> createPoll(Poll poll) async {
    try {
      final docRef = await _pollsCollection.add(poll.toMap());

      if (kDebugMode) {
        print('✅ [PollService] Poll created: ${docRef.id}');
        print('   Title: ${poll.title}');
        print('   Status: ${poll.status}');
        print('   PollLevel: ${poll.pollLevel}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PollService] Error creating poll: $e');
      }
      throw Exception('Gagal membuat polling: $e');
    }
  }

  /// Menambahkan opsi ke polling
  Future<String> addPollOption(String pollId, PollOption option) async {
    try {
      final docRef = await _pollOptionsCollection(pollId).add(option.toMap());

      // Update total options di poll document
      await _pollsCollection.doc(pollId).update({
        'totalOptions': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambahkan opsi: $e');
    }
  }

  /// Membuat polling dengan opsi sekaligus (transaction)
  Future<String> createPollWithOptions({
    required Poll poll,
    required List<PollOption> options,
  }) async {
    try {
      if (kDebugMode) {
        print('🗳️ [PollService] Creating poll with options...');
        print('   Title: ${poll.title}');
        print('   Status: ${poll.status}');
        print('   PollLevel: ${poll.pollLevel}');
        print('   Options: ${options.length}');
      }

      // Create poll first
      final pollId = await createPoll(poll);

      // Then add all options
      for (var i = 0; i < options.length; i++) {
        final option = options[i].copyWith(
          pollId: pollId,
          order: i,
        );
        await addPollOption(pollId, option);
      }

      // Create initial poll_results document
      await _createInitialPollResults(pollId, options.length);

      if (kDebugMode) {
        print('✅ [PollService] Poll created successfully!');
        print('   Poll ID: $pollId');
        print('   Ready to be viewed by ALL users (admin + warga)');
      }

      return pollId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PollService] Error in createPollWithOptions: $e');
      }
      throw Exception('Gagal membuat polling: $e');
    }
  }

  /// Create initial poll_results document
  Future<void> _createInitialPollResults(String pollId, int optionCount) async {
    try {
      await _pollResultsCollection.doc(pollId).set({
        'pollId': pollId,
        'totalVotes': 0,
        'totalParticipants': 0,
        'participationRate': 0.0,
        'lastUpdated': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error creating initial poll_results: $e');
      }
    }
  }

  // ===== VOTE OPERATIONS =====

  /// Submit vote untuk polling
  /// VALIDASI: 1 USER = 1 VOTE!
  Future<void> submitVote(PollVote vote) async {
    try {
      if (kDebugMode) {
        print('🗳️ [PollService] Submitting vote...');
        print('   User: ${vote.userId}');
        print('   Poll: ${vote.pollId}');
        print('   Option: ${vote.optionText}');
      }

      // ⚠️ CRITICAL: Check if user already voted
      final hasVoted = await hasUserVoted(vote.pollId, vote.userId);

      if (hasVoted) {
        if (kDebugMode) {
          print('❌ [PollService] User sudah vote sebelumnya!');
        }
        throw Exception('Anda sudah melakukan voting sebelumnya!');
      }

      if (kDebugMode) {
        print('✅ [PollService] User belum vote, melanjutkan...');
      }

      // Add vote document
      await _pollVotesCollection(vote.pollId).add(vote.toMap());

      if (kDebugMode) {
        print('✅ [PollService] Vote document created');
      }

      // Update option vote count
      await _pollOptionsCollection(vote.pollId).doc(vote.optionId).update({
        'voteCount': FieldValue.increment(1),
      });

      // Update poll stats
      await _pollsCollection.doc(vote.pollId).update({
        'totalVotes': FieldValue.increment(1),
        'totalParticipants': FieldValue.increment(1),
        'lastVoteAt': FieldValue.serverTimestamp(),
      });

      // Update poll_results
      await _updatePollResults(vote.pollId);

      if (kDebugMode) {
        print('🎊 [PollService] Vote submitted successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [PollService] Error submitting vote: $e');
      }
      throw Exception('Gagal submit vote: $e');
    }
  }

  /// Update aggregated poll results
  Future<void> _updatePollResults(String pollId) async {
    try {
      final votes = await _pollVotesCollection(pollId).get();

      final totalVotes = votes.docs.length;
      final uniqueVoters = votes.docs
          .map((v) => (v.data() as Map<String, dynamic>)['userId'])
          .toSet()
          .length;

      await _pollResultsCollection.doc(pollId).set({
        'pollId': pollId,
        'totalVotes': totalVotes,
        'totalParticipants': uniqueVoters,
        'participationRate': 0.0, // Calculate if needed
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating poll results: $e');
      }
    }
  }

  /// Check apakah user sudah vote
  Future<bool> hasUserVoted(String pollId, String userId) async {
    try {
      final snapshot = await _pollVotesCollection(pollId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal cek status vote: $e');
    }
  }

  /// Get user's vote untuk polling tertentu
  Future<PollVote?> getUserVote(String pollId, String userId) async {
    try {
      final snapshot = await _pollVotesCollection(pollId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return PollVote.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw Exception('Gagal get user vote: $e');
    }
  }

  // ===== READ OPERATIONS (REAL-TIME) =====

  /// Stream untuk list polling (dengan filter)
  Stream<List<Poll>> streamPolls({
    String? pollLevel, // "official" | "community"
    String? status, // "active" | "closed" | "draft"
    String? createdBy,
    String? targetRT,
    int limit = 20,
  }) {
    Query query = _pollsCollection;

    if (pollLevel != null) {
      query = query.where('pollLevel', isEqualTo: pollLevel);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    if (createdBy != null) {
      query = query.where('createdBy', isEqualTo: createdBy);
    }
    if (targetRT != null) {
      query = query.where('targetRT', isEqualTo: targetRT);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Poll.fromFirestore(doc)).toList();
    });
  }

  /// Stream untuk active polls - SHARED untuk ADMIN & WARGA!
  /// Polling yang dibuat admin akan otomatis muncul di warga (jika status=active)
  Stream<List<Poll>> streamActivePolls({String? pollLevel}) {
    if (kDebugMode) {
      print('🔍 [PollService] streamActivePolls called');
      print('   pollLevel: $pollLevel');
      print('   This query is SHARED - works for both admin and warga!');
    }

    // Query: status=active + optional pollLevel filter
    Query query = _pollsCollection.where('status', isEqualTo: 'active');

    if (pollLevel != null) {
      query = query.where('pollLevel', isEqualTo: pollLevel);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      if (kDebugMode) {
        print('📊 [PollService] Query returned ${snapshot.docs.length} documents');

        // Log details for debugging
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          print('   Poll: ${data['title']}');
          print('      ID: ${doc.id}');
          print('      Status: ${data['status']}');
          print('      PollLevel: ${data['pollLevel']}');
          print('      CreatedBy: ${data['createdBy']}');
          print('      CreatedByRole: ${data['createdByRole']}');
        }
      }

      // Filter by endDate on client-side
      final now = DateTime.now();
      final filtered = snapshot.docs
          .map((doc) => Poll.fromFirestore(doc))
          .where((poll) => poll.endDate.isAfter(now))
          .toList();

      if (kDebugMode) {
        print('   After endDate filter: ${filtered.length} polls');
        if (filtered.isEmpty) {
          print('   ⚠️  No active polls found!');
          print('   Check: 1) Polls exist? 2) status=active? 3) endDate future?');
        }
      }

      return filtered;
    });
  }

  /// Stream untuk single poll detail
  Stream<Poll> streamPollDetail(String pollId) {
    return _pollsCollection.doc(pollId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Polling tidak ditemukan');
      }
      return Poll.fromFirestore(doc);
    });
  }

  /// Stream untuk poll options (REAL-TIME untuk bar chart!)
  Stream<List<PollOption>> streamPollOptions(String pollId) {
    return _pollOptionsCollection(pollId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PollOption.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream untuk poll votes (untuk voter list)
  Stream<List<PollVote>> streamPollVotes(String pollId, {int limit = 100}) {
    return _pollVotesCollection(pollId)
        .orderBy('votedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PollVote.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream untuk poll results (agregasi)
  Stream<PollResult> streamPollResults(String pollId) {
    return _pollResultsCollection.doc(pollId).snapshots().map((doc) {
      if (!doc.exists) {
        // Return empty result if not exists
        return PollResult(
          pollId: pollId,
          totalVotes: 0,
          totalParticipants: 0,
          participationRate: 0.0,
          lastUpdated: DateTime.now(),
          options: [], // Empty list for initial state
        );
      }
      return PollResult.fromFirestore(doc);
    });
  }

  // ===== UPDATE OPERATIONS =====

  /// Update poll status
  Future<void> updatePollStatus(String pollId, String status) async {
    try {
      await _pollsCollection.doc(pollId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ [PollService] Poll status updated: $pollId → $status');
      }
    } catch (e) {
      throw Exception('Gagal update status: $e');
    }
  }

  /// Pin/unpin poll
  Future<void> togglePinPoll(String pollId, bool isPinned) async {
    try {
      await _pollsCollection.doc(pollId).update({
        'isPinned': isPinned,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal toggle pin: $e');
    }
  }

  /// Close poll
  Future<void> closePoll(String pollId) async {
    try {
      await _pollsCollection.doc(pollId).update({
        'status': 'closed',
        'closedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal close poll: $e');
    }
  }

  // ===== DELETE OPERATIONS =====

  /// Delete poll (soft delete - change status)
  Future<void> deletePoll(String pollId) async {
    try {
      await _pollsCollection.doc(pollId).update({
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal delete poll: $e');
    }
  }

  /// Hard delete poll (permanent)
  Future<void> hardDeletePoll(String pollId) async {
    try {
      // Delete subcollections first
      await _deleteSubcollections(pollId);

      // Delete poll document
      await _pollsCollection.doc(pollId).delete();

      // Delete poll_results
      await _pollResultsCollection.doc(pollId).delete();
    } catch (e) {
      throw Exception('Gagal hard delete poll: $e');
    }
  }

  Future<void> _deleteSubcollections(String pollId) async {
    // Delete options
    final options = await _pollOptionsCollection(pollId).get();
    for (var doc in options.docs) {
      await doc.reference.delete();
    }

    // Delete votes
    final votes = await _pollVotesCollection(pollId).get();
    for (var doc in votes.docs) {
      await doc.reference.delete();
    }
  }
}

