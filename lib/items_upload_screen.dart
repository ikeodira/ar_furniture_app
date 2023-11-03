import 'dart:typed_data';
import 'package:ar_furniture_app/api_consumer.dart';
import 'package:ar_furniture_app/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class ItemsUpload extends StatefulWidget {
  const ItemsUpload({super.key});

  @override
  State<ItemsUpload> createState() => _ItemsUploadState();
}

class _ItemsUploadState extends State<ItemsUpload> {
  Uint8List? imageFileUnint8List;

  TextEditingController sellerNameTextEditingController =
      TextEditingController();
  TextEditingController sellerPhoneTextEditingController =
      TextEditingController();
  TextEditingController itemNameTextEditingController = TextEditingController();
  TextEditingController itemDescriptionTextEditingController =
      TextEditingController();
  TextEditingController itemPriceTextEditingController =
      TextEditingController();

  bool isUploading = false;
  String downloadUrlOfUploadedImage = "";

  //Upload form screen
  Widget uploadFormScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.white,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              onPressed: () {
                // validate upload form fields
                if (isUploading != true) {
                  validateUploadFormAndUploadItemInfo();
                }
              },
              icon: const Icon(
                Icons.cloud_upload,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          isUploading == true
              ? const LinearProgressIndicator(
                  color: Colors.purpleAccent,
                )
              : Container(),

          //image
          SizedBox(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: imageFileUnint8List != null
                  ? Image.memory(imageFileUnint8List!)
                  : const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
            ),
          ),

          const Divider(
            color: Colors.white,
            thickness: 2.0,
          ),

          //seller name
          ListTile(
            leading: const Icon(
              Icons.person_pin_rounded,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(
                  color: Colors.grey,
                ),
                controller: sellerNameTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Seller Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const Divider(
            color: Colors.white70,
            thickness: 1.0,
          ),

          //seller phone
          ListTile(
            leading: const Icon(
              Icons.phone_iphone_rounded,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(
                  color: Colors.grey,
                ),
                controller: sellerPhoneTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Seller Phone",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const Divider(
            color: Colors.white70,
            thickness: 1.0,
          ),

          //item name
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(
                  color: Colors.grey,
                ),
                controller: itemNameTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const Divider(
            color: Colors.white70,
            thickness: 1.0,
          ),

          //item description
          ListTile(
            leading: const Icon(
              Icons.description,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(
                  color: Colors.grey,
                ),
                controller: itemDescriptionTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Description",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const Divider(
            color: Colors.white70,
            thickness: 1.0,
          ),

          //Item price
          ListTile(
            leading: const Icon(
              Icons.price_change,
              color: Colors.white,
            ),
            title: SizedBox(
              width: 250,
              child: TextField(
                style: const TextStyle(
                  color: Colors.grey,
                ),
                controller: itemPriceTextEditingController,
                decoration: const InputDecoration(
                  hintText: "Item Price",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const Divider(
            color: Colors.white70,
            thickness: 1.0,
          ),
        ],
      ),
    );
  }

  validateUploadFormAndUploadItemInfo() async {
    if (imageFileUnint8List != null) {
      if (sellerNameTextEditingController.text.isNotEmpty &&
          sellerPhoneTextEditingController.text.isNotEmpty &&
          itemNameTextEditingController.text.isNotEmpty &&
          itemDescriptionTextEditingController.text.isNotEmpty &&
          itemPriceTextEditingController.text.isNotEmpty) {
        setState(() {
          isUploading = true;
        });

        //1.  upload image to cloud
        String imageUniqueName =
            DateTime.now().microsecondsSinceEpoch.toString();

        fStorage.Reference firebaseStorageRef = fStorage
            .FirebaseStorage.instance
            .ref()
            .child("Items Images")
            .child(imageUniqueName);

        fStorage.UploadTask uploadTaskImageFile =
            firebaseStorageRef.putData(imageFileUnint8List!);

        fStorage.TaskSnapshot taskSnapshot =
            await uploadTaskImageFile.whenComplete(() {});
        await taskSnapshot.ref.getDownloadURL().then((imageDownloadUrl) {
          downloadUrlOfUploadedImage = imageDownloadUrl;
        });
        //2.  save item info to firestore database
        saveItemInfoToFirestore();
      } else {
        Fluttertoast.showToast(
            msg: "Please complete upload form. Every field is mandatory");
      }
    } else {
      Fluttertoast.showToast(msg: "Please select image file");
    }
  }

  saveItemInfoToFirestore() {
    String itemUniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    FirebaseFirestore.instance.collection("items").doc(itemUniqueId).set(
      {
        "itemID": itemUniqueId,
        "itemName": itemNameTextEditingController.text,
        "itemDescription": itemDescriptionTextEditingController.text,
        "itemImage": downloadUrlOfUploadedImage,
        "sellerName": sellerNameTextEditingController.text,
        "sellerPhone": sellerPhoneTextEditingController.text,
        "itemPrice": itemPriceTextEditingController.text,
        "publishedDate": DateTime.now(),
      },
    );
    Fluttertoast.showToast(msg: "Item uploaded successfully.");

    setState(() {
      isUploading = false;
      imageFileUnint8List = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Widget defaultScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Upload New Item",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
              size: 200,
            ),
            ElevatedButton(
              onPressed: () {
                showDialogBox();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black45,
              ),
              child: const Text(
                "Add New Item",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDialogBox() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Item Image",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                captureImageWithPhoneCamera();
              },
              child: const Text(
                "Capture image with Camera",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                choooseImageFromPhoneGallery();
              },
              child: const Text(
                "Choose image from Gallery",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  captureImageWithPhoneCamera() async {
    Navigator.pop(context);
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        imageFileUnint8List = await pickedImage.readAsBytes();

        //remove background from image
        imageFileUnint8List =
            await ApiConsumer().removeImageBackgroundApi(imagePath);

        setState(() {
          imageFileUnint8List;
        });
      }
    } catch (errorMsg) {
      print(errorMsg.toString());
      setState(() {
        imageFileUnint8List = null;
      });
    }
  }

  choooseImageFromPhoneGallery() async {
    Navigator.pop(context);
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        String imagePath = pickedImage.path;
        imageFileUnint8List = await pickedImage.readAsBytes();

        //remove background from imagg
        imageFileUnint8List =
            await ApiConsumer().removeImageBackgroundApi(imagePath);

        setState(() {
          imageFileUnint8List;
        });
      }
    } catch (errorMsg) {
      print(errorMsg.toString());
      setState(() {
        imageFileUnint8List = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return imageFileUnint8List == null ? defaultScreen() : uploadFormScreen();
  }
}
