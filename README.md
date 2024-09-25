## Getting Started

### Set up from the CLI 

1. ```cd``` into the 'example' directory

2. run ```npm install -g firebase-tools``` to install Firebase CLI then run ```firebase login``` 
   
3. Once you've logged in, run ```dart pub global activate flutterfire_cli``` to install the FlutterFire CLI, then ```flutterfire configure```
   *ADD STEPS ON SETTING UP FLUTTER AFTER INSTALL*
    i.Select the appropriate project
   ii.
ii. Choose which platforms you'd like to be supported (iOS & Android)

5. Make sure Flutter's installed: ```flutter doctor``` 

6. run ```flutter pub get```
   i. (opt.) run ```flutter pub outdated``` to see dependencies that could be upgraded
   ii. run ```flutter pub upgrade <pkgName>``` to update a specific dependency
       a. OR run ```flutter pub upgrade --major versions``` (may cause version errors)
   
7. Make sure to have a simulator available
    i. run ```flutter devices``` to see what emulators are available
   ii. (iOS) run ```open -a simulator``` (there's probably an Android equivalent, but I don't know it)

8. run ```flutter run``` and you're all set 

###
__Basic Project Structure__: 
- Credential Authentication & API calls are mainly in the 'example/lib/services' folder
- All UIs are in the 'example/lib/screens' folder
    - The Patient & Physician files should be in their respective folders 

#### Links

[https://damoov.com](https://damoov.com/)

#### Telematics SDK

A flutter plugin for tracking the person's driving behavior such as speeding, turning, braking and several other things on iOS and Android.

__Disclaimer__: This project uses Telematics SDK which belongs to DAMOOV PTE. LTD.  
When using Telematics SDK refer to these [terms of use](https://docs.damoov.com/docs/license)

For commercial use, you need to create a developer workspace in [DataHub](https://app.damoov.com) and get the `InstanceId` and `InstanceKey` auth keys to work with the API.

