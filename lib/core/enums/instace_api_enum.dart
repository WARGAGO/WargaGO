enum InstanceApiType {
  hostedApi('Hosted API'),
  custom('Custom');

  final String value;
  const InstanceApiType(this.value);

  static InstanceApiType fromString(String value) {
    return InstanceApiType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => InstanceApiType.hostedApi,
    );
  }
}

enum InstanceApiPrefKey { instanceType, baseUrl, isUseSSL }
