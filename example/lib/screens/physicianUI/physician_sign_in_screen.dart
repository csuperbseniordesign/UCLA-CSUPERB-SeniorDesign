import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:telematics_sdk_example/services/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telematics_sdk_example/screens/physicianUI/physician_home_screen.dart';
import 'package:telematics_sdk_example/services/UnifiedAuthService.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:telematics_sdk_example/widgets/show_dialog.dart';

class PhysicianSignInScreen extends StatefulWidget {
  const PhysicianSignInScreen({Key? key}) : super(key: key);

  @override
  State<PhysicianSignInScreen> createState() => _PhysicianSignInScreenState();
}

class _PhysicianSignInScreenState extends State<PhysicianSignInScreen> {
  String? errorMessage = ' ';
  bool isLogin = true;
  bool isConfirmed = false;
  bool isLoading = false;

  final TextEditingController _controllerFirstName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerOrgName = TextEditingController();
  final TextEditingController _controllerNPI = TextEditingController();
  final TextEditingController _controllerPhone = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final UnifiedAuthService _auth = UnifiedAuthService();

  String email = '';
  String password = '';
  String firstName = '';
  String lastName = '';
  String phone = '';
  // String clientId = '';

  bool _showPasswordValidator = false;
  // bool isVerified = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {
        _showPasswordValidator = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controllerPassword.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Widget _decoration() {
    return Stack(
      children: [
        Positioned(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 40, bottom: 15, right: 10, left: 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: (const Color.fromARGB(255, 4, 27, 63)),
                  width: 5,
                ),
              ),
            ),
          ),
        ),
        // This is that invisible rectangle at the top left.
        Positioned(
          top: 28,
          left: -100,
          child: Container(
            height: 175,
            width: 175,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              shape: BoxShape.rectangle,
            ),
          ),
        ),
        // This is that invisible rectangle at the bottom right.
        Positioned(
          bottom: -45,
          right: -13,
          child: Container(
            height: 175,
            width: 175,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
            ),
          ),
        ),
        // This is for the blue ball-top left.
        Positioned(
          top: 30.0,
          left: -40.0,
          child: Container(
            height: 125,
            width: 125,
            decoration: BoxDecoration(
              color: (const Color.fromARGB(255, 4, 27, 63)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
            ),
            child: BackButton(color: Colors.white),
          ),
        ),
        // This is for the beige ball-top left.
        Positioned(
          top: 100.0,
          left: -40.0,
          child: Container(
            height: 95,
            width: 95,
            decoration: BoxDecoration(
              color: (const Color.fromARGB(255, 200, 195, 146)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
            ),
          ),
        ),
        // This is for the blue ball-bottom right.
        Positioned(
          bottom: -80.0,
          right: -80.0,
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: (const Color.fromARGB(255, 4, 27, 63)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
            ),
          ),
        ),
        // This is for the beige ball-bottom right.
        Positioned(
          bottom: -50.0,
          right: 50.0,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: (const Color.fromARGB(255, 200, 195, 146)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
            ),
          ),
        ),
        // This belongs to the car logo.
        // Positioned(
        //   top: 100.0,
        //   right: 120,
        //   child: Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Container(
        //           child: ColorFiltered(
        //             colorFilter: const ColorFilter.mode(
        //               Color.fromARGB(255, 103, 139, 183),
        //               BlendMode.srcIn,
        //             ),
        //             child: Image.asset(
        //               'assets/images/road.png',
        //               height: 150,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _signInDecoration() {
    return Stack(
      children: [
        Positioned(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 40, bottom: 15, right: 10, left: 10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: (const Color.fromARGB(255, 4, 27, 63)),
                  width: 5,
                ),
              ),
            ),
          ),
        ),
        // This is that invisible rectangle at the top left.
        Positioned(
          top: 28,
          left: -100,
          child: Container(
            height: 175,
            width: 175,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              shape: BoxShape.rectangle,
            ),
          ),
        ),
        // This is that invisible rectangle at the bottom right.
        Positioned(
          bottom: -45,
          right: -13,
          child: Container(
            height: 175,
            width: 175,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
            ),
          ),
        ),
        // This is for the blue ball-top left.
        Positioned(
          top: 30.0,
          left: -40.0,
          child: Container(
            height: 125,
            width: 125,
            decoration: BoxDecoration(
              color: (const Color.fromARGB(255, 4, 27, 63)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
            ),
            child: BackButton(color: Colors.white),
          ),
        ),
        // This is for the beige ball-top left.
        Positioned(
          top: 100.0,
          left: -40.0,
          child: Container(
            height: 95,
            width: 95,
            decoration: BoxDecoration(
              color: (const Color.fromARGB(255, 200, 195, 146)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
            ),
          ),
        ),
        // This is for the blue ball-bottom right.
        Positioned(
          bottom: -80.0,
          right: -80.0,
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: (const Color.fromARGB(255, 4, 27, 63)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
            ),
          ),
        ),
        // This is for the beige ball-bottom right.
        Positioned(
          bottom: -50.0,
          right: 50.0,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: (const Color.fromARGB(255, 200, 195, 146)),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
            ),
          ),
        ),
        // This belongs to the car logo.
        Positioned(
          top: 100.0,
          right: 120,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Color.fromARGB(255, 103, 139, 183),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/images/road.png',
                      height: 150,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _loginHeader() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: isLogin
            ? const EdgeInsets.only(top: 300, left: 20, right: 20)
            : const EdgeInsets.only(top: 100, left: 20, right: 20),
        child: Column(
          children: [
            Text(
              isLogin ? 'Sign In' : 'Sign Up',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
              width: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      {FocusNode? focusNode}) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: SizedBox(
        height: 45,
        width: 300,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          cursorColor: Color.fromARGB(255, 103, 139, 183),
          // autofocus: false,
          decoration: InputDecoration(
            hintText: title,
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: const Color.fromARGB(255, 4, 27, 63)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneField(
    String title,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: SizedBox(
          height: 65,
          width: 310,
          child: IntlPhoneField(
              // style: ,
              cursorColor: const Color.fromARGB(255, 4, 27, 63),
              decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle:
                      TextStyle(color: const Color.fromARGB(255, 4, 27, 63)),
                  fillColor: const Color.fromARGB(255, 4, 27, 63),
                  hoverColor: const Color.fromARGB(255, 4, 27, 63),
                  focusColor: const Color.fromARGB(255, 4, 27, 63),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 85, 119, 176),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 4, 27, 63),
                    ),
                  )),
              initialCountryCode: 'US',
              onChanged: (phone) {
                controller.text = phone.completeNumber;
              })),
    );
  }

  Widget _passwordCheck() {
    return Padding(
        padding: const EdgeInsets.only(left: 0),
        child: SizedBox(
          height: 60,
          width: 300,
          child: TextFormField(
            controller: _controllerConfirmPassword,
            cursorColor: Color.fromARGB(255, 103, 139, 183),
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'CONFIRM PASSWORD',
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: const Color.fromARGB(255, 4, 27, 63)),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                showLoginDialog(
                    context, "Login Failed", "Password Field is empty");
                return 'Please re-enter password';
              }
              if (_controllerPassword.text != _controllerConfirmPassword.text) {
                showLoginDialog(
                    context, "Login Failed", "Email or Password is incorrect");
                return "Password does not match";
              }
              return null;
            },
          ),
        ));
  }

// Displays link and calls UnifiedAuthService method to send reset email
  Widget _forgotPasswordLink() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 190,
      ),
      child: GestureDetector(
        onTap: _resetPassword,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: const Color.fromARGB(255, 23, 111, 182),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _resetPassword() async {
    if (_controllerEmail.text.isNotEmpty) {
      email = _controllerEmail.text;
      try {
        await _auth.resetPassword(email);
        // Display a success message or navigate to a confirmation screen
        // _showSnackBar()
        _snackBar("Password reset email sent to $email");
        // print('Password reset email sent to $email');
      } catch (e) {
        // print('Failed to reset password: $e');
        _snackBar("Failed to reset password $e");
        // Handle the error appropriately, such as displaying an error message
      }
    } else {
      setState(() {
        errorMessage = 'Please enter your email to reset the password.';
      });
    }
  }

  void _snackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 25, right: 20),
      child: SizedBox(
        height: 50,
        width: 350,
        child: FilledButton(
          onPressed: isLogin ? _signIn : createUserWithEmailAndPassword,
          style: FilledButton.styleFrom(
            backgroundColor: (Color.fromARGB(255, 103, 139, 183)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35.0),
            ),
          ),
          child: Text(
            isLogin ? 'Sign In' : 'Sign Up',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
              color: (Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      setState(() => isLoading = true);
      AppUser? user = await _auth.registerPhysician(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
        firstName: _controllerFirstName.text,
        lastName: _controllerLastName.text,
        npi: _controllerNPI.text,
        organizationName: _controllerOrgName.text,
        phone: _controllerPhone.text,
      );
      if (user != null) {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PhysicianHomeScreen()));

        // Stop loading
        setState(() => isLoading = false);
      } else {
        throw Exception(
            'Failed to sign in. Please check your email and password.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> _signIn() async {
    try {
      setState(() => isLoading = true);
      AppUser? user = await _auth.signInWithEmailAndPassword(
          _controllerEmail.text, _controllerPassword.text);

      if (!mounted) return;

      if (user != null) {
        if (!mounted) return;
        String role = await _auth.checkUserRole(user.uid!);

        if(role == "Physician"){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PhysicianHomeScreen()));

        //   // Stop loading
          setState(() => isLoading = false);
        } else if (role == "Patient"){
          setState(() {
            isLoading = false;
            _snackBar('Patients are not allowed to sign in here.');
          });
        } else {
          throw Exception("Could not sign you in as Physician");
        }
      } else {
        showLoginDialog(
            context, "Login Failed", "Email or Password is incorrect");
        throw Exception(
            'Failed to sign in. Please check your email and password.');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _loginOrRegisterButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 100),
      // Link to change to sign up/sign in page
      child: GestureDetector(
          onTap: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 16.0, color: Color.fromARGB(255, 4, 27, 63)),
              children: <TextSpan>[
                TextSpan(
                  text: isLogin
                      ? 'Don\'t have an account? '
                      : 'Already have an account? ',
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color.fromARGB(255, 23, 111, 182),
                  ),
                ),
                TextSpan(
                    text: isLogin ? 'Sign up.' : 'Sign in.',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                      color: const Color.fromARGB(255, 23, 111, 182),
                    )),
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // _decoration(),
          _loginHeader(),
          if (isLogin) ...[
            _signInDecoration(),
            // _loginHeader(),
          ] else ...[
            _decoration(),
          ],
          _loginHeader(),
          Column(
            // space
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Padding(padding: const EdgeInsets.only(bottom: 200)),
              if (isLogin) ...[
                Padding(padding: const EdgeInsets.only(bottom: 200)),
                _entryField('EMAIL', _controllerEmail),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 25, right: 20),
                ),
                _entryField('PASSWORD', _controllerPassword),
                _forgotPasswordLink(),
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 25, right: 20),
                ),
                // Padding(padding: const EdgeInsets.only(bottom: 50)),
                _submitButton(),
                _loginOrRegisterButton(),
              ] else ...[
                _entryField('EMAIL', _controllerEmail),
                _entryField('PASSWORD', _controllerPassword,
                    focusNode: _passwordFocusNode),
                if (_showPasswordValidator)
                  FlutterPwValidator(
                      width: 300,
                      height: 98,
                      minLength: 8,
                      uppercaseCharCount: 1,
                      specialCharCount: 1,
                      numericCharCount: 2,
                      onSuccess: () {},
                      controller: _controllerPassword),
                _passwordCheck(),
                // _entryField('CONFIRM PASSWORD', _controllerConfirmPassword),
                _entryField('FIRST NAME', _controllerFirstName),
                _entryField('LAST NAME', _controllerLastName),
                _phoneField('PHONE', _controllerPhone),
                _entryField('NPI', _controllerNPI),
                _entryField('ORG. NAME', _controllerOrgName),
                _submitButton(),
                _loginOrRegisterButton(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
