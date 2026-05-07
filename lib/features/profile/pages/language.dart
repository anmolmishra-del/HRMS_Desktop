import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguagePage> {
  int selectedIndex = 3; // Default selected Telugu

  final List<Map<String, String>> languages = [
    {"native": "हिन्दी", "english": "Hindi"},
    {"native": "मराठी", "english": "Marathi"},
    {"native": "தமிழ்", "english": "Tamil"},
    {"native": "తెలుగు", "english": "Telugu"},
    {"native": "বাংলা", "english": "Bengali"},
    {"native": "ಕನ್ನಡ", "english": "Kannada"},
    {"native": "ગુજરાતી", "english": "Gujarati"},
    {"native": "ਪੰਜਾਬੀ", "english": "Punjabi"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// Title
              const Text(
                "Select Your Language",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 30),

              /// Language List
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang["native"]!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lang["english"]!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Check Icon
                            if (isSelected)
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5B8BD9),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// Save Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 25),
                child: ElevatedButton(
                  onPressed: () {
                    final selectedLanguage =
                        languages[selectedIndex]["english"];

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$selectedLanguage language selected"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color(0xFF5B8BD9),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
