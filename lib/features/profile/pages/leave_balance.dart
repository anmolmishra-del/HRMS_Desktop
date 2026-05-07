import 'package:flutter/material.dart';

class LeaveBalanceModernPage extends StatelessWidget {
  const LeaveBalanceModernPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Profile Section
              Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?img=3",
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "John Malik",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text("Team Lead", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  _circleIcon(Icons.add),
                  const SizedBox(width: 10),
                  _circleIcon(Icons.chat_bubble_outline),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "Leave Balance",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 18),

              /// 🔹 Smaller Leave Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4, // 🔥 reduced height
                children: const [
                  LeaveCard(
                    icon: Icons.beach_access,
                    title: "Total Leave",
                    value: "12",
                  ),
                  LeaveCard(
                    icon: Icons.check_circle_outline,
                    title: "Taken",
                    value: "8",
                  ),
                  LeaveCard(
                    icon: Icons.wb_sunny_outlined,
                    title: "Remaining",
                    value: "5",
                  ),
                  LeaveCard(
                    icon: Icons.medical_services_outlined,
                    title: "Sick Leave",
                    value: "2 / 5",
                  ),
                ],
              ),

              const SizedBox(height: 28),

              /// 🔹 Quick Actions
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  QuickActionCard(
                    icon: Icons.beach_access,
                    label: "Book Leave",
                  ),
                  QuickActionCard(
                    icon: Icons.local_hospital,
                    label: "Report Sick",
                  ),
                  QuickActionCard(
                    icon: Icons.mail_outline,
                    label: "Contact HR",
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// 🔹 Recent Activity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Activity",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint("View All Clicked");
                    },
                    child: const Text(
                      "View all",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const ActivityTile(
                icon: Icons.beach_access,
                title: "Annual Leave",
                subtitle: "3 days: Apr 4 - Apr 6, 2024",
              ),
              const ActivityTile(
                icon: Icons.local_hospital,
                title: "Sick Leave",
                subtitle: "1 day: Mar 20, 2024",
              ),
              const ActivityTile(
                icon: Icons.beach_access,
                title: "Annual Leave",
                subtitle: "1 day: Feb 10, 2024",
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 18),
    );
  }
}

//// 🔹 Compact Leave Card
class LeaveCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const LeaveCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 22),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

//// 🔹 Clickable Quick Action
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const QuickActionCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("$label Clicked");
      },
      child: Container(
        width: 105,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

//// 🔹 Clickable Activity Tile
class ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ActivityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint("$title Clicked");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Icon(icon, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}
