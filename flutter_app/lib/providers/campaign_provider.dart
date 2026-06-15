import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reliefnet_app/core/api/api_client.dart';
import 'package:reliefnet_app/core/api/api_constants.dart';
import 'package:reliefnet_app/models/campaign_model.dart';

class CampaignRepository {
  final ApiClient _client;

  CampaignRepository({required ApiClient client}) : _client = client;

  Future<List<CampaignModel>> getCampaigns({String? status}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status;
      final response = await _client.get(
        ApiConstants.campaigns,
        queryParameters: params.isEmpty ? null : params,
      );
      final data = response.data;

      // Handle the standardized 'data' wrapper from backend
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data.containsKey('data')) {
        list = data['data'] as List? ?? [];
      } else if (data is Map && data.containsKey('campaigns')) {
        // Fallback for old structure
        list = data['campaigns'] as List? ?? [];
      }

      return list
          .map((c) => CampaignModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // INTERNAL LOGGING (Placeholder)
      debugPrint('[RESILIENCE] Failed to load campaigns: $e');
      // Return empty list instead of throwing to keep UI stable
      return [];
    }
  }

  Future<CampaignModel> getCampaignById(int id) async {
    final response = await _client.get(ApiConstants.campaignById(id));
    return CampaignModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CampaignModel> createCampaign({
    required String title,
    String? description,
    required double goalPkr,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _client.post(ApiConstants.campaigns, data: {
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'goal_pkr': goalPkr,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final data = response.data;
    final json = data is Map<String, dynamic> && data.containsKey('data')
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return CampaignModel.fromJson(json);
  }
}

final campaignRepoProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepository(client: ref.read(apiClientProvider));
});

final campaignsProvider = FutureProvider<List<CampaignModel>>((ref) async {
  final repo = ref.read(campaignRepoProvider);
  return repo.getCampaigns(status: 'ACTIVE');
});

// Returns ALL campaigns regardless of status — used by NGO role to see their full portfolio
final allCampaignsProvider = FutureProvider<List<CampaignModel>>((ref) async {
  final repo = ref.read(campaignRepoProvider);
  return repo.getCampaigns();
});

final campaignDetailProvider =
    FutureProvider.family<CampaignModel, int>((ref, id) async {
  final repo = ref.read(campaignRepoProvider);
  return repo.getCampaignById(id);
});
