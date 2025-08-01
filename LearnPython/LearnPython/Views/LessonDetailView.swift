import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @StateObject private var executionService = PythonExecutionService()
    @ObservedObject var lessonsViewModel: LessonsViewModel
    @State private var currentCode: String
    @State private var showingOutput = false
    @State private var useSimpleEditor = false
    
    init(lesson: Lesson, lessonsViewModel: LessonsViewModel) {
        self.lesson = lesson
        self.lessonsViewModel = lessonsViewModel
        self._currentCode = State(initialValue: lesson.codeExample)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                // Lesson Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(lesson.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(lessonsViewModel.isLessonCompleted(lesson) ? "Completed ✓" : "Mark Complete") {
                            if lessonsViewModel.isLessonCompleted(lesson) {
                                // Remove from completed
                                lessonsViewModel.completedLessons.remove(lesson.id)
                            } else {
                                // Add to completed
                                lessonsViewModel.markLessonAsCompleted(lesson)
                            }
                        }
                        .foregroundColor(lessonsViewModel.isLessonCompleted(lesson) ? .green : .blue)
                        .fontWeight(.medium)
                    }
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label(lesson.difficulty.rawValue, systemImage: "star.fill")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(difficultyColor.opacity(0.2))
                            .foregroundColor(difficultyColor)
                            .cornerRadius(8)
                        
                        Label(lesson.category.rawValue, systemImage: "folder.fill")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Lesson Content
                VStack(alignment: .leading, spacing: 16) {
                    Text("Lesson Content")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(lesson.content)
                        .font(.body)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Code Editor Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Code Editor")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("Reset Code") {
                            currentCode = lesson.codeExample
                        }
                        .foregroundColor(.blue)
                        
                        Button(useSimpleEditor ? "Use Advanced" : "Use Simple") {
                            useSimpleEditor.toggle()
                        }
                        .foregroundColor(.orange)
                    }
                    
                    // Code Editor - Reduced height
                    if useSimpleEditor {
                        SimpleCodeEditorView(code: $currentCode) { newCode in
                            currentCode = newCode
                        }
                        .frame(height: 200)
                    } else {
                        CodeEditorView(code: $currentCode) { newCode in
                            currentCode = newCode
                        }
                        .frame(height: 200)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Execution Controls
                    HStack {
                        Button(action: {
                            Task {
                                print("Executing code: \(currentCode)")
                                await executionService.executePythonCode(currentCode)
                                showingOutput = true
                                print("Execution completed. Output: \(executionService.output), Error: \(executionService.error)")
                            }
                        }) {
                            HStack {
                                if executionService.isExecuting {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "play.fill")
                                }
                                Text(executionService.isExecuting ? "Running..." : "Run Code")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                        .disabled(executionService.isExecuting)
                        
                        Button("Clear Output") {
                            executionService.clearOutput()
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Output Section - More compact and always visible
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Output")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        if executionService.isExecuting {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    
                    // Output content
                    if !executionService.output.isEmpty {
                        Text(executionService.output)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.green)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    if !executionService.error.isEmpty {
                        Text(executionService.error)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    if executionService.output.isEmpty && executionService.error.isEmpty && !executionService.isExecuting {
                        Text("No output yet. Click 'Run Code' to execute your Python code.")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Add some bottom padding to ensure scrolling works
                Spacer(minLength: 100)
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
    
    private var difficultyColor: Color {
        switch lesson.difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        }
    }
}

#Preview {
    NavigationView {
        LessonDetailView(lesson: Lesson.sampleLessons[0], lessonsViewModel: LessonsViewModel())
    }
} 