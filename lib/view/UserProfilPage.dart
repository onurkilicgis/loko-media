import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loko_media/view_model/layout.dart';
import 'package:loko_media/services/auth.dart';

class UserProfilePage extends StatefulWidget {
  final String uid;
  final String img;

  UserProfilePage({required this.uid,required this.img});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late String name;
 late String imageUrl;
  final nameController = TextEditingController();
  final picker = ImagePicker();
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });

      final storageRef =
      FirebaseStorage.instance.ref().child('user_profile/${widget.uid}');
      final task = storageRef.putFile(File(pickedFile.path));
      final snapshot = await task.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      setState(() {
        imageUrl = url;
        isLoading = false;
      });
    }
  }

  Future updateUser(String name,String imageUrl) async {
    var user= await _auth.currentUser;
    user?.updateDisplayName(name);
    imageUrl = "https://www.diyadinnet.com/img/2022/05/tunceli-drone-ovacik-daglarinda-kis-ovalarinda-bahar-guzelligi-yasaniyor.jpg";
    user?.updatePhotoURL(imageUrl);
   setState(() {
     isLoading=false;
   });
  }

  @override
  void initState() {
    super.initState();
   imageUrl=widget.img;

   /* final userRef = FirebaseFirestore.instance.collection('users').doc(widget.uid);

     userRef.get().then((doc) {
      setState(() {
        name = doc.data()!['name'];
        imageUrl = doc.data()!['imageUrl'];
      });
      nameController.text = name;
    }).catchError((err){
       print('HATA'+err.toString());
     });*/


  }

  @override
   build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

          Stack(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        imageUrl),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () {
                      pickImage();
                    },
                  ),
                ),
              ),
            ],
          ),

          /*GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60.0,
                backgroundImage:
                     NetworkImage(imageUrl),
               // backgroundColor: Colors.transparent,


              ),
            ),*/
            SizedBox(height: 30.0),
            TextFormField(
              cursorColor: const Color(0xff017eba),
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                  labelStyle: TextStyle(
                      color: Theme.of(context).listTileTheme.iconColor,
                      fontSize: context.dynamicWidth(28)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).listTileTheme.iconColor!,
                      )),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).listTileTheme.iconColor!,
                      )),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32.0),
            SizedBox(
              height:50,
              width: 400,
              child: ElevatedButton(
                onPressed:() async{

              isLoading ? null :  await updateUser(nameController.text,imageUrl);


              },
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text("Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
