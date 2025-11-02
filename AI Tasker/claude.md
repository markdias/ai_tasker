# Claude.md

## App Overview
**Name:** Claude  
**Platform:** iOS (Swift + SwiftUI)  
**Purpose:** The app takes a short description of what the user wants to achieve in a day and uses AI (via the OpenAI ChatGPT API) to generate a structured list of tasks to complete that goal.

---

## Core Features
1. **User Input**
   - Text box for a short description (e.g., "I want to study for my exams and clean my room").
   - Optional fields for:
     - Time available (hours)
     - Priority level
     - Task categories (e.g., work, study, personal)

2. **AI Integration**
   - Connect to the user’s ChatGPT account using the OpenAI API.
   - Send the description and parameters as a prompt.
   - Receive structured JSON with task data (title, description, estimated time, priority).

3. **Task Display**
   - Show the AI-generated tasks in a clean, checklist format.
   - Allow users to:
     - Edit task names and descriptions
     - Mark tasks as complete
     - Delete tasks

4. **Persistence**
   - Save tasks locally using Core Data or SwiftData.
   - Optionally, sync with iCloud for backup.

5. **Scheduling & Notifications**
   - Allow users to assign times to tasks.
   - Push reminders using the UserNotifications framework.

6. **Customization**
   - Light/Dark mode.
   - Simple settings page for:
     - API key entry (stored securely in Keychain)
     - Default AI model selection (e.g., GPT-4-turbo)
     - Default task generation style (short or detailed)

---

## Technical Stack
| Component | Technology |
|------------|-------------|
| Frontend UI | SwiftUI |
| Backend/Logic | Swift (MVVM architecture) |
| AI Integration | OpenAI ChatGPT API |
| Local Data | Core Data or SwiftData |
| Notifications | UserNotifications framework |
| Authentication | API key input + secure Keychain storage |

---

## API Integration Plan
1. **Setup**
   - Add a settings view for entering and storing the OpenAI API key.
   - Use URLSession to send POST requests to the OpenAI API.

2. **Example Prompt**
   ```json
   {
     "model": "gpt-4-turbo",
     "messages": [
       {"role": "system", "content": "You create detailed task lists from short goals."},
       {"role": "user", "content": "I want to learn Swift and clean my apartment today."}
     ],
     "temperature": 0.7
   }