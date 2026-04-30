class DiseaseInfoResponse {
  DiseaseInfoResponse({
    required this.name,
    required this.slug,
    required this.description,
    this.symptoms,
    this.causes,
    this.prevention,
    this.severityLevel,
    required this.recommendations,
    required this.disclaimer,
  });

  final String name;
  final String slug;
  final String description;
  final String? symptoms;
  final String? causes;
  final String? prevention;
  final String? severityLevel;
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
      symptoms: json['symptoms'] as String?,
      causes: json['causes'] as String?,
      prevention: json['prevention'] as String?,
      severityLevel: json['severity_level'] as String?,
      recommendations: recommendations,
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}

typedef DiseaseInfo = DiseaseInfoResponse;
