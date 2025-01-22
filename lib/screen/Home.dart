import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 17, 20, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 45),
                Container(
                  width: double.infinity,
                  height: 129,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35, 35, 37, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wednesday',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'October 9, 2024',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: List.generate(7, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14.0),
                              child: Container(
                                width: 48,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: index == 2
                                      ? Color.fromRGBO(21, 17, 20, 1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${7 + index}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'][index],
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 11,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildActivitySection('Get up', '8 AM', '- 328 Kcal'),
                _buildActivitySection('Swimming', '8:30 AM', '- 328 Kcal'),
                _buildMealSection('Breakfast', '9:00 AM', [
                  _buildMealItem('1 Boiled Egg', '+ 50 Kcal'),
                  _buildMealItem('2 Slices of seed bread', '+ 150 Kcal'),
                  _buildMealItem('1 Black coffee', '+ 10 Kcal'),
                ]),
                _buildMealSection('Lunch', '12:30 AM', [
                  _buildMealItem('1 Boiled Egg', '+ 50 Kcal'),
                  _buildMealItem('2 Slices of seed bread', '+ 150 Kcal'),
                  _buildMealItem('1 Black coffee', '+ 10 Kcal'),
                ]),
                _buildMealSection('Dinner', '6:30 PM', [
                  _buildMealItem('1 Boiled Egg', '+ 50 Kcal'),
                  _buildMealItem('2 Slices of seed bread', '+ 150 Kcal'),
                  _buildMealItem('1 Black coffee', '+ 10 Kcal'),
                ]),
                _buildActivitySection('Sleep', '11:30 PM', ''),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35, 35, 37, 1),
                    borderRadius: BorderRadius.circular(46),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(55, 236, 203, 0.39),
                        offset: Offset(0, 4),
                        blurRadius: 14,
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(55, 236, 203, 1),
                        Color.fromRGBO(27, 137, 117, 1),
                        Color.fromRGBO(37, 198, 168, 1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Ask AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: <Color>[
                              Colors.white,
                              Colors.white.withOpacity(0.6),
                            ],
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 50.0, 19.0)),
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

  Widget _buildActivitySection(String title, String time, String kcal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 62),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Text(
            kcal,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, String time, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 62),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMealItem(String name, String kcal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          SizedBox(width: 78),
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          Text(
            kcal,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}