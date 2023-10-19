import 'package:carrent_admin/modules/home/open_product.dart';
import 'package:carrent_admin/modules/home/search_screen.dart';
import 'package:carrent_admin/modules/upload/update_product_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import '../../models/car_model/car_model.dart';
import '../../shared/componants/componants.dart';
import '../../shared/componants/constants.dart';
import '../../shared/styles/icon_brokin.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  var searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: 275,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search Products',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          IconBroken.Search,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.black,
                    child: IconButton(
                      onPressed: () {
                        navigateTo(
                          context,
                          CarSearchWidget(
                            searchQuery: searchController.text.trim(),
                          ),
                        );
                      },
                      icon: const Icon(
                        IconBroken.Filter,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Newly added cars',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'jannah',
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cars')
                    .where('carStatus', isEqualTo: 'CarStatus.AVAILABLE')
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Something is Wrong',
                      style: Constants.arabicTheme.textTheme.bodyLarge!
                          .copyWith(color: Colors.black),
                    );
                  }
      
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }
      
                  return snapshot.data!.docs.isEmpty
                      ? SizedBox(
                          height: 250,
                          child: Center(
                              child: Text(
                            "No Newly Added Cars",
                            style: Constants.arabicTheme.textTheme.bodyLarge!
                                .copyWith(color: Colors.black),
                          )),
                        )
                      : SizedBox(
                          height: 220.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;
                                  CarModel carModel = CarModel.fromJson(data);
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 350.0,
                                        child: CarCard(carModel: carModel),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  );
                                })
                                .toList()
                                .cast(),
                          ),
                        );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Cars for buy',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'jannah',
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cars')
                    .where("isUsed", isEqualTo: false)
                    .where('carStatus', isEqualTo: 'CarStatus.AVAILABLE')
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Something is Wrong',
                      style:
                          Constants.arabicTheme.textTheme.bodyLarge!.copyWith(
                        color: Colors.black,
                      ),
                    );
                  }
      
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }
      
                  return snapshot.data!.docs.isEmpty
                      ? SizedBox(
                          height: 250,
                          child: Center(
                              child: Text(
                            "No New Cars",
                            style: Constants.arabicTheme.textTheme.bodyLarge!
                                .copyWith(
                              color: Colors.black,
                            ),
                          )),
                        )
                      : SizedBox(
                          height: 220.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;
                                  CarModel carModel = CarModel.fromJson(data);
      
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 350.0,
                                        child: CarCard(carModel: carModel),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  );
                                })
                                .toList()
                                .cast(),
                          ),
                        );
                },
              ),
             const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Cars for rent',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'jannah',
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cars')
                    .where("isUsed", isEqualTo: true)
                    .where('carStatus', isEqualTo: 'CarStatus.AVAILABLE')
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Something is Wrong',
                      style: Constants.arabicTheme.textTheme.bodyLarge!
                          .copyWith(color: Colors.black),
                    );
                  }
      
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }
                  return snapshot.data!.docs.isEmpty
                      ? SizedBox(
                          height: 250,
                          child: Center(
                              child: Text(
                            "No Used Cars",
                            style: Constants.arabicTheme.textTheme.bodyLarge!
                                .copyWith(color: Colors.black),
                          )),
                        )
                      : SizedBox(
                          height: 220.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;
                                  CarModel carModel = CarModel.fromJson(data);
                                  DateTime now = DateTime.now();
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd HH:mm:ss.SSS')
                                          .format(now);
                                  print('Current Date: $formattedDate');
                                  print(
                                      'Offer Expiration Date: ${carModel.offerExpirationDate}');
                                  if (formattedDate.compareTo(
                                          carModel.offerExpirationDate!) >
                                      0) {
                                    print('Offer expired');
                                    FirebaseFirestore.instance
                                        .collection('cars')
                                        .doc(carModel.carId)
                                        .update({
                                      "priceAfterOffer": carModel.price,
                                      "offerPercentage": '',
                                      "offerExpirationDate": '',
                                      "isOffered": false,
                                    });
                                  } else {
                                    print('Offer still valid');
                                  }
      
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 350.0,
                                        child: CarCard(carModel: carModel),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  );
                                })
                                .toList()
                                .cast(),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.carModel,
  });
  final CarModel carModel;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OpenProductScreen(
            carModel: carModel,
          ),
        ));
      },
      child: Stack(
        children: [
          Container(
            height: 190,
            width: 340,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: HexColor('#d28a7c'),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CarName : ${carModel.branch!}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  carModel.isOffered! == true
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Price: ${carModel.price!} \$",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                decoration: TextDecoration
                                    .lineThrough, // Add line-through decoration
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Offer: ${carModel.priceAfterOffer!} \$",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Price: ${carModel.price!} \$",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            ),
          ),
          Container(
            height: 150,
            width: 340,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                width: 0.7,
                color: Colors.black,
              ),
              image: DecorationImage(
                image: NetworkImage(carModel.imageFiles![0]),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  alignment: Alignment.topLeft,
                  onPressed: () {
                    navigateTo(
                      context,
                      UpdateProductScreen(
                        carModel: carModel,
                      ),
                    );
                  },
                  icon: const Icon(
                    IconBroken.Edit,
                    size: 25,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  alignment: Alignment.topLeft,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title:
                            const Text("Do you want to delete this product ?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                "No",
                                style: TextStyle(color: Colors.red),
                              )),
                          TextButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection("cars")
                                    .doc(carModel.carId)
                                    .delete();
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "Yes",
                                style: TextStyle(color: Colors.blue),
                              )),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
                    IconBroken.Delete,
                    size: 25,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
