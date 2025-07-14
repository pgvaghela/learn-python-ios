import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @StateObject private var executionService = PythonExecutionService()
    @State private var currentCode: String
    @State private var showingOutput = false
    @State private var isCompleted = false
    @State private var useSimpleEditor = false
    
    init(lesson: Lesson) {
        self.lesson = lesson
        self._currentCode = State(initialValue: lesson.codeExample)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Lesson Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(lesson.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(isCompleted ? "Completed ✓" : "Mark Complete") {
                            isCompleted.toggle()
                        }
                        .foregroundColor(isCompleted ? .green : .blue)
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
                VStack(alignment: .leading, spacing: 16) {
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
                    
                    // Code Editor
                    if useSimpleEditor {
                        SimpleCodeEditorView(code: $currentCode) { newCode in
                            currentCode = newCode
                        }
                        .frame(height: 300)
                    } else {
                        CodeEditorView(code: $currentCode) { newCode in
                            currentCode = newCode
                        }
                        .frame(height: 300)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Execution Controls
                    HStack {
                        Button(action: {
                            Task {
                                await executionService.executePythonCode(currentCode)
                                showingOutput = true
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
                
                // Output Section
                if showingOutput || !executionService.output.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Output")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                if !executionService.output.isEmpty {
                                    Text(executionService.output)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.green)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                
                                if !executionService.error.isEmpty {
                                    Text(executionService.error)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundColor(.red)
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
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
        LessonDetailView(lesson: Lesson.sampleLessons[0])
    }
} 