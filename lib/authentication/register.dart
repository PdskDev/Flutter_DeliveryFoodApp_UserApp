import 'dart:io';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../global/global.dart';
import '../mainScreens/home_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  //TextEditingController phoneController = TextEditingController();
  //TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();
  String userImageUrl = "";

  //Position? position;
  //List<Placemark>? placeMarks;
  //String? completeAddress = "";

  Future<void> _getImage() async {
    imageXFile =  await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  /*getCurrentLocation() async {
    await Geolocator.requestPermission();
    await Geolocator.checkPermission();

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,);
    position = newPosition;
    placeMarks = await placemarkFromCoordinates(position!.latitude, position!.longitude);

    Placemark pMark = placeMarks![0];
    completeAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';
    locationController.text = completeAddress!;
  }*/

  displayErrorMessage(message){
    return showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(message: message,);
        }
    );
  }

  Future<void> formValidation() async {
    if(imageXFile == null) {
      displayErrorMessage("Please select an image");
    }
    else {
      if(passwordController.text == confirmPasswordController.text){
        if(passwordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty
        && nameController.text.isNotEmpty && emailController.text.isNotEmpty
            //&& locationController.text.isNotEmpty && phoneController.text.isNotEmpty){
             ){
          //start uploading image to database
          showDialog(context: context, builder: (c){
           return const LoadingDialog(message: "Registering Account");
          });

          String fileName = DateTime.now().microsecondsSinceEpoch.toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref().child("users").child(fileName);
          fStorage.UploadTask uploadTask = reference.putFile(
              File(imageXFile!.path),
              fStorage.SettableMetadata(contentType: 'image/jpg'));
          fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url){
            userImageUrl = url;

            //Save data to firestore
            authenticateUserAndSignUp();
          });
        }
        else {
          displayErrorMessage("Please fill required field for registration");
        }
      }
      else {
        displayErrorMessage("Password do not match");
      }
    }
  }

  void authenticateUserAndSignUp() async {
    User? currentUser;
    await firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim())
    .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      displayErrorMessage(error.message.toString());
    });

    if(currentUser != null){
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //Send user to home page
        Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
      "userUID": currentUser.uid,
      "userEmail": currentUser.email,
      "userName": nameController.text.trim(),
      "userPhotoURL": userImageUrl,
      //"userPhone": phoneController.text.trim(),
      //"userAddress": completeAddress,
      "status": "approved",
      "earnings": 0.0
    });

    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("userUID", currentUser.uid);
    await sharedPreferences!.setString("userEmail", currentUser.email.toString());
    await sharedPreferences!.setString("userName", nameController.text.trim());
    await sharedPreferences!.setString("userPhotoURL", userImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 20,),
          InkWell(
            onTap: () {
              _getImage();
            } ,
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.20,
              backgroundColor: Colors.white,
              backgroundImage: imageXFile == null ? null : FileImage(File(imageXFile!.path)),
              child: imageXFile == null ?
              Icon(
                Icons.add_photo_alternate,
                size: MediaQuery.of(context).size.width * 0.20,
                color: Colors.grey,) : null
              ,
            ),
          ),
          const SizedBox(height: 10,),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  data: Icons.person,
                  isObscure: false,
                  enabled: true,
                  hintText: "Name",
                  controller: nameController,
                ),
                CustomTextField(
                  data: Icons.email,
                  isObscure: false,
                  enabled: true,
                  hintText: "E-mail",
                  controller: emailController,
                ),
               /* CustomTextField(
                  data: Icons.phone,
                  isObscure: false,
                  enabled: true,
                  hintText: "Phone",
                  controller: phoneController,
                ),*/
                CustomTextField(
                  data: Icons.lock,
                  isObscure: true,
                  enabled: true,
                  hintText: "Password",
                  controller: passwordController,
                ),
                CustomTextField(
                  data: Icons.lock,
                  isObscure: true,
                  enabled: true,
                  hintText: "Confirm password",
                  controller: confirmPasswordController,
                ),
               /* CustomTextField(
                  data: Icons.my_location,
                  isObscure: false,
                  enabled: false,
                  hintText: "My Current address",
                  controller: locationController,
                ),*/
                /*Container(
                  width: 400,
                  height: 40,
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Get My Current Location",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {getCurrentLocation();},
                  ),
                )*/
              ],
            ),
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
              Icons.app_registration,
              color: Colors.white,
            ),
            label: const Text(
              "Sign Up",
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
    );
  }
}
