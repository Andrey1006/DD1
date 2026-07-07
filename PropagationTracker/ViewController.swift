
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

    func openWebIfValid(stringURL: String) {
        guard let url = URL(string: stringURL) else {
            openWeb(stringURL: stringURL)
            return
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { [weak self] _, response, _ in
            guard let self = self else { return }

            if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                self.openApp()
            } else {
                self.openWeb(stringURL: stringURL)
            }
        }.resume()
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

