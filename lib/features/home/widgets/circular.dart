import 'package:flutter/material.dart';

class CircularCardSection extends StatelessWidget {
  final String title;
  final IconData? trailing;

  const CircularCardSection({
    super.key,
    this.title = 'Circulars',
    this.trailing,
  });

  /// Built-in sample data
  List<Map<String, String>> get _cards => [
    {
      'title': 'Get Vaccinated, Stay Home, Stay Safe',
      'subtitle': '21 June 2021 · 10:55 AM',
      'imageUrl': 'https://i.pravatar.cc/150?img=5',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (trailing != null)
                Icon(trailing, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          // Circular Card List
          Column(
            children: _cards.map((c) {
              final cardTitle = c['title']!;
              final cardSubtitle = c['subtitle']!;
              final imageUrl = c['imageUrl'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        imageUrl ?? 'https://i.pravatar.cc/150?img=5',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cardTitle,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cardSubtitle,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
