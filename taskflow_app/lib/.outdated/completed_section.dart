import 'package:flutter/material.dart';

class CompletedSection extends StatelessWidget {
  final int count;
  final bool allDone;

  const CompletedSection({super.key, required this.count, required this.allDone});

  @override
  Widget build(BuildContext context) {
    if (allDone) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.celebration_rounded, color: Colors.greenAccent, size: 42),
            SizedBox(height: 8),
            Text("All tasks complete", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text("Nice work!", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
            Text("Completed ($count)", style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
