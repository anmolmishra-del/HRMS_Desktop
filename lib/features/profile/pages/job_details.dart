import 'package:flutter/material.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          title: const Text(
            "Employee Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.edit),
            ),
          ],
        ),

        // ✅ Proper Scrollable Structure
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 10),
                    _buildTabBar(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ];
          },

          body: const TabBarView(children: [ProfileTab(), JobDetailsTab()]),
        ),
      ),
    );
  }

  // PROFILE HEADER

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage(
              "https://randomuser.me/api/portraits/men/75.jpg",
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Praveen Kumar",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("Software Engineer", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          const Divider(),
          _infoRow(Icons.email, "praveen.kumar@example.in"),
          _infoRow(Icons.phone, "+91 98765 43210"),
          _infoRow(Icons.badge, "Employee ID: IND12345"),
          _infoRow(Icons.location_on, "Location: Hyderabad, Telangana"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // TAB BAR

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: const TabBar(
        indicator: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        labelColor: Colors.white,
        dividerColor: Colors.transparent,
        unselectedLabelColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Tab(text: "Profile"),
          Tab(text: "Job Details"),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// PROFILE TAB
//////////////////////////////////////////////////////////////////

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          title: "Personal Information",
          children: [
            _detailRow("Date of Birth", "15 April 1990"),
            _detailRow("Gender", "Male"),
            _detailRow("Address", "12 MG Road, Hyderabad, Telangana"),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: "Emergency Contact",
          children: [
            _detailRow("Name", "Priya Sharma"),
            _detailRow("Relationship", "Spouse"),
            _detailRow("Phone", "+91 91234 56789"),
          ],
        ),
      ],
    );
  }
}

// JOB DETAILS TAB

class JobDetailsTab extends StatelessWidget {
  const JobDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          title: "Employment Details",
          children: [
            _detailRow("Department", "Engineering"),
            _detailRow("Designation", "Software Engineer"),
            _detailRow("Joining Date", "1 July 2015"),
            _detailRow("Employment Type", "Full Time"),
            _detailRow("Work Location", "Hyderabad Office"),
            _detailRow("Reporting Manager", "Amit Kumar"),
            _detailRow("Status", "Active", isStatus: true),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: "Salary Information",
          children: [
            _detailRow("Salary", "₹12,00,000 / Year"),
            _detailRow("Bank Name", "State Bank of India"),
            _detailRow("Account No", "XXXXXX1234"),
          ],
        ),
      ],
    );
  }
}

// COMMON WIDGETS

Widget _buildCard({required String title, required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

Widget _detailRow(String title, String value, {bool isStatus = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            color: isStatus ? Colors.green : Colors.black,
            fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
