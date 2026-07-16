# Olio Finance

A personal‑finance manager built with Flutter. Track spending, scan receipts, manage
budgets and subscriptions, and understand your money through rich analytics — all backed by
a fully mocked in‑memory data layer, so the app is completely functional without any backend.

Built with **Clean Architecture**, a **feature‑first** folder structure, **Cubit** state
management, and **Material 3** with full light/dark theming.

---

## Features

| Feature | Highlights |
|---|---|
| **Authentication** | Register / login, "remember me", session persistence via `SharedPreferences` |
| **Dashboard** | Balance card, monthly income/expense, savings rate, spending‑trend line chart, category donut, budget glance, recent transactions, quick actions, live notification badge |
| **Transactions** | Full CRUD, debounced search, type & category filters, 4‑way sort, pagination, pull‑to‑refresh, swipe‑to‑delete, detail & form screens |
| **Budgets** | CRUD with per‑category limits; `spent` is computed live from the month's transactions; progress bars with near/over‑budget alerts |
| **Analytics** | 3M / 6M / 12M range toggle, income‑vs‑expense bars, spending‑trend line, category donut, auto‑generated insights, expandable monthly reports |
| **Receipt Scanner** | Animated **mock OCR** scan that returns a realistic parsed receipt, then saves it *and* auto‑creates a matching transaction |
| **Subscriptions** | Monthly/yearly totals, upcoming‑billing sort, pause / resume / cancel, CRUD |
| **Notifications** | Unread badge, mark‑as‑read, mark‑all, swipe‑delete, "simulate incoming" push |
| **Profile & Settings** | Dark‑mode toggle (persisted), currency picker, category browser, export entry, logout |
| **Export** | Preview & copy transactions as **CSV**, **JSON**, or a **text summary** |

Every screen ships with loading, empty, and error states, animations, responsive layouts,
and dark‑mode support. The app is seeded with **250 transactions, 20 categories, 15 budgets,
6 subscriptions, 20 receipts, and 12 monthly reports**, so nothing ever looks empty.

---

## Tech Stack

- **Flutter** 3.35+ / **Dart** 3.9+
- **flutter_bloc** — Cubit state management
- **get_it** — dependency injection / service locator
- **fl_chart** — line, bar & pie/donut charts
- **equatable** — value equality for entities & states
- **shared_preferences** — local persistence (auth session, theme)
- **package_info_plus** — app version on the splash screen

---

## Architecture

The project follows **Clean Architecture** with a **feature‑first** layout. Each feature is a
self‑contained vertical slice with three layers:

```
lib/<feature>/
├── data/
│   ├── datasources/     # in-memory sources backed by AppDatabase
│   └── repositories/    # repository implementations
├── domain/
│   ├── repositories/    # abstract repository contracts
│   └── usecases/        # single-purpose interactors
└── presentation/
    ├── cubit/           # Cubit + state
    ├── pages/           # screens
    └── widgets/         # feature-scoped widgets
```

**Data flow:** `UI → Cubit → UseCase → Repository (interface) → DataSource → AppDatabase`

### Core building blocks (`lib/core/`)

- **`data/app_database.dart`** — a single in‑memory source of truth, seeded once from
  `mock_data.dart`. All feature datasources mutate these shared lists, so a change in one
  feature (e.g. adding a transaction) is instantly reflected everywhere — dashboard, budgets,
  and analytics.
- **`di/injection_container.dart`** — registers every datasource, repository, use case, and
  cubit with `get_it`.
- **`theme/`** — Material 3 light & dark themes plus a persisted `ThemeCubit`.
- **`utils/`** — `FinanceCalculator` (pure aggregation logic), `AppFormatters`, `Debouncer`.
- **`widgets/`** — reusable UI: state views, stat card, progress bar, transaction tile,
  category avatar, confirm dialog, and the shared chart widgets.

### Mocked data & services

There is no network layer. "External" behaviours are simulated deterministically so the UI
behaves exactly like the real feature would:

- **OCR** → returns a realistic parsed receipt after a scan delay
- **Notifications** → local & in‑memory, with a "simulate incoming" action
- **Analytics / insights** → generated from the live transaction set
- Datasources add small `Future.delayed` latencies so loading states are exercised

---

## Project Structure

```
lib/
├── main.dart                 # bootstraps DI, theme & routing
├── core/                     # shared entities, data store, DI, theme, utils, widgets, routes
├── auth/                     # authentication
├── splash/                   # splash screen
├── home/                     # bottom-nav shell (IndexedStack of the 5 primary tabs)
├── dashboard/
├── transactions/
├── budgets/
├── analytics/
├── receipts/
├── subscriptions/
├── notifications/
├── profile/
└── export/
```

### Navigation

- `HomeShell` hosts five tabs — **Dashboard, Transactions, Budgets, Analytics, Profile** —
  in an `IndexedStack`, providing the shared cubits via `MultiBlocProvider`.
- **Receipts, Subscriptions, Notifications,** and **Export** are reachable via named routes
  (`AppRoutes.onGenerateRoute`) from the dashboard quick actions and the profile screen.

---

## Getting Started

### Prerequisites

- Flutter SDK **3.35** or newer (`flutter --version`)
- A device or emulator (Android / iOS / web / desktop)

### Run

```bash
# install dependencies
flutter pub get

# launch on a connected device / emulator
flutter run
```

On first launch you land on the splash screen → **register an account** → you're taken to the
dashboard. The session persists (with "remember me") across restarts.

### Tests

Unit tests cover the pure logic (`FinanceCalculator`, `AppFormatters`, `ExportService`):

```bash
flutter test
```

### Static analysis

```bash
flutter analyze
```

---

## State Management Pattern

Every feature uses a **Cubit** with an **Equatable** state object exposing `copyWith`.
Cubits depend on **use cases** — or, for read‑only aggregation screens like the dashboard and
analytics, directly on repositories to maximise reuse. No business logic lives in widgets;
screens simply render state and forward user intents to their cubit.

---

## License

This project is for demonstration / educational purposes.
