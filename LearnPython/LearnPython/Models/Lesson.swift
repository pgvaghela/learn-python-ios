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
            content: "The print() function is used to output text to the console. It's one of the most basic and commonly used functions in Python. You can print strings, numbers, and even the results of calculations.",
            codeExample: "print('Hello, World!')\nprint('Welcome to Python!')\nprint(2 + 3)\nprint('The result is:', 5)",
            difficulty: .beginner,
            category: .basics
        ),
        Lesson(
            title: "Variables and Data Types",
            description: "Understanding variables and basic data types in Python",
            content: "Variables are containers for storing data values. Python has several built-in data types including strings, integers, floats, and booleans. Variables are created when you assign a value to them.",
            codeExample: "name = 'Alice'\nage = 25\nheight = 5.6\nis_student = True\n\nprint(f'Name: {name}')\nprint(f'Age: {age}')\nprint(f'Height: {height}')\nprint(f'Student: {is_student}')",
            difficulty: .beginner,
            category: .basics
        ),
        Lesson(
            title: "Lists and Loops",
            description: "Working with lists and for loops",
            content: "Lists are ordered collections of items. For loops allow you to iterate over sequences like lists. List comprehension is a concise way to create lists based on existing sequences.",
            codeExample: "fruits = ['apple', 'banana', 'orange']\n\n# Iterating through a list\nfor fruit in fruits:\n    print(f'I like {fruit}')\n\n# List comprehension\nsquares = [x**2 for x in range(5)]\nprint(squares)\n\n# Adding items to a list\nfruits.append('grape')\nprint(fruits)",
            difficulty: .beginner,
            category: .dataStructures
        ),
        Lesson(
            title: "Dictionaries",
            description: "Working with key-value pairs in dictionaries",
            content: "Dictionaries store data as key-value pairs. They are unordered, changeable, and indexed. Dictionaries are perfect for storing related information together.",
            codeExample: "student = {\n    'name': 'Alice',\n    'age': 20,\n    'grades': [85, 90, 92]\n}\n\nprint(f'Student: {student[\"name\"]}')\nprint(f'Age: {student[\"age\"]}')\nprint(f'Average grade: {sum(student[\"grades\"]) / len(student[\"grades\"])}')\n\n# Adding new key-value pairs\nstudent['major'] = 'Computer Science'\nprint(student)",
            difficulty: .intermediate,
            category: .dataStructures
        ),
        Lesson(
            title: "Functions",
            description: "Creating and using functions in Python",
            content: "Functions are reusable blocks of code that perform specific tasks. They help organize code and avoid repetition. Functions can take parameters and return values.",
            codeExample: "def greet(name):\n    return f'Hello, {name}!'\n\ndef add_numbers(a, b):\n    return a + b\n\ndef calculate_area(length, width):\n    area = length * width\n    return area\n\n# Using the functions\nmessage = greet('Alice')\nresult = add_numbers(5, 3)\nrectangle_area = calculate_area(10, 5)\n\nprint(message)\nprint(f'5 + 3 = {result}')\nprint(f'Rectangle area: {rectangle_area}')",
            difficulty: .intermediate,
            category: .functions
        ),
        Lesson(
            title: "Classes and Objects",
            description: "Introduction to Object-Oriented Programming",
            content: "Classes are blueprints for creating objects. They encapsulate data and behavior. Object-oriented programming helps organize code and makes it more maintainable.",
            codeExample: "class Student:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n        self.grades = []\n    \n    def add_grade(self, grade):\n        self.grades.append(grade)\n    \n    def get_average(self):\n        if not self.grades:\n            return 0\n        return sum(self.grades) / len(self.grades)\n\n# Creating objects\nstudent1 = Student('Alice', 20)\nstudent1.add_grade(85)\nstudent1.add_grade(90)\n\nprint(f'{student1.name} average: {student1.get_average()}')",
            difficulty: .advanced,
            category: .oop
        ),
        Lesson(
            title: "File Handling",
            description: "Reading and writing files in Python",
            content: "Python provides built-in functions for file operations. You can read from files, write to files, and handle different file formats. Always remember to close files after use.",
            codeExample: "# Writing to a file\nwith open('example.txt', 'w') as file:\n    file.write('Hello, this is a test file!\\n')\n    file.write('This is the second line.')\n\n# Reading from a file\nwith open('example.txt', 'r') as file:\n    content = file.read()\n    print('File content:')\n    print(content)\n\n# Reading line by line\nwith open('example.txt', 'r') as file:\n    for line in file:\n        print(f'Line: {line.strip()}')",
            difficulty: .intermediate,
            category: .modules
        ),
        Lesson(
            title: "Error Handling",
            description: "Using try-except blocks to handle errors",
            content: "Error handling allows your program to gracefully handle unexpected situations. Try-except blocks catch exceptions and prevent your program from crashing.",
            codeExample: "def divide_numbers(a, b):\n    try:\n        result = a / b\n        return result\n    except ZeroDivisionError:\n        return 'Error: Cannot divide by zero'\n    except TypeError:\n        return 'Error: Please provide numbers'\n\n# Testing the function\nprint(divide_numbers(10, 2))\nprint(divide_numbers(10, 0))\nprint(divide_numbers('10', 2))\n\n# Using try-except with file operations\ntry:\n    with open('nonexistent.txt', 'r') as file:\n        content = file.read()\nexcept FileNotFoundError:\n    print('File not found!')",
            difficulty: .intermediate,
            category: .functions
        )
    ]
} 