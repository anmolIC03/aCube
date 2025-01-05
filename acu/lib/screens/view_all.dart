import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewAllScreen extends StatefulWidget {
  final Map<String, List<Map<String, String>>> items;

  ViewAllScreen({required this.items});

  @override
  _ViewAllScreenState createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = selectedCategory != null
        ? widget.items[selectedCategory] ?? []
        : widget.items.values.expand((itemList) => itemList).toList();

    final similarCategories = widget.items.keys.toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        toolbarHeight: 70,
        centerTitle: true,
        title: Text(
          'REFINED BY MODELS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.favorite_border_outlined,
                size: 28,
                color: Colors.red,
              ))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: similarCategories.length,
              itemBuilder: (context, index) {
                final category = similarCategories[index];
                final isActive = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory =
                            isActive ? null : category; // Toggle selection
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: isActive ? 4 : 1,
                      child: Container(
                        width: 120,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          category,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.red : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: filteredItems.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Image Section
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(item['imageUrl']!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Text Section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['model']!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['type']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.yellow,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item['rating']!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No items available for this category',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
