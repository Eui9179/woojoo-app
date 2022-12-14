import 'package:dor_app/controller/access_token_controller.dart';
import 'package:dor_app/controller/fcm_token_controller.dart';
import 'package:dor_app/dio/auth/login.dart';
import 'package:dor_app/main.dart';
import 'package:dor_app/ui/dynamic_widget/button/rounded_button.dart';
import 'package:dor_app/ui/layout/app_bar/logo_app_bar.dart';
import 'package:dor_app/utils/color_palette.dart';
import 'package:dor_app/utils/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../dynamic_widget/font/font.dart';

class Verification extends StatefulWidget {
  const Verification({Key? key}) : super(key: key);

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final String _phoneNumber = Get.arguments;

  _VerificationState({Key? key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String _verificationCode = "";
  String _smsCode = "";
  String _fcmToken = Get.find<FcmTokenController>().fcmToken;
  bool btnEnabled = false;
  bool isDisposed = false;
  bool isVerification = false;

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    const defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 25,
          color: Color.fromRGBO(255, 255, 255, 1.0),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Color.fromRGBO(168, 168, 168, 1.0), width: 3.0)),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: const Border(
          bottom:
              BorderSide(color: Color.fromRGBO(234, 239, 243, 1), width: 3.0)),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(),
    );

    return Scaffold(
        backgroundColor: ColorPalette.mainBackgroundColor,
        appBar: const LogoAppBar(),
        body: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Font(text: "??? ?????? ??????", size: 35),
              const SizedBox(
                height: 5,
              ),
              const Text("????????? ???????????? ?????? 1????????? ???????????????.\n???????????? ???????????? ?????? ?????? ????????? ???????????????.",
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorPalette.subFont,
                  )),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      margin: const EdgeInsets.only(top: 30),
                      child: Pinput(
                        length: 6,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 6) {
                            return "????????? ??????????????????";
                          }
                          return null;
                        },
                        onCompleted: (pin) {
                          setState(() {
                            _smsCode = pin;
                          });
                        },
                        onChanged: (val) {
                          val.length == 6
                              ? setState(() => btnEnabled = true)
                              : setState(() => btnEnabled = false);
                        },
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        autofocus: true,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Font(text: _phoneNumber, size: 20),
                        // TextButton(
                        //   onPressed: () {
                        //     _verifyPhone();
                        //   },
                        //   child: const Text(
                        //     "?????????",
                        //     style: TextStyle(
                        //         color: Colors.blueAccent, fontSize: 18),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    RoundedButton(
                        btnEnabled: btnEnabled,
                        onPressed: _onPressed,
                        text: "??????"),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  _verifyPhone() async {
    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          //async {
          setState(() {
            isVerification = true;
          });
          Future<Map<String, dynamic>> response =
              dioApiLogin(_phoneNumber, _fcmToken);
          response.then((result) {
            int statusCode = result["statusCode"];
            if (statusCode == 200) {
              _signin(result["data"]);
            } else if (statusCode == 401) {
              _signup();
            }
            // TODO: fcm ??? ??????
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String? verificationID, int? resendToken) {
          if (!isDisposed) {
            setState(() {
              _verificationCode = verificationID!;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          if (!isDisposed) {
            setState(() {
              _verificationCode = verificationID;
            });
          }
        },
        timeout: const Duration(seconds: 60));
  }

  _onPressed() async {
    if (_formKey.currentState!.validate()) {
      if (isVerification == true) {
        Future<Map<String, dynamic>> response =
            dioApiLogin(_phoneNumber, _fcmToken);
        response.then((result) {
          int statusCode = result["statusCode"];
          if (statusCode == 200) {
            _signin(result["data"]);
          } else if (statusCode == 401) {
            _signup();
          }
        });
      } else {
        try {
          await _auth
              .signInWithCredential(PhoneAuthProvider.credential(
                  verificationId: _verificationCode, smsCode: _smsCode))
              .then((value) {
            Future<Map<String, dynamic>> response =
                dioApiLogin(_phoneNumber, _fcmToken);
            response.then((result) {
              int statusCode = result["statusCode"];
              if (statusCode == 200) {
                _signin(result["data"]);
              } else if (statusCode == 401) {
                _signup();
              }
            });
          });
        } catch (e) {
          print(e.toString());
          FocusScope.of(context).unfocus();
          notification(context, '????????? ????????? ?????????');
        }
      }
    }
  }

  _signup() {
    Get.toNamed('auth/signup/step1', arguments: _phoneNumber);
  }

  _signin(String accessToken) async {
    storage.write(key: "accessToken", value: accessToken);
    Get.find<AccessTokenController>().setAccessToken(accessToken);
    Get.offAllNamed('/');
  }
}
