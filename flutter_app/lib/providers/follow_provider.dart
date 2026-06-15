import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kFollowedCampaignsKey = 'followed_campaign_ids';
const _kFollowedNgosKey = 'followed_ngo_ids';
const _storage = FlutterSecureStorage();

class FollowNotifier extends StateNotifier<Set<int>> {
  final String _storageKey;

  FollowNotifier(this._storageKey) : super({}) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw) as List;
      state = decoded.map((e) => e as int).toSet();
    }
  }

  Future<void> _save() async {
    await _storage.write(key: _storageKey, value: jsonEncode(state.toList()));
  }

  void toggle(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
    _save();
  }

  bool isFollowing(int id) => state.contains(id);
}

final followedCampaignsProvider =
    StateNotifierProvider<FollowNotifier, Set<int>>(
  (_) => FollowNotifier(_kFollowedCampaignsKey),
);

final followedNgosProvider =
    StateNotifierProvider<FollowNotifier, Set<int>>(
  (_) => FollowNotifier(_kFollowedNgosKey),
);
