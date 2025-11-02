# AI Tasker - Project Management Feature Update

## What's New

The AI Tasker app has been upgraded with an intelligent **Project Management System** that fundamentally changes how users plan complex goals.

### Before
- Users entered a goal
- App generated a flat list of tasks
- No context for related tasks
- Difficult to manage multi-step projects

### After  
- Users enter a goal
- **AI asks clarifying questions** to understand context
- User provides specific details (date, budget, guest count, etc.)
- **AI generates contextual task lists** based on complete information
- **All tasks organized in a project folder** with timeline and progress tracking

---

## Key Features

### 1. AI Clarifying Questions
When you create a new project, the AI doesn't just guess. It asks you specific questions:
- "What date is this for?"
- "How many people are involved?"
- "What's your budget?"
- "What's your priority level?"

Your answers directly influence the generated tasks.

### 2. Multi-Step Project Creation Wizard
The guided workflow ensures you provide all necessary information:
1. **Goal Input** → Describe what you want to plan
2. **Q&A Interview** → Answer AI-generated clarifying questions
3. **Review & Setup** → Confirm project details and due date
4. **Task Generation** → AI creates tailored task list
5. **Create Project** → All tasks saved in organized project folder

### 3. Projects Folder Organization
Tasks are now grouped by project:
- **Active Projects** - Currently being worked on
- **Archived Projects** - Completed or shelved
- Each project shows progress percentage, task count, and due date

### 4. Project Management
Full control over projects:
- Edit project details (name, description, due date)
- View all tasks within a project
- Mark tasks complete
- Add/remove individual tasks
- Archive completed projects
- Delete projects permanently

### 5. Visual Progress Tracking
- Progress bar showing % completion
- Task count (completed/total)
- Due date visibility
- Color-coded priorities

---

## User Experience Example

### Scenario: Planning a Birthday Party

**Step 1: You enter your goal**
```
"I want to plan a birthday party"
```

**Step 2: AI asks clarifying questions**
- "What is the date?" → You answer: "November 15, 2025"
- "How many guests?" → You answer: "25 people"
- "What type of party?" → You choose: "Casual Birthday"
- "What's your budget?" → You enter: "$300-400"

**Step 3: You review and create project**
- Project Title: "Birthday Party - November 15"
- Due Date: November 15, 2025
- Status: Ready to create

**Step 4: AI generates contextual tasks**
The app creates 20+ tasks like:
- Reserve venue (3 hours, High)
- Buy decorations (1.5 hours, Medium)
- Order cake (1 hour, High)
- Create invitations (1 hour, Medium)
- Plan menu (1.5 hours, Medium)
- Send RSVPs (1 hour, Medium)
- Setup decorations (2 hours, Medium)
- ...and more

**Step 5: All tasks organized in project**
- Navigate to "Projects" tab
- Tap the "Birthday Party" project
- See all 20+ tasks organized and ready to complete
- Track progress as you complete tasks
- Archive when done

---

## Navigation

The app now has **3 tabs**:

```
┌──────────────────────────────────┐
│ Tasks │ Projects │ Stats          │
└──────────────────────────────────┘
```

- **Tasks Tab** - Individual tasks (legacy mode)
- **Projects Tab** - NEW! All your projects and folders
- **Stats Tab** - Overall statistics and completion tracking

---

## What Problems Does This Solve?

### Problem 1: Lack of Context
**Before:** Generic task list with no connection to the original goal
**After:** Tasks are specific to your situation with clarifying questions ensuring AI understands what you need

### Problem 2: Related Tasks Scattered
**Before:** 20 tasks mixed with hundreds of others
**After:** All related tasks grouped in one project folder

### Problem 3: No Timeline
**Before:** Tasks are generic with no deadline
**After:** Projects have a due date and clear timeline

### Problem 4: Hard to Track Progress
**Before:** Completion % across all tasks (confusing)
**After:** Progress % per project + overall stats

### Problem 5: No Way to Manage Similar Projects
**Before:** All tasks in one list
**After:** Projects can be archived, keeping workspace clean

---

## Technical Details

### Core Data Changes
- **New Entity:** Project (with title, description, color, due date, archive status)
- **Relationship:** One Project → Many Tasks
- **Cascade Delete:** Deleting project removes all associated tasks

### New Services
- **ClarifyingQuestionsManager** - Generates and processes AI questions
- Asks contextual questions in multiple formats (text, date, multiple choice, number)
- Collects answers and generates tailored task lists

### New Views
- **ProjectCreationView** - 5-step wizard for project creation
- **ProjectsView** - List of active and archived projects
- **ProjectDetailView** - Manage individual project and its tasks

### Smart Features
- AI questions are dynamically generated based on your goal
- Question types automatically adapt (date picker for dates, etc.)
- Progress bars show completion at a glance
- Empty states guide new users
- Error handling with copy button for debugging

---

## How to Get Started

1. **Switch to Projects Tab**
   - Tap the "Projects" tab at the bottom

2. **Create Your First Project**
   - Tap the "+" button
   - Describe what you want to plan
   - Answer the AI's clarifying questions
   - Review and create

3. **Manage Your Project**
   - View all tasks for your project
   - Mark tasks complete as you go
   - See progress in real-time
   - Archive when finished

---

## Best Practices

✅ **DO:**
- Be specific in your goal description
- Answer all clarifying questions thoroughly
- Set realistic due dates
- Archive completed projects
- Review generated tasks before creation

❌ **DON'T:**
- Use vague goals ("plan stuff")
- Rush through clarifying questions
- Create projects without due dates
- Delete projects you might need later (archive instead)

---

## Future Enhancements

Coming soon:
- Task dependencies (mark tasks as blocking other tasks)
- Intelligent scheduling (auto-assign tasks to dates)
- Collaboration (share projects with others)
- Custom project colors and icons
- Burndown charts
- Project templates for reuse

---

## Summary

The Project Management feature transforms AI Tasker from a simple task list app into an intelligent project planning tool. By combining AI-powered clarifying questions with organized project structures, users can tackle complex goals systematically and stay motivated throughout the process.

**Try it out with your next big project!**

---

*Feature released: November 2025*
*Status: Production Ready*
