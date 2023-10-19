import 'package:carrent_admin/modules/admin_page/employee_control/add_cubit.dart';
import 'package:carrent_admin/modules/admin_page/employee_control/admin_states.dart';
import 'package:carrent_admin/shared/componants/reusable_button.dart';
import 'package:carrent_admin/shared/componants/reusable_form_field.dart';
import 'package:carrent_admin/shared/styles/icon_brokin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

class DeleteEmployeeScreen extends StatelessWidget {
  const DeleteEmployeeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCubit, AdminStates>(listener: (context, state) {
      if (state is EmployeeCrDeleteSuccessState) {
        Navigator.pop(context);
      }
    }, builder: (context, state) {
      var cubit = AddCubit.get(context);
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Fire Employee'),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                child: Form(
                  key: cubit.formState,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ReusableFormField(
                        isPassword: false,
                        icon: const Icon(IconBroken.Message),
                        checkValidate: (value) {
                          if (value!.isEmpty) {
                            return 'Email must not be empty';
                          }
                          final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                        },
                        controller: cubit.deleteEmailController,
                        hint: 'Enter Email',
                        keyType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      ReUsableButton(
                        onPressed: () {
                          if (cubit.formState.currentState!.validate()) {
                            cubit.deleteDocumentByEmail();
                          }
                        },
                        height: 20,
                        width: 200,
                        radius: 20,
                        text: "Fire Employee",
                        colour: Colors.redAccent,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              )
            ],
          ),
        )),
      );
    });
  }
}
