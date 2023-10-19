import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:carrent_admin/layout/cubit/cubit.dart';
import 'package:carrent_admin/layout/cubit/states.dart';
import 'package:carrent_admin/models/announce_model.dart';
import 'package:carrent_admin/models/complaint_model.dart';
import 'package:carrent_admin/models/process_model.dart';
import 'package:carrent_admin/shared/componants/complaints_card.dart';
import 'package:carrent_admin/shared/componants/constants.dart';
import 'package:carrent_admin/shared/componants/processes_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../shared/componants/global_method.dart';
import '../../shared/componants/snackbar.dart';

class AdminPage extends StatelessWidget {
  AdminPage({super.key});
  @override
  Widget build(BuildContext context) {
    final postFormKey = GlobalKey<FormState>();
    TextEditingController commentController = TextEditingController();
    TextEditingController aboutController = TextEditingController();

    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = MainCubit.get(context);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: QrImage(
                      data: cubit.qrCodeData,
                      version: QrVersions.min,
                      size: 360.0,
                      semanticsLabel: "Attendance QR Code",
                    ),
                  ),
                ),
                Text(
                  "Processes",
                  style: Constants.arabicTheme.textTheme.displayLarge!.copyWith(
                    color: Colors.black,
                    fontFamily: 'jannah',
                    fontSize: 20,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('processes')
                      .orderBy("requestDate", descending: true)
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
                              "No Processes",
                              style: Constants.arabicTheme.textTheme.bodyLarge!
                                  .copyWith(color: Colors.black),
                            )),
                          )
                        : SizedBox(
                            height: 390.0,
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data()!
                                        as Map<String, dynamic>;
                                    ProcessModel processModel =
                                        ProcessModel.fromJson(data);
                                    return Row(
                                      children: [
                                        if (snapshot.data!.docs.length <= 1)
                                          const SizedBox(width: 30),
                                        SizedBox(
                                          width: 350.0,
                                          child: ProcessesCard(
                                            processModel: processModel,
                                            show: false,
                                          ),
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
                Text(
                  "Complaints",
                  style: Constants.arabicTheme.textTheme.displayLarge!.copyWith(
                      color: Colors.black, fontSize: 20, fontFamily: 'jannah'),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .orderBy("date", descending: true)
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
                            child: Center(
                                child: Text(
                              "No Complaints",
                              style: Constants.arabicTheme.textTheme.bodyLarge!
                                  .copyWith(color: Colors.black),
                            )),
                          )
                        : SizedBox(
                            height: 200.0,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data()!
                                        as Map<String, dynamic>;
                                    ComplaintModel complaintModel =
                                        ComplaintModel.fromJson(data);
                                    return Row(
                                      children: [
                                        SizedBox(
                                          width: 350.0,
                                          child: ComplaintsCard(
                                            complaintModel: complaintModel,
                                          ),
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
        );
      },
    );
  }
}
