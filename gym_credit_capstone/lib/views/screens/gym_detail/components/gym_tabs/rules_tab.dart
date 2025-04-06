import 'package:flutter/material.dart';

class RulesTab extends StatelessWidget {
  final List<Map<String, dynamic>> rulesData;

  const RulesTab({super.key, required this.rulesData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
      itemCount: rulesData.length,
      itemBuilder: (context, sectionIndex) {
        final section = rulesData[sectionIndex];
        final sectionTitle = section['section'];
        final items = section['items'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sectionTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (sectionTitle == "주의사항")
              ...items.map<Widget>((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• ${item['title']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description'],
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ))
            else
              ...items.map<Widget>((text) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "• $text",
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              )),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
