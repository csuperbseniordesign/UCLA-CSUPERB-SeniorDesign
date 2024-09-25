import Flutter
import UIKit
import RaxelPulse
import flutter_local_notifications
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      RPEntry.initialize(withRequestingPermissions: false)

  if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
   

      let options = launchOptions ?? [:]
      RPEntry.application(application, didFinishLaunchingWithOptions: options)
      
      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
// import Flutter
// import UIKit
// import RaxelPulse

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate, UIResponder, UIApplicationDelegate, RPLocationDelegate {

//     override func application(
//         _ application: UIApplication,
//         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//     ) -> Bool {
//         RPEntry.initialize(withRequestingPermissions: false)
//         RPEntry.instance().locationDelegate = self
//         let options = launchOptions ?? [:]
//         RPEntry.application(application, didFinishLaunchingWithOptions: options)
        
//         GeneratedPluginRegistrant.register(with: self)
        
//         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//     }
    
//     func triggerNotification(forEvent event: RPEventPoint) {
//         if event.type == "SpecificEventType" {
//             let content = UNMutableNotificationContent()
//             content.title = "New Event Notification"
//             content.subtitle = "A new event of type \(event.type) has occurred"
//             content.sound = UNNotificationSound.default
            
//             let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//             let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//             UNUserNotificationCenter.current().add(request)
//         }
//     }
    
//     func onNewEvents(_ events: NSMutableArray!) {
//         for item in events {
//             if let event = item as? RPEventPoint {
//                 NSLog("event id = %@ type = %@", event.theId, event.type)
//                 triggerNotification(forEvent: event)
//             }
//         }
//     }
// }
