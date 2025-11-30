enum PredictClass {
  sayurAkar('Sayur Akar'),
  sayurBuah('Sayur Buah'),
  sayurBunga('Sayur Bunga'),
  sayurDaun('Sayur Daun'),
  sayurPolong('Sayur Polong');

  final String displayName;

  const PredictClass(this.displayName);

  @override
  String toString() => displayName;
}
