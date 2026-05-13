import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguagePage> {
  final AppLocalization _appLocalization = AppLocalization();

  final List<Map<String, String>> languages = [
    {"code": "en", "native": "English", "english": "English"},
    {"code": "hi", "native": "हिन्दी", "english": "Hindi"},
    {"code": "te", "native": "తెలుగు", "english": "Telugu"},
  ];

  @override
  Widget build(BuildContext context) {
    // Find current selected index based on current locale
    final currentLanguageCode = _appLocalization.currentLanguageCode;
    int selectedIndex = languages.indexWhere((lang) => lang["code"] == currentLanguageCode);
    if (selectedIndex == -1) selectedIndex = 0; // Default to English if not found

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
                          // Update the locale when language is selected
                          _appLocalization.setLocaleByLanguageCode(lang["code"]!);
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
                    // Language is already saved when selected, just show confirmation and go back
                    final selectedLanguage = languages.firstWhere(
                      (lang) => lang["code"] == _appLocalization.currentLanguageCode,
                      orElse: () => languages[0],
                    )["english"];

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$selectedLanguage language selected"),
                      ),
                    );
                    
                    // Navigate back after selection
                    Navigator.of(context).pop();
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
