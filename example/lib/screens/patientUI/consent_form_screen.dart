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
  bool _isSaving = false;

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
        title: const Text('Research Consent Form'),
        backgroundColor: const Color.fromARGB(255, 114, 147, 200),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONSENT TO PARTICIPATE IN RESEARCH',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Leveraging Digital Phenotyping to Support Patients with Visual Field Loss',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'California Law',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'These rights are the rights of every person who is asked to be in a medical research study. Your signature means you understand your rights. As a research participant, you have the following rights:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildRightsList(),
            const SizedBox(height: 20),
            _buildSection(
              'INTRODUCTION',
              'Dr. [Insert Full Name], from the Department of [Insert Department Name] at the University of California, Los Angeles, is conducting a research study. This study is being funded by the National Institutes of Health (NIH), CSUBIOTECH, and the Department of Education. You were selected as a possible participant because you are a glaucoma patient with a smartphone capable of running our study app. Your participation in this research study is voluntary.',
            ),
            _buildSection(
              'WHAT SHOULD I KNOW ABOUT A RESEARCH STUDY?',
              '• Someone will explain this research study to you.\n'
              '• Whether or not you take part is up to you.\n'
              '• You can choose not to take part.\n'
              '• You can agree to take part and later change your mind.\n'
              '• Your decision will not be held against you.\n'
              '• You can ask all the questions you want before you decide.',
            ),
            _buildSection(
              'WHY IS THIS RESEARCH BEING DONE?',
              'This research evaluates whether smartphone-collected driving behavior data can help alert physicians to glaucoma progression. The application processes sensor data (accelerometer, GPS, gyroscope) to assess behaviors related to vision loss, potentially leading to early intervention.',
            ),
            _buildSection(
              'HOW LONG WILL THE RESEARCH LAST AND WHAT WILL I NEED TO DO?',
              'The study will last approximately 3 months. Participants will:\n'
              '• Install and use the app, which passively collects data while driving.',
            ),
            _buildSection(
              'ARE THERE ANY RISKS IF I PARTICIPATE?',
              '• Risk of loss of privacy from data collection. All data is encrypted and access is limited.\n'
              '• There are no physical or medical risks.',
            ),
            _buildSection(
              'ARE THERE ANY BENEFITS IF I PARTICIPATE?',
              'You may not directly benefit from participating. However, this research could help prevent vision loss for others by improving early detection of glaucoma progression.',
            ),
            _buildSection(
              'WHAT OTHER CHOICES DO I HAVE IF I CHOOSE NOT TO PARTICIPATE?',
              'Your alternative is to not participate.',
            ),
            _buildSection(
              'HOW WILL INFORMATION ABOUT ME AND MY PARTICIPATION BE KEPT CONFIDENTIAL?',
              '• All identifying data will be anonymized and encrypted.\n'
              '• Only physicians and authorized UCLA researchers will have access to linked user data.\n'
              '• Data is stored securely on Damoov\'s HIPAA-compliant DataHub using AES-256 encryption.\n'
              '• Study data will be kept for up to 5 years after completion.',
            ),
            _buildSection(
              'USE OF DATA FOR FUTURE RESEARCH',
              'Your data, including de-identified data, may be used for future research.',
            ),
            _buildSection(
              'WILL I BE PAID FOR MY PARTICIPATION?',
              'You will not be paid for participation.',
            ),
            _buildSection(
              'WHO CAN I CONTACT IF I HAVE QUESTIONS ABOUT THIS STUDY?',
              '• The research team: Contact Dr. [Insert PI Name] at [Insert Phone/Email Info]\n'
              '• UCLA Office of the Human Research Protection Program (OHRPP):\n'
              '  Phone: (310) 206-2040\n'
              '  Email: cscsulaseniordesign@gmail.com\n'
              '  Mail: Box 951406, Los Angeles, CA 90095-1406',
            ),
            _buildSection(
              'WHAT ARE MY RIGHTS IF I TAKE PART IN THIS STUDY?',
              '• You may withdraw at any time without penalty.\n'
              '• You may refuse to answer questions.\n'
              '• Your decision to participate will not affect your healthcare.\n'
              '• You will be given a copy of this consent for your records.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Please sign below to indicate your agreement to participate:',
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
                  onPressed: _hasSignature && !_isSaving ? _createAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 114, 147, 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Sign & Create Account'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRightsList() {
    final rights = [
      'You have the right to be told what the research is trying to find out.',
      'You have the right to be told about all research procedures, drugs, and/or devices and whether any of these are different from what would be used in standard practice.',
      'You have the right to be told about any risks, discomforts or side effects that might reasonably occur as a result of the research.',
      'You have the right to be told about the benefits, if any, you can reasonably expect from participating.',
      'You have the right to be told about other choices you have and how they may be better or worse than being in the research. These choices may include other procedures, drugs or devices.',
      'You have the right to be told what kind of treatment will be available if the research causes any complications.',
      'You have the right to have a chance to ask any questions about the research or the procedure. You can ask these questions before the research begins or at any time during the research.',
      'You have the right to refuse to be part of the research or to stop at any time. This decision will not affect your care or your relationship with your doctor or this institution in any other way.',
      'You have the right to receive a copy of the signed and dated written consent form for the research.',
      'You have the right to be free of any pressure as you decide whether you want to be in the research study.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rights.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            '${entry.key + 1}. ${entry.value}',
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _createAccount() async {
    setState(() {
      _isSaving = true;
    });

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
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
} 