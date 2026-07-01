
import UIKit
import SwiftUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let onbScreen = SplashView()
        let hostContr = UIHostingController(rootView: onbScreen)
        
        addChild(hostContr)
        view.addSubview(hostContr.view)
        hostContr.didMove(toParent: self)
        
        hostContr.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostContr.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostContr.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostContr.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostContr.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func openWeb(stringURL: String) {
        DispatchQueue.main.async {
            let vc = SecondView(targetUrl: URL(string: stringURL) ?? .applicationDirectory)
            let hostingController = UIHostingController(rootView: vc)
            self.setRootViewController(hostingController)
        }
    }

    func createURL(mainURL: String) -> (String) {
        return mainURL
    }
    
    func openApp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let onboardingScreen = PropagationTracker()
            let hostingController = UIHostingController(rootView: onboardingScreen)
            self.setRootViewController(hostingController)
        }
    }
    
    func setRootViewController(_ viewController: UIViewController) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController = viewController
        }
    }
}

