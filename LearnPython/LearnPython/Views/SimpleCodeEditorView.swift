import SwiftUI

struct SimpleCodeEditorView: View {
    @Binding var code: String
    let onCodeChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with line numbers
            HStack {
                Text("Python Code Editor")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button("Clear") {
                    code = ""
                    onCodeChange("")
                }
                .foregroundColor(.red)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Code editor
            TextEditor(text: $code)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.primary)
                .background(Color(.systemBackground))
                .onChange(of: code) { newValue in
                    onCodeChange(newValue)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    SimpleCodeEditorView(code: .constant("print('Hello, World!')")) { _ in }
        .padding()
} 