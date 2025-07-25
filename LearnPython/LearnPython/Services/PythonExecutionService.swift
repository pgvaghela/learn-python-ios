import Foundation

class PythonExecutionService: ObservableObject {
    @Published var isExecuting = false
    @Published var output = ""
    @Published var error = ""
    
    private let baseURL = "http://127.0.0.1:8000"
    
    func executePythonCode(_ code: String) async {
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
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            await MainActor.run {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        do {
                            let result = try JSONDecoder().decode(CodeExecutionResult.self, from: data)
                            if result.success {
                                self.output = result.output
                                self.error = result.error
                            } else {
                                self.output = ""
                                self.error = result.error
                            }
                        } catch {
                            self.error = "Failed to parse response: \(error.localizedDescription)"
                        }
                    } else {
                        self.error = "Server error: \(httpResponse.statusCode)"
                    }
                } else {
                    self.error = "Invalid response from server"
                }
                self.isExecuting = false
            }
        } catch {
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