import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:todo_app/bloc/auth/authentication_cubit.dart';
import 'package:todo_app/bloc/connectivity/connectivity_cubit.dart';
import 'package:todo_app/presentation/screens/sudent/my_homepage.dart';
import 'package:todo_app/presentation/screens/teacher/teachhome.dart';
import 'package:todo_app/presentation/widgets/mybutton.dart';
import 'package:todo_app/presentation/widgets/myindicator.dart';
import 'package:todo_app/presentation/widgets/mysnackbar.dart';
import 'package:todo_app/presentation/widgets/mytextfield.dart';
import 'package:todo_app/presentation/widgets/progressindicator.dart';
import 'package:todo_app/shared/constants/assets_path.dart';
import 'package:todo_app/shared/constants/strings.dart';
import 'package:todo_app/shared/styles/colors.dart';
import 'package:todo_app/shared/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/data/repositories/user_repository.dart';
import 'package:todo_app/data/repositories/firestore_crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/globals.dart' as globals;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailcontroller;
  late TextEditingController _passwordcontroller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailcontroller = TextEditingController();
    _passwordcontroller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _emailcontroller.dispose();
    _passwordcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthenticationCubit authcubit = BlocProvider.of(context);
    ConnectivityCubit connectivitycubit = BlocProvider.of(context);
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
      body: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationErrortate) {
            // Showing the error message if the user has entered invalid credentials
            MySnackBar.error(
                message: state.error.toString(),
                color: Colors.red,
                context: context);
          }
        },
        builder: (context, state) {
          if (state is AuthenticationLoadingState) {
            return const MyCircularIndicator();
          }
          if (state is! AuthenticationSuccessState) {
            return SafeArea(
                child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: Form(
                  key: _formKey,
                  child: BounceInDown(
                    duration: const Duration(milliseconds: 1500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome !',
                          style:
                              Theme.of(context).textTheme.headline1?.copyWith(
                                    fontSize: 20.sp,
                                    letterSpacing: 2,
                                  ),
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        Text(
                          'Sign In To Continue !',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(
                                  fontSize: 12.sp,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        MyTextfield(
                          hint: 'Email Address',
                          icon: Icons.email,
                          keyboardtype: TextInputType.emailAddress,
                          validator: (value) {
                            return !Validators.isValidEmail(value!)
                                ? 'Enter a valid email'
                                : null;
                          },
                          textEditingController: _emailcontroller,
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        MyTextfield(
                          hint: 'Password',
                          icon: Icons.password,
                          keyboardtype: TextInputType.text,
                          obscure: true,
                          validator: (value) {
                            return value!.length < 6
                                ? "Enter min. 6 characters"
                                : null;
                          },
                          textEditingController: _passwordcontroller,
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        MyButton(
                          color: Colors.deepPurple,
                          width: 80.w,
                          title: 'Login',
                          func: () {
                            if (connectivitycubit.state
                                is ConnectivityOnlineState) {
                              // _authenticatewithemailandpass(context, authcubit);
                              login(
                                  email: _emailcontroller.text,
                                  password: _passwordcontroller.text,
                                  ctx: context);
                            } else {
                              MySnackBar.error(
                                  message:
                                      'Please Check Your Internet Conection',
                                  color: Colors.red,
                                  context: context);
                            }
                          },
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an Account ?',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, signuppage);
                              },
                              child: Text(
                                'Sign Up',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1
                                    ?.copyWith(
                                      fontSize: 9.sp,
                                      color: Colors.deepPurple,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
          }
          return Container();
        },
      ),
    );
  }

  Container _myDivider() {
    return Container(
      width: 27.w,
      height: 0.2.h,
      color: Appcolors.black,
    );
  }

  void _authenticatewithemailandpass(context, AuthenticationCubit cubit) {
    if (_formKey.currentState!.validate()) {
      cubit.login(
          email: _emailcontroller.text, password: _passwordcontroller.text);
    }
  }
}

Future<void> login(
    {required String email, required String password, required ctx}) async {
  try {
    final _firebaseAuth = FirebaseAuth.instance;
    LoadingIndicatorDialog().show(ctx, 'Logging In');
    await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((currentuser) async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setString('uid', currentuser.user!.uid);
      await FireStoreCrud().checkRole(uid: currentuser.user!.uid);
      //debugPrint(globals.role);
      if (globals.role == 'teacher') {
        LoadingIndicatorDialog().dismiss();
        Navigator.pop(ctx);
        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (ctx) => const TeacherHome()),
        );
      } else if (globals.role == 'student') {
        await FireStoreCrud().loadDetails(uid: currentuser.user!.uid);
        LoadingIndicatorDialog().dismiss();
        Navigator.pop(ctx);
        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (ctx) => const StudentHome()),
        );
      }
    });
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      throw 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      throw 'Wrong password provided for that user.';
    }
  } catch (e) {
    throw e.toString();
  }
}
