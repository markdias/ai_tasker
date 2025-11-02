# Dynamic Task Fields Feature Guide

## Overview

The Dynamic Task Fields system allows the AI to determine what additional details each task should capture. Instead of generic fields, the system generates context-specific fields for each task based on the project goal and user answers.

## How It Works

### 1. AI Field Generation

When you create a project with AI task generation:

1. User provides a goal (e.g., "Plan a birthday party")
2. User answers 5 clarifying questions
3. AI generates 15-30 tasks with context-specific fields for each task

**Example Task with Fields:**
- **Task:** "Book Accommodation"
- **Fields:**
  - Hotel Name (text)
  - Check-in Date (date)
  - Room Type (text)
  - Confirmation Number (text)

- **Task:** "Create Guest List"
- **Fields:**
  - Guest Name (text)
  - Contact Info (text)
  - Dietary Restrictions (text)

### 2. Field Types

The system supports five field types:

| Type | Use Case | Input |
|------|----------|-------|
| **text** | Names, descriptions, addresses | Text field |
| **number** | Quantities, prices, headcounts | Number input |
| **date** | Event dates, deadlines, times | Date picker |
| **toggle** | Yes/No decisions, confirmations | Toggle switch |
| **list** | Multiple items (guests, checklist) | Dynamic list input |

### 3. Data Storage

Fields are stored in the `TaskField` Core Data entity:

```
Task (1-to-many) → TaskField
├── fieldName: "Hotel Name"
├── fieldType: "text"
├── fieldValue: "Hilton Downtown"
├── fieldOrder: 1
└── createdAt: 2025-11-02
```

## User Experience

### Adding Task Details

1. **Open Task Detail View** - Tap a task to edit it
2. **Scroll to "Task Details"** section
3. **Fill in the Fields** - Each field shows a type-appropriate input
4. **Values Auto-Save** - Changes are saved automatically

### Field Type Interactions

**Text Fields:**
```
Hotel Name: [_______________]
```

**Date Fields:**
```
Check-in Date: [Nov 15, 2025 ▼]
```

**List Fields:**
```
Guest Name: [John Doe] [✕]
Contact:    [john@example.com] [✕]
            [+ Add Item]
```

**Toggle Fields:**
```
Confirmed: [Toggle Switch]
```

**Number Fields:**
```
Guest Count: [_______________]
```

## Implementation Details

### Core Data Model

**TaskField Entity:**
- `fieldName` (String, required) - Display name of the field
- `fieldType` (String) - Type of field (text, number, date, toggle, list)
- `fieldValue` (String) - The value entered by user
- `fieldOrder` (Int16) - Sort order for display
- `createdAt` (Date) - Timestamp
- `task` (Relationship) - Reference to parent Task

**Task Entity Updates:**
- New `fields` relationship (one-to-many with TaskField)

### AI Prompt Integration

The ClarifyingQuestionsManager now includes field suggestions in the task generation prompt:

```swift
"For each task, determine relevant fields that the user should fill in. For example:
- "Book Accommodation" should have fields: hotel_name, check_in_date, room_type
- "Create Guest List" should have fields: guest_name, contact_info, dietary_restrictions"
```

### Generated Task Structure

Tasks are returned by AI with optional fields array:

```json
{
  "title": "Book Accommodation",
  "description": "Find and book hotel for the event",
  "estimatedTime": 60,
  "priority": "high",
  "fields": [
    {"fieldName": "Hotel Name", "fieldType": "text", "fieldOrder": 1},
    {"fieldName": "Check-in Date", "fieldType": "date", "fieldOrder": 2}
  ]
}
```

### View Components

**TaskFieldsInputView** - Main component displaying all task fields
- Shows "No additional details needed" for tasks with no fields
- Renders each field based on its type
- Auto-saves changes to Core Data

**TaskFieldInputRow** - Individual field input component
- Handles type-specific input rendering
- Manages state for each field type
- Supports list items with add/remove functionality

## Examples

### Birthday Party Planning

**Task:** "Order Catering"
- Caterer Name (text)
- Menu Items (list)
- Headcount (number)
- Delivery Time (date)

**Task:** "Arrange Decorations"
- Decoration Theme (text)
- Budget (number)
- Venue Address (text)
- Setup Complete (toggle)

### Home Renovation

**Task:** "Get Contractor Quotes"
- Contractor Name (text)
- Quote Amount (number)
- Quote Date (date)
- References Checked (toggle)

**Task:** "Schedule Inspections"
- Inspection Type (text)
- Inspection Date (date)
- Inspector Name (text)
- Approved (toggle)

## Benefits

1. **Contextual Information** - Each task gets fields relevant to its specific work
2. **Organized Input** - Users know exactly what details to capture
3. **AI Intelligence** - AI determines field types and naming
4. **Flexible Types** - Support for text, numbers, dates, toggles, and lists
5. **Persistent Storage** - All field data is saved to Core Data
6. **Easy Editing** - Inline editing with automatic saves

## Future Enhancements

Potential improvements to the dynamic fields system:

- **Field Validation** - Add regex patterns or number ranges
- **Field Dependencies** - Show fields conditionally based on other fields
- **Field Templates** - Reusable field templates for common task types
- **Field History** - Track changes to field values over time
- **Field Collaboration** - Share field data with team members
- **Export Fields** - Export task details to CSV or PDF
