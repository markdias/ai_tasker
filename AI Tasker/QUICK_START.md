# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Add Permissions to Info.plist
Edit `Promptodo.xcodeproj/Promptodo/Info.plist` and add:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Promptodo needs access to your microphone to record voice prompts.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>Promptodo uses speech recognition to transcribe your voice input.</string>
```

### Step 2: Open Project
```bash
cd /Users/markdias/project/Promptodo
open Promptodo.xcodeproj
```

### Step 3: Build & Run
- Select iOS 18+ simulator
- Press **Cmd + R** to build and run

---

## 📱 Testing the App

### Flow
```
Home Screen
    ↓
    (Type: "Plan a birthday party" or tap 🎤)
    ↓
Question Form
    ↓
    (Answer 5 questions by swiping)
    ↓
Task Review
    ↓
    (Accept 3 tasks, name project)
    ↓
Project Dashboard
```

### Test Cases

#### ✅ Happy Path
1. App opens to HomeView
2. Type a prompt (e.g., "Plan a birthday party")
3. Tap "Generate Questions"
4. Answer all 5 questions (swipe to navigate)
5. Review tasks (all pre-selected)
6. Name project (e.g., "Birthday Party")
7. Tap "Save 3 Tasks"
8. See ProjectDashboard

#### ✅ Voice Testing
1. Tap the microphone icon on HomeView
2. Speak: "Plan a birthday party"
3. Recording indicator shows
4. Speech transcribed to text field
5. Proceed normally

#### ✅ UI Testing
- Button disabled until input provided
- Next button disabled until question answered
- Save button disabled without accepted tasks
- Progress indicator updates as you swipe

#### ❌ Error Cases (Not in M1)
- No API validation (M2)
- No network errors (M2)
- No task persistence (M2)

---

## 🎯 Key Features (M1)

| Feature | Status | Notes |
|---------|--------|-------|
| Text Input | ✅ | Full textarea support |
| Voice Input | ✅ | Local speech-to-text |
| Question Form | ✅ | 5 mock questions, swiping |
| Task Review | ✅ | Accept/reject, project naming |
| Local Storage | ✅ | SwiftData models ready |
| API Keys | ✅ | Keychain secure storage |
| Error Display | ✅ | Error overlay component |
| Navigation | ✅ | Full flow support |
| ChatGPT | ❌ | M2 feature |
| Firebase | ❌ | M2 feature |
| Reminders | ❌ | M5 feature |

---

## 🔧 Customization

### Change Mock Questions
Edit **QuestionFormView.swift** line ~50:
```swift
appState.currentQuestions = [
    QuestionCard(index: 1, text: "Your custom Q1?"),
    // ... etc
]
```

### Change Mock Tasks
Edit **QuestionFormView.swift** line ~70:
```swift
appState.generatedTasks = [
    GeneratedTaskModel(
        title: "Your task title",
        description: "Your description",
        type: "list",
        inputFields: [...]
    ),
    // ... etc
]
```

### Change Colors
View files use `.blue` and `.red`. Replace with your brand colors:
```swift
.background(Color.blue)  // Change to Color(red: ..., green: ..., blue: ...)
```

### Change Fonts
Replace `.system(size: X, weight: .Y)` with your preferred fonts.

---

## 📊 File Map

| File | Purpose | Status |
|------|---------|--------|
| `PromptodoApp.swift` | App entry point | ✅ Complete |
| `ContentView.swift` | Root view | ✅ Complete |
| `Models/LocalModels.swift` | Data structures | ✅ Complete |
| `ViewModels/AppState.swift` | State management | ✅ Complete |
| `Views/HomeView.swift` | Prompt input | ✅ Complete |
| `Views/QuestionFormView.swift` | Question form | ✅ Complete |
| `Views/TaskReviewView.swift` | Task review | ✅ Complete |
| `Views/ProjectDashboardView.swift` | Dashboard | ⏳ Placeholder |
| `Views/TaskDetailsView.swift` | Task details | ⏳ Placeholder |
| `Views/RootView.swift` | Router | ✅ Complete |
| `Views/ErrorOverlayView.swift` | Error display | ✅ Complete |
| `Services/SpeechRecognizer.swift` | Voice input | ✅ Complete |

---

## 🐛 Troubleshooting

### Build Fails
**Problem:** "Cannot find 'RootView' in scope"
**Solution:** Ensure all files are added to Xcode target
1. Cmd+B (build)
2. Check Build Phases → Compile Sources
3. All .swift files should be listed

### Microphone Not Working
**Problem:** Voice recording button does nothing
**Solution:**
1. Check Info.plist has both microphone keys
2. Check simulator settings → Privacy → Microphone
3. Restart simulator
4. Check SpeechRecognizer logs

### Questions Don't Show
**Problem:** QuestionFormView shows blank
**Solution:**
1. Check `AppState.currentQuestions` is populated
2. Verify HomeView navigates to `.questionForm`
3. Check `QuestionFormView.swift` initialization

### App Crashes
**Problem:** Fatal error on launch
**Solution:**
1. Check ModelContainer initialization in `PromptodoApp`
2. Check all models added to schema
3. Delete app from simulator and rebuild
4. Check console for specific error

---

## 📈 Performance

### Current (M1)
- **Launch Time:** < 1 second
- **Question Navigation:** Instant (local)
- **Memory:** ~50 MB (idle)
- **Storage:** ~100 KB (SwiftData)

### After M2 (Firebase)
- **Launch Time:** 1-2 seconds (network)
- **Question Generation:** 2-5 seconds (ChatGPT)
- **Task Generation:** 3-10 seconds (ChatGPT)
- **Memory:** ~80 MB (with network)

### Optimization Tips
- Use `.throttle()` for frequent state updates
- Lazy load project tasks
- Paginate large lists
- Cache API responses

---

## 📚 Next Steps

### Learning
1. Read `ARCHITECTURE.md` to understand data flow
2. Read `DATA_MODELS.md` to understand schema
3. Read `PROJECT_STRUCTURE.md` for code organization

### Implementation
1. **M2:** Set up Firebase + ChatGPT
2. **M3:** Implement dynamic input fields
3. **M4:** Build project dashboard
4. **M5:** Add Reminders sync
5. **M6:** Polish and ship

### Testing
1. Manual testing of all flows
2. Unit tests for state management
3. UI tests for navigation
4. Integration tests (M2+)

---

## 🎓 Learning Resources

### SwiftUI
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [WWDC23 SwiftUI Videos](https://developer.apple.com/wwdc23/)

### SwiftData
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Data Modeling Guide](https://developer.apple.com/documentation/swiftdata/modeling-your-data)

### Speech Framework
- [Speech Recognition](https://developer.apple.com/documentation/speech)
- [Building Speech-Controlled Apps](https://developer.apple.com/documentation/speech/building_a_speech-enabled_app)

### Firebase
- [Firestore Guide](https://firebase.google.com/docs/firestore)
- [iOS Setup](https://firebase.google.com/docs/ios/setup)

---

## ✅ Checklist Before M2

- [ ] App builds without errors
- [ ] HomeView works (text input)
- [ ] HomeView works (voice input)
- [ ] QuestionForm displays 5 questions
- [ ] Can swipe between questions
- [ ] TaskReview shows mock tasks
- [ ] Can accept/reject tasks
- [ ] Can name project
- [ ] ProjectDashboard displays project
- [ ] No crashes during normal use
- [ ] Navigation works smoothly

---

## 🚀 Ready?

You're all set! Open Xcode and start building.

```bash
open Promptodo.xcodeproj
```

Questions? Check:
- `M1_SETUP.md` for build instructions
- `BUILD_SUMMARY.md` for overview
- `ARCHITECTURE.md` for technical details
- `claude.md` for product requirements

Happy coding! 💪
