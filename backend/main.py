from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import jwt
from datetime import datetime, timedelta
import os

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

# Mock database (in real app, this would be PostgreSQL)
users_db = {}
lessons_db = {
    1: {
        "id": 1,
        "title": "Hello World",
        "description": "Learn how to print text in Python",
        "content": "The print() function is used to output text to the console.",
        "code_example": "print('Hello, World!')",
        "difficulty": "beginner",
        "category": "basics"
    },
    2: {
        "id": 2,
        "title": "Variables and Data Types",
        "description": "Understanding variables and basic data types",
        "content": "Variables are containers for storing data values.",
        "code_example": "name = 'Alice'\nage = 25\nprint(f'Name: {name}')",
        "difficulty": "beginner",
        "category": "basics"
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 