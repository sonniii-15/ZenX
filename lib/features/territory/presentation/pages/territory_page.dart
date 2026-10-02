import 'package:flutter/material.dart';
import '../../../../core/theme/zenx_colors.dart';

class TerritoryPage extends StatelessWidget {
  const TerritoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'TERRITORY OVERVIEW',
          style: TextStyle(color: ZenXColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
