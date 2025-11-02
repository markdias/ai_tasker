# Promptodo Architecture Overview

## M1 Architecture (Current)

```
┌─────────────────────────────────────────────────┐
│          PromptodoApp (Entry Point)             │
│  • SwiftData ModelContainer initialization      │
│  • AppState injection via .environment()        │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│           RootView (Router)                     │
│  • Switches between screens based on             │
│    AppState.currentFlow                         │
└────────────────────┬────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
    ┌────────┐  ┌──────────┐  ┌────────────────┐
    │ Home   │→ │Questions │→ │ Task Review    │
    │ View   │  │ Form     │  │ View           │
    └────────┘  └──────────┘  └───────┬────────┘
                                       │
                                       ▼
                              ┌──────────────────┐
                              │ Project          │
                              │ Dashboard (M4)   │
                              └──────────────────┘
```

---

## Data Flow

### 1. Prompt Input (HomeView)
```
User Input (text/voice)
        │
        ▼
SpeechRecognizer (optional)
        │
        ▼
PromptLocal (created)
        │
        ▼
AppState.currentPrompt
        │
        ▼
Navigate to QuestionForm
```

### 2. Question Answering (QuestionFormView)
```
Mock Questions (M1) / ChatGPT (M2)
        │
        ▼
AppState.currentQuestions[]
        │
        ▼
User fills answers
        │
        ▼
AppState.currentAnswers[]
        │
        ▼
Navigate to TaskReview
```

### 3. Task Review (TaskReviewView)
```
Mock Tasks (M1) / ChatGPT (M2)
        │
        ▼
GeneratedTaskModel[]
        │
        ▼
User accepts/rejects
        │
        ▼
Create ProjectLocal + TaskLocal[]
        │
        ▼
Save to SwiftData
        │
        ▼
Navigate to ProjectDashboard
```

---

## State Management

### AppState (Observable)
```swift
@Observable
class AppState {
    // Navigation
    var currentFlow: AppFlow

    // Session
    var currentPrompt: PromptLocal?
    var currentQuestions: [QuestionCard]
    var currentAnswers: [String]
    var generatedTasks: [GeneratedTaskModel]

    // UI
    var isLoading: Bool
    var errorMessage: String?

    // Settings
    var openAIAPIKey: String? (Keychain)
}
```

### View Hierarchy
```
RootView
├── HomeView
│   └── VoiceRecordingButton
│       └── SpeechRecognizer
├── QuestionFormView
│   └── ProgressBar
├── TaskReviewView
│   └── TaskAcceptanceCard
├── TaskDetailsView (M3)
├── ProjectDashboardView (M4)
│   └── ProjectCard
└── ErrorOverlayView
```

---

## Data Models (SwiftData)

### ProjectLocal
```
ProjectLocal
├── id: String (unique)
├── title: String
├── description: String?
├── taskCount: Int
├── completedTaskCount: Int
├── tasks: [TaskLocal] (one-to-many)
└── timestamps
```

### TaskLocal
```
TaskLocal
├── id: String (unique)
├── title: String
├── type: String (list|text|number|currency|date)
├── status: String (pending|in_progress|completed)
├── inputSchemaJSON: String (Codable schema)
├── dataJSON: String (user input)
├── project: ProjectLocal (many-to-one)
└── timestamps
```

### PromptLocal
```
PromptLocal
├── id: String (unique)
├── text: String
├── voiceDataURL: String?
├── status: String (pending|completed|rejected)
└── timestamps
```

---

## Services

### SpeechRecognizer
- Uses `AVAudioEngine` + `SFSpeechRecognizer`
- Processes audio locally (no server calls)
- Returns transcribed text

### OpenAIService (M2)
- Will wrap ChatGPT API calls
- Generate questions and tasks
- Store AI history in Firestore

### FirebaseService (M2)
- Firestore sync
- Authentication
- Cloud Storage for voice files

### KeychainManager
- Secure API key storage
- Never synced to cloud

---

## Error Handling

```
                    Error Occurs
                         │
                         ▼
                  appState.setError()
                         │
                         ▼
                  ErrorOverlayView
                    (shown as overlay)
                         │
                         ▼
                  User dismisses
                         │
                         ▼
                  appState.clearError()
```

---

## M2+ Architecture Changes

### Firebase Integration
```
┌──────────────────┐
│ SwiftData        │
│ (Local Cache)    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ FirebaseService  │
├──────────────────┤
│ • Sync           │
│ • Auth           │
│ • Cloud Storage  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Firebase         │
│ (Backend)        │
└──────────────────┘
```

### ChatGPT Integration
```
AppState + Answers
         │
         ▼
OpenAIService
         │
         ▼
ChatGPT API
         │
         ▼
Generate Questions/Tasks
         │
         ▼
Store in FirebaseService
         │
         ▼
Populate AppState
         │
         ▼
Render Views
```

---

## Key Design Principles

1. **Single Source of Truth:** AppState
2. **View = State Function:** UI always reflects AppState
3. **Observable Pattern:** Views auto-update when state changes
4. **Separation of Concerns:** Models, ViewModels, Views, Services
5. **Composition:** Reusable view components
6. **Local-First:** SwiftData as primary storage
7. **Security:** API keys in Keychain, never in Firestore

---

## Performance Considerations

### M1
- ✅ Fast: All data in memory during session
- ✅ Lightweight: No network calls
- ⚠️ Issue: Data lost on app close

### M2+
- ⚠️ Network: Firestore sync adds latency
- ✅ Persistence: Data survives app restart
- ✅ Sync: Multi-device support (future)

### Optimization Strategies
- Lazy load projects in dashboard
- Cache ChatGPT responses in Firestore
- Debounce Firestore writes
- Use offline-first SwiftData
- Pagination for large task lists

---

## Testing Strategy

### Unit Tests
- `AppState` navigation logic
- `SpeechRecognizer` transcription
- Data model encoders/decoders

### UI Tests
- Flow: Home → Form → Review → Dashboard
- Button interactions
- Error display

### Integration Tests (M2+)
- Firebase sync
- ChatGPT API mocking
- Error recovery

---

## Future Scalability

### Multi-User (Post-M6)
- User model + authentication
- Shared projects with permissions
- Real-time collaboration via Firestore

### Analytics
- Track prompt-to-task conversion
- Monitor ChatGPT API costs
- User engagement metrics

### Performance
- Pagination for large datasets
- Caching layer
- Offline-first capabilities

### Internationalization
- Localization strings
- ChatGPT language support
- Regional compliance

