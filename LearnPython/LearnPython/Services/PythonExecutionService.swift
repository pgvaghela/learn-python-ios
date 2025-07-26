import Foundation

class PythonExecutionService: ObservableObject {
    @Published var isExecuting = false
    @Published var output = ""
    @Published var error = ""
    
    private let baseURL = "http://127.0.0.1:8000"
    
    func executePythonCode(_ code: String) async {
        print("🔵 Starting Python code execution...")
        print("🔵 Code to execute: \(code)")
        print("🔵 Backend URL: \(baseURL)")
        
        await MainActor.run {
            isExecuting = true
            output = ""
            error = ""
        }
        
        do {
            let url = URL(string: "\(baseURL)/execute")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let requestBody = ["code": code]
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
            
            print("🔵 Sending request to: \(url)")
            print("🔵 Request body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("🔵 Received response: \(response)")
            print("🔵 Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            await MainActor.run {
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔵 HTTP Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        do {
                            let result = try JSONDecoder().decode(CodeExecutionResult.self, from: data)
                            print("🔵 Decoded result: \(result)")
                            if result.success {
                                self.output = result.output
                                self.error = result.error
                                print("🔵 Success! Output: \(result.output)")
                            } else {
                                self.output = ""
                                self.error = result.error
                                print("🔵 Error! Error: \(result.error)")
                            }
                        } catch {
                            self.error = "Failed to parse response: \(error.localizedDescription)"
                            print("🔵 Parse error: \(error)")
                        }
                    } else {
                        self.error = "Server error: \(httpResponse.statusCode)"
                        print("🔵 Server error: \(httpResponse.statusCode)")
                    }
                } else {
                    self.error = "Invalid response from server"
                    print("🔵 Invalid response")
                }
                self.isExecuting = false
            }
        } catch {
            print("🔵 Network error: \(error)")
            await MainActor.run {
                self.error = "Network error: \(error.localizedDescription)"
                self.isExecuting = false
            }
        }
    }
    
    func clearOutput() {
        output = ""
        error = ""
    }
}

// Response models for the API
struct CodeExecutionResult: Codable {
    let output: String
    let error: String
    let success: Bool
} 