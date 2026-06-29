import SwiftUI
import WebKit

struct WebLink: Identifiable {
    let id = UUID()
    let title: String
    let url: URL
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var progress: Double

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(context.coordinator, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.load(URLRequest(url: url))
        context.coordinator.webView = webView
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.removeObserver(coordinator, forKeyPath: "estimatedProgress")
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        weak var webView: WKWebView?

        init(_ parent: WebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                   change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "estimatedProgress", let webView = object as? WKWebView {
                parent.progress = webView.estimatedProgress
            }
        }
    }
}

struct WebViewSheet: View {
    let link: WebLink
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var progress: Double = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AppTheme.background.ignoresSafeArea()

                WebView(url: link.url, isLoading: $isLoading, progress: $progress)
                    .ignoresSafeArea(edges: .bottom)

                if isLoading && progress < 1 {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                        .tint(AppTheme.primary)
                }
            }
            .navigationTitle(link.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}
