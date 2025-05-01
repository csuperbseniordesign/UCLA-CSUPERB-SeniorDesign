import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telematics_sdk_example/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:telematics_sdk/telematics_sdk.dart';
import 'package:telematics_sdk_example/screens/patientUI/settings_screen.dart';
import 'package:telematics_sdk_example/screens/patientUI/tutorial_screen.dart';

const _sizedBoxSpace = SizedBox(height: 24);

class PatientHomeScreen extends StatefulWidget {
  PatientHomeScreen({Key? key}) : super(key: key);

  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen>
    with WidgetsBindingObserver {
  final _trackingApi = TrackingApi();
  late StreamSubscription<PermissionWizardResult?>
      _onPermissionWizardStateChanged;
  late StreamSubscription<bool> _onLowerPower;
  late StreamSubscription<TrackLocation> _onLocationChanged;

  var _deviceId = '';
  var _isSdkEnabled = false;
  var _isTracking = true;

  final _tokenEditingController = TextEditingController();

  Timer? _inactivityTimer;
  bool _isTripOngoing = false;
  String _speedInfo = "Waiting for trip to start...";
  final double notMovingSpeedThreshold = 0.5; // meters per second
  final int inactivityTimeout = 60; // seconds

  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _onPermissionWizardStateChanged =
        _trackingApi.onPermissionWizardClose.listen(_onPermissionWizardResult);
    _onLowerPower = _trackingApi.lowerPowerMode.listen(_onLowPowerResult);
    _onLocationChanged =
        _trackingApi.locationChanged.listen(_onLocationChangedResult);
    initPlatformState();

    WidgetsBinding.instance.addObserver(this);
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationService.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationService.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationService.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationService.onDismissActionReceivedMethod);
    startListeningLocation();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // get Device ID
    final virtualDeviceToken = await _trackingApi.getDeviceId();

    // set decive_id and text field - if empty; disable SDK
    if (virtualDeviceToken != null && virtualDeviceToken.isNotEmpty) {
      _deviceId = virtualDeviceToken;
      _tokenEditingController.text = _deviceId;
    } else {
      await _trackingApi.setEnableSdk(enable: false);
    }
    // bool if SDK is enabled
    _isSdkEnabled = await _trackingApi.isSdkEnabled() ?? false;

    // bool if perms are granted

    // disable tracking & aggressive heartbeats
    if (Platform.isIOS) {
      final disableTracking = await _trackingApi.isDisableTracking() ?? false;
      _isTracking = !disableTracking;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsScreen()));
      }
    });
  }

  Widget _logo() {
    return Center(
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
                height: 200,
              ),
            ),
          ),
        ],
      ),
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: false,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Row(
            children: [
              Padding(padding: EdgeInsets.only(top: 200, right: 150)),
              Text('HOME', style: TextStyle(color: Colors.black, fontSize: 20)),
              Padding(padding: EdgeInsets.only(right: 100)),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  size: 25,
                  color: Colors.black,
                ),
                onPressed: () {
                  showDialog(
                      context: context, builder: (context) => Tutorial());
                  // Navigator.of(context).push(TutorialHome());
                },
              ),
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 30)),
          _logo(),

          // Uncomment to view status of SDK and debugging

          // Text('SDK status: ${_isSdkEnabled ? 'Enabled' : 'Disabled'}'),
          // Text(
          //   'Permissions: ${_isAllRequiredPermissionsGranted ? 'Granted' : 'Not granted'}',
          // ),
          // Text("Virtual Device Token:\n ${_tokenEditingController.text}"),
          // (Platform.isIOS)
          //     ? Text(
          //         'Tracking: ${_isSdkEnabled && _isTracking && _isAllRequiredPermissionsGranted ? 'Enabled' : 'Disabled'}')
          //     : SizedBox.shrink(),
          //Text(_getCurrentLocation()),
          _sizedBoxSpace,
          Text(
            'Tracking Status',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
            ),
          ),
          Text(
              ' ${_isSdkEnabled && _isTracking && _isAllRequiredPermissionsGranted ? '- ENABLED -' : ' - DISABLED-'}',
              textAlign: TextAlign.center,
              style: _isSdkEnabled &&
                      _isTracking &&
                      _isAllRequiredPermissionsGranted
                  ? TextStyle(
                      color: Color.fromARGB(255, 49, 165, 4),
                      fontSize: 30,
                      fontWeight: FontWeight.bold)
                  : TextStyle(
                      color: const Color.fromARGB(255, 216, 10, 10),
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Text(
              // padding
              _speedInfo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),

          _sizedBoxSpace,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 103, 139, 183),
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    _onPermissionWizardStateChanged.cancel();
    _onLowerPower.cancel();
    _onLocationChanged.cancel();

    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel(); // Clean up the timer

    super.dispose();
  }

  void _onPermissionWizardResult(PermissionWizardResult result) {
    const _wizardResultMapping = {
      PermissionWizardResult.allGranted: 'All permissions was granted',
      PermissionWizardResult.notAllGranted: 'All permissions was not granted',
      PermissionWizardResult.canceled: 'Wizard cancelled',
    };

    if (result == PermissionWizardResult.allGranted ||
        result == PermissionWizardResult.notAllGranted) {
      setState(() {});
    }

    _showSnackBar(_wizardResultMapping[result] ?? '');
  }

  void _onLowPowerResult(bool isLowPower) {
    if (isLowPower) {
      _showSnackBar(
        "Low Power Mode.\nYour trips may be not recorded. Please, follow to Settings=>Battery=>Low Power",
      );
    }
  }

  void _onLocationChangedResult(TrackLocation location) {
    print(
        'location latitude: ${location.latitude}, longitude: ${location.longitude}');
    setState(() {});
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  void startListeningLocation() {
    Geolocator.getPositionStream().listen((Position position) {
      double speedInMetersPerSecond =
          max(position.speed, 0); // Ensure speed is not negative

      // Convert speed from m/s to mph
      double speedInMph = speedInMetersPerSecond * 2.23694;

      bool isCurrentlyMoving = speedInMph > notMovingSpeedThreshold;

      setState(() {
        // Only update trip state if there is a change

        if (isCurrentlyMoving != _isTripOngoing) {

          if (isCurrentlyMoving) {
            // Movement detected
            _isTripOngoing = true;
            _speedInfo =
                "Trip started. Speed: ${speedInMph.toStringAsFixed(2)} mph";
            print("Trip started");
            _inactivityTimer?.cancel();
          } else {
            // End of trip detected, start inactivity timer
            // _inactivityTimer?.cancel();

          }
        } else if (_isTripOngoing) {
          // Update speed info without changing trip state
          _speedInfo = "Speed: ${speedInMph.toStringAsFixed(2)} mph";
        }
      });
    });

  }

  void _showEndOfTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trip Completed'),
          content: const Text('Were you the driver for this trip?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

  }
}
