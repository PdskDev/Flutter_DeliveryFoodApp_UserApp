import 'package:flutter/material.dart';
import 'package:users_app/global/global.dart';

import '../authentication/auth_screen.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 25, bottom: 10),
            child: Column(
              children: [
                //Header
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(80)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Container(
                      height: 160,
                      width: 160,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(sharedPreferences!.getString("userPhotoURL")!),
                        foregroundColor: Colors.grey,
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Text(sharedPreferences!.getString("userName")!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: "Acme"
                )),
              ],

            ),
          ),
          const SizedBox(height: 12,),
          Container(
            padding: const EdgeInsets.only(top: 1.0),
            child: Column(
              children: [
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.black,),
                  title: const Text(
                    "Home", style: TextStyle(color: Colors.black),
                  ),
                  onTap: (){

                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.reorder, color: Colors.black,),
                  title: const Text(
                    "My Orders", style: TextStyle(color: Colors.black),
                  ),
                  onTap: (){

                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.black,),
                  title: const Text(
                    "History", style: TextStyle(color: Colors.black),
                  ),
                  onTap: (){

                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.search, color: Colors.black,),
                  title: const Text(
                    "Search", style: TextStyle(color: Colors.black),
                  ),
                  onTap: (){

                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.add_location, color: Colors.black,),
                  title: const Text(
                    "Add New Address", style: TextStyle(color: Colors.black),
                  ),
                  onTap: (){

                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.black,),
                  title: const Text(
                    "Sign Out", style: TextStyle(color: Colors.black),
                  ),
                  onTap: (){
                    firebaseAuth.signOut().then((value) {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
                    });
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
              ],
            ),

          )
        ],
      ),
    );
  }
}
