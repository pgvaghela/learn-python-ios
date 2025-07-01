# LearnPython iOS App

An interactive iOS app that teaches Python syntax and fundamental concepts through embedded code execution labs.

## 🚀 Project Overview

**Technologies Used:** Swift, SwiftUI, Python, FastAPI, PostgreSQL

**Project Timeline:** July 2025 - August 2025

## ✨ Key Features

- **Interactive Python Lessons**: Learn Python syntax and concepts through hands-on coding exercises
- **Embedded Code Execution**: Run Python code directly on your iOS device
- **Syntax-Highlighted Editor**: CodeMirror-based editor with Python syntax highlighting
- **Progress Tracking**: Track your learning progress across different lessons
- **Modern SwiftUI Interface**: Beautiful, intuitive user interface built with SwiftUI
- **MVVM Architecture**: Clean, maintainable code structure
- **Backend API**: FastAPI + PostgreSQL backend with JWT authentication

## 📱 iOS App Features

### Core Components
- **LessonListView**: Browse and filter Python lessons by difficulty and category
- **LessonDetailView**: Interactive lesson interface with code editor and execution
- **CodeEditorView**: WebView-based code editor with CodeMirror syntax highlighting
- **PythonExecutionService**: On-device Python code execution (simulated)

### Architecture
- **MVVM Pattern**: Clean separation of concerns with ViewModels
- **SwiftUI**: Modern declarative UI framework
- **WebKit Integration**: CodeMirror editor embedded in WebView
- **Progress Persistence**: User progress tracking and completion status

## 🔧 Backend API

### FastAPI Features
- **JWT Authentication**: Secure user authentication and authorization
- **Pydantic Models**: Type-safe data validation and serialization
- **CORS Support**: Cross-origin resource sharing for mobile app integration
- **PostgreSQL Integration**: Robust database for user data and progress

### API Endpoints
- `POST /register` - User registration
- `POST /login` - User authentication
- `GET /lessons` - Retrieve available lessons
- `GET /lessons/{id}` - Get specific lesson details
- `POST /progress` - Update user progress
- `GET /progress/{user_id}` - Get user progress

## 🛠️ Development Setup

### iOS App
1. Open `LearnPython/LearnPython.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project

### Backend API
1. Navigate to the `backend` directory
2. Install dependencies: `pip install -r requirements.txt`
3. Run the server: `python main.py`
4. API will be available at `http://localhost:8000`

## 📊 CI/CD Pipeline

### GitHub Actions Workflow
- **Backend Testing**: Automated testing with PostgreSQL database
- **iOS Build Testing**: Xcode build verification on macOS
- **Deployment**: Automated deployment to staging environment

## 🎯 Project Structure

```
learn-python-ios-1/
├── LearnPython/                 # iOS App
│   ├── LearnPython/
│   │   ├── Models/             # Data models
│   │   ├── ViewModels/         # MVVM ViewModels
│   │   ├── Views/              # SwiftUI views
│   │   ├── Services/           # Business logic services
│   │   └── ContentView.swift   # Main app interface
│   └── LearnPython.xcodeproj/
├── backend/                     # FastAPI Backend
│   ├── main.py                 # FastAPI application
│   └── requirements.txt        # Python dependencies
├── .github/workflows/          # CI/CD pipeline
└── README.md
```

## 🎨 UI/UX Features

- **Progress Tracking**: Visual progress indicators and completion status
- **Difficulty Filtering**: Filter lessons by beginner, intermediate, or advanced
- **Category Organization**: Lessons organized by Python concepts
- **Code Editor**: Syntax-highlighted Python code editor
- **Real-time Execution**: Run code and see immediate output
- **Responsive Design**: Optimized for iPhone and iPad

## 🔮 Future Enhancements

- **Real PythonKit Integration**: Actual Python interpreter on device
- **More Lesson Content**: Expanded curriculum with advanced topics
- **User Authentication**: Backend integration for user accounts
- **Cloud Sync**: Progress synchronization across devices
- **Offline Mode**: Local lesson storage and execution
- **Social Features**: Share progress and achievements

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

---

**Built with ❤️ using Swift, SwiftUI, and FastAPI**
