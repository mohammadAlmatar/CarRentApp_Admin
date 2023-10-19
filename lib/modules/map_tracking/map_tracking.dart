import 'package:carrent_admin/layout/cubit/cubit.dart';
import 'package:carrent_admin/modules/map_tracking/delivery_cubit.dart';
import 'package:carrent_admin/modules/map_tracking/report_screen.dart';
import 'package:carrent_admin/shared/componants/componants.dart';
import 'package:carrent_admin/shared/componants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'delivery_states.dart';

class MapTracking extends StatelessWidget {
  const MapTracking({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryCubit, DeliveryStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = DeliveryCubit.get(context);
        return ModalProgressHUD(
          inAsyncCall: cubit.isLoading,
          child: Scaffold(
            body: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      cubit.currentLocation.latitude,
                      cubit.currentLocation.longitude,
                    ),
                    zoom: 13.5,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("Bus Current Location"),
                      position: LatLng(cubit.currentLocation.latitude,
                          cubit.currentLocation.longitude),
                    ),
                    Marker(
                      markerId: const MarkerId("Specified Location"),
                      position: LatLng(cubit.latitude, cubit.longitude),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("Route"),
                      color: Colors.blue,
                      width: 5,
                      points: [
                        LatLng(cubit.currentLocation.latitude,
                            cubit.currentLocation.longitude),
                        LatLng(cubit.latitude, cubit.longitude),
                      ],
                    ),
                  },
                  onMapCreated: (mapController) {
                    cubit.gmapsController.complete(mapController);
                  },
                ),
                Positioned(
                  right: 0,
                  left: 0,
                  top: 0,
                  child: Container(
                    height: 100,
                    color: Colors.black54,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                            cubit.displayOkorNotOkForRespnose(context);
                            },
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.black54),
                            ),
                            child: Text(
                              "Delivered",
                              style: Constants
                                  .arabicTheme.textTheme.displayMedium!
                                  .copyWith(height: 5),
                            ),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 0,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                cubit.displayTextInputDialog(context),
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.black54),
                            ),
                            child: Text(
                              "report",
                              style: Constants
                                  .arabicTheme.textTheme.displayMedium!
                                  .copyWith(height: 5),
                            ),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 0,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => navigateTo(
                                context,
                                ProcessDetails(
                                    processModel: cubit.processModel!)),
                            style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.black54),
                            ),
                            child: Text(
                              "view details",
                              style: Constants
                                  .arabicTheme.textTheme.displayMedium!
                                  .copyWith(height: 5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    bottom: 10,
                    left: 10,
                    child: SizedBox(
                      width: 150,
                      child: OutlinedButton(
                          onPressed: () {
                            MainCubit.get(context)
                                .logoutAndNavigateToSignInScreen(context);
                          },
                          child: const Text("LogOut")),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
