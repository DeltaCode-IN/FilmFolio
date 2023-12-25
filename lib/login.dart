import 'package:animate_do/animate_do.dart';
import 'package:filmfolio/constants.dart';
import 'package:filmfolio/home/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userNameCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  bool isObscure = true;

  void login() {
    if (userNameCont.text.isEmpty || passwordCont.text.isEmpty) {
      toast("Please enter valid credentials");
    } else if (userNameCont.text == username && passwordCont.text == password) {
      navigation(context, HomePage(), true);
    } else {
      toast("Invalid credentials");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeIn(
        child: SizedBox(
          height: height(context),
          width: width(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5),
                        child: Image(
                          image: AssetImage(
                            'assets/lottie/dclogo.png',
                          ),
                          height: 80,
                          width: 80,
                        ),
                      )),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: width(context) * 0.07),
                    child: Lottie.asset(
                      'assets/lottie/search.json',
                      height: height(context) * 0.4,
                      width: height(context) * 0.4,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              20.height,
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: width(context) * 0.37),
                child: TextFormField(
                  cursorColor: Colors.black,
                  style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                  controller: userNameCont,
                  onChanged: (val) {},
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      hintText: 'Username',
                      hintStyle: GoogleFonts.lato(
                          color: Colors.grey, fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onFieldSubmitted: (_) {
                    
                  },
                ),
              ),
              20.height,
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: width(context) * 0.37),
                child: TextFormField(
                  obscureText: isObscure,
                  cursorColor: Colors.black,
                  style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                  controller: passwordCont,
                  onChanged: (val) {},
                  decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                            onPressed: () => setState(() {
                                  isObscure = !isObscure;
                                }),
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            )),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      hintText: 'Password',
                      hintStyle: GoogleFonts.lato(
                          color: Colors.grey, fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onFieldSubmitted: (_) {
                    login();
                  },
                ),
              ),
              SizedBox(
                height: height(context) * 0.07,
              ),
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  login();
                },
                child: Container(
                  width: width(context) * 0.1,
                  height: height(context) * 0.06,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      "Login",
                      style: GoogleFonts.lato(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
