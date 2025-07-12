import SwiftUI
import WebKit

import UIKit

struct CodeEditorView: UIViewRepresentable {
    @Binding var code: String
    let onCodeChange: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        
        // Add message handler
        webView.configuration.userContentController.add(context.coordinator, name: "codeChanged")
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlContent = createHTMLContent(code: code)
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createHTMLContent(code: String) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.css">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/theme/monokai.min.css">
            <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/mode/python/python.min.js"></script>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background-color: #272822;
                    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
                }
                .CodeMirror {
                    height: 100vh;
                    font-size: 14px;
                    line-height: 1.5;
                }
                .CodeMirror-linenumbers {
                    color: #75715e;
                }
                .CodeMirror-cursor {
                    border-left: 2px solid #f8f8f2;
                }
            </style>
        </head>
        <body>
            <textarea id="editor">\(code)</textarea>
            <script>
                var editor = CodeMirror.fromTextArea(document.getElementById("editor"), {
                    mode: "python",
                    theme: "monokai",
                    lineNumbers: true,
                    indentUnit: 4,
                    tabSize: 4,
                    indentWithTabs: false,
                    lineWrapping: true,
                    autofocus: true,
                    extraKeys: {
                        "Tab": function(cm) {
                            if (cm.somethingSelected()) {
                                cm.indentSelection("add");
                            } else {
                                cm.replaceSelection("    ", "end");
                            }
                        }
                    }
                });
                
                editor.on("change", function(cm) {
                    var code = cm.getValue();
                    window.webkit.messageHandlers.codeChanged.postMessage(code);
                });
                
                // Set initial value
                editor.setValue(`\(code.replacingOccurrences(of: "`", with: "\\`"))`);
            </script>
        </body>
        </html>
        """
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: CodeEditorView
        
        init(_ parent: CodeEditorView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "codeChanged" {
                if let code = message.body as? String {
                    DispatchQueue.main.async {
                        self.parent.onCodeChange(code)
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("""
                var editor = document.querySelector('.CodeMirror').CodeMirror;
                if (editor) {
                    editor.on("change", function(cm) {
                        var code = cm.getValue();
                        window.webkit.messageHandlers.codeChanged.postMessage(code);
                    });
                }
            """)
        }
    }
}

#else

// Fallback for other platforms (macOS, visionOS)
struct CodeEditorView: View {
    @Binding var code: String
    let onCodeChange: (String) -> Void
    
    var body: some View {
        SimpleCodeEditorView(code: $code, onCodeChange: onCodeChange)
    }
}

#endif 
