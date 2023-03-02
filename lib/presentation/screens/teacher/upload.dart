import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ipfs/flutter_ipfs.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/presentation/widgets/mybutton.dart';
import 'package:todo_app/presentation/widgets/mytextfield.dart';
import 'package:todo_app/shared/styles/colors.dart';
import 'package:todo_app/shared/validators.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';

late String cnum;
late String ctype;
late String clink;

class uploadPage extends StatefulWidget {
  const uploadPage({Key? key}) : super(key: key);

  @override
  State<uploadPage> createState() => _uploadState();
}

class _uploadState extends State<uploadPage> {
  CollectionReference certificates =
      FirebaseFirestore.instance.collection('certificates');
  late TextEditingController _aadharController;
  late TextEditingController _typecontroller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _aadharController = TextEditingController();
    _typecontroller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _aadharController.dispose();
    _typecontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Appcolors.white,
        appBar: AppBar(
          backgroundColor: Appcolors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Appcolors.black,
              size: 30,
            ),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Form(
              key: _formKey,
              child: BounceInDown(
                duration: const Duration(milliseconds: 1500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload !',
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontSize: 20.sp,
                            letterSpacing: 2,
                          ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    MyTextfield(
                      hint: 'Aadhar No. of Student',
                      icon: Icons.text_fields,
                      keyboardtype: TextInputType.text,
                      validator: (value) {
                        cnum != value;
                      },
                      textEditingController: _aadharController,
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    MyTextfield(
                      hint: 'Type of Certificate',
                      icon: Icons.credit_card_outlined,
                      keyboardtype: TextInputType.text,
                      validator: (value) {
                        ctype != value;
                      },
                      textEditingController: _typecontroller,
                    ),
                    SizedBox(
                      height: 4.h,
                    ),
                    MaterialButton(
                      onPressed: () async {
                        await ImagePickerService.pickImage(context);
                        return await certificates
                            .add({
                              'num': cnum, // John Doe
                              'type': ctype, // Stokes and Sons
                              'link': "https://ipfs.io/ipfs" + clink // 42
                            })
                            .then((value) => print("User Added"))
                            .catchError(
                                (error) => print("Failed to add user: $error"));
                      },
                      color: Colors.deepPurple,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(
                            'Upload Image',
                            style: TextStyle(
                                fontSize: 18, fontFamily: 'Brand-Bold'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )));

    return Container();
  }
}

class ImagePickerService {
//PICKER
  static Future<XFile?> pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    try {
      // Pick an image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      //Nothing picked
      if (image == null) {
        Fluttertoast.showToast(
          msg: 'No Image Selected',
        );
        return null;
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => ProgressDialog(
            status: 'Uploading to IPFS',
          ),
        );

        // upload image to ipfs
        final cid = await FlutterIpfs().uploadToIpfs(image.path);
        clink = cid;
        debugPrint(cid);

        // Popping out the dialog box
        Navigator.pop(context);

        //Return Path
        return image;
      }
    } catch (e) {
      debugPrint('Error at image picker: $e');
      SnackBar(
        content: Text(
          'Error at image picker: $e',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
      );
      return null;
    }
  }
}
