import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eternal_dungeon/styles/app_colors.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController confirmPassController = TextEditingController();
  TextEditingController nickController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isPassDifferent = false;
  bool isLoading = false;
  bool isAnyEmpty = false;
  bool isInvalidEmail = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: height,
            width: width,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.asset("assets/background.png"),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 100.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: width > 450 ? width * 0.4 : width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        border: Border.all(width: 2, color: Colors.white30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Cadastro",
                              style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                  color: AppColors.textPrimary,
                                  fontSize: height * 0.05),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.03,
                          ),
                          textFieldForUser(
                            context,
                            width,
                            TextField(
                              controller: emailController,
                              cursorColor: AppColors.background,
                              cursorHeight: height * 0.03,
                              decoration: inputTextdecoration("Email"),
                            ),
                            (isAnyEmpty || isInvalidEmail),
                          ),
                          SizedBox(
                            height: height * 0.03,
                          ),
                          textFieldForUser(
                            context,
                            width,
                            TextField(
                              controller: nickController,
                              cursorColor: AppColors.background,
                              cursorHeight: height * 0.03,
                              obscureText: false,
                              decoration: inputTextdecoration("Nick"),
                            ),
                            (isAnyEmpty || isPassDifferent),
                          ),
                          SizedBox(
                            height: height * 0.03,
                          ),
                          textFieldForUser(
                            context,
                            width,
                            TextField(
                              controller: passController,
                              cursorColor: AppColors.background,
                              cursorHeight: height * 0.03,
                              obscureText: true,
                              decoration: inputTextdecoration("Senha"),
                            ),
                            (isAnyEmpty || isPassDifferent),
                          ),
                          SizedBox(
                            height: height * 0.03,
                          ),
                          textFieldForUser(
                            context,
                            width,
                            TextField(
                              controller: confirmPassController,
                              cursorColor: AppColors.background,
                              cursorHeight: height * 0.03,
                              obscureText: true,
                              decoration: inputTextdecoration("Confirma Senha"),
                            ),
                            (isAnyEmpty || isPassDifferent),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          errorMessage(width, height),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          signInButton(width, height, passController,
                              confirmPassController, emailController, context),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          exitButton(width, height, context),
                          SizedBox(
                            height: height * 0.01,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  errorMessage(double width, double height) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: width * 0.55,
        height: height * 0.02,
        child: Align(
          alignment: Alignment.topRight,
          child: (isAnyEmpty)
              ? const Text(
                  "Todos os campos são obrigatórios",
                  style: TextStyle(color: Colors.red),
                )
              : (isPassDifferent)
                  ? const Text(
                      "Senhas não são iguis",
                      style: TextStyle(color: Colors.red),
                    )
                  : (isInvalidEmail)
                      ? const Text(
                          "Email inválido",
                          style: TextStyle(color: Colors.red),
                        )
                      : Container(),
        ),
      ),
    );
  }

  exitButton(double width, double height, BuildContext context) {
    return TextButton(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          border: Border.all(width: 2, color: Colors.white30),
          borderRadius: BorderRadius.circular(12),
        ),
        width: 200,
        height: height * 0.05,
        child: Center(
          child: Text(
            "Voltar",
            style: TextStyle(
                fontSize: height * 0.03, color: AppColors.textPrimary),
          ),
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  signInButton(
      double width,
      double height,
      TextEditingController? pass,
      TextEditingController? confirmPass,
      TextEditingController? email,
      BuildContext context) {
    return TextButton(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          border: Border.all(width: 2, color: Colors.white30),
          borderRadius: BorderRadius.circular(12),
        ),
        width: 200,
        height: height * 0.05,
        child: Center(
          child: !isLoading
              ? Text(
                  "Cadastrar",
                  style: TextStyle(
                      fontSize: height * 0.03, color: AppColors.textPrimary),
                )
              : SizedBox(
                  height: height * 0.02,
                  width: height * 0.02,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
        ),
      ),
      onPressed: () {
        setState(() {
          isLoading = true;
          isPassDifferent = false;
          isAnyEmpty = false;
          isInvalidEmail = false;
        });

        if (pass!.text != "" && confirmPass!.text != "" && email!.text != "") {
          if ((pass.text == confirmPass.text)) {
            if (RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(email.text)) {
              FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: email.text, password: pass.text)
                  .then(
                (value) {
                  FirebaseFirestore.instance
                      .collection("players")
                      .doc(value.user!.uid)
                      .set({
                    "name": nickController.text,
                    "email": email.text,
                    'current_level': 1,
                    'equiped_armor': "",
                    'equiped_weapon': "",
                    'current_health': 0,
                    'max_health': 0,
                    'current_mana': 0,
                    'max_mana': 0,
                    'force': 0,
                    'agility': 0,
                    'intelligence': 0,
                    'is_new': true,
                  });
                  Navigator.of(context).pop();
                },
              );
            } else {
              setState(() {
                isInvalidEmail = true;
              });
            }
          } else {
            setState(() {
              isPassDifferent = true;
            });
          }
        } else {
          setState(() {
            isAnyEmpty = true;
          });
        }
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  inputTextdecoration(String text) {
    return InputDecoration(
      contentPadding: EdgeInsets.only(left: 20),
      border: InputBorder.none,
      hintText: text,
    );
  }

  textFieldForUser(
      BuildContext context, double width, TextField campo, bool isError) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            border: Border.all(
                width: 2, color: isError ? Colors.red : Colors.white30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: width * 0.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: campo,
            ),
          ),
        ),
      ),
    );
  }
}
