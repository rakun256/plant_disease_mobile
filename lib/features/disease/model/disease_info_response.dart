class DiseaseInfoResponse {
  DiseaseInfoResponse({
    required this.name,
    required this.slug,
    required this.description,
    required this.recommendations,
    required this.disclaimer,
  });

  final String name;
  final String slug;
  final String description;
  final List<String> recommendations;
  final String disclaimer;

  factory DiseaseInfoResponse.fromJson(Map<String, dynamic> json) {
    final recommendations =
        (json['recommendations'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList();

    return DiseaseInfoResponse(
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      recommendations: recommendations,
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}
