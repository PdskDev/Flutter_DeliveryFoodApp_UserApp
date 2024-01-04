import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import '../mainScreens/home_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';
import 'auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  displayErrorMessage(message){
    return showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(message: message,);
        }
    );
  }

  Future<void> formValidation() async {
        if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty){
          loginNow();
        }
        else {
          displayErrorMessage("Please enter your credentials");
        }
  }

  loginNow() async {
    showDialog(context: context, builder: (c){
      return const LoadingDialog(message: "Checking credentials");
    });

    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim())
        .then((auth)
    {
      currentUser = auth.user!;
    }).catchError((error)
    {
      Navigator.pop(context);
      displayErrorMessage(error.message.toString());
    });

    if(currentUser !=  null){
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance.collection("users")
        .doc(currentUser.uid).get()
        .then((snapshot) async {

          if(snapshot.exists){
            await sharedPreferences!.setString("userUID", currentUser.uid);
            await sharedPreferences!.setString("userEmail", snapshot.data()!["userEmail"]);
            await sharedPreferences!.setString("userName", snapshot.data()!["userName"]);
            await sharedPreferences!.setString("userPhotoURL", snapshot.data()!["userPhotoURL"]);

            if (!mounted) return;

            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
          }
          else {
            firebaseAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
            displayErrorMessage("User account not exist !");
          }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset("images/login.png", height: 270),
            ),

          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.email,
                  isObscure: false,
                  enabled: true,
                  hintText: "E-mail",
                  controller: emailController,
                ),
                CustomTextField(
                  data: Icons.lock,
                  isObscure: true,
                  enabled: true,
                  hintText: "Password",
                  controller: passwordController,
                ),
                const SizedBox(height:10,),
                /*ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
            ),
            child: const Text(
              "Sign Up",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
            ),
            onPressed: () => print("Clicked"),
          ),*/
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    formValidation();

                  },
                ),
                const SizedBox(height:20,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
