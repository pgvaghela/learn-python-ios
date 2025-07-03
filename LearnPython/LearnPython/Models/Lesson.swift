import Foundation

struct Lesson: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let content: String
    let codeExample: String
    let difficulty: LessonDifficulty
    let category: LessonCategory
    
    enum LessonDifficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
    
    enum LessonCategory: String, CaseIterable, Codable {
        case basics = "Basics"
        case dataStructures = "Data Structures"
        case functions = "Functions"
        case oop = "Object-Oriented Programming"
        case modules = "Modules & Libraries"
    }
}

// Sample lessons data
extension Lesson {
    static let sampleLessons: [Lesson] = [
        Lesson(
            title: "Hello World",
            description: "Learn how to print text in Python",
            content: "The print() function is used to output text to the console. It's one of the most basic and commonly used functions in Python.",
            codeExample: "print('Hello, World!')\nprint('Welcome to Python!')",
            difficulty: .beginner,
            category: .basics
        ),
        Lesson(
            title: "Variables and Data Types",
            description: "Understanding variables and basic data types in Python",
            content: "Variables are containers for storing data values. Python has several built-in data types including strings, integers, floats, and booleans.",
            codeExample: "name = 'Alice'\nage = 25\nheight = 5.6\nis_student = True\n\nprint(f'Name: {name}')\nprint(f'Age: {age}')\nprint(f'Height: {height}')\nprint(f'Student: {is_student}')",
            difficulty: .beginner,
            category: .basics
        ),
        Lesson(
            title: "Lists and Loops",
            description: "Working with lists and for loops",
            content: "Lists are ordered collections of items. For loops allow you to iterate over sequences like lists.",
            codeExample: "fruits = ['apple', 'banana', 'orange']\n\n# Iterating through a list\nfor fruit in fruits:\n    print(f'I like {fruit}')\n\n# List comprehension\nsquares = [x**2 for x in range(5)]\nprint(squares)",
            difficulty: .beginner,
            category: .dataStructures
        ),
        Lesson(
            title: "Functions",
            description: "Creating and using functions in Python",
            content: "Functions are reusable blocks of code that perform specific tasks. They help organize code and avoid repetition.",
            codeExample: "def greet(name):\n    return f'Hello, {name}!'\n\ndef add_numbers(a, b):\n    return a + b\n\n# Using the functions\nmessage = greet('Alice')\nresult = add_numbers(5, 3)\nprint(message)\nprint(f'5 + 3 = {result}')",
            difficulty: .intermediate,
            category: .functions
        )
    ]
} 