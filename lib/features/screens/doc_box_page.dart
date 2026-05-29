import 'package:flutter/material.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';

class DocBoxPage extends StatelessWidget {
  const DocBoxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final companyDocs = [
      {"title": "January Salary Slip", "type": "PDF", "date": "01 Feb 2026"},
      {"title": "Offer Letter", "type": "PDF", "date": "15 Jan 2025"},
      {"title": "Experience Letter", "type": "PDF", "date": "20 Dec 2025"},
    ];

    final personalDocs = [
      {"title": "Aadhar Card", "type": "Image", "date": "10 Jan 2025"},
      {"title": "PAN Card", "type": "Image", "date": "05 Jan 2025"},
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context).docBox,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            tabs: [
              Tab(text: AppLocalizations.of(context).companyDocs),
              Tab(text: AppLocalizations.of(context).personalDocs),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2A5298),
          onPressed: () {
            // Upload functionality
          },
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: Text(AppLocalizations.of(context).upload, style: const TextStyle(color: Colors.white)),
        ),
        body: TabBarView(
          children: [_buildDocList(context, companyDocs), _buildDocList(context, personalDocs)],
        ),
      ),
    );
  }

  Widget _buildDocList(BuildContext context, List<Map<String, String>> documents) {
    if (documents.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context).noDocumentsAvailable));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        final isPdf = doc["type"] == "PDF";

        return Card(
          elevation: 4,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPdf
                      ? [Colors.red.shade300, Colors.red.shade100]
                      : [Colors.green.shade300, Colors.green.shade100],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.image,
                color: Colors.white,
              ),
            ),
            title: Text(
              doc["title"]!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${AppLocalizations.of(context).uploadedOn} ${doc["date"]}",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            trailing: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                // Handle actions
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: "view", child: Text(AppLocalizations.of(context).view)),
                PopupMenuItem(value: "download", child: Text(AppLocalizations.of(context).download)),
                PopupMenuItem(value: "delete", child: Text(AppLocalizations.of(context).delete)),
              ],
            ),
          ),
        );
      },
    );
  }
}
