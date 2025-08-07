from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import jwt
from datetime import datetime, timedelta
import os
import subprocess
import tempfile
import json

# Initialize FastAPI app
app = FastAPI(title="LearnPython API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-here")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

security = HTTPBearer()

# Pydantic Models
class User(BaseModel):
    id: Optional[int] = None
    username: str
    email: str
    full_name: Optional[str] = None

class UserCreate(BaseModel):
    username: str
    email: str
    password: str
    full_name: Optional[str] = None

class Lesson(BaseModel):
    id: int
    title: str
    description: str
    content: str
    code_example: str
    difficulty: str
    category: str

class UserProgress(BaseModel):
    user_id: int
    lesson_id: int
    completed: bool
    completed_at: Optional[datetime] = None

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class CodeExecutionRequest(BaseModel):
    code: str

class CodeExecutionResponse(BaseModel):
    output: str
    error: str
    success: bool

# Mock database (in real app, this would be PostgreSQL)
users_db = {}
lessons_db = {
    1: {
        "id": 1,
        "title": "Hello World",
        "description": "Learn how to print text in Python",
        "content": "The print() function is used to output text to the console. It's one of the most basic and commonly used functions in Python. You can print strings, numbers, and even the results of calculations.",
        "code_example": "print('Hello, World!')\nprint('Welcome to Python!')\nprint(2 + 3)\nprint('The result is:', 5)",
        "difficulty": "beginner",
        "category": "basics"
    },
    2: {
        "id": 2,
        "title": "Variables and Data Types",
        "description": "Understanding variables and basic data types in Python",
        "content": "Variables are containers for storing data values. Python has several built-in data types including strings, integers, floats, and booleans. Variables are created when you assign a value to them.",
        "code_example": "name = 'Alice'\nage = 25\nheight = 5.6\nis_student = True\n\nprint(f'Name: {name}')\nprint(f'Age: {age}')\nprint(f'Height: {height}')\nprint(f'Student: {is_student}')",
        "difficulty": "beginner",
        "category": "basics"
    },
    3: {
        "id": 3,
        "title": "Basic Math Operations",
        "description": "Performing mathematical calculations in Python",
        "content": "Python can perform all basic mathematical operations. You can use +, -, *, / for addition, subtraction, multiplication, and division. Python also supports more advanced operations like exponentiation (**) and modulo (%).",
        "code_example": "# Basic arithmetic\nx = 10\ny = 3\n\naddition = x + y\nsubtraction = x - y\nmultiplication = x * y\ndivision = x / y\nmodulo = x % y\nexponent = x ** y\n\nprint(f'Addition: {addition}')\nprint(f'Subtraction: {subtraction}')\nprint(f'Multiplication: {multiplication}')\nprint(f'Division: {division}')\nprint(f'Modulo: {modulo}')\nprint(f'Exponent: {exponent}')",
        "difficulty": "beginner",
        "category": "basics"
    },
    4: {
        "id": 4,
        "title": "String Operations",
        "description": "Working with text and string manipulation",
        "content": "Strings are sequences of characters. Python provides many built-in methods for string manipulation including concatenation, slicing, formatting, and various string methods.",
        "code_example": "text = 'Hello, Python!'\n\n# String length\nprint(f'Length: {len(text)}')\n\n# String slicing\nprint(f'First 5 characters: {text[:5]}')\nprint(f'Last 6 characters: {text[-6:]}')\n\n# String methods\nprint(f'Uppercase: {text.upper()}')\nprint(f'Lowercase: {text.lower()}')\nprint(f'Title case: {text.title()}')\n\n# String concatenation\nfirst = 'Hello'\nsecond = 'World'\nresult = first + ' ' + second\nprint(f'Concatenated: {result}')",
        "difficulty": "beginner",
        "category": "basics"
    },
    5: {
        "id": 5,
        "title": "Lists and Loops",
        "description": "Working with lists and for loops",
        "content": "Lists are ordered collections of items. For loops allow you to iterate over sequences like lists. List comprehension is a concise way to create lists based on existing sequences.",
        "code_example": "fruits = ['apple', 'banana', 'orange']\n\n# Iterating through a list\nfor fruit in fruits:\n    print(f'I like {fruit}')\n\n# List comprehension\nsquares = [x**2 for x in range(5)]\nprint(squares)\n\n# Adding items to a list\nfruits.append('grape')\nprint(fruits)\n\n# List methods\nnumbers = [3, 1, 4, 1, 5, 9, 2, 6]\nprint(f'Original: {numbers}')\nprint(f'Sorted: {sorted(numbers)}')\nprint(f'Sum: {sum(numbers)}')\nprint(f'Max: {max(numbers)}')",
        "difficulty": "beginner",
        "category": "data structures"
    },
    6: {
        "id": 6,
        "title": "Conditional Statements",
        "description": "Using if, elif, and else statements",
        "content": "Conditional statements allow your program to make decisions based on certain conditions. You can use if, elif (else if), and else to control the flow of your program.",
        "code_example": "age = 18\ntemperature = 25\n\n# Simple if statement\nif age >= 18:\n    print('You are an adult')\nelse:\n    print('You are a minor')\n\n# Multiple conditions\nif temperature < 0:\n    print('It is freezing')\nelif temperature < 20:\n    print('It is cold')\nelif temperature < 30:\n    print('It is warm')\nelse:\n    print('It is hot')\n\n# Complex conditions\nscore = 85\nif score >= 90:\n    grade = 'A'\nelif score >= 80:\n    grade = 'B'\nelif score >= 70:\n    grade = 'C'\nelse:\n    grade = 'F'\nprint(f'Grade: {grade}')",
        "difficulty": "beginner",
        "category": "basics"
    },
    7: {
        "id": 7,
        "title": "Dictionaries",
        "description": "Working with key-value pairs in dictionaries",
        "content": "Dictionaries store data as key-value pairs. They are unordered, changeable, and indexed. Dictionaries are perfect for storing related information together.",
        "code_example": "student = {\n    'name': 'Alice',\n    'age': 20,\n    'grades': [85, 90, 92]\n}\n\nprint(f'Student: {student[\"name\"]}')\nprint(f'Age: {student[\"age\"]}')\nprint(f'Average grade: {sum(student[\"grades\"]) / len(student[\"grades\"])}')\n\n# Adding new key-value pairs\nstudent['major'] = 'Computer Science'\nprint(student)\n\n# Dictionary methods\nprint(f'Keys: {list(student.keys())}')\nprint(f'Values: {list(student.values())}')\nprint(f'Items: {list(student.items())}')",
        "difficulty": "intermediate",
        "category": "data structures"
    },
    8: {
        "id": 8,
        "title": "Functions",
        "description": "Creating and using functions in Python",
        "content": "Functions are reusable blocks of code that perform specific tasks. They help organize code and avoid repetition. Functions can take parameters and return values.",
        "code_example": "def greet(name):\n    return f'Hello, {name}!'\n\ndef add_numbers(a, b):\n    return a + b\n\ndef calculate_area(length, width):\n    area = length * width\n    return area\n\n# Using the functions\nmessage = greet('Alice')\nresult = add_numbers(5, 3)\nrectangle_area = calculate_area(10, 5)\n\nprint(message)\nprint(f'5 + 3 = {result}')\nprint(f'Rectangle area: {rectangle_area}')",
        "difficulty": "intermediate",
        "category": "functions"
    },
    9: {
        "id": 9,
        "title": "List Comprehensions",
        "description": "Advanced list creation and manipulation",
        "content": "List comprehensions provide a concise way to create lists based on existing sequences. They are more readable and often faster than traditional for loops.",
        "code_example": "# Basic list comprehension\nsquares = [x**2 for x in range(10)]\nprint(f'Squares: {squares}')\n\n# List comprehension with condition\neven_squares = [x**2 for x in range(10) if x % 2 == 0]\nprint(f'Even squares: {even_squares}')\n\n# Nested list comprehension\nmatrix = [[i+j for j in range(3)] for i in range(3)]\nprint(f'Matrix: {matrix}')\n\n# Dictionary comprehension\nword_lengths = {word: len(word) for word in ['apple', 'banana', 'cherry']}\nprint(f'Word lengths: {word_lengths}')\n\n# Set comprehension\nunique_squares = {x**2 for x in range(10)}\nprint(f'Unique squares: {unique_squares}')",
        "difficulty": "intermediate",
        "category": "data structures"
    },
    10: {
        "id": 10,
        "title": "Error Handling",
        "description": "Using try-except blocks to handle errors",
        "content": "Error handling allows your program to gracefully handle unexpected situations. Try-except blocks catch exceptions and prevent your program from crashing.",
        "code_example": "def divide_numbers(a, b):\n    try:\n        result = a / b\n        return result\n    except ZeroDivisionError:\n        return 'Error: Cannot divide by zero'\n    except TypeError:\n        return 'Error: Please provide numbers'\n\n# Testing the function\nprint(divide_numbers(10, 2))\nprint(divide_numbers(10, 0))\nprint(divide_numbers('10', 2))\n\n# Using try-except with file operations\ntry:\n    with open('nonexistent.txt', 'r') as file:\n        content = file.read()\nexcept FileNotFoundError:\n    print('File not found!')\n\n# Custom exceptions\ntry:\n    age = int(input('Enter age: '))\n    if age < 0:\n        raise ValueError('Age cannot be negative')\nexcept ValueError as e:\n    print(f'Invalid input: {e}')",
        "difficulty": "intermediate",
        "category": "functions"
    },
    11: {
        "id": 11,
        "title": "File Handling",
        "description": "Reading and writing files in Python",
        "content": "Python provides built-in functions for file operations. You can read from files, write to files, and handle different file formats. Always remember to close files after use.",
        "code_example": "# Writing to a file\nwith open('example.txt', 'w') as file:\n    file.write('Hello, this is a test file!\\n')\n    file.write('This is the second line.')\n\n# Reading from a file\nwith open('example.txt', 'r') as file:\n    content = file.read()\n    print('File content:')\n    print(content)\n\n# Reading line by line\nwith open('example.txt', 'r') as file:\n    for line in file:\n        print(f'Line: {line.strip()}')\n\n# Working with CSV-like data\ndata = [['Name', 'Age'], ['Alice', '25'], ['Bob', '30']]\nwith open('data.csv', 'w') as file:\n    for row in data:\n        file.write(','.join(row) + '\\n')",
        "difficulty": "intermediate",
        "category": "modules & libraries"
    },
    12: {
        "id": 12,
        "title": "Classes and Objects",
        "description": "Introduction to Object-Oriented Programming",
        "content": "Classes are blueprints for creating objects. They encapsulate data and behavior. Object-oriented programming helps organize code and makes it more maintainable.",
        "code_example": "class Student:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n        self.grades = []\n    \n    def add_grade(self, grade):\n        self.grades.append(grade)\n    \n    def get_average(self):\n        if not self.grades:\n            return 0\n        return sum(self.grades) / len(self.grades)\n    \n    def __str__(self):\n        return f'Student: {self.name}, Age: {self.age}'\n\n# Creating objects\nstudent1 = Student('Alice', 20)\nstudent1.add_grade(85)\nstudent1.add_grade(90)\n\nprint(student1)\nprint(f'{student1.name} average: {student1.get_average()}')",
        "difficulty": "advanced",
        "category": "object-oriented programming"
    },
    13: {
        "id": 13,
        "title": "Recursion",
        "description": "Understanding recursive functions",
        "content": "Recursion is when a function calls itself. It's a powerful programming technique that can solve complex problems by breaking them down into smaller, similar subproblems.",
        "code_example": "def factorial(n):\n    if n <= 1:\n        return 1\n    return n * factorial(n - 1)\n\ndef fibonacci(n):\n    if n <= 1:\n        return n\n    return fibonacci(n - 1) + fibonacci(n - 2)\n\ndef count_down(n):\n    if n <= 0:\n        print('Blast off!')\n        return\n    print(n)\n    count_down(n - 1)\n\n# Testing recursive functions\nprint(f'Factorial of 5: {factorial(5)}')\nprint(f'Fibonacci of 7: {fibonacci(7)}')\ncount_down(5)",
        "difficulty": "advanced",
        "category": "functions"
    },
    14: {
        "id": 14,
        "title": "Decorators",
        "description": "Using function decorators for code enhancement",
        "content": "Decorators are functions that modify the behavior of other functions. They provide a way to add functionality to existing functions without modifying their code.",
        "code_example": "import time\n\ndef timer(func):\n    def wrapper(*args, **kwargs):\n        start = time.time()\n        result = func(*args, **kwargs)\n        end = time.time()\n        print(f'{func.__name__} took {end - start:.4f} seconds')\n        return result\n    return wrapper\n\ndef cache(func):\n    memo = {}\n    def wrapper(*args):\n        if args not in memo:\n            memo[args] = func(*args)\n        return memo[args]\n    return wrapper\n\n@timer\n@cache\ndef fibonacci(n):\n    if n <= 1:\n        return n\n    return fibonacci(n - 1) + fibonacci(n - 2)\n\nprint(fibonacci(10))",
        "difficulty": "advanced",
        "category": "functions"
    },
    15: {
        "id": 15,
        "title": "Generators",
        "description": "Creating memory-efficient iterators with generators",
        "content": "Generators are functions that return an iterator. They use the 'yield' keyword and are memory efficient for large datasets since they generate values on-demand.",
        "code_example": "def number_generator(n):\n    for i in range(n):\n        yield i\n\ndef fibonacci_generator():\n    a, b = 0, 1\n    while True:\n        yield a\n        a, b = b, a + b\n\ndef even_numbers_generator(n):\n    for i in range(n):\n        if i % 2 == 0:\n            yield i\n\n# Using generators\nprint('Number generator:')\nfor num in number_generator(5):\n    print(num, end=' ')\nprint()\n\nprint('First 10 Fibonacci numbers:')\nfib = fibonacci_generator()\nfor _ in range(10):\n    print(next(fib), end=' ')\nprint()\n\nprint('Even numbers:')\nfor even in even_numbers_generator(10):\n    print(even, end=' ')\nprint()",
        "difficulty": "advanced",
        "category": "functions"
    },
    16: {
        "id": 16,
        "title": "Data Structures Challenge",
        "description": "Advanced problem solving with data structures",
        "content": "This challenge combines multiple data structures to solve complex problems. You'll work with lists, dictionaries, sets, and custom data structures to implement efficient algorithms.",
        "code_example": "# Implementing a simple cache system\nclass Cache:\n    def __init__(self, max_size=3):\n        self.max_size = max_size\n        self.cache = {}\n        self.access_order = []\n    \n    def get(self, key):\n        if key in self.cache:\n            # Move to end (most recently used)\n            self.access_order.remove(key)\n            self.access_order.append(key)\n            return self.cache[key]\n        return None\n    \n    def put(self, key, value):\n        if key in self.cache:\n            self.access_order.remove(key)\n        elif len(self.cache) >= self.max_size:\n            # Remove least recently used\n            lru_key = self.access_order.pop(0)\n            del self.cache[lru_key]\n        \n        self.cache[key] = value\n        self.access_order.append(key)\n\n# Testing the cache\ncache = Cache(3)\ncache.put('A', 1)\ncache.put('B', 2)\ncache.put('C', 3)\nprint(f'Cache: {cache.cache}')\nprint(f'Get A: {cache.get(\"A\")}')\ncache.put('D', 4)\nprint(f'Cache after adding D: {cache.cache}')",
        "difficulty": "advanced",
        "category": "data structures"
    },
    17: {
        "id": 17,
        "title": "Lambda Functions",
        "description": "Creating anonymous functions with lambda expressions",
        "content": "Lambda functions are small anonymous functions that can have any number of arguments but only one expression. They are useful for simple operations and can be used with higher-order functions like map, filter, and reduce.",
        "code_example": "# Basic lambda function\nsquare = lambda x: x**2\nprint(f'Square of 5: {square(5)}')\n\n# Lambda with multiple arguments\nadd = lambda x, y: x + y\nprint(f'Sum of 3 and 7: {add(3, 7)}')\n\n# Using lambda with map\nnumbers = [1, 2, 3, 4, 5]\nsquared = list(map(lambda x: x**2, numbers))\nprint(f'Squared numbers: {squared}')\n\n# Using lambda with filter\neven_numbers = list(filter(lambda x: x % 2 == 0, numbers))\nprint(f'Even numbers: {even_numbers}')\n\n# Lambda with conditional expression\ncheck_grade = lambda score: 'Pass' if score >= 60 else 'Fail'\nprint(f'Score 75: {check_grade(75)}')\nprint(f'Score 45: {check_grade(45)}')",
        "difficulty": "intermediate",
        "category": "functions"
    },
    18: {
        "id": 18,
        "title": "Regular Expressions",
        "description": "Pattern matching and text processing with regex",
        "content": "Regular expressions are powerful tools for pattern matching and text manipulation. They allow you to search, extract, and replace text based on complex patterns.",
        "code_example": "import re\n\n# Basic pattern matching\ntext = 'My phone number is 123-456-7890'\nphone_pattern = r'\\d{3}-\\d{3}-\\d{4}'\nmatch = re.search(phone_pattern, text)\nif match:\n    print(f'Found phone: {match.group()}')\n\n# Finding all matches\nemails = 'Contact us at john@example.com or jane@test.org'\nemail_pattern = r'\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b'\nfound_emails = re.findall(email_pattern, emails)\nprint(f'Found emails: {found_emails}')\n\n# Replacing text\nsentence = 'The color is red, the sky is blue, the grass is green'\ncolor_pattern = r'\\b(red|blue|green)\\b'\nreplaced = re.sub(color_pattern, 'COLOR', sentence)\nprint(f'Replaced: {replaced}')\n\n# Splitting text\ncsv_data = 'apple,banana,cherry,date'\nsplit_data = re.split(r',', csv_data)\nprint(f'Split data: {split_data}')",
        "difficulty": "intermediate",
        "category": "modules & libraries"
    },
    19: {
        "id": 19,
        "title": "Working with JSON",
        "description": "Parsing and creating JSON data",
        "content": "JSON (JavaScript Object Notation) is a lightweight data interchange format. Python provides built-in support for working with JSON through the json module.",
        "code_example": "import json\n\n# Creating JSON from Python objects\ndata = {\n    'name': 'Alice',\n    'age': 25,\n    'city': 'New York',\n    'hobbies': ['reading', 'swimming', 'coding']\n}\n\n# Convert to JSON string\njson_string = json.dumps(data, indent=2)\nprint('JSON string:')\nprint(json_string)\n\n# Parse JSON string back to Python object\nparsed_data = json.loads(json_string)\nprint(f'\\nParsed data: {parsed_data}')\nprint(f'Name: {parsed_data[\"name\"]}')\n\n# Working with JSON files\nwith open('data.json', 'w') as f:\n    json.dump(data, f, indent=2)\n\nwith open('data.json', 'r') as f:\n    loaded_data = json.load(f)\nprint(f'\\nLoaded from file: {loaded_data}')",
        "difficulty": "intermediate",
        "category": "modules & libraries"
    },
    20: {
        "id": 20,
        "title": "Context Managers",
        "description": "Using with statements for resource management",
        "content": "Context managers provide a way to properly manage resources like files, network connections, and database connections. They ensure that resources are properly cleaned up even if exceptions occur.",
        "code_example": "# Custom context manager\nclass Timer:\n    def __init__(self, name):\n        self.name = name\n    \n    def __enter__(self):\n        import time\n        self.start = time.time()\n        print(f'Starting {self.name}...')\n        return self\n    \n    def __exit__(self, exc_type, exc_val, exc_tb):\n        import time\n        self.end = time.time()\n        print(f'{self.name} took {self.end - self.start:.4f} seconds')\n\n# Using the context manager\nwith Timer('calculation'):\n    result = sum(i**2 for i in range(1000))\n    print(f'Result: {result}')\n\n# File context manager (built-in)\nwith open('test.txt', 'w') as f:\n    f.write('Hello, context manager!')\n\nwith open('test.txt', 'r') as f:\n    content = f.read()\n    print(f'File content: {content}')",
        "difficulty": "intermediate",
        "category": "functions"
    },
    21: {
        "id": 21,
        "title": "Inheritance and Polymorphism",
        "description": "Advanced object-oriented programming concepts",
        "content": "Inheritance allows a class to inherit attributes and methods from another class. Polymorphism enables objects of different classes to be treated as objects of a common superclass.",
        "code_example": "class Animal:\n    def __init__(self, name):\n        self.name = name\n    \n    def speak(self):\n        pass\n    \n    def describe(self):\n        return f'{self.name} is an animal'\n\nclass Dog(Animal):\n    def speak(self):\n        return f'{self.name} says Woof!'\n    \n    def fetch(self):\n        return f'{self.name} fetches the ball'\n\nclass Cat(Animal):\n    def speak(self):\n        return f'{self.name} says Meow!'\n    \n    def climb(self):\n        return f'{self.name} climbs the tree'\n\n# Using inheritance and polymorphism\nanimals = [Dog('Buddy'), Cat('Whiskers'), Animal('Generic')]\n\nfor animal in animals:\n    print(animal.describe())\n    print(animal.speak())\n    if isinstance(animal, Dog):\n        print(animal.fetch())\n    elif isinstance(animal, Cat):\n        print(animal.climb())\n    print()",
        "difficulty": "advanced",
        "category": "object-oriented programming"
    },
    22: {
        "id": 22,
        "title": "Metaclasses",
        "description": "Understanding class creation and metaclasses",
        "content": "Metaclasses are classes for classes. They control how classes are created and can be used to add functionality to all classes of a certain type. This is an advanced concept that demonstrates Python's flexibility.",
        "code_example": "class LoggedMeta(type):\n    def __new__(cls, name, bases, attrs):\n        print(f'Creating class: {name}')\n        return super().__new__(cls, name, bases, attrs)\n    \n    def __init__(cls, name, bases, attrs):\n        print(f'Initializing class: {name}')\n        super().__init__(name, bases, attrs)\n\nclass SingletonMeta(type):\n    _instances = {}\n    \n    def __call__(cls, *args, **kwargs):\n        if cls not in cls._instances:\n            cls._instances[cls] = super().__call__(*args, **kwargs)\n        return cls._instances[cls]\n\n# Using the logging metaclass\nclass MyClass(metaclass=LoggedMeta):\n    def __init__(self):\n        print('MyClass instance created')\n\n# Using the singleton metaclass\nclass Database(metaclass=SingletonMeta):\n    def __init__(self):\n        self.connection = 'Connected to database'\n    \n    def query(self, sql):\n        return f'Executing: {sql}'\n\n# Testing singleton behavior\ndb1 = Database()\ndb2 = Database()\nprint(f'db1 is db2: {db1 is db2}')\nprint(f'db1 connection: {db1.connection}')\nprint(f'db2 connection: {db2.connection}')",
        "difficulty": "advanced",
        "category": "object-oriented programming"
    },
    23: {
        "id": 23,
        "title": "Concurrency with Threading",
        "description": "Running multiple threads for concurrent execution",
        "content": "Threading allows you to run multiple threads of execution concurrently. This is useful for I/O-bound tasks and can improve performance in certain scenarios.",
        "code_example": "import threading\nimport time\nfrom queue import Queue\n\n# Simple thread function\ndef worker(name, delay):\n    print(f'Thread {name} starting')\n    time.sleep(delay)\n    print(f'Thread {name} finished')\n\n# Creating and starting threads\nthread1 = threading.Thread(target=worker, args=('A', 2))\nthread2 = threading.Thread(target=worker, args=('B', 1))\n\nthread1.start()\nthread2.start()\n\n# Waiting for threads to complete\nthread1.join()\nthread2.join()\nprint('All threads completed')\n\n# Thread-safe counter\nclass Counter:\n    def __init__(self):\n        self.value = 0\n        self.lock = threading.Lock()\n    \n    def increment(self):\n        with self.lock:\n            current = self.value\n            time.sleep(0.1)  # Simulate work\n            self.value = current + 1\n    \n    def get_value(self):\n        return self.value\n\n# Testing thread-safe counter\ncounter = Counter()\nthreads = []\n\nfor i in range(5):\n    thread = threading.Thread(target=counter.increment)\n    threads.append(thread)\n    thread.start()\n\nfor thread in threads:\n    thread.join()\n\nprint(f'Final counter value: {counter.get_value()}')",
        "difficulty": "advanced",
        "category": "modules & libraries"
    },
    24: {
        "id": 24,
        "title": "Async Programming",
        "description": "Writing asynchronous code with asyncio",
        "content": "Asynchronous programming allows you to write concurrent code that can handle many operations simultaneously without using threads. This is particularly useful for I/O-bound applications.",
        "code_example": "import asyncio\nimport aiohttp\nimport time\n\nasync def fetch_data(session, url, delay):\n    print(f'Starting request to {url}')\n    await asyncio.sleep(delay)  # Simulate network delay\n    print(f'Completed request to {url}')\n    return f'Data from {url}'\n\nasync def main():\n    urls = [\n        ('http://api1.com', 1),\n        ('http://api2.com', 2),\n        ('http://api3.com', 1.5)\n    ]\n    \n    async with aiohttp.ClientSession() as session:\n        tasks = [fetch_data(session, url, delay) for url, delay in urls]\n        results = await asyncio.gather(*tasks)\n        \n        for result in results:\n            print(f'Result: {result}')\n\n# Running the async function\nasyncio.run(main())\n\n# Async generator\nasync def number_generator(n):\n    for i in range(n):\n        await asyncio.sleep(0.1)\n        yield i\n\nasync def consume_generator():\n    async for num in number_generator(5):\n        print(f'Generated: {num}')\n\nasyncio.run(consume_generator())",
        "difficulty": "advanced",
        "category": "modules & libraries"
    },
    25: {
        "id": 25,
        "title": "Design Patterns",
        "description": "Implementing common software design patterns",
        "content": "Design patterns are typical solutions to common problems in software design. They provide proven approaches to solving recurring design problems.",
        "code_example": "# Singleton Pattern\nclass Singleton:\n    _instance = None\n    \n    def __new__(cls):\n        if cls._instance is None:\n            cls._instance = super().__new__(cls)\n        return cls._instance\n\n# Factory Pattern\nclass AnimalFactory:\n    @staticmethod\n    def create_animal(animal_type, name):\n        if animal_type == 'dog':\n            return Dog(name)\n        elif animal_type == 'cat':\n            return Cat(name)\n        else:\n            raise ValueError(f'Unknown animal type: {animal_type}')\n\n# Observer Pattern\nclass Subject:\n    def __init__(self):\n        self._observers = []\n        self._state = None\n    \n    def attach(self, observer):\n        self._observers.append(observer)\n    \n    def notify(self):\n        for observer in self._observers:\n            observer.update(self._state)\n    \n    def set_state(self, state):\n        self._state = state\n        self.notify()\n\nclass Observer:\n    def __init__(self, name):\n        self.name = name\n    \n    def update(self, state):\n        print(f'{self.name} received state: {state}')\n\n# Testing patterns\n# Singleton\nsingleton1 = Singleton()\nsingleton2 = Singleton()\nprint(f'Singleton test: {singleton1 is singleton2}')\n\n# Factory\nfactory = AnimalFactory()\ndog = factory.create_animal('dog', 'Rex')\ncat = factory.create_animal('cat', 'Fluffy')\nprint(f'Created: {dog.speak()}')\nprint(f'Created: {cat.speak()}')\n\n# Observer\nsubject = Subject()\nobserver1 = Observer('Observer1')\nobserver2 = Observer('Observer2')\nsubject.attach(observer1)\nsubject.attach(observer2)\nsubject.set_state('New state')",
        "difficulty": "advanced",
        "category": "object-oriented programming"
    }
}

progress_db = {}

# JWT Functions
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
        token_data = TokenData(username=username)
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return token_data

def execute_python_code(code: str) -> CodeExecutionResponse:
    """Execute Python code safely and return the result"""
    try:
        # Create a temporary file for the code
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(code)
            temp_file = f.name
        
        # Execute the code with a timeout
        result = subprocess.run(
            ['python3', temp_file],
            capture_output=True,
            text=True,
            timeout=10  # 10 second timeout
        )
        
        # Clean up the temporary file
        os.unlink(temp_file)
        
        if result.returncode == 0:
            return CodeExecutionResponse(
                output=result.stdout.strip(),
                error="",
                success=True
            )
        else:
            return CodeExecutionResponse(
                output="",
                error=result.stderr.strip(),
                success=False
            )
            
    except subprocess.TimeoutExpired:
        return CodeExecutionResponse(
            output="",
            error="Code execution timed out (max 10 seconds)",
            success=False
        )
    except Exception as e:
        return CodeExecutionResponse(
            output="",
            error=f"Execution error: {str(e)}",
            success=False
        )

# API Routes
@app.get("/")
async def root():
    return {"message": "LearnPython API is running!"}

@app.post("/register", response_model=User)
async def register(user: UserCreate):
    if user.username in users_db:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    # In real app, hash the password
    user_dict = user.model_dump()
    user_dict["id"] = len(users_db) + 1
    del user_dict["password"]
    users_db[user.username] = user_dict
    
    return user_dict

@app.post("/login", response_model=Token)
async def login(username: str, password: str):
    if username not in users_db:
        raise HTTPException(status_code=400, detail="Invalid credentials")
    
    # In real app, verify password hash
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/lessons", response_model=List[Lesson])
async def get_lessons():
    return list(lessons_db.values())

@app.get("/lessons/{lesson_id}", response_model=Lesson)
async def get_lesson(lesson_id: int):
    if lesson_id not in lessons_db:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return lessons_db[lesson_id]

@app.post("/progress")
async def update_progress(progress: UserProgress, token_data: TokenData = Depends(verify_token)):
    progress_key = f"{progress.user_id}_{progress.lesson_id}"
    progress_db[progress_key] = progress.model_dump()
    return {"message": "Progress updated successfully"}

@app.get("/progress/{user_id}")
async def get_user_progress(user_id: int, token_data: TokenData = Depends(verify_token)):
    user_progress = []
    for key, value in progress_db.items():
        if key.startswith(f"{user_id}_"):
            user_progress.append(value)
    return user_progress

@app.post("/execute", response_model=CodeExecutionResponse)
async def execute_code(request: CodeExecutionRequest):
    """Execute Python code and return the result"""
    return execute_python_code(request.code)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 