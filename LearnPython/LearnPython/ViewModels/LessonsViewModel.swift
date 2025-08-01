import Foundation
import SwiftUI

@MainActor
class LessonsViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var selectedLesson: Lesson?
    @Published var completedLessons: Set<UUID> = []
    @Published var currentFilter: Lesson.LessonDifficulty?
    @Published var currentCategory: Lesson.LessonCategory?
    @Published var isLoading = false
    @Published var error: String?
    
    private let lessonService = LessonService()
    
    init() {
        loadLessons()
        loadProgress()
    }
    
    private func loadLessons() {
        // First try to load from backend API
        Task {
            await fetchLessonsFromAPI()
        }
        
        // Fallback to local lessons if API fails
        if lessons.isEmpty {
            lessons = Lesson.sampleLessons
        }
    }
    
    private func fetchLessonsFromAPI() async {
        isLoading = true
        error = nil
        
        await lessonService.fetchLessons()
        
        if !lessonService.lessons.isEmpty {
            lessons = lessonService.lessons
            print("✅ Loaded \(lessons.count) lessons from API")
        } else if lessonService.error != nil {
            print("⚠️ API error: \(lessonService.error ?? "Unknown error")")
            print("📱 Falling back to local lessons")
            lessons = Lesson.sampleLessons
        }
        
        isLoading = false
    }
    
    private func loadProgress() {
        // In a real app, this would load from UserDefaults or Core Data
        completedLessons = []
    }
    
    func markLessonAsCompleted(_ lesson: Lesson) {
        completedLessons.insert(lesson.id)
        saveProgress()
    }
    
    func isLessonCompleted(_ lesson: Lesson) -> Bool {
        completedLessons.contains(lesson.id)
    }
    
    private func saveProgress() {
        // In a real app, this would save to UserDefaults or Core Data
    }
    
    var filteredLessons: [Lesson] {
        var filtered = lessons
        
        if let filter = currentFilter {
            filtered = filtered.filter { $0.difficulty == filter }
        }
        
        if let category = currentCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    var progressPercentage: Double {
        guard !lessons.isEmpty else { return 0 }
        return Double(completedLessons.count) / Double(lessons.count) * 100
    }
    
    func resetProgress() {
        completedLessons.removeAll()
        saveProgress()
    }
    
    func refreshLessons() {
        Task {
            await fetchLessonsFromAPI()
        }
    }
} 