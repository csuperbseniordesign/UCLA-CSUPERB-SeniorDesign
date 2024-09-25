import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telematics_sdk_example/services/auth.dart';
import 'package:telematics_sdk_example/services/UnifiedAuthService.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class PatientProfileScreen extends StatefulWidget {
  PatientProfileScreen({Key? key}) : super(key: key);

  @override
  _PatientProfileScreenState createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final User? user = Auth().currentUser;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  String? _selectedGender;
  final TextEditingController _newPasswordController = TextEditingController();
  final UnifiedAuthService _auth = UnifiedAuthService();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _birthdayController = TextEditingController();
  String physician = "";
  bool hasBirthday = false;
  String birthday = "";
  bool changePassword = false;
  String gender = "";
  bool hasGender = false;
  // String? physician = "";
  final FocusNode _passwordFocusNode = FocusNode();
  bool _showPasswordValidator = false;
  @override
  void initState() {
    super.initState();
    _displayPhysician();
    _displayBirthday();
    _displayGender();
    _passwordFocusNode.addListener(() {
    setState(() {
      _showPasswordValidator = _passwordFocusNode.hasFocus;
    });
        });
  }

//Change password
  Future<void> updateUserPassword() async {
    if (_newPasswordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      try {
        await _auth
            .getCurrentUser()
            ?.updatePassword(_newPasswordController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully")),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update password: $error")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdayController.text.isNotEmpty
          ? DateTime.tryParse(_birthdayController.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
    try {
      await _auth.addBirthday(_birthdayController.text);
    } catch (e) {
      print("Birthday not added");
    }
  }

  Future<void> _displayPhysician() async {
    var doc = await _auth.getPhysician(user?.uid);
    if (doc != null) {
      setState(() {
        physician = doc;
        print(physician);
      });
    }
  }

  Future<void> _displayBirthday() async {
    var bday = await _auth.getBirthday(user?.uid);
    if (bday != null) {
      setState(() {
        birthday = bday;
        if (birthday != "") {
          hasBirthday = true;
        }
      });
    }
  }

  Future<void> _displayGender() async {
    var s = await _auth.getGender(user?.uid);
    if (s != null) {
      setState(() {
        gender = s;
        if (gender != "") {
          hasGender = true;
        }
      });
    }
  }

  Widget _infoItem(String text1, String text2) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 16.0,
            // color: Colors.black,
            color: Color.fromARGB(255, 4, 27, 63)),
        children: <TextSpan>[
          TextSpan(
              text: text1, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: text2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(250.0),
          child: AppBar(
            title:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "Edit Profile",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ]),
            backgroundColor: Color.fromARGB(255, 103, 139, 183),
          ),
        ),
        body: Stack(
          children: [
            ListView(
                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 50),
                children: [
                  Text("Basic Information",
                      style: TextStyle(
                        fontSize: 25,
                        color: Color.fromARGB(255, 4, 27, 63),
                      ))
                ]),
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 20, top: 60),
              children: [
                _infoItem('Email: ', '${user?.email} '),
                _infoItem('Physician: ', '${physician} '),
                if (hasGender) ...[
                  _infoItem('Gender: ', '${gender}')
                ] else ...[
                  ExpansionTile(
                    title: Text('Add Gender'),
                    trailing: Icon(
                      Icons.create,
                    ),
                    // onExpansionChanged: 
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(labelText: 'Gender'),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                            if (_selectedGender != null) {
                              _auth.addGender(_selectedGender);
                            }
                          });
                        },
                        items: _genderOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        // onChanged: ,
                      ),
                    ],
                  )
                ],
                if (hasBirthday) ...[
                  _infoItem('Birthday: ', '${birthday}')
                ] else ...[
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                  ),
                  ExpansionTile(
                      title: Text('Add Birthday'),
                      trailing: Icon(
                        Icons.create,
                      ),
                      children: <Widget>[
                        TextFormField(
                          controller: _birthdayController,
                          decoration: const InputDecoration(
                            labelText: 'Birthday',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectBirthday(context),
                        ),
                      ]),
                ],
                Theme(
                    data:
                        ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text('Change Password',
                          
                          style:
                              TextStyle(color: Color.fromARGB(255, 4, 27, 63))),
                      trailing: Icon(Icons.create,
                          color: const Color.fromARGB(255, 68, 68, 68)),
                      childrenPadding: EdgeInsets.only(right: 25, left: 25),
                      children: <Widget>[
                        TextFormField(
                          controller: _newPasswordController,
                          decoration:
                              const InputDecoration(labelText: 'New Password'),
                          obscureText: true,
                          focusNode: _passwordFocusNode,
                        ),
                        if (_showPasswordValidator) ...[
                          FlutterPwValidator(
                              width: 300,
                              height: 98,
                              minLength: 8,
                              uppercaseCharCount: 1,
                              specialCharCount: 1,
                              numericCharCount: 2,
                              onSuccess: () {},
                              controller: _newPasswordController),
                        ],
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                              labelText: 'Confirm New Password'),
                          obscureText: true,
                        
                    
                        ),
                        TextButton(
                          child: Text("Change Password",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 49, 121, 179))),
                          onPressed: updateUserPassword,
                        ),
                      ],
                    )),
              ],
            )
          ],
        ));
  }
}
