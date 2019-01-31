//
//  AppDelegate.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 15/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import Firebase
import Fabric
import Crashlytics
import Networking
import Common
import Moya
import IQKeyboardManagerSwift
import TwitterKit
import FBSDKLoginKit
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator!
    private let disposeBag = DisposeBag()

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let schemeTwitter = TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        let schemeFacebook = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        // MARK
        // Handler from URL Schemes
        // Get code from oauth identitas, then parse into callback
        // Need improve this strategy later...
        // refresh token etc in Network Services., using granType
        if let code = url.getQueryString(parameter: "code") {
            loginSymbolic(code: code)
        }
        return schemeTwitter || schemeFacebook
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        // IQKeyboardManager
        IQKeyboardManager.shared.enable = true
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstTime") == nil {
            window?.rootViewController = StartOnboardingController()
            window?.makeKeyAndVisible()
        } else {
            appCoordinator = AppCoordinator(window: window!)
            appCoordinator.start()
                .subscribe()
                .disposed(by: disposeBag)
        }
        
        // MARK: Configuration twitter
        configurationTwitter()
        // MARK: Configuration Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // MARK: Configuration Crashlytics
        Fabric.with([Crashlytics.self])
        
        UIApplication.shared.registerForRemoteNotifications()
        
        #if DEBUG
            let filePath = Bundle.main.path(forResource: "GoogleService-Info-Staging", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: filePath)
            FirebaseApp.configure(options: options!)
        #else
            let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: filePath)
            FirebaseApp.configure(options: options!)
        #endif
        // MARK: Register Notifications
        configureRemoteNotifications(application: application)
        
        // MARK: Check version
        UserDefaults.Account.set(false, forKey: .skipVersion)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        ReachabilityManager.shared.stopMonitoring()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PantauBersama")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: Register remote notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken as Data
        // TODO: subscribe topic broadcast activity
        Messaging.messaging().subscribe(toTopic: "broadcasts-activity")
    }
    // MARK: Remote receive notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        if UIApplication.shared.applicationState == .active {
            Parser.parse(userInfo: userInfo, active: true)
        } else {
            Parser.parse(userInfo: userInfo, active: false)
        }
    }
}

extension URL {
    func getQueryString(parameter: String) -> String? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == parameter }?
            .value
    }
}

extension AppDelegate {
    
    func configurationTwitter() {
        TWTRTwitter.sharedInstance()
            .start(withConsumerKey: AppContext.instance.infoForKey("KEY_TWITTER"),
                   consumerSecret: AppContext.instance.infoForKey("SECRET_TWITTER"))
    }
    
    func loginSymbolic(code: String) {
        NetworkService.instance.requestObject(
            IdentitasAPI.loginIdentitas(code: code,
                                        grantType: "authorization_code",
                                        clientId: AppContext.instance.infoForKey("CLIENT_ID"),
                                        clientSecret: AppContext.instance.infoForKey("CLIENT_SECRET"),
                                        redirectURI: AppContext.instance.infoForKey("REDIRECT_URI")),
            c: IdentitasResponses.self)
            .subscribe(onSuccess: { (response) in
                // MARK
                // Exchange token identitas to get token pantau
                // Save this token
                NetworkService.instance.requestObject(
                    PantauAuthAPI.callback(code: "",
                                           provider: response.accessToken),
                    c: PantauAuthResponse.self)
                    .subscribe(onSuccess: { (response) in
                        KeychainService.remove(type: NetworkKeychainKind.token)
                        KeychainService.remove(type: NetworkKeychainKind.refreshToken)
                        AppState.save(response)
                        self.appCoordinator = AppCoordinator(window: self.window!)
                        self.appCoordinator.start()
                            .subscribe()
                            .disposed(by: self.disposeBag)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        }
}

// MARK: - UNUserNotification
extension AppDelegate: UNUserNotificationCenterDelegate {
    // This method will be called when app received push notifications in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    { completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        InstanceID.instanceID().instanceID { (result, error) in
//            guard let `self` = self else { return }
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                UserDefaults.Account.reset(forKey: .instanceId)
                UserDefaults.Account.set(result.token, forKey: .instanceId)
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("received remote notification")
    }
    
}


extension AppDelegate {
    
    func configureRemoteNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        if let token = Messaging.messaging().fcmToken {
            print("FCM token: \(token)")
            UserDefaults.Account.reset(forKey: .instanceId)
            UserDefaults.Account.set(token, forKey: .instanceId)
        }
        
        //Added Code to display notification when app is in Foreground
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
    }
}
