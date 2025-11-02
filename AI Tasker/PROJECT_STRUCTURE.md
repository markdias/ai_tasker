# Promptodo Project Structure

## Overview
This document outlines the iOS app structure for Promptodo, organized by M1 (Base UI & Prompt Flow) deliverables.

---

## Directory Structure

```
Promptodo/
├── PromptodoApp.swift          # App entry point (SwiftData setup)
├── ContentView.swift           # Root view wrapper
│
├── Models/
│   └── LocalModels.swift       # SwiftData models (ProjectLocal, TaskLocal, PromptLocal)
│
├── ViewModels/
│   └── AppState.swift          # Global app state (Observable)
│                               # Navigation, UI state, user settings
│                               # Keychain manager for API key storage
│
├── Views/
│   ├── RootView.swift          # Navigation router based on AppState.currentFlow
│   ├── HomeView.swift          # Prompt input (text + voice)
│   ├── QuestionFormView.swift  # Swiping question cards (5 questions)
│   ├── TaskReviewView.swift    # Accept/reject generated tasks
│   ├── TaskDetailsView.swift   # Task detail view (M3 - deferred)
│   ├── ProjectDashboardView.swift # Project list & overview (M4 - deferred)
│   └── ErrorOverlayView.swift  # Error message display
│
├── Services/
│   └── SpeechRecognizer.swift  # Apple Speech Framework integration
│
├── Utilities/
│   └── [Future: Extensions, Helpers]
│
├── Resources/
│   └── [Assets, Localization, Data]
│
└── Tests/
    ├── PromptodoTests/
    └── PromptodoUITests/
```

---

## M1 Implementation Status

### ✅ Complete
- **HomeView:** Text + voice prompt input
- **QuestionFormView:** Swiping card form with 5 questions
- **TaskReviewView:** Accept/reject tasks with project naming
- **SpeechRecognizer:** Voice-to-text using Apple Speech Framework
- **AppState:** Global navigation and session state
- **SwiftData Models:** Local data persistence

### ⏳ Placeholder (Deferred to Future Phases)
- **TaskDetailsView:** Full task editing (M3)
- **ProjectDashboardView:** Project list and task organization (M4)
- **Firebase Integration:** Backend sync (M2+)
- **ChatGPT Integration:** AI question/task generation (M2)
- **Dynamic Input Fields:** List, currency, date inputs (M3)
- **Reminders Sync:** Apple Reminders integration (M5)

---

## Key Design Decisions

### 1. State Management
- **AppState** is an Observable class injected via `.environment()`
- Navigation happens via `AppState.currentFlow` enum
- Session state (prompts, questions, tasks) is held in memory during flow
- Settings (API key) are persisted via Keychain

### 2. Data Persistence (M1)
- **SwiftData** handles local storage (Projects, Tasks, Prompts)
- Models are defined in `LocalModels.swift`
- Relationships: Project → Tasks (one-to-many)
- JSON fields store flexible input schema and data

### 3. Voice Input
- **SpeechRecognizer** uses Apple's Speech Framework
- Runs on main thread; results appended to prompt text
- Requires `NSMicrophoneUsageDescription` in Info.plist
- Requires `NSSpeechRecognitionUsageDescription` in Info.plist

### 4. API Key Security
- **Keychain** stores OpenAI API key (never Firestore)
- Key accessed via `KeychainManager.shared.retrieveAPIKey()`
- Prompted on first task generation (M2)

### 5. Navigation Flow
```
Home
  ↓ (Enter prompt)
QuestionForm
  ↓ (Submit answers)
TaskReview
  ↓ (Save project)
ProjectDashboard
```

---

## Next Steps (M2 - AI Integration)

1. **Firebase Setup:**
   - Create Firebase project
   - Set up Firestore with security rules
   - Implement Firestore sync service

2. **ChatGPT Integration:**
   - Create `OpenAIService` for API calls
   - Replace mock questions with real ChatGPT questions
   - Replace mock tasks with ChatGPT-generated tasks
   - Store AI history in Firestore

3. **Error Handling:**
   - Network error handling
   - ChatGPT API error handling
   - User-friendly error messages

4. **Loading States:**
   - Show loading indicator during API calls
   - Disable buttons during processing

---

## Info.plist Permissions (Required for Voice)

Add these keys to `Promptodo/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Promptodo needs access to your microphone to record prompts via voice.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>Promptodo uses speech recognition to transcribe your voice prompts.</string>
```

---

## Testing Strategy

### M1 Testing
- Unit tests for `AppState` navigation
- Unit tests for `SpeechRecognizer`
- UI tests for flow navigation (Home → Form → Review)
- Snapshot tests for view layouts

### M2+ Testing
- Mock Firebase/Firestore
- Mock ChatGPT API responses
- Integration tests for AI flow

---

## Development Notes

### Updating App Flow
1. Add new case to `AppState.AppFlow` enum
2. Create corresponding View
3. Add case to `RootView` switch statement
4. Use `appState.navigateTo(.newFlow)` to navigate

### Adding New Models
1. Define in `LocalModels.swift` with `@Model` decorator
2. Add to SwiftData schema in `PromptodoApp.init()`
3. Define relationships with `@Relationship` for cascading deletes

### Storing Complex Data
- Use `JSON` fields (String) for flexible data
- Define Codable structs for type safety (e.g., `ListTaskData`, `CurrencyTaskData`)
- Encode/decode using `JSONEncoder`/`JSONDecoder`

---

## Future Enhancements (Post-M6)

- Siri Shortcuts integration
- Multi-user collaboration
- Budget rollup calculations
- Task subtasks/dependencies
- Weekly AI summaries
- Advanced filtering and search
