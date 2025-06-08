class TermsDocument {
  final String termTitle;
  final String effectiveDate;
  final String company;
  final String service;
  final List<TermsSection> sections;

  TermsDocument({
    required this.termTitle,
    required this.effectiveDate,
    required this.company,
    required this.service,
    required this.sections,
  });

  factory TermsDocument.fromJson(Map<String, dynamic> json) {
    return TermsDocument(
      termTitle: json['term_title'] as String? ?? '',
      effectiveDate: json['effective_date'] as String? ?? '',
      company: json['company'] as String? ?? '',
      service: json['service'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => TermsSection.fromJson(e))
          .toList(),
    );
  }
}

class TermsSection {
  final String title;
  final List<String> content;

  TermsSection({
    required this.title,
    required this.content,
  });

  factory TermsSection.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    List<String> contentList;

    if (rawContent is String) {
      contentList = [rawContent];
    } else if (rawContent is List<dynamic>) {
      contentList = rawContent
          .map((e) => e.toString())
          .toList();
    } else {
      contentList = [];
    }

    return TermsSection(
      title: json['title'] as String? ?? '',
      content: contentList,
    );
  }
}
