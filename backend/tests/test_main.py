import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "LearnPython API is running!"}

def test_get_lessons():
    response = client.get("/lessons")
    assert response.status_code == 200
    lessons = response.json()
    assert isinstance(lessons, list)
    assert len(lessons) > 0

def test_get_lesson():
    response = client.get("/lessons/1")
    assert response.status_code == 200
    lesson = response.json()
    assert lesson["id"] == 1
    assert "title" in lesson
    assert "description" in lesson

def test_get_nonexistent_lesson():
    response = client.get("/lessons/999")
    assert response.status_code == 404

def test_register_user():
    user_data = {
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpassword",
        "full_name": "Test User"
    }
    response = client.post("/register", json=user_data)
    assert response.status_code == 200
    user = response.json()
    assert user["username"] == "testuser"
    assert user["email"] == "test@example.com"

def test_register_duplicate_user():
    user_data = {
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpassword",
        "full_name": "Test User"
    }
    # Register first time
    client.post("/register", json=user_data)
    # Try to register again
    response = client.post("/register", json=user_data)
    assert response.status_code == 400 