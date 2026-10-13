# SantaList iOS - Parity Reference Document

This document records the exact 1:1 design, copy, color tokens, typography, hierarchy, and interaction specifications derived directly from the reference SantaList app and verified against the reference screenshots in `docs/reference/`.

---

## 1. Global Specifications

### Language & Locale
- **Language**: **100% English only**. All UI copy, labels, placeholders, errors, dialogs, empty states, and seed data are strictly in English.
- **Localization**: `Localizable.xcstrings` configured with source language `"en"`.
- **Currency Format**: Format `Formatters.formatVND` outputs `1.250.000 ₫` / `2.000.000 ₫` using dot grouping and the `₫` symbol (consistent with the reference app and Vietnamese Dong budget values).
- **Date Format**: `dd/MM/yyyy` for full dates, `dd MMM` for short dates, and relative terms (`Today`, `Tomorrow`, `Yesterday`).

### Color Palette (Asset Catalog)
| Color Token | Light Mode (Hex) | Dark Mode (Hex) | Usage |
| :--- | :---: | :---: | :--- |
| **PineGreen** | `#0F4A35` | `#4FB98A` | Primary brand color, tab tint, completed status, positive values |
| **CranberryRed** | `#B3243B` | `#EE6A80` | Overdue badge, over-budget warning, destructive actions |
| **WarmGold** | `#C8912B` | `#E0AE4D` | Idea status, planned budget KPI, Christmas sparkles |
| **AppBackground** | `#F3F6F4` | `#0E1A15` | Canvas background for entire app |
| **AppCard** | `#FFFFFF` | `#16251E` | Card surface container |
| **TextPrimary** | `#111827` | `#F9FAFB` | Primary headers, card titles |
| **TextSecondary** | `#6B7280` | `#9CA3AF` | Subtitles, helper text, captions |

---

## 2. Screens & Visual Breakdown

### 2.1 Brand Header (`AppHeaderView`)
- **Logo**: `🎅` emoji (or gift icon) + `SantaList` title in bold rounded font with `PineGreen` tint.
- **Slogan**: `"Gifts for the right people, on time, on budget"` in caption font, `TextSecondary`.
- **Countdown Badge**: Capsule with `sparkles` icon (`WarmGold`), text:
  - `[X] days until Christmas 🎄`
  - `1 day until Christmas 🎅`
  - `Today is Christmas! 🎄`
  - Rollover logic: After Dec 25 of current year, automatically counts down to Dec 25 of next year.

---

### 2.2 Tab 1: Recipients (`PeopleView`)
- **Tab Bar Item**: Label `"Recipients"`, icon `"person.2.fill"`.
- **Navigation Toolbar**:
  - Leading: `"Add Person"` button (`person.badge.plus` icon).
  - Trailing: `"Add Gift"` button (`gift.fill` icon).
- **Floating Action Button (FAB)**:
  - Position: Bottom trailing (padding 20pt trailing, 16pt bottom).
  - Appearance: Capsule in `PineGreen` with drop shadow, white text `+ Add Gift`.
- **Recipient Card (`PersonCard`)**:
  - Name (Headline, `TextPrimary`).
  - Note (Caption, `TextSecondary`).
  - Ellipsis menu button: Options `"Edit Recipient"` (`pencil`) and `"Delete Recipient"` (`trash`, destructive).
  - Summary row: `[X] gifts` (`gift` icon), `Planned: [X] ₫` (`PineGreen` or `CranberryRed` if exceeding budget) ` / [Budget] ₫`.
  - Progress Bar (`BudgetProgressBar`):
    - Height: 8pt capsule.
    - Fill: `PineGreen` when within budget, `CranberryRed` when over budget.
    - Labels: `[X]% of budget` on the left, `Remaining: [X] ₫` or `Over by [X] ₫` on the right.
- **Empty State**:
  - `ContentUnavailableView`:
    - Title: `"No Recipients Yet"`
    - Description: `"Add your family and friends to start tracking gift ideas."`
    - Action: Button `"Add First Recipient"` (`person.badge.plus`).
- **Cascade Deletion Confirmation**:
  - Dialog Title: `"Delete Recipient"`
  - Message: `"Deleting \"[Name]\" will permanently remove all gifts for this person. This action cannot be undone."`
  - Destructive Button: `"Delete recipient & all gifts"`
  - Cancel Button: `"Cancel"`

---

### 2.3 Recipient Detail (`PersonDetailView`)
- **Navigation Title**: `[Person Name]`.
- **Budget Summary Card**:
  - 4 values: Budget, Planned, Spent, Remaining (turns `CranberryRed` when negative).
  - Progress bar with percentage.
- **Gifts Section**:
  - Header: `"Gifts ([X])"`, button `"Add Gift"`.
  - List of gift rows with interactive status chips and swipe actions.
  - Empty state: `"No Gifts Yet"`, `"Add your first gift idea for [Name]."`.

---

### 2.4 Tab 2: Timeline (`TimelineView`)
- **Tab Bar Item**: Label `"Timeline"`, icon `"clock.arrow.circlepath"`.
- **Header**: Includes `AppHeaderView`.
- **Segmented Filter Bar**: 4 segments:
  - `"All"`: All gifts ordered by due date ascending, unscheduled gifts at the end.
  - `"Pending"`: Gifts not completed (`status != .received && status != .wrapped`).
  - `"Overdue"`: Overdue gifts (`dueDate < today && !isCompleted`).
  - `"Completed"`: Gifts completed (`status == .received || status == .wrapped`).
- **Gift Row (`GiftRow`)**:
  - Title (Headline), Recipient tag (`person.crop.circle.fill`).
  - Price in `PineGreen`, Occasion capsule badge.
  - Due date badge:
    - If overdue: `CranberryRed` capsule with `"Overdue ([date])"`.
    - If completed: `PineGreen` capsule with `"Completed"`.
    - Normal due date: `"Due: [date]"`.
    - No due date: `"No deadline"`.
  - Status Chip (`StatusChipView`):
    - 4 values: `Idea`, `Ordered`, `Received`, `Wrapped`.
    - Tap: Advances to next cyclic status.
    - Long Press / Context Menu: Directly pick any status.
  - Swipe actions: Delete (confirmation alert) and Edit.
- **Empty State**:
  - Title: `"No Gifts in Timeline"`
  - Description: `"Add gifts and set deadlines to see them scheduled here."`
  - Action: Button `"Add Gift"`

---

### 2.5 Tab 3: Budget (`BudgetView`)
- **Tab Bar Item**: Label `"Budget"`, icon `"chart.pie.fill"`.
- **Header**: Includes `AppHeaderView`.
- **4 KPI Metric Cards**:
  1. `"Total Budget"`: Sum of all recipients' budgets (icon: `"wallet.pass.fill"`, color: `PineGreen`).
  2. `"Planned"`: Sum of all gift prices (icon: `"list.clipboard.fill"`, color: `WarmGold`).
  3. `"Spent"`: Sum of gifts with status `Ordered`, `Received`, or `Wrapped` (icon: `"creditcard.fill"`, color: `Orange`).
  4. `"Remaining"`: `Total Budget - Planned` (icon: `"checkmark.circle.fill"`, turns `CranberryRed` with `"exclamationmark.triangle.fill"` if negative).
- **Swift Charts**:
  - Bar chart comparing `Budget` vs `Planned` per person with distinct legend badges.
- **Section `"Per-Person Progress"`**:
  - Card for each recipient showing name, planned vs budget, budget progress bar, spent amount, remaining amount.
- **Empty State**:
  - Title: `"No Budget Data"`
  - Description: `"Add recipients and set budgets to track your holiday spending."`

---

### 2.6 Form Sheets & Validations

#### Add/Edit Person Sheet (`AddEditPersonSheet`)
- **Navigation Title**: `"Add Recipient"` or `"Edit Recipient"`.
- **Section `"Recipient Information"`**:
  - Field: `"Full name or nickname"` (Validation: `"Please enter recipient name"`).
  - Field: `"Budget (VNĐ)"` (Validation: `"Budget must be a non-negative number"`).
  - Conversion hint: `"Formatted: 2.000.000 ₫"`.
- **Section `"Notes"`**:
  - Field: `"Preferences, sizes, notes (optional)"`.
- **Toolbar**: `"Cancel"` and `"Save"` (or `"Add"`).

#### Add/Edit Gift Sheet (`AddEditGiftSheet`)
- **Navigation Title**: `"Add Gift"` or `"Edit Gift"`.
- **Section `"Recipient"`**:
  - Picker: `"Select recipient"` (Validation: `"Please select a recipient"`).
- **Section `"Gift Information"`**:
  - Field: `"Gift title (required)"` (Validation: `"Gift title cannot be empty"`).
  - Field: `"Price (VNĐ)"` (Validation: `"Price must be a non-negative number"`).
  - Picker: `"Occasion"` (`Christmas`, `Birthday`, `Anniversary`, `Other`).
  - Picker: `"Status"` (`Idea`, `Ordered`, `Received`, `Wrapped`).
- **Section `"Deadline"`**:
  - Toggle: `"Has deadline"`.
  - DatePicker: `"Due date"` (graphical calendar style).
  - Button: `"Remove deadline"` (`xmark.circle`, destructive).
- **Section `"Additional Details"`**:
  - Field: `"Purchase link (https://...)"`.
  - Field: `"Notes (size, color, store...)"`.
- **Toolbar**: `"Cancel"` and `"Save"` (or `"Add"`).

---

### 2.7 Seed Data (Initial Launch)
- Flag in `UserDefaults`: `"hasSeededInitialData"`.
- **Recipient 1**:
  - Name: `"Mom"`
  - Budget: `2,000,000 ₫`
  - Note: `"Most wonderful woman in the family"`
  - Gifts:
    - `"Cashmere scarf"`, `650,000 ₫`, Status: `Ordered`, Due: `Dec 15`, Occasion: `Christmas`, Note: `"Light cream color, soft and warm cashmere"`, URL: `"https://example.com/scarf"`.
    - `"Herbal tea set"`, `300,000 ₫`, Status: `Idea`, Due: `Dec 20`, Occasion: `Christmas`, Note: `"Chamomile and mint relaxing tea"`, URL: `""`.
- **Recipient 2**:
  - Name: `"Minh (best friend)"`
  - Budget: `800,000 ₫`
  - Note: `"Best friend from university"`
  - Gifts:
    - `"Atomic Habits book"`, `220,000 ₫`, Status: `Wrapped`, Due: `Dec 10`, Occasion: `Christmas`, Note: `"Hardcover edition with bookmark"`, URL: `"https://example.com/atomic-habits"`.

---

### 2.8 Local Notifications (`ReminderService`)
- Scheduled time: **9:00 AM on the day before the due date** (1 day prior).
- Eligibility: Only gifts where `dueDate != nil` and `status != .received && status != .wrapped`.
- Title: `"Gift Reminder: [Title]"`
- Body: `"Deadline is tomorrow! For [Recipient]."`
- Identifier: `"gift-[UUID]"`.
- Auto-cancellation & reschedule upon edit, status change, or deletion.

---

## 3. Visual & Parity Verification Checklist

| Screen / Feature | Reference Asset | Parity Status | Verified Aspects |
| :--- | :--- | :---: | :--- |
| **Tab 1: Recipients (Light)** | `docs/reference/tab1_people_light.png` | ✅ 100% | Header, Countdown, Mom & Minh cards, Progress bars, FAB, Tab bar |
| **Tab 1: Recipients (Dark)** | `docs/reference/tab1_people_dark.png` | ✅ 100% | Dark surface `#16251E`, dark background `#0E1A15`, glowing chips |
| **Tab 2: Timeline (Light)** | `docs/reference/tab2_timeline_light.png` | ✅ 100% | Segmented filter, sorted dates, status chips, deadline badges |
| **Tab 2: Timeline (Dark)** | `docs/reference/tab2_timeline_dark.png` | ✅ 100% | Dark palette, contrast badges, status chip highlights |
| **Tab 3: Budget (Light)** | `docs/reference/tab3_budget_light.png` | ✅ 100% | 4 KPI cards, Swift Charts bars, per-person progress breakdown |
| **Tab 3: Budget (Dark)** | `docs/reference/tab3_budget_dark.png` | ✅ 100% | Dark KPI cards, chart contrast, progress colors |
| **Add/Edit Person Sheet** | Architecture Spec | ✅ 100% | Real-time inline validation errors below inputs, Cancel/Save |
| **Add/Edit Gift Sheet** | Architecture Spec | ✅ 100% | Recipient picker, price validation, graphical DatePicker, remove deadline |
| **Cascade Deletion** | SwiftData Model Spec | ✅ 100% | In-memory verified: deleting person deletes all gifts |
| **Status Chip Interaction**| SwiftUI Button/Menu | ✅ 100% | Tap to advance, context menu to pick any status |
| **Local Notification** | UNUserNotification | ✅ 100% | 9:00 AM 1-day prior, auto-reschedule, identifier `gift-<uuid>` |
