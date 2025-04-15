import 'package:flutter/material.dart';
import 'package:telematics_sdk_example/services/user.dart';
import 'package:telematics_sdk_example/screens/patientUI/patient_home_screen.dart';
import 'package:telematics_sdk_example/services/UnifiedAuthService.dart';
import 'package:signature/signature.dart';

class ConsentFormScreen extends StatefulWidget {
  final String email;
  final String password;
  final String physician;
  final String physicianUid;
  final String instanceId;
  final String instanceKey;

  const ConsentFormScreen({
    Key? key,
    required this.email,
    required this.password,
    required this.physician,
    required this.physicianUid,
    required this.instanceId,
    required this.instanceKey,
  }) : super(key: key);

  @override
  State<ConsentFormScreen> createState() => _ConsentFormScreenState();
}

class _ConsentFormScreenState extends State<ConsentFormScreen> {
  final UnifiedAuthService _auth = UnifiedAuthService();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _signatureController.addListener(() {
      setState(() {
        _hasSignature = !_signatureController.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Collection Consent'),
        backgroundColor: const Color.fromARGB(255, 4, 27, 63),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Collection Consent Form',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'By creating an account, you agree to the following:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            const Text(
              '1. Data Collection: We collect driving data including but not limited to:\n'
              '   - Speed\n'
              '   - Location\n'
              '   - Acceleration\n'
              '   - Braking patterns\n'
              '   - Trip duration and distance',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              '2. Data Usage: Your data will be used to:\n'
              '   - Monitor driving behavior\n'
              '   - Provide feedback to your healthcare provider\n'
              '   - Improve the service\n'
              '   - Conduct research (anonymized)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              '3. Data Protection: We are committed to:\n'
              '   - Securing your data\n'
              '   - Maintaining confidentiality\n'
              '   - Complying with privacy regulations\n'
              '   - Providing you access to your data',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please sign below to indicate your consent:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: _signatureController,
                height: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _signatureController.clear();
                    setState(() {
                      _hasSignature = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Clear Signature'),
                ),
                ElevatedButton(
                  onPressed: _hasSignature
                      ? () async {
                          try {
                            // Create the user account
                            AppUser? user = await _auth.registerPatient(
                              email: widget.email,
                              password: widget.password,
                              gender: "",
                              birthday: "",
                              physician: widget.physician,
                              physicianID: widget.physicianUid,
                              instanceId: widget.instanceId,
                              instanceKey: widget.instanceKey,
                            );

                            if (user != null) {
                              // Get device token and login
                              String? deviceToken = await _auth.getDeviceTokenForUser(
                                user.uid,
                                true,
                                instanceId: widget.instanceId,
                              );

                              if (!mounted) return;
                              await _auth.login(user.uid, instanceId: widget.instanceId);

                              if (!mounted) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => PatientHomeScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error creating account: $e')),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 4, 27, 63),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 