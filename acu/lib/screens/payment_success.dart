import 'package:acu/screens/components/hidden_drawer.dart';
import 'package:acu/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentSuccessWidget extends StatelessWidget {
  const PaymentSuccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Stack to layer the small circles and tick icon inside a larger container
              Container(
                width: 330,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Multiple small circles in the background
                    Positioned(
                      left: 40,
                      top: 10,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      right: 20,
                      top: 40,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      top: 80,
                      left: 60,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 50,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 40,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      top: 120,
                      left: 90,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      right: 70,
                      bottom: 80,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      left: 110,
                      top: 50,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      right: 34,
                      top: 130,
                      child: _buildSmallCircle(),
                    ),
                    Positioned(
                      left: 100,
                      bottom: 20,
                      child: _buildSmallCircle(),
                    ),

                    // Main gear-like circle with tick icon in the center
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(185, 28, 28, 1.0), // Red color
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Success message
              Text(
                'Order Placed Successfully',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 50),

              ElevatedButton(
                onPressed: () {
                  Get.to(() => HiddenDrawer());
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 120, vertical: 16),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'DONE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build small circles for decoration
  Widget _buildSmallCircle() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(185, 28, 28, 0.6), // Red color
      ),
    );
  }
}
