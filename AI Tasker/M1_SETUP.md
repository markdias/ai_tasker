# M1 Setup & Build Guide

## What's Been Created

### Core Files
✅ **PromptodoApp.swift** - SwiftData initialization + app entry point
✅ **ContentView.swift** - Root view routing
✅ **RootView.swift** - Navigation based on AppState

### Models
✅ **Models/LocalModels.swift**
  - ProjectLocal, TaskLocal, PromptLocal
  - Input field definitions (InputFieldDefinition, InputSchemaDefinition)
  - Data models for different task types (ListTaskData, CurrencyTaskData, etc.)

### View Models
✅ **ViewModels/AppState.swift**
  - Observable state container
  - Navigation stack management
  - API key storage (Keychain)
  - Session state (current prompt, questions, answers, tasks)

### Views
✅ **Views/HomeView.swift**
  - Text input field
  - Voice recording button with real-time feedback
  - Submit button (disabled until input provided)
  - API key prompt on first submission

✅ **Views/QuestionFormView.swift**
  - Swipeable question cards (5 questions)
  - Progress indicator (●●●○○)
  - Answer validation (next button disabled without answer)
  - Previous/Next navigation

✅ **Views/TaskReviewView.swift**
  - Accept/reject individual tasks
  - Project title input
  - Save button (disabled without accepted tasks)

✅ **Views/TaskDetailsView.swift** (Placeholder for M3)
✅ **Views/ProjectDashboardView.swift** (Placeholder for M4)
✅ **Views/ErrorOverlayView.swift** - Error display

### Services
✅ **Services/SpeechRecognizer.swift**
  - Uses Apple Speech Framework
  - Local speech-to-text processing
  - No server calls needed

### Documentation
✅ **DATA_MODELS.md** - Firebase schema + API design
✅ **PROJECT_STRUCTURE.md** - Code organization
✅ **M1_SETUP.md** - This file

---

## Next Steps to Build

### 1. Update Info.plist
Add these two keys for microphone/speech permissions:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Promptodo needs access to your microphone to record voice prompts.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>Promptodo uses speech recognition to transcribe your voice input.</string>
```

### 2. Build & Run
```bash
cd /Users/markdias/project/Promptodo
open Promptodo.xcodeproj
# Select iOS 18+ simulator
# Press Cmd+R to build & run
```

### 3. Test the Flow
1. **Home Screen:** Type or speak a prompt (e.g., "Plan a birthday party")
2. **Question Form:** Answer 5 questions by swiping through cards
3. **Task Review:** Accept/reject the 3 mock tasks, name your project
4. **Success:** Tasks saved (will show project dashboard in M4)

---

## M1 Current Limitations

**These are intentional for MVP and will be added in later phases:**

- ❌ No Firebase backend (added in M2)
- ❌ No ChatGPT API (mock questions/tasks only)
- ❌ No dynamic input fields (hardcoded list, currency, date in TaskDetailsView)
- ❌ No project persistence (resets on app restart - will sync to Firebase in M2)
- ❌ No Reminders sync (coming in M5)
- ❌ No task editing (coming in M3)

---

## M2 - What Comes Next

**AI Integration (3 weeks)**
- Firebase setup + Firestore
- ChatGPT API wrapper service
- Replace mock questions with real ChatGPT questions
- Replace mock tasks with ChatGPT-generated tasks
- Add loading states during API calls
- Error handling for API failures

**Key Changes:**
- New file: `Services/FirebaseService.swift`
- New file: `Services/OpenAIService.swift`
- Update `QuestionFormView` to load real questions
- Update `TaskReviewView` to load real tasks
- Add `.isLoading` UI state

---

## Debugging Tips

### View Hierarchy
Press `Cmd+Shift+D` in Xcode Preview to debug view hierarchy.

### State Changes
Add print statements in `AppState` methods:
```swift
func navigateTo(_ flow: AppFlow) {
    print("Navigating to: \(flow)")
    currentFlow = flow
}
```

### Speech Recognition
If microphone isn't working:
1. Check Info.plist permissions
2. Check simulator microphone permissions (Settings > Privacy > Microphone)
3. Check `SpeechRecognizer` logs for auth status

### SwiftData Issues
If models don't persist:
1. Check `modelContainer` initialization in `PromptodoApp`
2. Verify models are in schema
3. Use SwiftData inspector in Xcode

---

## File Checklist

Before building, ensure these files exist:

```
Promptodo/
├── PromptodoApp.swift ✅
├── ContentView.swift ✅
├── Models/LocalModels.swift ✅
├── ViewModels/AppState.swift ✅
├── Views/
│   ├── RootView.swift ✅
│   ├── HomeView.swift ✅
│   ├── QuestionFormView.swift ✅
│   ├── TaskReviewView.swift ✅
│   ├── TaskDetailsView.swift ✅
│   ├── ProjectDashboardView.swift ✅
│   └── ErrorOverlayView.swift ✅
└── Services/SpeechRecognizer.swift ✅
```

---

## Questions?

Refer to:
- **DATA_MODELS.md** for backend architecture
- **PROJECT_STRUCTURE.md** for code organization
- **claude.md** for product requirements

Good luck! 🚀
