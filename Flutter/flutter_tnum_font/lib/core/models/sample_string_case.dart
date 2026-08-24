class SampleStringCase {
  const SampleStringCase({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final String value;

  String get datePart => value.split(' ').first;

  String get statusPart =>
      value.contains(' ') ? value.substring(value.indexOf(' ') + 1) : value;

  static List<SampleStringCase> defaults() {
    return const [
      SampleStringCase(id: 'a', label: '比賽狀態', value: '下'),
      SampleStringCase(id: 'a1', label: '比賽狀態', value: '中'),
      SampleStringCase(id: 'b', label: '比賽狀態', value: '場'),
      SampleStringCase(id: 'halftime', label: '比賽狀態', value: '04-22 中場'),
      SampleStringCase(id: 'penalty', label: 'PK 狀態', value: '04-22 點球PK'),
      SampleStringCase(id: 'extraTime', label: '加時狀態', value: '04-22 加時賽'),
    ];
  }
}
