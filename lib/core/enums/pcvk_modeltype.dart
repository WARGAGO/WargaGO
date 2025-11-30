enum PcvkModelType {
  mlpv2('mlpv2'),
  mlpv2AutoClahe('mlpv2_auto-clahe'),
  efficientnetv2('efficientnetv2');

  final String value;
  const PcvkModelType(this.value);

  @override
  String toString() => value;

  static PcvkModelType fromString(String value) {
    return PcvkModelType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PcvkModelType.mlpv2AutoClahe,
    );
  }
}
