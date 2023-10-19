import 'dart:async';
import 'dart:convert';

import 'package:carrent_admin/layout/cubit/cubit.dart';
import 'package:carrent_admin/models/car_model/car_model.dart';
import 'package:carrent_admin/models/employeeModel.dart';
import 'package:carrent_admin/models/process_model.dart';
import 'package:carrent_admin/models/siginup_model/users_model.dart';
import 'package:carrent_admin/modules/map_tracking/map_tracking.dart';
import 'package:carrent_admin/modules/signin/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../shared/componants/constants.dart';
import 'delivery_states.dart';

class DeliveryCubit extends Cubit<DeliveryStates> {
  DeliveryCubit() : super(DeliveryInitialState());

  static DeliveryCubit get(context) => BlocProvider.of(context);
  initializeDeliveryCubit() async {
    await getEmployeeData();
    await getCurrentLocation();
    await getProcessData();
    await getUserByEmail(processModel!.clientEmail!);
    await getCarById();
    reportController = TextEditingController();
  }

  late TextEditingController reportController;
  String reportField = "";
  getEmployeeData() async {
    print("e1");
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("companyUsers")
        .doc(uId)
        .get();
    print("e2");
    if (snapshot.exists) {
      print("e3");
      Map<String, dynamic> data = snapshot.data()!;
      print("e4");
      Constants.employeeModel = EmployeeModel.fromJson(data);
      print("e5");
      extractCoordinates(Constants.employeeModel!.assignedProcessLocation!);
      print("e6");
      emit(DeliveryGottenSuccessfully());
    } else {
      // Handle document not found scenario
      emit(DeliveryGottenUnSuccessfully());
    }
  }

  Position currentLocation = Position(
    latitude: 36.16571412472137,
    longitude: 37.1262037238395,
    accuracy: 10.0,
    speed: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speedAccuracy: 0.0,
    timestamp: DateTime.now(),
    floor: null,
    isMocked: false,
  );
  Completer<GoogleMapController> gmapsController = Completer();

  Future<void> getCurrentLocation() async {
    try {
      Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      currentLocation = newPosition;
      print('Current Location: $currentLocation');

      final Query<Map<String, dynamic>> tripDocRef = FirebaseFirestore.instance
          .collection('companyUsers')
          .where('email', isEqualTo: Constants.employeeModel!.email)
          .where('userType', isEqualTo: "JobTypes.DELIVERY");

      QuerySnapshot<Map<String, dynamic>> tripSnapshot = await tripDocRef.get();
      if (tripSnapshot.docs.isNotEmpty) {
        final List<DocumentSnapshot<Map<String, dynamic>>> trips =
            tripSnapshot.docs;
        for (final trip in trips) {
          final tripDocRef = trip.reference;
          await tripDocRef.update({'locationData': '$currentLocation'});
        }
      } else {
        // Handle empty case
      }
    } catch (e) {
      print("Catch Error : $e");
    }

    GoogleMapController googleMapController = await gmapsController.future;
    Geolocator.getPositionStream().listen((newPosition) async {
      currentLocation = newPosition;
      print('Location Update: $currentLocation');
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(newPosition.latitude, newPosition.longitude),
            zoom: 13.5,
          ),
        ),
      );
      final Query<Map<String, dynamic>> tripDocRef = FirebaseFirestore.instance
          .collection('companyUsers')
          .where('email', isEqualTo: Constants.employeeModel!.email)
          .where('userType', isEqualTo: "JobTypes.DELIVERY");

      QuerySnapshot<Map<String, dynamic>> tripSnapshot = await tripDocRef.get();
      if (tripSnapshot.docs.isNotEmpty) {
        final List<DocumentSnapshot<Map<String, dynamic>>> trips =
            tripSnapshot.docs;
        for (final trip in trips) {
          final tripDocRef = trip.reference;
          await tripDocRef.update({'locationData': '$currentLocation'});
        }
        emit(UpdatingCurrentLocation());
      }
    });
  }

  Future<void> displayOkorNotOkForRespnose(context) async {
    var cubit = DeliveryCubit.get(context);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Finished ?"),
        elevation: 5,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("No"),
          ),
          TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("companyUsers")
                    .doc(Constants.employeeModel!.uId)
                    .update({
                  "isAvailable": true,
                  "assignedProcessId": "",
                  "assignedProcessLocation": "",
                }).then((value) {
                  FirebaseFirestore.instance
                      .collection("processes")
                      .doc(Constants.employeeModel!.assignedProcessId)
                      .update({
                    "requestStatus": "RequestStatus.DELIVERED",
                    "receivingDate": DateTime.now().toString(),
                    "deliveryId": "",
                  }).then((value) async {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(cubit.clientModel!.uId)
                        .collection('cart')
                        .add(
                          cubit.carModel!.toJson(),
                        );
                    if (cubit.carModel!.isUsed! == false) {
                      FirebaseFirestore.instance
                          .collection('cars')
                          .doc(cubit.processModel!.carId)
                          .delete();
                    } else {
                      DateTime currentDateTime = DateTime.now();
                      DateFormat format =
                          DateFormat("MMMM d, yyyy 'at' h:mm:ss a 'UTC'Z");
                      String timestampString = format.format(currentDateTime);

                      FirebaseFirestore.instance
                          .collection('cars')
                          .doc(cubit.processModel!.carId)
                          .update({
                        'carStatus': 'CarStatus.RENTED',
                        'requestDate': timestampString,
                      }).then((value) {
                        Navigator.of(context).pop();
                      });
                    }
                    await MainCubit.get(context).sendNotification(
                        context: context,
                        title: 'Done ..',
                        body: 'Car is Home',
                        receiver: 'admin');
                    // ignore: use_build_context_synchronously
                    await MainCubit.get(context).sendNotification(
                      context: context,
                      title: 'Done ..',
                      body: 'Car is Home',
                      receiver: cubit.processModel!.clientNumber!,
                    );
                  }).catchError((onError) {});
                }).catchError((onError) {
                  print(onError);
                });
              },
              child: const Text("Yes")),
        ],
      ),
    );
  }

  Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Do you want to report a problem ?'),
            content: TextField(
              onChanged: (value) {
                reportField = value;
              },
              controller: reportController,
              decoration: const InputDecoration(hintText: "write here ..."),
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: () => Navigator.pop(context),
                color: Colors.redAccent,
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  emit(UpdatingCurrentLocation());
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Do You Want To Cancel The Delivery ?"),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              await MainCubit.get(context).sendNotification(
                                  context: context,
                                  title: 'Problem',
                                  body: reportField,
                                  receiver: 'admin');
                              // ignore: use_build_context_synchronously
                              navigateAndFinish(context, const MapTracking());
                            },
                            child: const Text("No")),
                        TextButton(
                            onPressed: () {
                              sendNotification(context);
                              FirebaseFirestore.instance
                                  .collection("companyUsers")
                                  .doc(Constants.employeeModel!.uId)
                                  .update({
                                "isAvailable": true,
                                "assignedProcessId": '',
                                "assignedProcessLocation": '',
                              }).then((value) {
                                FirebaseFirestore.instance
                                    .collection("processes")
                                    .doc(Constants
                                        .employeeModel!.assignedProcessId)
                                    .update({
                                  "requestStatus": "RequestStatus.APPROVED",
                                }).then((value) async {
                                  await MainCubit.get(context).sendNotification(
                                      context: context,
                                      title: 'Problem',
                                      body: reportField,
                                      receiver: 'admin');
                                  // ignore: use_build_context_synchronously
                                  await MainCubit.get(context).sendNotification(
                                      context: context,
                                      title: 'Problem',
                                      body: reportField,
                                      receiver: processModel!.clientNumber!);
                                  // ignore: use_build_context_synchronously
                                  navigateAndFinish(context, SignInScreen());
                                }).catchError((onError) {
                                  print(onError);
                                });
                              }).catchError((onError) {
                                print(onError);
                              });
                            },
                            child: const Text("Yes")),
                      ],
                    ),
                  );
                },
                color: Colors.green,
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          );
        });
  }

  bool isLoading = false;
  changeLoadingState() {
    isLoading = !isLoading;
    emit(UpdatingCurrentLocation());
  }

  double latitude = 0;
  double longitude = 0;
  void extractCoordinates(String input) {
    final regex = RegExp(
        r'(-?\d+(?:\.\d+)?)'); // Regular expression pattern to match decimal numbers
    final matches = regex.allMatches(input);
    if (matches.length >= 2) {
      latitude = double.tryParse(matches.elementAt(0).group(0) ?? '')!;
      longitude = double.tryParse(matches.elementAt(1).group(0) ?? '')!;
    }

    print('Latitude: $latitude');
    print('Longitude: $longitude');
  }

  Future<void> sendNotification(BuildContext context) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm:ss').format(now);
    Map<String, dynamic> data = {
      "alertTime": formattedDate,
      "location": currentLocation.toString(),
      "deliveryNumber": Constants.employeeModel!.phone,
      "deliveryEmail": Constants.employeeModel!.email,
      "processId": Constants.employeeModel!.assignedProcessId,
      "report-content": reportField,
    };
    await http
        .post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.fcmServerKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': "a problem ocurred",
            'title': "Any Problem?"
          },
          'priority': 'high',
          'data': data,
          'to': "/topics/all",
        },
      ),
    )
        .then((value) async {
      print(value.statusCode);
      print("=========done=========");
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('notifications').doc();
      data.putIfAbsent("notificationId", () => docRef.id);
      docRef.set(data);
      if (value.statusCode == 200) {
      } else {
        print("=========false=========");
      }
    }).catchError((onError) {
      print(onError);
    });
    emit(UpdatingCurrentLocation());
    reportController.clear();
  }

  ProcessModel? processModel;
  Future<void> getProcessData() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('processes')
        .doc(Constants.employeeModel!.assignedProcessId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      processModel = ProcessModel.fromJson(data);
      emit(UpdatingCurrentLocation());
    }
  }

  UsersModel? clientModel;
  Future<void> getUserByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.size > 0) {
        var userData = snapshot.docs[0].data();
        clientModel = UsersModel.fromJson(userData as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  CarModel? carModel;
  Future<void> getCarById() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cars')
          .where('carId', isEqualTo: processModel!.carId)
          .limit(1)
          .get();

      if (snapshot.size > 0) {
        var userData = snapshot.docs[0].data();
        carModel = CarModel.fromJson(userData as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error retrieving car data: $e');
    }
  }
}
