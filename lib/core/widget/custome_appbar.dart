import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final double height;
  final String? assetImage;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.actions,
    this.height = 120,
    this.assetImage,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: leading == null,
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: height,
      actions: actions,
      flexibleSpace: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              leading ??
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: assetImage != null
                        ? AssetImage(assetImage!)
                        : null,
                    backgroundColor: Colors.white24,
                    child: assetImage == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
