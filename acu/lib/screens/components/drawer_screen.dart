import 'package:flutter/material.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 40, left: 50, bottom: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                CircleAvatar(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image(
                        image: NetworkImage(
                            'https://www.acubemart.in/_next/static/media/hero-image-1.a2f50314.jpeg'),
                        fit: BoxFit.fill,
                      )),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "John Doe",
                  style: TextStyle(color: Colors.black, fontSize: 22),
                )
              ],
            ),
            Column(
              children: <Widget>[
                newRow(
                  icon: Icons.home_filled,
                  text: 'ACUBEMART',
                ),
                SizedBox(
                  height: 20,
                ),
                newRow(
                  icon: Icons.home_filled,
                  text: 'ACUBEMART',
                ),
                SizedBox(
                  height: 20,
                ),
                newRow(
                  icon: Icons.home_filled,
                  text: 'ACUBEMART',
                ),
                SizedBox(
                  height: 20,
                ),
                newRow(
                  icon: Icons.home_filled,
                  text: 'ACUBEMART',
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class newRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const newRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: Colors.black,
        ),
        SizedBox(
          width: 20,
        ),
        Text(
          text,
          style: TextStyle(color: Colors.black),
        )
      ],
    );
  }
}
