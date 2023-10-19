import 'package:carrent_admin/layout/cubit/cubit.dart';
import 'package:carrent_admin/layout/cubit/states.dart';
import 'package:carrent_admin/modules/delivery/delivery_profile_screen.dart';
import 'package:carrent_admin/shared/componants/componants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/employeeModel.dart';
import '../../shared/componants/constants.dart';
import '../../shared/styles/icon_brokin.dart';
import '../delivery/delivery_screen.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    return BlocConsumer<MainCubit, MainStates>(
      builder: (context, state) {
        var cubit = MainCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Attendance'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 25),
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
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Search an employee',
                            
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
                          onPressed: () async {
                            String email = searchController.text.trim();
                            try {
                              CollectionReference companyUsersCollection =
                                  FirebaseFirestore.instance
                                      .collection('companyUsers');

                              QuerySnapshot querySnapshot =
                                  await companyUsersCollection
                                      .where(
                                        'email',
                                        isEqualTo: email,
                                      )
                                      .get();

                              if (querySnapshot.docs.isEmpty) {
                                print(
                                    'No company user found with the email: $email');
                                return;
                              }

                              // Access the first document in the query results
                              DocumentSnapshot documentSnapshot =
                                  querySnapshot.docs[0];

                              // Retrieve the data of the company user document
                              Map<String, dynamic> userData = documentSnapshot
                                  .data() as Map<String, dynamic>;
                              EmployeeModel employeeModel =
                                  EmployeeModel.fromJson(userData);
                              searchController.clear();
                              navigateTo(
                                context,
                                DeliveryProfileScreen(
                                  employeeModel: employeeModel,
                                ),
                              );
                            } catch (e) {
                              print(
                                  'Error searching for company user by email: $e');
                            }
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
                    height: 50,
                  ),
                  Text(
                    "Absent Employees :",
                    style: Constants.arabicTheme.textTheme.displayLarge!.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'jannah',
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('companyUsers')
                        .where("userType", isEqualTo: "JobTypes.EMPLOYEE")
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

                      // Filter the documents to exclude those where 'attendanceSchedule' array contains cubit.qrCodeData
                      final filteredDocs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final attendanceSchedule =
                            data['attendanceSchedule'] as List<dynamic>;
                        return !attendanceSchedule.contains(cubit.qrCodeData);
                      }).toList();

                      return filteredDocs.isEmpty
                          ? SizedBox(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Text(
                                    "No Absent Employees",
                                    style: Constants
                                        .arabicTheme.textTheme.bodyLarge!
                                        .copyWith(color: Colors.black),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 100.0,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                children: filteredDocs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  EmployeeModel employeeModel =
                                      EmployeeModel.fromJson(data);
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 335.0,
                                        child: BuildDeliveryWidget(
                                          employeeModel: employeeModel,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                    },
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Attended Employees :",
                    style:
                        Constants.arabicTheme.textTheme.displayLarge!.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'jannah',
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('companyUsers')
                        .where("userType", isEqualTo: "JobTypes.EMPLOYEE")
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

                      // Filter the documents to exclude those where 'attendanceSchedule' array contains cubit.qrCodeData
                      final filteredDocs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final attendanceSchedule =
                            data['attendanceSchedule'] as List<dynamic>;
                        return attendanceSchedule.contains(cubit.qrCodeData);
                      }).toList();

                      return filteredDocs.isEmpty
                          ? SizedBox(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Text(
                                    "No Attended Employees",
                                    style: Constants
                                        .arabicTheme.textTheme.bodyLarge!
                                        .copyWith(color: Colors.black),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 100.0,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                children: filteredDocs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  EmployeeModel employeeModel =
                                      EmployeeModel.fromJson(data);
                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: 340.0,
                                        child: BuildDeliveryWidget(
                                          employeeModel: employeeModel,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      listener: (context, state) {},
    );
  }
}
