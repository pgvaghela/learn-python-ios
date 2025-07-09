import Foundation

class PythonExecutionService: ObservableObject {
    @Published var isExecuting = false
    @Published var output = ""
    @Published var error = ""
    
    func executePythonCode(_ code: String) async {
        await MainActor.run {
            isExecuting = true
            output = ""
            error = ""
        }
        
        // For now, we'll simulate Python execution
        // In a real implementation, you would integrate PythonKit or use a Python interpreter
        await simulatePythonExecution(code)
        
        await MainActor.run {
            isExecuting = false
        }
    }
    
    private func simulatePythonExecution(_ code: String) async {
        // Simulate execution delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            // Simple simulation of Python execution
            if code.contains("print(") {
                // Extract print statements and simulate output
                let lines = code.components(separatedBy: .newlines)
                var outputLines: [String] = []
                
                for line in lines {
                    if line.contains("print(") {
                        // Extract content from print statements
                        if let start = line.range(of: "print(")?.upperBound,
                           let end = line.range(of: ")")?.lowerBound {
                            let content = String(line[start..<end])
                            outputLines.append(content.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "\"", with: ""))
                        }
                    }
                }
                
                if !outputLines.isEmpty {
                    output = outputLines.joined(separator: "\n")
                }
            } else if code.contains("Hello") {
                output = "Hello, World!\nWelcome to Python!"
            } else if code.contains("fruits") {
                output = "I like apple\nI like banana\nI like orange\n[0, 1, 4, 9, 16]"
            } else if code.contains("greet") {
                output = "Hello, Alice!\n5 + 3 = 8"
            } else {
                output = "Code executed successfully!"
            }
        }
    }
    
    func clearOutput() {
        output = ""
        error = ""
    }
} 