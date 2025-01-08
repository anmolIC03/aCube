import 'package:flutter/material.dart';

class BrandInfoContainer extends StatelessWidget {
  final String brandLogoUrl;
  final String brandName;
  final bool isAvailable;

  const BrandInfoContainer({
    Key? key,
    required this.brandLogoUrl,
    required this.brandName,
    required this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.network(
                brandLogoUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 8),
              Text(
                brandName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                isAvailable ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  fontSize: 14,
                  color: isAvailable ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
