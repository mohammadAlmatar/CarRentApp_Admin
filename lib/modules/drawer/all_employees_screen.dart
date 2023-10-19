import 'package:carrent_admin/layout/cubit/cubit.dart';
import 'package:carrent_admin/layout/cubit/states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/employeeModel.dart';
import '../../shared/componants/constants.dart';
import '../../shared/styles/icon_brokin.dart';
import '../delivery/delivery_screen.dart';

class AllEmployees extends StatelessWidget {
  AllEmployees({super.key});
  var searchController1 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = MainCubit.get(context);
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('All Employees'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: 340,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade100),
                        child: TextField(
                          controller: searchController1,
                           keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => cubit.refresh(),
                          decoration: const InputDecoration(
                            hintText: 'Search an employee',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            prefixIcon: Icon(
                              IconBroken.Search,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (Constants.employeeModel!.userType == "JobTypes.ADMIN")
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('companyUsers')
                          .where('name', isNotEqualTo: 'Mohammad Almatar')
                          .where('name',
                              isGreaterThanOrEqualTo:
                                  searchController1.text.trim())
                          .where('name',
                              isLessThan: '${searchController1.text.trim()}z',)
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

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                  "No't found Employees",
                                  style: Constants
                                      .arabicTheme.textTheme.bodyLarge!
                                      .copyWith(color: Colors.black),
                                )),
                              )
                            : Column(
                                children: [
                                  ListView(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    children: snapshot.data!.docs
                                        .map((DocumentSnapshot document) {
                                          Map<String, dynamic> data = document
                                              .data()! as Map<String, dynamic>;
                                          EmployeeModel employeeModel =
                                              EmployeeModel.fromJson(data);
                                          return Column(
                                            children: [
                                              SizedBox(
                                                width: 335.0,
                                                child: BuildDeliveryWidget(
                                                  employeeModel: employeeModel,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          );
                                        })
                                        .toList()
                                        .cast(),
                                  ),
                                ],
                              );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
