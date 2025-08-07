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
            title: "Basic Math Operations",
            description: "Performing mathematical calculations in Python",
            content: "Python can perform all basic mathematical operations. You can use +, -, *, / for addition, subtraction, multiplication, and division. Python also supports more advanced operations like exponentiation (**) and modulo (%).",
            codeExample: "# Basic arithmetic\nx = 10\ny = 3\n\naddition = x + y\nsubtraction = x - y\nmultiplication = x * y\ndivision = x / y\nmodulo = x % y\nexponent = x ** y\n\nprint(f'Addition: {addition}')\nprint(f'Subtraction: {subtraction}')\nprint(f'Multiplication: {multiplication}')\nprint(f'Division: {division}')\nprint(f'Modulo: {modulo}')\nprint(f'Exponent: {exponent}')",
            difficulty: .beginner,
            category: .basics
        ),
        Lesson(
            title: "String Operations",
            description: "Working with text and string manipulation",
            content: "Strings are sequences of characters. Python provides many built-in methods for string manipulation including concatenation, slicing, formatting, and various string methods.",
            codeExample: "text = 'Hello, Python!'\n\n# String length\nprint(f'Length: {len(text)}')\n\n# String slicing\nprint(f'First 5 characters: {text[:5]}')\nprint(f'Last 6 characters: {text[-6:]}')\n\n# String methods\nprint(f'Uppercase: {text.upper()}')\nprint(f'Lowercase: {text.lower()}')\nprint(f'Title case: {text.title()}')\n\n# String concatenation\nfirst = 'Hello'\nsecond = 'World'\nresult = first + ' ' + second\nprint(f'Concatenated: {result}')",
            difficulty: .beginner,
            category: .basics
        ),
        Lesson(
            title: "Lists and Loops",
            description: "Working with lists and for loops",
            content: "Lists are ordered collections of items. For loops allow you to iterate over sequences like lists. List comprehension is a concise way to create lists based on existing sequences.",
            codeExample: "fruits = ['apple', 'banana', 'orange']\n\n# Iterating through a list\nfor fruit in fruits:\n    print(f'I like {fruit}')\n\n# List comprehension\nsquares = [x**2 for x in range(5)]\nprint(squares)\n\n# Adding items to a list\nfruits.append('grape')\nprint(fruits)\n\n# List methods\nnumbers = [3, 1, 4, 1, 5, 9, 2, 6]\nprint(f'Original: {numbers}')\nprint(f'Sorted: {sorted(numbers)}')\nprint(f'Sum: {sum(numbers)}')\nprint(f'Max: {max(numbers)}')",
            difficulty: .beginner,
            category: .dataStructures
        ),
        Lesson(
            title: "Conditional Statements",
            description: "Using if, elif, and else statements",
            content: "Conditional statements allow your program to make decisions based on certain conditions. You can use if, elif (else if), and else to control the flow of your program.",
            codeExample: "age = 18\ntemperature = 25\n\n# Simple if statement\nif age >= 18:\n    print('You are an adult')\nelse:\n    print('You are a minor')\n\n# Multiple conditions\nif temperature < 0:\n    print('It is freezing')\nelif temperature < 20:\n    print('It is cold')\nelif temperature < 30:\n    print('It is warm')\nelse:\n    print('It is hot')\n\n# Complex conditions\nscore = 85\nif score >= 90:\n    grade = 'A'\nelif score >= 80:\n    grade = 'B'\nelif score >= 70:\n    grade = 'C'\nelse:\n    grade = 'F'\nprint(f'Grade: {grade}')",
            difficulty: .beginner,
            category: .basics
        ),
        Lesson(
            title: "Dictionaries",
            description: "Working with key-value pairs in dictionaries",
            content: "Dictionaries store data as key-value pairs. They are unordered, changeable, and indexed. Dictionaries are perfect for storing related information together.",
            codeExample: "student = {\n    'name': 'Alice',\n    'age': 20,\n    'grades': [85, 90, 92]\n}\n\nprint(f'Student: {student[\"name\"]}')\nprint(f'Age: {student[\"age\"]}')\nprint(f'Average grade: {sum(student[\"grades\"]) / len(student[\"grades\"])}')\n\n# Adding new key-value pairs\nstudent['major'] = 'Computer Science'\nprint(student)\n\n# Dictionary methods\nprint(f'Keys: {list(student.keys())}')\nprint(f'Values: {list(student.values())}')\nprint(f'Items: {list(student.items())}')",
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
            title: "List Comprehensions",
            description: "Advanced list creation and manipulation",
            content: "List comprehensions provide a concise way to create lists based on existing sequences. They are more readable and often faster than traditional for loops.",
            codeExample: "# Basic list comprehension\nsquares = [x**2 for x in range(10)]\nprint(f'Squares: {squares}')\n\n# List comprehension with condition\neven_squares = [x**2 for x in range(10) if x % 2 == 0]\nprint(f'Even squares: {even_squares}')\n\n# Nested list comprehension\nmatrix = [[i+j for j in range(3)] for i in range(3)]\nprint(f'Matrix: {matrix}')\n\n# Dictionary comprehension\nword_lengths = {word: len(word) for word in ['apple', 'banana', 'cherry']}\nprint(f'Word lengths: {word_lengths}')\n\n# Set comprehension\nunique_squares = {x**2 for x in range(10)}\nprint(f'Unique squares: {unique_squares}')",
            difficulty: .intermediate,
            category: .dataStructures
        ),
        Lesson(
            title: "Error Handling",
            description: "Using try-except blocks to handle errors",
            content: "Error handling allows your program to gracefully handle unexpected situations. Try-except blocks catch exceptions and prevent your program from crashing.",
            codeExample: "def divide_numbers(a, b):\n    try:\n        result = a / b\n        return result\n    except ZeroDivisionError:\n        return 'Error: Cannot divide by zero'\n    except TypeError:\n        return 'Error: Please provide numbers'\n\n# Testing the function\nprint(divide_numbers(10, 2))\nprint(divide_numbers(10, 0))\nprint(divide_numbers('10', 2))\n\n# Using try-except with file operations\ntry:\n    with open('nonexistent.txt', 'r') as file:\n        content = file.read()\nexcept FileNotFoundError:\n    print('File not found!')\n\n# Custom exceptions\ntry:\n    age = int(input('Enter age: '))\n    if age < 0:\n        raise ValueError('Age cannot be negative')\nexcept ValueError as e:\n    print(f'Invalid input: {e}')",
            difficulty: .intermediate,
            category: .functions
        ),
        Lesson(
            title: "File Handling",
            description: "Reading and writing files in Python",
            content: "Python provides built-in functions for file operations. You can read from files, write to files, and handle different file formats. Always remember to close files after use.",
            codeExample: "# Writing to a file\nwith open('example.txt', 'w') as file:\n    file.write('Hello, this is a test file!\\n')\n    file.write('This is the second line.')\n\n# Reading from a file\nwith open('example.txt', 'r') as file:\n    content = file.read()\n    print('File content:')\n    print(content)\n\n# Reading line by line\nwith open('example.txt', 'r') as file:\n    for line in file:\n        print(f'Line: {line.strip()}')\n\n# Working with CSV-like data\ndata = [['Name', 'Age'], ['Alice', '25'], ['Bob', '30']]\nwith open('data.csv', 'w') as file:\n    for row in data:\n        file.write(','.join(row) + '\\n')",
            difficulty: .intermediate,
            category: .modules
        ),
        Lesson(
            title: "Classes and Objects",
            description: "Introduction to Object-Oriented Programming",
            content: "Classes are blueprints for creating objects. They encapsulate data and behavior. Object-oriented programming helps organize code and makes it more maintainable.",
            codeExample: "class Student:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n        self.grades = []\n    \n    def add_grade(self, grade):\n        self.grades.append(grade)\n    \n    def get_average(self):\n        if not self.grades:\n            return 0\n        return sum(self.grades) / len(self.grades)\n    \n    def __str__(self):\n        return f'Student: {self.name}, Age: {self.age}'\n\n# Creating objects\nstudent1 = Student('Alice', 20)\nstudent1.add_grade(85)\nstudent1.add_grade(90)\n\nprint(student1)\nprint(f'{student1.name} average: {student1.get_average()}')",
            difficulty: .advanced,
            category: .oop
        ),
        Lesson(
            title: "Recursion",
            description: "Understanding recursive functions",
            content: "Recursion is when a function calls itself. It's a powerful programming technique that can solve complex problems by breaking them down into smaller, similar subproblems.",
            codeExample: "def factorial(n):\n    if n <= 1:\n        return 1\n    return n * factorial(n - 1)\n\ndef fibonacci(n):\n    if n <= 1:\n        return n\n    return fibonacci(n - 1) + fibonacci(n - 2)\n\ndef count_down(n):\n    if n <= 0:\n        print('Blast off!')\n        return\n    print(n)\n    count_down(n - 1)\n\n# Testing recursive functions\nprint(f'Factorial of 5: {factorial(5)}')\nprint(f'Fibonacci of 7: {fibonacci(7)}')\ncount_down(5)",
            difficulty: .advanced,
            category: .functions
        ),
        Lesson(
            title: "Decorators",
            description: "Using function decorators for code enhancement",
            content: "Decorators are functions that modify the behavior of other functions. They provide a way to add functionality to existing functions without modifying their code.",
            codeExample: "import time\n\ndef timer(func):\n    def wrapper(*args, **kwargs):\n        start = time.time()\n        result = func(*args, **kwargs)\n        end = time.time()\n        print(f'{func.__name__} took {end - start:.4f} seconds')\n        return result\n    return wrapper\n\ndef cache(func):\n    memo = {}\n    def wrapper(*args):\n        if args not in memo:\n            memo[args] = func(*args)\n        return memo[args]\n    return wrapper\n\n@timer\n@cache\ndef fibonacci(n):\n    if n <= 1:\n        return n\n    return fibonacci(n - 1) + fibonacci(n - 2)\n\nprint(fibonacci(10))",
            difficulty: .advanced,
            category: .functions
        ),
        Lesson(
            title: "Generators",
            description: "Creating memory-efficient iterators with generators",
            content: "Generators are functions that return an iterator. They use the 'yield' keyword and are memory efficient for large datasets since they generate values on-demand.",
            codeExample: "def number_generator(n):\n    for i in range(n):\n        yield i\n\ndef fibonacci_generator():\n    a, b = 0, 1\n    while True:\n        yield a\n        a, b = b, a + b\n\ndef even_numbers_generator(n):\n    for i in range(n):\n        if i % 2 == 0:\n            yield i\n\n# Using generators\nprint('Number generator:')\nfor num in number_generator(5):\n    print(num, end=' ')\nprint()\n\nprint('First 10 Fibonacci numbers:')\nfib = fibonacci_generator()\nfor _ in range(10):\n    print(next(fib), end=' ')\nprint()\n\nprint('Even numbers:')\nfor even in even_numbers_generator(10):\n    print(even, end=' ')\nprint()",
            difficulty: .advanced,
            category: .functions
        ),
        Lesson(
            title: "Data Structures Challenge",
            description: "Advanced problem solving with data structures",
            content: "This challenge combines multiple data structures to solve complex problems. You'll work with lists, dictionaries, sets, and custom data structures to implement efficient algorithms.",
            codeExample: "# Implementing a simple cache system\nclass Cache:\n    def __init__(self, max_size=3):\n        self.max_size = max_size\n        self.cache = {}\n        self.access_order = []\n    \n    def get(self, key):\n        if key in self.cache:\n            # Move to end (most recently used)\n            self.access_order.remove(key)\n            self.access_order.append(key)\n            return self.cache[key]\n        return None\n    \n    def put(self, key, value):\n        if key in self.cache:\n            self.access_order.remove(key)\n        elif len(self.cache) >= self.max_size:\n            # Remove least recently used\n            lru_key = self.access_order.pop(0)\n            del self.cache[lru_key]\n        \n        self.cache[key] = value\n        self.access_order.append(key)\n\n# Testing the cache\ncache = Cache(3)\ncache.put('A', 1)\ncache.put('B', 2)\ncache.put('C', 3)\nprint(f'Cache: {cache.cache}')\nprint(f'Get A: {cache.get(\"A\")}')\ncache.put('D', 4)\nprint(f'Cache after adding D: {cache.cache}')",
            difficulty: .advanced,
            category: .dataStructures
        )
    ]
} 