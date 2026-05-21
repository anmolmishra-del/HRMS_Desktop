import 'package:flutter/material.dart';
import '../services/internet_service.dart';

class InternetWrapper extends StatelessWidget {
  final Widget child;

  const InternetWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: InternetService.isConnected,
      builder: (context, isConnected, _) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              child,

              // No internet banner
              if (!isConnected)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.red,
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: const Text(
                          "No Internet Connection",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
