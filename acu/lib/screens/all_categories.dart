import 'package:flutter/material.dart';
import 'package:acu/screens/components/category_card.dart';
import 'package:get/get.dart';

class ViewAllCategoriesScreen extends StatefulWidget {
  @override
  _ViewAllCategoriesScreenState createState() =>
      _ViewAllCategoriesScreenState();
}

class _ViewAllCategoriesScreenState extends State<ViewAllCategoriesScreen> {
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.pedal_bike, 'label': 'Bikes'},
    {'icon': Icons.car_rental, 'label': 'Cars'},
    {'icon': Icons.chair, 'label': 'Riding Gears'},
    {'icon': Icons.electrical_services, 'label': 'Goggles'},
    {'icon': Icons.kitchen, 'label': 'Accessories'},
    {'icon': Icons.watch, 'label': 'Watches'},
    {'icon': Icons.phone_iphone, 'label': 'Phones'},
    {'icon': Icons.laptop, 'label': 'Laptops'},
    {'icon': Icons.camera_alt, 'label': 'Cameras'},
  ];

  // This will hold the index of the selected category card
  ValueNotifier<int> _selectedIndex = ValueNotifier<int>(-1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'CATEGORIES',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, size: 26),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];

            return ValueListenableBuilder<int>(
              valueListenable: _selectedIndex,
              builder: (context, selectedIndex, child) {
                bool isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    // Update the selected index when clicked
                    _selectedIndex.value = isSelected ? -1 : index;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected ? Colors.orange : Colors.grey.shade300,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: CategoryCard(
                      onTap: () {
                        print(category['label']);
                      },
                      icon: category['icon'],
                      label: category['label'],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
