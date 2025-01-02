import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  VerificationScreen({required this.email});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  int _timer = 59;
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        setState(() {
          _timer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _resendCode() {
    setState(() {
      _timer = 59;
    });
    _startTimer();
    print('Resend OTP to ${widget.email}');
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100),
                Text(
                  'Verification',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  "We've sent you a verification code on \n${widget.email}",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20),

                // OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllers[index],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '', // Remove character counter
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            FocusScope.of(context)
                                .nextFocus(); // Move to next box
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context)
                                .previousFocus(); // Move to previous box
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 30),

                // Continue Button
                ElevatedButton(
                  onPressed: () {
                    String otp = _getOtp();
                    print('OTP Entered: $otp');
                    // Handle OTP verification logic
                  },
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60),
                    backgroundColor: Color.fromRGBO(185, 28, 28, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Resend Code with Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Didn\'t receive the code?'),
                    TextButton(
                      onPressed: _timer == 0 ? _resendCode : null,
                      child: Text(
                        'Resend Code',
                        style: TextStyle(
                          color: _timer == 0
                              ? Color.fromRGBO(185, 28, 28, 1.0)
                              : Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      '$_timer s',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 3,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 28,
              ),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
            ),
          ),
        ],
      ),
    );
  }
}
