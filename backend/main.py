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
        "title": "Lists and Loops",
        "description": "Working with lists and for loops",
        "content": "Lists are ordered collections of items. For loops allow you to iterate over sequences like lists. List comprehension is a concise way to create lists based on existing sequences.",
        "code_example": "fruits = ['apple', 'banana', 'orange']\n\n# Iterating through a list\nfor fruit in fruits:\n    print(f'I like {fruit}')\n\n# List comprehension\nsquares = [x**2 for x in range(5)]\nprint(squares)\n\n# Adding items to a list\nfruits.append('grape')\nprint(fruits)",
        "difficulty": "beginner",
        "category": "data structures"
    },
    4: {
        "id": 4,
        "title": "Dictionaries",
        "description": "Working with key-value pairs in dictionaries",
        "content": "Dictionaries store data as key-value pairs. They are unordered, changeable, and indexed. Dictionaries are perfect for storing related information together.",
        "code_example": "student = {\n    'name': 'Alice',\n    'age': 20,\n    'grades': [85, 90, 92]\n}\n\nprint(f'Student: {student[\"name\"]}')\nprint(f'Age: {student[\"age\"]}')\nprint(f'Average grade: {sum(student[\"grades\"]) / len(student[\"grades\"])}')\n\n# Adding new key-value pairs\nstudent['major'] = 'Computer Science'\nprint(student)",
        "difficulty": "intermediate",
        "category": "data structures"
    },
    5: {
        "id": 5,
        "title": "Functions",
        "description": "Creating and using functions in Python",
        "content": "Functions are reusable blocks of code that perform specific tasks. They help organize code and avoid repetition. Functions can take parameters and return values.",
        "code_example": "def greet(name):\n    return f'Hello, {name}!'\n\ndef add_numbers(a, b):\n    return a + b\n\ndef calculate_area(length, width):\n    area = length * width\n    return area\n\n# Using the functions\nmessage = greet('Alice')\nresult = add_numbers(5, 3)\nrectangle_area = calculate_area(10, 5)\n\nprint(message)\nprint(f'5 + 3 = {result}')\nprint(f'Rectangle area: {rectangle_area}')",
        "difficulty": "intermediate",
        "category": "functions"
    },
    6: {
        "id": 6,
        "title": "Classes and Objects",
        "description": "Introduction to Object-Oriented Programming",
        "content": "Classes are blueprints for creating objects. They encapsulate data and behavior. Object-oriented programming helps organize code and makes it more maintainable.",
        "code_example": "class Student:\n    def __init__(self, name, age):\n        self.name = name\n        self.age = age\n        self.grades = []\n    \n    def add_grade(self, grade):\n        self.grades.append(grade)\n    \n    def get_average(self):\n        if not self.grades:\n            return 0\n        return sum(self.grades) / len(self.grades)\n\n# Creating objects\nstudent1 = Student('Alice', 20)\nstudent1.add_grade(85)\nstudent1.add_grade(90)\n\nprint(f'{student1.name} average: {student1.get_average()}')",
        "difficulty": "advanced",
        "category": "object-oriented programming"
    },
    7: {
        "id": 7,
        "title": "File Handling",
        "description": "Reading and writing files in Python",
        "content": "Python provides built-in functions for file operations. You can read from files, write to files, and handle different file formats. Always remember to close files after use.",
        "code_example": "# Writing to a file\nwith open('example.txt', 'w') as file:\n    file.write('Hello, this is a test file!\\n')\n    file.write('This is the second line.')\n\n# Reading from a file\nwith open('example.txt', 'r') as file:\n    content = file.read()\n    print('File content:')\n    print(content)\n\n# Reading line by line\nwith open('example.txt', 'r') as file:\n    for line in file:\n        print(f'Line: {line.strip()}')",
        "difficulty": "intermediate",
        "category": "modules & libraries"
    },
    8: {
        "id": 8,
        "title": "Error Handling",
        "description": "Using try-except blocks to handle errors",
        "content": "Error handling allows your program to gracefully handle unexpected situations. Try-except blocks catch exceptions and prevent your program from crashing.",
        "code_example": "def divide_numbers(a, b):\n    try:\n        result = a / b\n        return result\n    except ZeroDivisionError:\n        return 'Error: Cannot divide by zero'\n    except TypeError:\n        return 'Error: Please provide numbers'\n\n# Testing the function\nprint(divide_numbers(10, 2))\nprint(divide_numbers(10, 0))\nprint(divide_numbers('10', 2))\n\n# Using try-except with file operations\ntry:\n    with open('nonexistent.txt', 'r') as file:\n        content = file.read()\nexcept FileNotFoundError:\n    print('File not found!')",
        "difficulty": "intermediate",
        "category": "functions"
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