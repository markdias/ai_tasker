# Promptodo Build Plan

## 1. Overview
Promptodo is a **voice- and text-driven personal and family task generator** that turns prompts into structured projects and tasks. It uses the **ChatGPT API** to generate clarifying questions, structured tasks, and clever task inputs such as lists, costs, or linked budgets.  

The app will run on **iOS 18+ (future-ready for iOS 26 Liquid Glass)** using **SwiftUI** and a **cloud backend** for data.  

---

## 2. Core Concept and Flow
1. **User opens Promptodo**
   - Input prompt via text or voice (voice is priority).
   - Example: "Plan a birthday party."

2. **ChatGPT generates 5 form-style questions** (not conversational).
   - Questions appear as cards the user swipes through.
   - User must answer all, no skipping.

3. **ChatGPT generates tasks and subtasks** based on responses.
   - Each task includes type-detected input fields (list, number, cost, date).
   - Example:
     - "Create Guest List" → list field
     - "Set Budget" → numeric input linked to cost fields

4. **User approves/rejects tasks** before adding them to a project.
   - Accept or Reject individual tasks (no detailed editing in MVP).

5. **Tasks saved under a generated Project.**
   - Projects group related tasks.
   - Example: "Birthday Party Project" with "Guest List", "Menu", "Budget" etc.

6. **Single-user MVP** (no sharing/assignment in MVP).
   - Multi-user collaboration deferred to post-MVP.

7. **Sync and Notifications** (one-way for MVP)
   - One-way sync: Promptodo → Apple Reminders.
   - Optional two-way sync and calendar later.

---

## 3. Data Architecture
**Backend:** Firebase (or Supabase alternative)  
**Storage:** Cloud database + backend for AI logs  
**Local:** Cache for offline editing  

| Entity | Fields | Description |
|--------|---------|-------------|
| `User` | id, name, email, appleId, role | Individual or family member |
| `Prompt` | id, text, voiceDataURL | Raw prompt from user |
| `PromptResponse` | id, promptId, question, answer | Five-question form answers |
| `Task` | id, projectId, title, description, type, inputs, status, dueDate, cost, linkedListId | Supports clever inputs |
| `Project` | id, title, metadata, ownerId | Group container for tasks |
| `Assignment` | taskId, assigneeEmail, status | Handles shared or synced tasks |
| `AIHistory` | id, promptId, chatResponse | For backend AI recordkeeping |

---

## 4. ChatGPT Integration
- **Autonomy:** ChatGPT handles full logic for generating clarifying questions, tasks, and input detection.  
- **Backend-driven:** All prompts and responses stored in backend.  
- **Visible conversation:** Users can see AI reasoning.  

**API Model Suggestion:**
```json
{
  "questions": [...],
  "tasks": [
    {
      "title": "Create Guest List",
      "type": "list",
      "fields": ["guest_name", "contact_info"],
      "dependencies": []
    }
  ]
}
```

---

## 5. Clever Tasks and Input Handling
Each generated task automatically detects required field types:
- `list`: checklist or table (guest list, shopping items)  
- `number`: numeric input (budget, quantity)  
- `currency`: cost fields  
- `date`: deadlines or reminders  
- `text`: free notes  

Rendered using dynamic SwiftUI components based on schema type.

---

## 6. Collaboration and Syncing
- **Assignments:** Invite via Apple ID or email.  
- **Non-users:** Assigned tasks appear in Apple Reminders.  
- **Sync:** Two-way sync with Reminders.  
- **Notifications:** Managed by Apple’s native system.  

Future upgrade: Firebase Cloud Messaging for cross-platform notifications.

---

## 7. Projects
Projects are containers for grouped tasks with metadata: title, due date, progress, and budget.  
They can be generated via prompts and support multiple users (owner, editor, viewer).

---

## 8. Privacy and Data
- **Cloud backend:** temporary prompt storage.  
- **Disposable data:** deleted after each session unless saved.  
- **Compliance:** GDPR-ready options to delete or export data.  

---

## 9. UX and Design
- **Visual layout:** card and board views for tasks and projects.  
- **Key screens:**
  1. Home (prompt input + voice)
  2. Five-question form
  3. AI task results
  4. Project dashboard (cards/kanban)
  5. Task details (dynamic input view)

Theme: Apple-style Liquid Glass for iOS 18+.

---

## 10. Technical Plan
- **Framework:** SwiftUI 5, iOS 18+  
- **Architecture:** MVVM + SwiftData  
- **Backend:** Firebase (Firestore + Auth)  
- **AI:** OpenAI Chat Completions (ChatGPT API)  
- **Integrations:**  
  - Apple Reminders (EventKit)  
  - Speech Framework for voice input  
  - Siri Shortcuts (later version)

---

## 11. Monetisation
- Free app initially.  
- Future upgrades: premium tier for teams or AI credits.  

---

## 12. MVP Milestones (Refined)

**MVP Scope:** Single-user, voice + text input, question/task generation, one-way Reminders sync.

| Phase | Focus | Duration | Key Deliverables |
|-------|--------|-----------|------------------|
| M1 | Base UI & Prompt Flow | 3 weeks | Prompt input (text + voice) → Swiping question cards → Tasks view |
| M2 | AI Integration | 3 weeks | ChatGPT-driven question & task generation (accept/reject) |
| M3 | Task Input System | 2 weeks | Dynamic fields (list, cost, number, date, text) |
| M4 | Project Management | 2 weeks | Single-user project grouping & task organization |
| M5 | Reminders Sync | 2 weeks | One-way sync: Promptodo → Apple Reminders |
| M6 | Polish & Test | 2 weeks | Visual refinements, onboarding, beta release |

**Post-MVP Features:** Multi-user assignments, two-way sync, task editing, budget tracking, AI summaries.

---

## 13. Future Features
- Siri and Apple Shortcuts integration for “Create promptodo” commands.  
- Shared projects with progress dashboards.  
- Budget tracking and AI-generated summaries.  
- Weekly AI “review my week” summaries.  
