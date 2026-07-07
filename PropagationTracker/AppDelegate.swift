import SwiftUI
import FirebaseCore
import FirebaseInstallations
import FirebaseRemoteConfigInternal
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    weak var initialVC: ViewController?
    static var orientationLock = UIInterfaceOrientationMask.all
    private var remoteConfig: RemoteConfig?
    private let hasRequestedReviewKey = "hasRequestedReview"
    private let launchCountKey = "launchCount"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        remoteConfig = RemoteConfig.remoteConfig()
        setupRemoteConfig()
        
        let viewController = ViewController()
        initialVC = viewController
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
        
        start(viewController: viewController)

        requestAppOnSecondLaunch()

        return true
    }
    
    func requestApp() {
       if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
           SKStoreReviewController.requestReview(in: scene)
       }
    }

    func requestAppOnSecondLaunch() {
        let defaults = UserDefaults.standard
        let launchCount = defaults.integer(forKey: launchCountKey) + 1
        defaults.set(launchCount, forKey: launchCountKey)

        if launchCount == 2 {
            requestApp()
        }
    }
    
    func scheduleReviewRequest() {
        guard !UserDefaults.standard.bool(forKey: hasRequestedReviewKey) else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.requestApp()

            UserDefaults.standard.set(true, forKey: self.hasRequestedReviewKey)
        }
    }
    
    func setupRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig?.configSettings = settings
    }
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    
    func start(viewController: ViewController) {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "alwaysOpenApp") == true {
            DispatchQueue.main.async {
                viewController.openApp()
            }
            return
        }
        
        remoteConfig?.fetch { [weak self] status, error in
            guard let self = self else { return }
            
            if let _ = error {
                defaults.set(true, forKey: "alwaysOpenApp")
                DispatchQueue.main.async {
                    viewController.openApp()
                }
                return
            }
            
            if status == .success {
                self.remoteConfig?.activate { _, error in
                    DispatchQueue.main.async {
                        
                        if error != nil {
                            defaults.set(true, forKey: "alwaysOpenApp")
                            viewController.openApp()
                            return
                        }
                        
                        guard let stringFire = self.remoteConfig?.configValue(forKey: "propagation").stringValue,
                              !stringFire.isEmpty else {
                            defaults.set(true, forKey: "alwaysOpenApp")
                            viewController.openApp()
                            return
                        }
                        
                        if let finalURL = defaults.string(forKey: "value") {
                            viewController.openWebIfValid(stringURL: finalURL)
                            return
                        }
                        
                        let stringURL = viewController.createURL(mainURL: stringFire)
                        
                        guard let url = URL(string: stringURL) else {
                            defaults.set(true, forKey: "alwaysOpenApp")
                            viewController.openApp()
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(url) {
                            viewController.openWebIfValid(stringURL: stringURL)
                        } else {
                            defaults.set(true, forKey: "alwaysOpenApp")
                            viewController.openApp()
                        }
                    }
                }
                
            } else {
                defaults.set(true, forKey: "alwaysOpenApp")
                DispatchQueue.main.async {
                    viewController.openApp()
                }
            }
        }
    }
}
