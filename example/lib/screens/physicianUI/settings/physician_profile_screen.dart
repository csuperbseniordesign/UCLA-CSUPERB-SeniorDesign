import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telematics_sdk_example/services/auth.dart';
import 'package:group_button/group_button.dart';
import 'package:telematics_sdk_example/services/UnifiedAuthService.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class PhysicianProfileScreen extends StatefulWidget {
  PhysicianProfileScreen({Key? key}) : super(key: key);

  @override
  _PhysicianProfileScreenState createState() => _PhysicianProfileScreenState();
}

class _PhysicianProfileScreenState extends State<PhysicianProfileScreen> {
  final User? user = Auth().currentUser;

  final TextEditingController _newPasswordController = TextEditingController();
  final UnifiedAuthService _auth = UnifiedAuthService();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
        final TextEditingController _addNPIController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool isVerified = false;
  bool _showPasswordValidator = false;
  String firstName = "";
  String lastName = "";

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {
        _showPasswordValidator = _passwordFocusNode.hasFocus;
      });
    });
    getVerification();
    getFirstName();
    getLastName();
  }

 Future<void> getVerification() async {
    var v = await _auth.getNPIVerification(user?.uid);
    if (v!= null) {
      // if(v = true){
         setState(() {
        isVerified = v; 
      });
      // }
    }
  }

   Future<void> getFirstName() async {
    var f = await _auth.getPhysicianFirstName(user?.uid);
    if (f != null) {
         setState(() {
        firstName = f; 
      });
    }
  }

   Future<void> getLastName() async {
    var l = await _auth.getPhysicianLastName(user?.uid);
    if (l != null) {
         setState(() {
        lastName = l; 
      });
    }
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
                padding: const EdgeInsets.only(left: 10, top: 10),
                children: [
                  Text("Basic Information",
                      style: TextStyle(
                        fontSize: 25,
                        color: Color.fromARGB(255, 4, 27, 63),
                      ))
                ]),
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 50),
              children: [
                Padding(
                    padding: EdgeInsets.only(
                      left: 40,
                      right: 40,
                    ),
                    child: Text('Email: ${user?.email ?? 'User email'}',
                        style: TextStyle(fontSize: 15))),
                if(isVerified)...[
                   Padding(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: Text('Verified NPI: $isVerified',
                        style: TextStyle(fontSize: 15))),
                ]
                else...[
                   Theme(
                    data:
                        ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text('Verify your account now to view patient statistics.',
                          
                          style:
                              TextStyle(color: Color.fromARGB(255, 4, 27, 63))),
                      trailing: Icon(Icons.create,
                          color: const Color.fromARGB(255, 68, 68, 68)),
                      childrenPadding: EdgeInsets.only(right: 25, left: 25),
                      children: <Widget>[
                        TextFormField(
                          controller: _addNPIController,
                          decoration:
                              const InputDecoration(labelText: 'NPI'),
                          obscureText: true,
                          focusNode: _passwordFocusNode,
                        ),
                         TextButton(
                          child: Text("Add NPI",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 49, 121, 179))),
                          onPressed: () async{
                        var v = await _auth.updateNPI(_addNPIController.text, firstName, lastName);
                            // getVerification(); 
                       setState(() {
                        
                          isVerified = v; 
                            // var v = await _auth.updateNPI(_addNPIController.text, firstName, lastName);
                            // // getVerification(); 
                       });
                          }), 
                      ],
                    )
                   )
                ],
               
                Theme(
                    data:
                        ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: ExpansionTile(
                          title: Text('Change Password'),
                          trailing: Icon(
                            Icons.create,
                          ),
                          children: <Widget>[
                            TextFormField(
                              controller: _newPasswordController,
                              decoration: const InputDecoration(
                                  labelText: 'New Password'),
                              obscureText: true,
                              focusNode: _passwordFocusNode,
                            ),
                             if (_showPasswordValidator) ... [
                  FlutterPwValidator(
                      width: 300,
                      height: 98,
                      minLength: 8,
                      uppercaseCharCount: 1,
                      specialCharCount: 1,
                      numericCharCount: 2,
                      onSuccess: () {},
                      controller: _newPasswordController),], 
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                  labelText: 'Confirm New Password'),
                              obscureText: true,
                            ),
                            TextButton(
                              child: Text("Change Password",
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: updateUserPassword,
                            ),
                          ],
                        ))),
                Padding(
                  padding: EdgeInsets.only(left: 25, top: 40),
                ),
                Text("Preferred Unit of Measurement",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: EdgeInsets.only(left: 25, top: 40),
                  child: Row(children: [
                    GroupButton(isRadio: true, buttons: ['km/hr', 'mi/hr']),
                    GroupButton(
                      isRadio: true,
                      buttons: ['12hr', '24hr'],
                    )
                  ]),
                ),
              ],
            )
          ],
        ));
  }
}
