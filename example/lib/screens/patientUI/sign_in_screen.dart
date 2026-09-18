import 'dart:async';
import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/services/alert_user.dart';
import 'package:telematics_sdk_example/services/fire_fetch.dart';
import 'package:telematics_sdk_example/services/user.dart';
import 'package:telematics_sdk_example/screens/patientUI/patient_home_screen.dart';
import 'package:telematics_sdk_example/services/UnifiedAuthService.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:telematics_sdk_example/widgets/show_dialog.dart';
import 'package:telematics_sdk_example/screens/patientUI/consent_form_screen.dart';

const String virtualDeviceToken = '';

class PatientSignInScreen extends StatefulWidget {
  const PatientSignInScreen({Key? key}) : super(key: key);

  @override
  State<PatientSignInScreen> createState() => _PatientSignInScreenState();
}

class _PatientSignInScreenState extends State<PatientSignInScreen> {
  String? errorMessage = ' ';
  bool isLogin = true;
  bool isConfirmed = false;
  bool isLoading = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
      TextEditingController();
  final UnifiedAuthService _auth = UnifiedAuthService();

  String email = '';
  String password = '';
  String physician = '';
  String firstName = '';
  String lastName = '';
  String phone = '';
  String clientId = '';
  String? physicianUid;
  List<DropdownMenuItem<String>> physicianItems = [];
  bool isLoadingPhysicians = true;

  @override
  void initState() {
    super.initState();
    physicianUid = null;
    loadPhysicians();
  }

  // grab physician records from Firebase
  void loadPhysicians() async {
    try {
      var items = await _auth.getPhysicianDropdownItems();
      if (!mounted) return;
      setState(() {
        physicianItems = items;
        isLoadingPhysicians = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingPhysicians = false);
    }
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerConfirmPassword.dispose();
    super.dispose();
  }

  // border of the page and logo
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

  // Header of the screen
  Widget _loginHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }

  Widget _backButton() {
    return const Positioned(
      top: 30,
      left: -40,
      width: 125,
      height: 125,
      child: BackButton(color: Colors.white),
    );
  }

  // Text fields for either sign in or sign up
  Widget _entryField(String title, TextEditingController controller,
      {bool obscureText = false,
      TextInputAction textInputAction = TextInputAction.next}) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: SizedBox(
        height: 60,
        width: 300,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          keyboardType: title == 'EMAIL'
              ? TextInputType.emailAddress
              : TextInputType.text,
          autofocus: false,
          cursorColor: Color.fromARGB(255, 14, 56, 90),
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

  Widget _passwordCheck() {
    return Padding(
        padding: const EdgeInsets.only(left: 0),
        child: SizedBox(
          height: 60,
          width: 300,
          child: TextFormField(
            controller: _controllerConfirmPassword,
            obscureText: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'CONFIRM PASSWORD',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                showLoginDialog(
                    context, "Login Failed", "Password Field is empty");
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

  String _physicianName(String? uid) {
    if (uid == null) return '';

    for (final item in physicianItems) {
      if (item.value == uid && item.child is Text) {
        return (item.child as Text).data ?? '';
      }
    }
    return '';
  }

  Widget _physicianDropdown() {
    final dropdownItems = physicianItems
        .map(
          (item) => DropdownMenuItem<String>(
            value: item.value,
            child: Text(
              _physicianName(item.value),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList();

    final hint = isLoadingPhysicians
        ? 'LOADING PHYSICIANS...'
        : physicianItems.isEmpty
            ? 'NO PHYSICIANS AVAILABLE'
            : 'SELECT PHYSICIAN';

    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        initialValue: physicianUid,
        isExpanded: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
        ),
        hint: Text(hint, overflow: TextOverflow.ellipsis),
        onChanged: isLoadingPhysicians || physicianItems.isEmpty
            ? null
            : (String? newValue) {
                setState(() {
                  physicianUid = newValue;
                  physician = _physicianName(newValue);
                });
              },
        items: dropdownItems,
      ),
    );
  }

  bool _validateSignUp() {
    if (_controllerEmail.text.trim().isEmpty ||
        _controllerPassword.text.isEmpty ||
        _controllerConfirmPassword.text.isEmpty) {
      showLoginDialog(context, 'Sign Up Failed', 'Please fill in all fields.');
      return false;
    }
    if (_controllerPassword.text != _controllerConfirmPassword.text) {
      showLoginDialog(context, 'Sign Up Failed', 'Passwords do not match.');
      return false;
    }
    if (physicianUid == null || physicianUid!.isEmpty) {
      showLoginDialog(
          context, 'Sign Up Failed', 'Please select your physician.');
      return false;
    }
    return true;
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

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 20),
      child: SizedBox(
        height: 50,
        width: 350,
        child: FilledButton(
          onPressed: () async {
            if (!isLogin && !_validateSignUp()) return;

            String? instanceId = await fireFetch('InstanceId');

            if (instanceId == null) {
              // if it's null, show user network pop up
              AlertUser.show(context,
                  title: 'Unable to connect to firebase',
                  description: 'Please check your network connection');

              return;
            }

            if (isLogin) {
              // then call the sign in function
              try {
                await _signIn(instanceId: instanceId);
                print('success');
              } catch (e) {
                showLoginDialog(
                    context, "Login Failed", "Email or Password is incorrect");
              }
            } else {
              String? instanceKey = await fireFetch('InstanceKey');

              if (instanceKey == null) {
                print('Error: instanceKey is null');
                return;
              }

              createUserWithEmailAndPassword(
                  instanceId: instanceId, instanceKey: instanceKey);
            }
          },
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

  Future<void> createUserWithEmailAndPassword(
      {required String instanceId, required String instanceKey}) async {
    try {
      setState(() => isLoading = true);

      // Navigate to consent form instead of directly creating account
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ConsentFormScreen(
            email: _controllerEmail.text,
            password: _controllerPassword.text,
            physician: physician,
            physicianUid: physicianUid!,
            instanceId: instanceId,
            instanceKey: instanceKey,
          ),
        ),
      );

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _signIn({required String instanceId}) async {
    try {
      setState(() => isLoading = true);
      // sign in with the credientials
      AppUser? user = await _auth.signInWithEmailAndPassword(
          _controllerEmail.text, _controllerPassword.text);

      if (!mounted) return;
      // if FireBase user is retrieved successfully check role
      if (user != null) {
        if (!mounted) return;
        String role = await _auth.checkUserRole(user.uid!);

        if (!mounted) return;
        if (role == 'Patient') {
          // if it is a patient grab the token & login
          String? deviceToken = await _auth
              .getDeviceTokenForUser(user.uid, false, instanceId: instanceId);
          if (deviceToken == null) {
            throw Exception('Device token could not be retrieved.');
          }
          await _auth.login(deviceToken, instanceId: instanceId);

          if (!mounted) return;
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PatientHomeScreen()));
          // Stop loading
          setState(() => isLoading = false);
        } else if (role == 'Physician') {
          // If the role is Physician, but this sign-in method is for Patients,
          // you might want to show an error or redirect to the Physician sign-in page
          setState(() {
            isLoading = false;
            _snackBar('Physicians are not allowed to sign in here.');
          });
        } else {
          throw Exception('Device token could not be retrieved.');
        }
      } else {
        showLoginDialog(
            context, "Login Failed", "Email or Password is incorrect");
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _snackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
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
          _decoration(),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 245),
                  _loginHeader(),
                  if (isLogin) ...[
                    _entryField('EMAIL', _controllerEmail),
                    _entryField('PASSWORD', _controllerPassword,
                        obscureText: true,
                        textInputAction: TextInputAction.done),
                    _forgotPasswordLink(),
                    const SizedBox(height: 50),
                    _submitButton(),
                    _loginOrRegisterButton(),
                  ] else ...[
                    _entryField('EMAIL', _controllerEmail),
                    _entryField('PASSWORD', _controllerPassword,
                        obscureText: true),
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
                    _physicianDropdown(),
                    const SizedBox(height: 30),
                    _submitButton(),
                    _loginOrRegisterButton(),
                  ],
                ],
              ),
            ),
          ),
          _backButton(),
        ],
      ),
    );
  }
}
