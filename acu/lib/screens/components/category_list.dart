import 'package:acu/screens/view_all.dart';
import 'package:flutter/material.dart';

class CategoryListSection extends StatefulWidget {
  @override
  _CategoryListSectionState createState() => _CategoryListSectionState();
}

class _CategoryListSectionState extends State<CategoryListSection> {
  final List<String> categories = ['Bikes', 'Parts', 'Jackets'];
  String selectedCategory = 'Bikes';

  final Map<String, List<Map<String, String>>> categoryItems = {
    'Bikes': [
      {
        'label': 'Bikes',
        'imageUrl':
            'https://www.acubemart.in/_next/static/media/hero-image-1.a2f50314.jpeg',
        'model': 'KTM 350 CC',
        'type': 'Plastic Body',
        'rating': '4.5',
      },
    ],
    'Parts': [
      {
        'label': 'Parts',
        'imageUrl':
            'https://www.acubemart.in/_next/static/media/hero-image-1.a2f50314.jpeg',
        'model': 'Part 1',
        'type': 'Metal',
        'rating': '4.2',
      },
      {
        'label': 'Parts',
        'imageUrl':
            'https://www.acubemart.in/_next/static/media/hero-image-1.a2f50314.jpeg',
        'model': 'Part 2',
        'type': 'Plastic',
        'rating': '4.0',
      },
    ],
    'Jackets': [
      {
        'label': 'Jackets',
        'imageUrl':
            'https://www.acubemart.in/_next/static/media/hero-image-1.a2f50314.jpeg',
        'model': 'Jacket 1',
        'type': 'Leather',
        'rating': '4.8',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REFINED BY MODELS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewAllScreen(items: categoryItems),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Container(
                color: Colors.white, // White background for the button
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: selectedCategory == category
                        ? Colors.red // Text color for selected category
                        : Colors.black, // Default text color
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: selectedCategory == category
                          ? TextDecoration
                              .underline // Underline for selected category
                          : TextDecoration
                              .none, // No underline for unselected category
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: ListView(
            scrollDirection: Axis.vertical,
            children: categoryItems[selectedCategory]!
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildItemCard(
                        imageUrl: item['imageUrl']!,
                        model: item['model']!,
                        type: item['type']!,
                        rating: item['rating']!,
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required String imageUrl,
    required String model,
    required String type,
    required String rating,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 160,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      model,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$type',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 22, color: Colors.yellow),
                        SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
