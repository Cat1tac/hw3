# Task Manager — Flutter + Firebase

A minimalist task management app built with Flutter and Firebase Firestore.
Purple & black design language. Full CRUD with real-time sync and nested subtasks.

## Setup

1. Clone this repository
2. Run `flutterfire configure` to connect your Firebase project
3. Replace placeholder values in `lib/firebase_options.dart`
4. Run `flutter pub get`
5. Run `flutter run`

## Features

- **Full CRUD** — Create, read, update, and delete tasks via Firestore
- **Nested Subtasks** — Each task expands to reveal a sub-list of items
- **Real-time Sync** — StreamBuilder drives live UI updates
- **Input Validation** — Empty submissions are blocked
- **Search/Filter** — Filter tasks by title in real time
- **UX States** — Loading spinner, empty-state message, error handling

## Enhanced Features

1. **Real-time Search** — A search bar filters the task list instantly as you type,
   matching against task titles. Chosen because it dramatically improves usability
   when the task list grows beyond a screenful.

2. **Animated Transitions** — Tasks animate in/out with fade and slide effects
   using `AnimatedList`-style patterns. Chosen because motion feedback makes
   add/delete actions feel responsive and intentional.

## Known Limitations

- No user authentication — all tasks share a single Firestore collection
- No offline persistence enabled (could add via Firestore settings)
- No due dates or priority levels (stretch goal for future iteration)
