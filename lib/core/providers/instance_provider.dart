import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wargago/core/configs/url_pcvk_api.dart';
import 'package:wargago/core/enums/instace_api_enum.dart';

class InstanceProvider extends ChangeNotifier {
  VoidCallback get notify => notifyListeners;
  final SharedPreferences prefs;

  InstanceProvider._({
    required this.prefs,
    required InstanceApiType instanceSelectedType,
  }) : _instanceSelected = instanceSelectedType;

  static Future<InstanceProvider> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final baseUrl =
        prefs.getString(InstanceApiPrefKey.baseUrl.name) ?? UrlPCVKAPI.baseUrl;
    final isSSL = prefs.getBool(InstanceApiPrefKey.isUseSSL.name) ?? false;
    final instanceType = InstanceApiType.fromString(
      prefs.getString(InstanceApiPrefKey.instanceType.name) ??
          InstanceApiType.hostedApi.value,
    );

    if (instanceType != InstanceApiType.hostedApi) {
      UrlPCVKAPI.setBaseUrl(baseUrl);
      UrlPCVKAPI.setIsSSL(isSSL);
    }

    return InstanceProvider._(prefs: prefs, instanceSelectedType: instanceType)
      .._loadedBaseUrl = baseUrl;
  }

  List<String> get instanceList =>
      InstanceApiType.values.map((e) => e.value).toList();

  InstanceApiType _instanceSelected;
  String get instanceSelected => _instanceSelected.value;
  set instanceSelected(String value) {
    _instanceSelected = InstanceApiType.fromString(value);
    if (_instanceSelected == InstanceApiType.hostedApi) {
      UrlPCVKAPI.setBaseUrl(UrlPCVKAPI.baseUrlEnv);
      UrlPCVKAPI.setIsSSL(UrlPCVKAPI.isSSLEnv);
    }
    prefs.setString(InstanceApiPrefKey.instanceType.name, instanceSelected);
    notifyListeners();
  }

  String _loadedBaseUrl = '';
  String get baseUrl => UrlPCVKAPI.baseUrl == UrlPCVKAPI.baseUrlEnv
      ? _loadedBaseUrl
      : UrlPCVKAPI.baseUrl;
  set baseUrl(String value) {
    UrlPCVKAPI.setBaseUrl(value);
    _loadedBaseUrl = value;
    prefs.setString(InstanceApiPrefKey.baseUrl.name, UrlPCVKAPI.baseUrl);
    notifyListeners();
  }

  bool get isSSL => UrlPCVKAPI.isSSL;
  set isSSL(bool value) {
    UrlPCVKAPI.setIsSSL(value);
    prefs.setBool(InstanceApiPrefKey.isUseSSL.name, value);
    notifyListeners();
  }

  void save({
    required String instanceType,
    required String baseUrl,
    required bool isSSL,
  }) {
    this.baseUrl = baseUrl;
    this.isSSL = isSSL;
    instanceSelected = instanceType;
  }
}
