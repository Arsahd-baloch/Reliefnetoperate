import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reliefnet_app/core/api/api_client.dart';
import 'package:reliefnet_app/models/ngo_model.dart';

class NgoRepository {
  final ApiClient _client;

  NgoRepository({required ApiClient client}) : _client = client;

  Future<NgoProfileModel> getProfile() async {
    final response = await _client.get('/ngo/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return NgoProfileModel.fromJson(data);
  }

  Future<NgoProfileModel> updateProfile(Map<String, dynamic> body) async {
    final response = await _client.patch('/ngo/profile', data: body);
    final data = response.data['data'] as Map<String, dynamic>;
    return NgoProfileModel.fromJson(data);
  }
}

final ngoRepoProvider = Provider<NgoRepository>((ref) {
  return NgoRepository(client: ref.read(apiClientProvider));
});

final ngoProfileProvider = FutureProvider<NgoProfileModel>((ref) async {
  final repo = ref.read(ngoRepoProvider);
  return repo.getProfile();
});

class NgoProfileNotifier extends StateNotifier<AsyncValue<NgoProfileModel?>> {
  final NgoRepository _repo;
  final Ref _ref;

  NgoProfileNotifier({required NgoRepository repo, required Ref ref})
      : _repo = repo,
        _ref = ref,
        super(const AsyncValue.data(null));

  Future<void> updateProfile(Map<String, dynamic> body) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = await _repo.updateProfile(body);
      _ref.invalidate(ngoProfileProvider);
      return profile;
    });
  }
}

final ngoProfileActionsProvider =
    StateNotifierProvider<NgoProfileNotifier, AsyncValue<NgoProfileModel?>>((ref) {
  final repo = ref.read(ngoRepoProvider);
  return NgoProfileNotifier(repo: repo, ref: ref);
});
