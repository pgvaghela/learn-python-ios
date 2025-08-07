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
        // Force API loading - don't use hardcoded lessons
        Task {
            await fetchLessonsFromAPI()
        }
    }
    
    private func fetchLessonsFromAPI() async {
        print("🔵 LessonsViewModel: Starting to fetch lessons from API...")
        isLoading = true
        error = nil
        
        // Test connection first
        let connectionTest = await lessonService.testConnection()
        print("🔵 LessonsViewModel: Connection test result: \(connectionTest)")
        
        if !connectionTest {
            print("❌ LessonsViewModel: Cannot connect to backend - using hardcoded lessons")
            lessons = Lesson.sampleLessons
            isLoading = false
            return
        }
        
        await lessonService.fetchLessons()
        
        print("🔵 LessonsViewModel: LessonService returned \(lessonService.lessons.count) lessons")
        print("🔵 LessonsViewModel: LessonService error: \(lessonService.error ?? "none")")
        
        if !lessonService.lessons.isEmpty {
            lessons = lessonService.lessons
            print("✅ LessonsViewModel: Loaded \(lessons.count) lessons from API")
            
            // Debug: Print difficulty levels of first few lessons
            for (index, lesson) in lessons.prefix(5).enumerated() {
                print("🔵 LessonsViewModel: Lesson \(index + 1): '\(lesson.title)' - Difficulty: \(lesson.difficulty)")
            }
            
            // Debug: Count lessons by difficulty
            let difficultyCounts = Dictionary(grouping: lessons, by: { $0.difficulty })
                .mapValues { $0.count }
            print("🔵 LessonsViewModel: Difficulty breakdown: \(difficultyCounts)")
            
        } else if lessonService.error != nil {
            print("⚠️ LessonsViewModel: API error: \(lessonService.error ?? "Unknown error")")
            print("📱 LessonsViewModel: Falling back to local lessons")
            lessons = Lesson.sampleLessons
        } else {
            print("⚠️ LessonsViewModel: No lessons returned from API and no error")
            print("📱 LessonsViewModel: Falling back to local lessons")
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
        print("🔄 LessonsViewModel: Manual refresh requested")
        Task {
            await fetchLessonsFromAPI()
        }
    }
    
    func testAPIConnection() {
        print("🧪 LessonsViewModel: Testing API connection...")
        Task {
            await fetchLessonsFromAPI()
        }
    }
    
    func forceRefreshFromAPI() {
        print("🔄 LessonsViewModel: Force refresh from API requested")
        lessons = [] // Clear current lessons
        Task {
            await fetchLessonsFromAPI()
        }
    }
} 