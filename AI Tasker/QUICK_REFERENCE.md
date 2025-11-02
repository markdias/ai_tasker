# Quick Reference Guide - What Changed & How to Use It

## 🎯 Quick Summary
Your Promptodo app now has smarter task generation, better cost tracking, and improved list management. Here's what's new.

---

## 🆕 New Features

### 1. **Cost Tracking** 💰
**What's New**: Tasks can now have costs that automatically contribute to your project budget

**How to Use**:
- Open any task and tap "Cost" section
- Enter the dollar amount
- Cost automatically added to project total
- See budget status on project cards

**Example**: Plan a party → Each catering task shows cost → Project shows "Total: $250 / $500 Budget"

---

### 2. **Category Tags** 🏷️
**What's New**: Organize tasks by category (Work, Personal, Shopping, Home, etc.)

**How to Use**:
- Open task details
- Tap "Category" menu
- Select from 8 categories
- Category displays as purple tag on task list

**Example**: Budget task → Tag as "Finance" → Easily find all finance-related tasks

---

### 3. **Enhanced List Editing** ✏️
**What's New**: Edit, mark complete, and track list items

**How to Use**:
- Open a list-type task (shopping list, guest list, etc.)
- **Add items**: Type name → Tap + button
- **Edit items**: Tap pencil icon → Edit text → Tap ✓
- **Mark complete**: Tap checkbox → Item gets strikethrough
- **Delete items**: Tap X button
- Progress shows: "5 items • 2 completed"

**Example**: Shopping list → Add milk, eggs, bread → Check off as you shop

---

### 4. **Smarter Task Generation** 🤖
**What's New**: AI now generates 5-8 tasks with better list detection

**Key Improvements**:
- **More tasks**: 5-8 per project instead of 3-5
- **List detection**: Recognizes when you need guest lists, shopping lists, etc.
- **Rich fields**: Each list item has multiple fields (Name, Email, Quantity, Price, etc.)
- **Better examples**: AI generates more detailed task structures

**Examples**:
- "Plan a party" → Guest list (Name, Email, Phone, Dietary Restrictions)
- "Plan a trip" → Packing list (Item, Category, Quantity, Packed?)
- "Renovate kitchen" → Materials list (Item, Quantity, Supplier, Cost)

---

## 📊 Where to Find These Features

### On Task Details Screen
```
┌─────────────────────────┐
│ Task Title              │
├─────────────────────────┤
│ ⭕ Status: Pending      │
│ 💵 Cost: $50.00         │ ← NEW
│ 📅 Due Date: Jan 1, 25  │ ← NEW
│ 🏷️ Category: Work       │ ← NEW
├─────────────────────────┤
│ Task Details            │
│ ┌───────────────────┐   │
│ │ ☐ Item 1         │   │ ← NEW: Edit/Delete
│ │ ☑ Item 2         │   │ ← NEW: Mark complete
│ └───────────────────┘   │
├─────────────────────────┤
│ [💾 Save Task]          │
└─────────────────────────┘
```

### On Project Dashboard
```
┌──────────────────────────┐
│ Birthday Party Plan      │
├──────────────────────────┤
│ Tasks: 4/8              │
│ ████░░░░ 50%            │
├──────────────────────────┤
│ Budget:                  │ ← NEW
│ $250/$500               │
│ ████░░░░ 50% used       │
└──────────────────────────┘
```

### On Task List
```
┌──────────────────────────┐
│ ⭕ Create Guest List     │
│ Party planning details   │
│ 📅 Dec 15  💵 $0   🏷️Work│ ← NEW: Category
├──────────────────────────┤
│ ⭕ Buy Decorations       │
│ 📅 Dec 10  💵 $45  🏷️Shop│ ← NEW: Cost + Category
└──────────────────────────┘
```

---

## 🚀 Quick Start Examples

### Example 1: Plan a Wedding
1. Open app → "New Project"
2. Type: "Plan my wedding"
3. Answer the 5 clarifying questions
4. Get tasks like:
   - **Guest List** (list type with Name, Email, Phone)
   - **Vendors** (list type with Type, Company, Phone, Quote)
   - **Budget** (currency type)
   - **Timeline** (date type)
5. Set costs on vendor and catering tasks
6. Tag all tasks with categories (Logistics, Catering, Finance, etc.)
7. Track progress and budget as you complete tasks

### Example 2: Home Renovation
1. Type: "Renovate my kitchen"
2. Get tasks like:
   - **Materials List** (list type with Item, Quantity, Cost)
   - **Contractor Quotes** (list type with Company, Phone, Quote)
   - **Design Selections** (list type)
   - **Timeline** (date type)
   - **Budget** (currency type)
3. Add costs to each task
4. Edit materials list as you shop (check off items)
5. Monitor budget on project card

### Example 3: Trip Packing
1. Type: "Pack for my vacation to Hawaii"
2. Get:
   - **Packing List** (with Category, Quantity)
   - **Electronics** (with Chargers, Cables needed)
   - **Travel Documents** (with Type, Status)
   - **Budget** (for shopping/purchases)
3. Edit packing list as you pack (check items)
4. See progress as you complete items

---

## 💡 Pro Tips

### Cost Tracking
- Set budgets on projects for automatic tracking
- Every task's cost automatically adds to project total
- Project cards show budget status at a glance
- Go to Project Settings for detailed budget breakdown

### List Management
- Each list item can have multiple fields
- Mark items complete as you work
- Completion shows progress (e.g., "3 of 5 items")
- Great for shopping, guest lists, checklists

### Category Usage
- Use categories to organize by:
  - **Work**: Job-related tasks
  - **Personal**: Personal errands/projects
  - **Shopping**: All shopping lists
  - **Home**: Home projects
  - **Health**: Health/wellness tasks
  - **Education**: Learning/courses
  - **Finance**: Budget/money tasks
  - **Other**: Miscellaneous

### Task Generation
- **Be specific**: "Plan a 50-person corporate picnic" generates better tasks than "Plan an event"
- **Answer thoroughly**: Detailed question answers help AI understand your needs
- **Review before saving**: Edit task titles/descriptions to match your vision
- **Expect 5-8 tasks**: More comprehensive coverage of your project

---

## ⚙️ Technical Details

### Files Changed
- TaskDetailsView.swift → Cost, due date, category fields
- InputFieldRenderers.swift → Enhanced list editor
- LocalModels.swift → Category field on tasks
- ProjectDashboardView.swift → Budget display on cards
- TaskListView.swift → Category badge display
- OpenAIService.swift → Smarter task generation

### Data Persistence
- All costs save to database
- Categories save to tasks
- List items save as JSON
- All changes sync with SwiftData

### Backward Compatibility
- Existing projects work unchanged
- Old tasks continue to work
- No breaking changes
- Safe to update without data loss

---

## 🎓 Learning Path

### Beginner
1. Create first project with new prompt
2. Notice 5-8 tasks generated (vs. 3-5 before)
3. See list fields with multiple input areas
4. Set cost on one task
5. View project card and see budget update

### Intermediate
1. Create project with guest list task
2. Edit list items (add/edit/delete)
3. Add costs to multiple tasks
4. Tag tasks with categories
5. Track project budget and completion

### Advanced
1. Create complex project (wedding, home reno)
2. Use all field types together
3. Leverage cost tracking for budgeting
4. Use categories for filtering/organization
5. Export/share project status

---

## 🐛 Troubleshooting

### Cost not saving?
- Make sure to tap "Save Task" button
- Wait for green checkmark confirmation
- Check project card to verify total updated

### List items not editing?
- Tap pencil icon (not the item text)
- Make sure text field isn't empty
- Tap green checkmark to save edit

### Category not showing?
- Open task and make sure category is selected
- Save the task
- Refresh task list (pull down) if needed

### Tasks not generated?
- Check API key is set in Settings
- Make sure you answered all 5 questions
- Try a more specific prompt
- Check internet connection

---

## 📞 Need Help?

Check out these guides:
- **TASK_GENERATION_ENHANCEMENT.md** → How AI generates tasks
- **EXAMPLE_PROMPTS.md** → Real examples by use case
- **COMPREHENSIVE_IMPROVEMENTS.md** → Full technical details

---

## ✅ Checklist for New Users

- [ ] Set OpenAI API key in Settings
- [ ] Create first project with detailed prompt
- [ ] Review generated tasks
- [ ] Edit task details (cost, date, category)
- [ ] Add items to list-type tasks
- [ ] Mark some items complete
- [ ] View project budget tracking
- [ ] Explore category tagging
- [ ] Try different prompts to see variations

Happy organizing! 🎉
