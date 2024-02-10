import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const Map<String, dynamic> objects = {
  "Jebena": {
    "image": "assets/jebena2.png",
    "description":
        """A Jebena is a traditional Ethiopian coffee pot used in the Ethiopian coffee ceremony. 
It is typically made from clay or ceramic, contributing to the unique flavor of the coffee 
produced in the ceremony. The Jebena features a round bottom, a long neck, and a spout for 
pouring. Adorned with decorative motifs, the Jebena is a key element in the rich cultural 
heritage of Ethiopia. Used in the coffee ceremony, it facilitates the multi-step process of
roasting, grinding, and brewing coffee to create a strong and flavorful beverage.
The ceremony itself symbolizes hospitality, community, and social connection in Ethiopian culture. 
The intricate designs on the Jebena often reflect the artisan's creativity and are passed down 
through generations, adding a sense of history to each piece. Jebenas are cherished not only for 
their functional use but also as beautiful artifacts representing Ethiopian heritage.""",
    "materials": ["clay", "leather", "woven grass"],
    "origin": "Ethiopia",
    "colors": ["brown", "black", "white"],
  },
  "Sini": {
    "image": "assets/Sini.jpg",
    "description":
        """The 'Sini' is an essential element in the Ethiopian coffee ceremony, serving as a traditional 
serving tray or platter. Crafted from materials such as wood, metal, or woven materials, 
the Sini is often round or oval-shaped with raised edges and adorned with intricate designs. 
Its primary function is to hold small handle-less cups, known as 'cini' or 'fincan,' during 
the coffee ceremony. Positioned alongside the central element, the 'Jebena,' on the Sini, 
freshly brewed coffee is poured into the cups, fostering a communal experience. Beyond its 
practical use, the Sini symbolizes the communal and social aspects of coffee consumption, 
embodying hospitality, friendship, and shared traditions in Ethiopian culture.
The artistry of the Sini lies not only in its functionality but also in the detailed craftsmanship 
that goes into its creation. Artisans meticulously carve or decorate Sinis with cultural symbols, 
geometric patterns, or scenes inspired by Ethiopian life. The use of locally sourced materials and 
techniques passed down through generations adds a unique touch to each Sini, making it a symbol 
of cultural richness and artistry.""",
    "materials": ["wood", "metal", "woven materials"],
    "origin": "Ethiopia",
    "colors": ["various"],
  },
};

class ProductItemScreen extends StatelessWidget {
  final String objectName;

  const ProductItemScreen({Key? key, required this.objectName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? selectedObject = objects[objectName];

    if (selectedObject == null) {
      return Scaffold(
        body: Center(
          child: Text("Object not found"),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.asset(selectedObject["image"]),
            ),
            buttonArrow(context),
            scroll(selectedObject),
          ],
        ),
      ),
    );
  }

  Widget buttonArrow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.transparent, // Set a transparent background
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget scroll(Map<String, dynamic> selectedObject) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 5,
                        width: 35,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                ),
                Text(
                  objectName,
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 42,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  selectedObject["description"],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Materials",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 18,
                  ),
                ).animate().fade(duration: 1000.ms).slideX(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedObject["materials"].map<Widget>((material) {
                    return Text(
                      "- $material",
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Origin",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 18,
                  ),
                ).animate().fade(duration: 1000.ms).slideX(),
                Text(
                  selectedObject["origin"],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Colors",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 18,
                  ),
                ).animate().fade(duration: 1000.ms).slideX(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedObject["colors"].map<Widget>((material) {
                    return Text(
                      "- $material",
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  }).toList(),
                ),
              ],
            ).animate().fade(duration: 1000.ms).slideX(),
          ),
        );
      },
    );
  }
}
