import Foundation

class PythonExecutionService: ObservableObject {
    @Published var isExecuting = false
    @Published var output = ""
    @Published var error = ""
    
    private let baseURL = "http://192.168.0.250:8000"
    
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

// Lesson fetching service
class LessonService: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let baseURL = "http://192.168.0.250:8000"
    
    func testConnection() async -> Bool {
        print("🧪 LessonService: Testing connection to \(baseURL)")
        do {
            let url = URL(string: "\(baseURL)/")!
            let (_, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🧪 LessonService: Connection test - Status: \(httpResponse.statusCode)")
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            print("🧪 LessonService: Connection test failed - \(error)")
            return false
        }
    }
    
    func fetchLessons() async {
        print("🔵 LessonService: Starting to fetch lessons...")
        print("🔵 LessonService: Base URL: \(baseURL)")
        
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let url = URL(string: "\(baseURL)/lessons")!
            print("🔵 LessonService: Making request to: \(url)")
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            print("🔵 LessonService: Received response: \(response)")
            print("🔵 LessonService: Data size: \(data.count) bytes")
            
            await MainActor.run {
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔵 LessonService: HTTP Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        do {
                            let apiLessons = try JSONDecoder().decode([APILesson].self, from: data)
                            print("🔵 LessonService: Successfully decoded \(apiLessons.count) lessons from API")
                            
                            // Convert API lessons to local lessons
                            self.lessons = apiLessons.map { apiLesson in
                                // Fix difficulty conversion - capitalize the first letter
                                let difficultyString = apiLesson.difficulty.prefix(1).uppercased() + apiLesson.difficulty.dropFirst().lowercased()
                                let difficulty = Lesson.LessonDifficulty(rawValue: difficultyString) ?? .beginner
                                let category = Lesson.LessonCategory(rawValue: apiLesson.category.lowercased()) ?? .basics
                                
                                print("🔵 LessonService: Converting lesson '\(apiLesson.title)' - difficulty: '\(apiLesson.difficulty)' -> '\(difficultyString)' -> \(difficulty)")
                                
                                return Lesson(
                                    title: apiLesson.title,
                                    description: apiLesson.description,
                                    content: apiLesson.content,
                                    codeExample: apiLesson.code_example,
                                    difficulty: difficulty,
                                    category: category
                                )
                            }
                            print("🔵 LessonService: Successfully converted \(self.lessons.count) lessons")
                        } catch {
                            print("🔵 LessonService: Failed to parse lessons: \(error)")
                            self.error = "Failed to parse lessons: \(error.localizedDescription)"
                        }
                    } else {
                        print("🔵 LessonService: Server error: \(httpResponse.statusCode)")
                        self.error = "Server error: \(httpResponse.statusCode)"
                    }
                } else {
                    print("🔵 LessonService: Invalid response from server")
                    self.error = "Invalid response from server"
                }
                self.isLoading = false
            }
        } catch {
            print("🔵 LessonService: Network error: \(error)")
            await MainActor.run {
                self.error = "Network error: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

// Response models for the API
struct CodeExecutionResult: Codable {
    let output: String
    let error: String
    let success: Bool
}

struct APILesson: Codable {
    let id: Int
    let title: String
    let description: String
    let content: String
    let code_example: String
    let difficulty: String
    let category: String
} 