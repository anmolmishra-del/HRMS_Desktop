import 'package:flutter/material.dart';

class TrainingLearningPage extends StatelessWidget {
  const TrainingLearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// SEARCH BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Search courses...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// CATEGORIES
                const Text(
                  "Categories",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  height: 110,

                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: CategoryCard(
                          icon: Icons.code,
                          label: "Development",
                          color: Color(0xFFD6E4FF),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: CategoryCard(
                          icon: Icons.design_services,
                          label: "Design",
                          color: Color(0xFFE8D9FF),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: CategoryCard(
                          icon: Icons.bar_chart,
                          label: "Management",
                          color: Color(0xFFFFE8D6),
                        ),
                      ),

                      CategoryCard(
                        icon: Icons.public,
                        label: "Soft Skills",
                        color: Color(0xFFD9F3E4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// ONGOING TRAINING
                const Text(
                  "Ongoing Training",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                TrainingCard(
                  icon: Icons.flutter_dash,
                  title: "Flutter Advanced Course",
                  trainer: "John Smith",
                  progress: 0.7,
                  weeks: "8 Weeks",
                ),

                const SizedBox(height: 15),

                TrainingCard(
                  icon: Icons.trending_up,
                  title: "Project Management Basics",
                  trainer: "Sarah Johnson",
                  progress: 0.4,
                  weeks: "6 Weeks",
                ),

                const SizedBox(height: 15),

                TrainingCard(
                  icon: Icons.language,
                  title: "UI/UX Design Mastery",
                  trainer: "David Lee",
                  progress: 0.9,
                  weeks: "10 Weeks",
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CATEGORY CARD

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,

      padding: const EdgeInsets.all(6),

      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, size: 30, color: Colors.black54),

          const SizedBox(height: 10),

          Text(
            label,
            textAlign: TextAlign.center,

            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// TRAINING CARD

class TrainingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trainer;
  final double progress;
  final String weeks;

  const TrainingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.trainer,
    required this.progress,
    required this.weeks,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailsPage(
              title: title,
              trainer: trainer,
              progress: progress,
              totalDays: 30,
              completedDays: (progress * 30).toInt(),
            ),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Icon(icon, color: Colors.blue),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Trainer: $trainer",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),

                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  weeks,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              "${(progress * 100).toInt()}% Completed",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// COURSE DETAILS PAGE

class CourseDetailsPage extends StatelessWidget {
  final String title;
  final String trainer;
  final double progress;
  final int totalDays;
  final int completedDays;

  const CourseDetailsPage({
    super.key,
    required this.title,
    required this.trainer,
    required this.progress,
    required this.totalDays,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text("Trainer: $trainer"),

            const SizedBox(height: 20),

            LinearProgressIndicator(value: progress, minHeight: 10),

            const SizedBox(height: 10),

            Text("${(progress * 100).toInt()}% Completed"),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                statCard("Total Days", totalDays.toString()),

                statCard("Completed", completedDays.toString()),

                statCard("Remaining", (totalDays - completedDays).toString()),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Learning Timeline",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: totalDays,

                itemBuilder: (context, index) {
                  bool completed = index < completedDays;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: completed ? Colors.green : Colors.grey,

                      child: Icon(
                        completed ? Icons.check : Icons.lock,
                        color: Colors.white,
                      ),
                    ),

                    title: Text("Day ${index + 1} Lesson"),

                    subtitle: Text(completed ? "Completed" : "Locked"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(String title, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(title),
        ],
      ),
    );
  }
}
