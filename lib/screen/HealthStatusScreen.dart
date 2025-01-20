import 'package:flutter/material.dart';

class HealthStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 17, 20, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35, 35, 37, 1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Transform.rotate(
                    angle: -90 * 3.1415926535897932 / 180,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Color.fromRGBO(106, 106, 108, 1),
                      size: 22,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Training AI...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Your health status",
                  style: TextStyle(
                    fontSize: 33,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Upload your health report",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 159,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35, 35, 37, 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: Color.fromRGBO(37, 195, 166, 1),
                      size: 34,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "or give me some context",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 185,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35, 35, 37, 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Describe your Blood Pressure, Cholesterol Levels, Blood Sugar Levels...",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35, 35, 37, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "Next",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}