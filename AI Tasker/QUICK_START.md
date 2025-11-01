# AI Tasker - Quick Start Guide

## Getting Started

### Prerequisites
- iOS 16 or later
- OpenAI API key (optional - app has fallback mode)
- Internet connection for AI task generation

### First Launch
1. Open the app
2. Accept notification permission when prompted
3. You'll see an empty task list with a "Generate Tasks" button

---

## Setting Up Your OpenAI API Key

### Step 1: Get Your API Key
1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign in or create an account
3. Generate a new API key
4. Copy the key (you won't see it again!)

### Step 2: Store in AI Tasker
1. Tap the gear icon (⚙️) in the top-right
2. Tap "API Key Setup"
3. Paste your API key in the text field
4. Tap "Save API Key"
5. You should see "API key is configured" confirmation

### Optional: Customize AI Settings
1. In Settings, tap "Model Selection" to choose:
   - **GPT-4-Turbo** (recommended) - Best balance of cost and performance
   - **GPT-4** - Most powerful but more expensive
   - **GPT-3.5-Turbo** - Fastest and cheapest
2. Tap "Task Generation Style" to choose:
   - **Detailed** - Includes context and tips (default)
   - **Brief** - Quick actionable tasks

---

## Creating Tasks

### Option 1: Using AI (Recommended)
1. Tap the **+** button in the toolbar
2. Describe your daily goal (e.g., "Study for exams and clean my room")
3. Set optional parameters:
   - **Priority Level**: Low, Medium, or High
   - **Category**: Work, Study, Personal, Health, or Home
   - **Time Available**: 1-24 hours
4. Make sure "Use AI (ChatGPT)" is enabled
5. Tap "Generate with AI"
6. Wait for ChatGPT to analyze your goal and create tasks

### Option 2: Without AI
1. Tap the **+** button
2. Describe your goal
3. Turn OFF "Use AI (ChatGPT)"
4. Tap "Generate Tasks"
5. The app will create tasks based on keyword matching

---

## Managing Your Tasks

### Mark a Task Complete
- Tap the **circle icon** next to a task
- It becomes green with a checkmark
- The task title gets struck through

### View Task Details
- Tap anywhere on a task row
- See full description, priority, time estimate, and category

### Edit a Task
1. Tap the task to open details
2. Modify any field:
   - Title and description
   - Priority level
   - Category
   - Estimated time (5-480 minutes)
3. Optionally schedule the task with a date/time
4. Tap "Save Changes"

### Schedule a Task Reminder
1. Open a task's detail view
2. Toggle "Schedule Task" on
3. Select date and time for the reminder
4. Tap "Save Changes"
5. You'll receive a notification at the scheduled time

### Delete a Task
- Swipe left on a task in the list
- Tap the delete button

---

## Understanding Your Task Display

Each task shows:
- **Checkbox**: Mark complete
- **Title**: Task name (struck through if complete)
- **Description**: Task details (preview, 2 lines)
- **Tag**: Category with icon
- **Priority**: High 🔴, Medium 🟠, or Low ⚪
- **Time**: Estimated minutes with clock icon

---

## Tracking Your Progress

### View Statistics
1. Tap the **Stats** tab at the bottom
2. See:
   - **Completed Today**: Tasks finished today
   - **Overall Completion**: Percentage of all tasks done
   - **Time Spent**: Total minutes on completed tasks
   - **Task Summary**: Total, completed, and remaining counts

---

## Notifications & Reminders

### Enable Notifications
- Grant permission when first prompted
- Can enable anytime in iPhone Settings > AI Tasker > Notifications

### Schedule Reminders
1. Open a task's detail view
2. Toggle "Schedule Task" on
3. Choose date and time
4. Save changes
5. You'll get a notification at that time

### Manage Reminders
- Remove a scheduled time to cancel the reminder
- Reminders are local to your device (no cloud sync)

---

## Tips & Tricks

### 1. Effective Goal Descriptions
❌ Bad: "study"
✅ Good: "Learn chapter 5 of calculus, complete practice problems, and create summary notes"

### 2. Use Categories Wisely
Organize tasks by:
- **Work**: Job-related tasks
- **Study**: Learning and education
- **Personal**: Self-care and hobbies
- **Health**: Exercise and wellness
- **Home**: Household chores

### 3. Realistic Time Estimates
The app shows total time on completed tasks - be honest with estimates:
- Small tasks: 5-15 minutes
- Medium tasks: 15-60 minutes
- Large tasks: 60+ minutes

### 4. Group Related Goals
Create one session per major goal:
- "Prepare for presentation" generates multiple slides, rehearsal, and timing tasks
- "Clean apartment" breaks into room-by-room tasks

### 5. Monitor Progress
- Check Stats tab daily to track productivity
- Completion percentage shows how you're doing
- Time tracking helps validate estimates for future planning

---

## Troubleshooting

### "API key not configured"
**Solution**: Go to Settings > API Key Setup and add your OpenAI API key

### No tasks generated from AI
**Possible causes**:
1. API key not set or invalid
2. Network connection issue
3. OpenAI API quota exceeded
4. Goal description too vague

**Solution**: Try toggling "Use AI" off to use pattern matching instead

### Notifications not working
**Solution**: Check iPhone Settings > AI Tasker > Notifications are enabled

### Tasks not saving
**Solution**: Make sure you tapped "Save Changes" in the task detail view

### App crashes on launch
**Solution**: Force quit the app and reopen. If persists, check iOS version (iOS 16+)

---

## Privacy & Security

- **API Keys**: Stored securely in iPhone Keychain, never sent to iCloud
- **Tasks**: Stored locally with optional iCloud backup
- **Data**: Never shared with third parties
- **OpenAI**: Only your goal text is sent to generate tasks

---

## Keyboard Shortcuts

| Gesture | Action |
|---------|--------|
| Swipe left | Delete task |
| Tap circle | Toggle complete |
| Tap task | View/edit details |
| Long press | (future feature) |

---

## What's Next?

### Planned Features
- Dark mode
- Recurring tasks
- Task dependencies
- Calendar view
- Voice input
- Export to CSV
- Sharing with others

### Feedback
Have suggestions? Found a bug? Let us know through the App Store feedback.

---

**Happy tasking! 📋✨**
