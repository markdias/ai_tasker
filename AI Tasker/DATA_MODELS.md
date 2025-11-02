# Promptodo Data Models & Firebase Schema

## Overview
This document defines the data structures for Promptodo, optimized for Firebase Firestore with local SwiftData caching.

---

## 1. Core Entities

### User
Represents a single user (MVP is single-user, but structure ready for multi-user).

**Firestore Path:** `users/{userId}`

```json
{
  "id": "user123",
  "email": "user@example.com",
  "name": "John Doe",
  "appleId": "001234.abcdef..." (optional, for future Sign in with Apple),
  "createdAt": "2025-11-02T10:30:00Z",
  "updatedAt": "2025-11-02T10:30:00Z",
  "apiKey": "" (NOT stored in Firestore—stored locally only),
  "settings": {
    "notificationsEnabled": true,
    "darkMode": false,
    "syncToReminders": true
  }
}
```

**MVP Notes:**
- `apiKey` is stored **locally only** (Keychain) on the device.
- Firebase Auth handles user sign-up/login (anonymous or email).
- `appleId` is reserved for future Sign in with Apple.

---

### Prompt
Represents the raw user input (text or voice).

**Firestore Path:** `users/{userId}/prompts/{promptId}`

```json
{
  "id": "prompt_abc123",
  "userId": "user123",
  "text": "Plan a birthday party",
  "voiceDataURL": "gs://bucket/prompts/user123/voice_abc123.m4a" (optional),
  "createdAt": "2025-11-02T10:30:00Z",
  "status": "pending" (pending | completed | rejected),
  "aiGeneratedAt": "2025-11-02T10:32:00Z"
}
```

**MVP Notes:**
- Voice files stored in Firebase Cloud Storage.
- Local speech-to-text (Speech Framework) before uploading.
- `status` tracks whether prompt led to saved tasks.

---

### PromptResponse
Represents the answers to the 5 clarifying questions.

**Firestore Path:** `users/{userId}/prompts/{promptId}/responses/{responseId}`

```json
{
  "id": "response_xyz789",
  "promptId": "prompt_abc123",
  "answers": [
    {
      "questionIndex": 1,
      "question": "What's the occasion?",
      "answer": "My sister's 30th birthday"
    },
    {
      "questionIndex": 2,
      "question": "How many guests?",
      "answer": "About 50 people"
    },
    {
      "questionIndex": 3,
      "question": "What's your budget?",
      "answer": "$2000"
    },
    {
      "questionIndex": 4,
      "question": "Preferred venue type?",
      "answer": "Outdoor garden"
    },
    {
      "questionIndex": 5,
      "question": "Any dietary restrictions?",
      "answer": "2 vegetarians, 1 vegan"
    }
  ],
  "createdAt": "2025-11-02T10:32:00Z"
}
```

**MVP Notes:**
- Simple string answers (no complex types in MVP).
- Sent to ChatGPT to generate tasks.

---

### Task
Represents a single actionable task with dynamic input fields.

**Firestore Path:** `users/{userId}/projects/{projectId}/tasks/{taskId}`

```json
{
  "id": "task_123",
  "projectId": "project_xyz",
  "title": "Create Guest List",
  "description": "Compile the list of guests and their contact info",
  "type": "list",
  "inputSchema": {
    "fieldType": "list",
    "itemSchema": {
      "fields": [
        {
          "name": "guest_name",
          "label": "Guest Name",
          "type": "text",
          "required": true
        },
        {
          "name": "contact_info",
          "label": "Email or Phone",
          "type": "text",
          "required": false
        }
      ]
    }
  },
  "data": {
    "items": [
      {
        "id": "item_1",
        "guest_name": "John Smith",
        "contact_info": "john@example.com"
      },
      {
        "id": "item_2",
        "guest_name": "Jane Doe",
        "contact_info": "+1-555-0100"
      }
    ]
  },
  "status": "pending" (pending | in_progress | completed),
  "dueDate": "2025-11-15T23:59:59Z" (optional),
  "cost": 0 (optional, if currency type),
  "linkedListId": "list_xyz" (optional, for cost tracking across tasks),
  "createdAt": "2025-11-02T10:32:00Z",
  "updatedAt": "2025-11-02T10:35:00Z",
  "syncedToReminders": false,
  "reminderIdentifier": "" (optional, Apple Reminders event ID)
}
```

**Field Types Supported:**
- `list` — table/checklist (array of items)
- `text` — free-form text
- `number` — numeric input
- `currency` — monetary value
- `date` — date picker
- `checkbox` — boolean toggle

**MVP Notes:**
- `inputSchema` defines how to render the input UI.
- `data` stores the actual user input (flexible structure).
- `status` tracks progress (pending → in_progress → completed).
- `reminderIdentifier` links to Apple Reminders for sync.

---

### Project
Represents a grouping of related tasks.

**Firestore Path:** `users/{userId}/projects/{projectId}`

```json
{
  "id": "project_xyz",
  "userId": "user123",
  "title": "Birthday Party Planning",
  "description": "Plans for Sarah's 30th birthday",
  "promptId": "prompt_abc123" (optional, which prompt generated this),
  "metadata": {
    "dueDate": "2025-11-15T23:59:59Z" (optional),
    "budget": 2000 (optional),
    "budgetCurrency": "USD"
  },
  "taskCount": 6,
  "completedTaskCount": 2,
  "createdAt": "2025-11-02T10:32:00Z",
  "updatedAt": "2025-11-02T10:35:00Z",
  "isArchived": false
}
```

**MVP Notes:**
- Simple container for tasks.
- `promptId` links back to the original prompt.
- `metadata` is flexible for future extensions (budget, dates, etc.).

---

### AIHistory (Backend Logging)
Represents the ChatGPT API requests and responses (for logging and debugging).

**Firestore Path:** `users/{userId}/prompts/{promptId}/aiHistory/{historyId}`

```json
{
  "id": "history_abc",
  "promptId": "prompt_abc123",
  "requestType": "generate_questions" (generate_questions | generate_tasks),
  "chatRequest": {
    "model": "gpt-4-turbo",
    "messages": [
      {
        "role": "user",
        "content": "Plan a birthday party..."
      }
    ]
  },
  "chatResponse": {
    "model": "gpt-4-turbo",
    "usage": {
      "prompt_tokens": 150,
      "completion_tokens": 200
    },
    "choices": [
      {
        "message": {
          "role": "assistant",
          "content": "{\n\"questions\": [...]\n}"
        }
      }
    ]
  },
  "createdAt": "2025-11-02T10:30:00Z",
  "tokensUsed": 350,
  "costEstimate": 0.01
}
```

**MVP Notes:**
- Stored for debugging and cost tracking.
- Timestamps all AI calls.
- Optional: deleted after 30 days to save storage.

---

## 2. SwiftData Models (Local Cache)

SwiftData will mirror Firestore for offline access. Models:

```swift
@Model
final class PromptLocal {
    @Attribute(.unique) var id: String
    var text: String
    var voiceDataURL: String?
    var createdAt: Date
    var status: String // "pending", "completed", "rejected"
}

@Model
final class ProjectLocal {
    @Attribute(.unique) var id: String
    var title: String
    var description: String?
    var taskCount: Int
    var createdAt: Date
}

@Model
final class TaskLocal {
    @Attribute(.unique) var id: String
    var projectId: String
    var title: String
    var description: String?
    var type: String // "list", "text", "number", "currency", "date"
    var status: String // "pending", "in_progress", "completed"
    var dueDate: Date?
    var data: Data? // JSON blob for input data
    var createdAt: Date
}
```

---

## 3. Firebase Firestore Index & Query Strategy

### Collections Structure
```
users/
├── {userId}/
    ├── prompts/
    │   ├── {promptId}
    │   └── responses/
    │       └── {responseId}
    ├── projects/
    │   ├── {projectId}
    │   └── tasks/
    │       └── {taskId}
    └── aiHistory/
        └── {historyId}
```

### Key Queries (MVP)
- **Get all projects:** `users/{userId}/projects` (ordered by createdAt DESC)
- **Get tasks for project:** `users/{userId}/projects/{projectId}/tasks` (ordered by createdAt DESC)
- **Get pending tasks:** Filter by `status == "pending"`
- **Get completed tasks:** Filter by `status == "completed"`

### Indexes (auto-created by Firestore)
- Prompt: createdAt (descending)
- Task: status, dueDate (for filtering)
- Project: createdAt (descending)

---

## 4. API Models (ChatGPT Integration)

### Request: Generate Clarifying Questions

```json
{
  "model": "gpt-4-turbo",
  "messages": [
    {
      "role": "user",
      "content": "Generate 5 clarifying questions for this prompt: 'Plan a birthday party for 50 people with a $2000 budget.' Return JSON with a 'questions' array containing objects with 'index' and 'text' fields."
    }
  ],
  "temperature": 0.7
}
```

### Response: Generated Questions

```json
{
  "questions": [
    {
      "index": 1,
      "text": "What's the occasion or theme for this party?"
    },
    {
      "index": 2,
      "text": "Do you have a preferred venue type (indoor/outdoor)?"
    },
    {
      "index": 3,
      "text": "Are there any dietary restrictions or allergies?"
    },
    {
      "index": 4,
      "text": "What's your preferred date and time?"
    },
    {
      "index": 5,
      "text": "Would you like catering or DIY food?"
    }
  ]
}
```

---

### Request: Generate Tasks

```json
{
  "model": "gpt-4-turbo",
  "messages": [
    {
      "role": "user",
      "content": "Generate structured tasks for: Prompt: 'Plan a birthday party' Answers: [Q1: Occasion - Sister's 30th, Q2: Venue - Outdoor garden, Q3: Budget - $2000, Q4: Date - Nov 15, Q5: Catering - Hired caterer]. Return JSON with 'projectTitle', 'projectDescription', and 'tasks' array. Each task should have: title, description, type (list|text|number|currency|date), and inputFields array."
    }
  ],
  "temperature": 0.7
}
```

### Response: Generated Tasks

```json
{
  "projectTitle": "Sarah's 30th Birthday Party",
  "projectDescription": "Planning outdoor garden party for 50 guests with professional catering",
  "tasks": [
    {
      "title": "Create Guest List",
      "description": "Compile guest names and contact info",
      "type": "list",
      "inputFields": [
        {
          "name": "guest_name",
          "label": "Guest Name",
          "type": "text",
          "required": true
        },
        {
          "name": "contact_info",
          "label": "Email or Phone",
          "type": "text",
          "required": false
        }
      ]
    },
    {
      "title": "Confirm Budget",
      "description": "Verify and allocate the $2000 budget across categories",
      "type": "currency",
      "inputFields": [
        {
          "name": "total_budget",
          "label": "Total Budget",
          "type": "currency",
          "value": 2000
        }
      ]
    },
    {
      "title": "Set Party Date & Time",
      "description": "Confirm November 15th and send invites with date/time",
      "type": "date",
      "inputFields": [
        {
          "name": "party_date",
          "label": "Date",
          "type": "date",
          "value": "2025-11-15"
        },
        {
          "name": "party_time",
          "label": "Time",
          "type": "text",
          "value": "6:00 PM"
        }
      ]
    }
  ]
}
```

---

## 5. Local Storage (Keychain)

**What goes in Keychain (NOT Firestore):**
- OpenAI API Key (encrypted)
- Firebase Authentication Token
- User session tokens

---

## 6. Summary Table

| Entity | Storage | Lifecycle | Sync |
|--------|---------|-----------|------|
| User | Firebase Auth + Firestore | Persistent | One-time on login |
| Prompt | Firestore + SwiftData | Persistent | Bidirectional |
| PromptResponse | Firestore + SwiftData | Persistent | One-way (upload) |
| Task | Firestore + SwiftData | Persistent | Bidirectional |
| Project | Firestore + SwiftData | Persistent | Bidirectional |
| AIHistory | Firestore (optional pruning) | 30-day retention | Upload only |
| API Keys | Keychain | Persistent | Never synced |

---

## 7. Future Considerations (Post-MVP)

- **Two-way Reminders sync:** Track `reminderIdentifier` for edits.
- **Assignments:** Add `Assignment` entity for multi-user tasks.
- **Budget rollup:** Calculate total project budget from currency-type tasks.
- **Subtasks:** Nest tasks under parent tasks.
- **Attachments:** Link files/images to tasks.
