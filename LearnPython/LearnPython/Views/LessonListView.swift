import SwiftUI

struct LessonListView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Progress Header
                    VStack(spacing: 12) {
                        HStack {
                            Text("Your Progress")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button("Reset") {
                                viewModel.resetProgress()
                            }
                            .foregroundColor(.red)
                        }
                        
                        ProgressView(value: viewModel.progressPercentage / 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        HStack {
                            Text("\(viewModel.completedLessons.count) of \(viewModel.lessons.count) completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.progressPercentage))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    
                    // Filter Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(
                                title: "All",
                                isSelected: viewModel.currentFilter == nil && viewModel.currentCategory == nil
                            ) {
                                viewModel.currentFilter = nil
                                viewModel.currentCategory = nil
                            }
                            
                            ForEach(Lesson.LessonDifficulty.allCases, id: \.self) { difficulty in
                                FilterButton(
                                    title: difficulty.rawValue,
                                    isSelected: viewModel.currentFilter == difficulty
                                ) {
                                    viewModel.currentFilter = difficulty
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                    
                    // Loading State
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading lessons from server...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Error State
                    if let error = viewModel.error {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Text("Using local lessons")
                                .font(.headline)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                viewModel.refreshLessons()
                            }
                            .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Lessons List - Now using LazyVStack instead of List
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredLessons) { lesson in
                            NavigationLink(destination: LessonDetailView(lesson: lesson, lessonsViewModel: viewModel)) {
                                LessonRowView(lesson: lesson, isCompleted: viewModel.isLessonCompleted(lesson))
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Add bottom padding for better scrolling
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("Learn Python")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await Task {
                    viewModel.refreshLessons()
                }.value
            }
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion indicator
            Circle()
                .fill(isCompleted ? Color.green : Color(.systemGray4))
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.green, lineWidth: isCompleted ? 0 : 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(lesson.difficulty.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor.opacity(0.2))
                        .foregroundColor(difficultyColor)
                        .cornerRadius(8)
                }
                
                Text(lesson.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(lesson.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
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
    LessonListView()
} 