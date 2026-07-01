
import Foundation
import SwiftUI
import WebKit

struct SecondView: View {
    let targetUrl: URL
    
    var body: some View {
        NavigationView {
            WebContainer(targetUrl: targetUrl)
                .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(Color.black.ignoresSafeArea())
    }
}

struct WebContainer: View {
    let targetUrl: URL
    
    @State private var webView = WKWebView()
    @State private var canGoBack = false
    @State private var canGoForward = false
    
    @State private var sheetURL: URL?
    @State private var showSheet = false
    
    @AppStorage("value") private var savedURL: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            WebWrapper(
                webView: $webView,
                targetUrl: targetUrl,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                savedURL: $savedURL,
                onLinkTap: { url in
                    sheetURL = url
                    showSheet = true
                }
            )
            
            HStack {
                Button {
                    if webView.canGoBack { webView.goBack() }
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2)
                        .foregroundColor(canGoBack ? .white : .gray)
                }
                
                Spacer()
                
                Button {
                    if webView.canGoForward { webView.goForward() }
                } label: {
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                        .foregroundColor(canGoForward ? .white : .gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .background(Color.black)
        }
        .background(Color.black)
        .sheet(isPresented: $showSheet) {
            if let sheetURL {
                SecondView(targetUrl: sheetURL)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}


struct WebWrapper: UIViewRepresentable {
    @Binding var webView: WKWebView
    let targetUrl: URL
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var savedURL: String
    let onLinkTap: (URL) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.websiteDataStore = .default()
        
        let wk = WKWebView(frame: .zero, configuration: config)
        wk.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        wk.navigationDelegate = context.coordinator
        wk.uiDelegate = context.coordinator
        
        wk.scrollView.contentInsetAdjustmentBehavior = .never
        wk.allowsBackForwardNavigationGestures = true
        
        let request = URLRequest(url: targetUrl)
        wk.load(request)
        
        DispatchQueue.main.async {
            self.webView = wk
        }
        
        return wk
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebWrapper
        
        var popupWebView: WKWebView?
        var closeButton: UIButton?
        
        init(_ parent: WebWrapper) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.canGoBack = webView.canGoBack
                self.parent.canGoForward = webView.canGoForward
                
                if let final = webView.url?.absoluteString,
                   self.parent.savedURL.isEmpty {
                    self.parent.savedURL = final
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
            reloadSafely(webView)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError: Error) {
            reloadSafely(webView)
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            reloadSafely(webView)
        }
        
        private func reloadSafely(_ webView: WKWebView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                webView.reload()
            }
        }
        
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {

            let popup = WKWebView(frame: webView.bounds, configuration: configuration)
            popup.navigationDelegate = self
            popup.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            popup.uiDelegate = self
            popup.translatesAutoresizingMaskIntoConstraints = false

            guard let parentView = webView.superview else { return nil }
            parentView.addSubview(popup)

            NSLayoutConstraint.activate([
                popup.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                popup.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                popup.topAnchor.constraint(equalTo: parentView.topAnchor),
                popup.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
            ])

            let close = UIButton(type: .system)
            close.setTitle("✕", for: .normal)
            close.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
            close.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            close.tintColor = .white
            close.layer.cornerRadius = 20
            close.translatesAutoresizingMaskIntoConstraints = false
            close.addTarget(self, action: #selector(closePopup), for: .touchUpInside)

            parentView.addSubview(close)

            NSLayoutConstraint.activate([
                close.widthAnchor.constraint(equalToConstant: 40),
                close.heightAnchor.constraint(equalToConstant: 40),
                close.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 10),
                close.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16)
            ])

            self.popupWebView = popup
            self.closeButton = close

            return popup
        }

        @objc func closePopup() {
            popupWebView?.removeFromSuperview()
            closeButton?.removeFromSuperview()
            popupWebView = nil
            closeButton = nil
        }

        func webViewDidClose(_ webView: WKWebView) {
            if webView == popupWebView {
                closePopup()
            }
        }
        
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
                     requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                     initiatedByFrame frame: WKFrameInfo,
                     type: WKMediaCaptureType,
                     decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }
    }
}
