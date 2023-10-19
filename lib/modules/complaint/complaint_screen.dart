import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../layout/cubit/cubit.dart';
import '../../layout/cubit/states.dart';
import '../../models/announce_model.dart';
import '../../shared/componants/constants.dart';
import '../../shared/componants/global_method.dart';
import '../../shared/componants/snackbar.dart';
import '../../shared/styles/icon_brokin.dart';

class ComplaintScreen extends StatelessWidget {
  ComplaintScreen({super.key});
  var contentsInfo = const TextStyle(
      fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black45);
  late TextEditingController aboutController = TextEditingController(text: '');
  final postFormKey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = MainCubit.get(context);
        return Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  IconBroken.Arrow___Left_2,
                  color: Colors.black,
                  size: 25,
                ),
              ),
              ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 75,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.grey.shade100,
                    shadowColor: Colors.blue.shade200,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Uploaded by',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.deepOrange,
                                  ),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      Constants.usersModel!.image!,
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Constants.usersModel!.name!),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Submit An Announcement :',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: cubit.isCommenting
                                ? Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Flexible(
                                            flex: 3,
                                            child: Form(
                                              key: postFormKey,
                                              child: Column(
                                                children: [
                                                  TextFormField(
                                                    controller: aboutController,
                                                    style: const TextStyle(
                                                      color: Colors.brown,
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    maxLines: 1,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Theme.of(
                                                              context)
                                                          .scaffoldBackgroundColor,
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      errorBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.red),
                                                      ),
                                                      focusedBorder:
                                                          const OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.pink),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  TextField(
                                                    maxLength: 200,
                                                    controller:
                                                        commentController,
                                                    style: const TextStyle(
                                                      color: Colors.brown,
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    maxLines: 6,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Theme.of(
                                                              context)
                                                          .scaffoldBackgroundColor,
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      errorBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.red),
                                                      ),
                                                      focusedBorder:
                                                          const OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.pink),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.only(top: 0,left: 8,right: 8),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  MaterialButton(
                                                    onPressed: () async {
                                                      if (commentController
                                                              .text.isEmpty ||
                                                          commentController
                                                                  .text.length <
                                                              7) {
                                                        snackBar(
                                                          context: context,
                                                          contentType:
                                                              ContentType
                                                                  .failure,
                                                          title:
                                                              "invalid announcement !!",
                                                          body:
                                                              "Message can 't be less than 7 characters",
                                                        );
                                                      } else {
                                                        DocumentReference
                                                            docRef =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'adminAnnounces')
                                                                .doc();
                                                        AnnounceModel announce =
                                                            AnnounceModel(
                                                          date: Timestamp
                                                              .fromDate(DateTime
                                                                  .now()),
                                                          announcerEmail:
                                                              Constants
                                                                  .usersModel!
                                                                  .email,
                                                          announcerNumber:
                                                              Constants
                                                                  .usersModel!
                                                                  .phone,
                                                          announce:
                                                              commentController
                                                                  .text
                                                                  .trim(),
                                                          announceAbout:
                                                              aboutController
                                                                  .text
                                                                  .trim(),
                                                          announceId: docRef.id,
                                                        );
                                                        docRef
                                                            .set(announce
                                                                .toJson())
                                                            .then(
                                                                (value) async {
                                                          snackBar(
                                                            context: context,
                                                            contentType:
                                                                ContentType
                                                                    .success,
                                                            title: 'Success',
                                                            body:
                                                                'Announce uploaded successfully',
                                                          );

                                                          await MainCubit
                                                                  .get(context)
                                                              .sendNotification(
                                                                  context:
                                                                      context,
                                                                  title:
                                                                      'Announce!',
                                                                  body:
                                                                      'about : ${aboutController.text.trim()}',
                                                                  receiver:
                                                                      'users');
                                                          commentController
                                                              .clear();
                                                          MainCubit.get(context)
                                                              .currentIndex = 0;
                                                          MainCubit.get(context)
                                                              .refresh();
                                                        }).onError((error,
                                                                stackTrace) {
                                                          print(error);
                                                          snackBar(
                                                              context: context,
                                                              contentType:
                                                                  ContentType
                                                                      .failure,
                                                              title: 'Failure',
                                                              body:
                                                                  'Announce is not uploaded');
                                                        });
                                                      }
                                                    },
                                                    color: Colors.blue,
                                                    elevation: 10,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              13),
                                                      side: BorderSide.none,
                                                    ),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 14),
                                                      child: Text(
                                                        'Send',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        cubit
                                                            .changeIscommenting();
                                                      },
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: MaterialButton(
                                      onPressed: () {
                                        cubit.changeIscommenting();
                                      },
                                      color: Colors.blue,
                                      elevation: 10,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13),
                                        side: BorderSide.none,
                                      ),
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 14),
                                        child: Text(
                                          'Add a complaint',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
