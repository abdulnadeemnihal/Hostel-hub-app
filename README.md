# 🏠 Hostel Hub — Smart Hostel Management System

A full-stack hostel management platform built with **Flutter** and **Firebase**, featuring dedicated apps for **Students** and **Wardens** with real-time data synchronization.

---

## 📌 Overview

Hostel Hub streamlines day-to-day hostel operations by providing separate, role-based interfaces:

- **Student App** — A mobile-first Flutter web app for students to manage complaints, leave requests, gate passes, fees, meals, attendance, and more.
- **Warden App** — A desktop/web-optimized Flutter app for wardens to oversee students, approve requests, manage rooms, track fees, and post announcements.

Both apps share a common Firebase backend with **real-time Firestore streams**, ensuring instant UI updates across all connected clients.

---

## 🛠️ Tech Stack

| Layer              | Technology                                  |
| ------------------ | ------------------------------------------- |
| **Frontend**       | Flutter 3.x (Dart SDK ^3.10.1), Material 3 |
| **Authentication** | Firebase Auth (Email/Password)              |
| **Database**       | Cloud Firestore (real-time streams)         |
| **State Mgmt**     | Provider (ChangeNotifier + MultiProvider)   |
| **Backend**        | Node.js with Firebase Admin SDK (scaffolded)|

---

## ✨ Features

### Student App

| Module             | Description                                                                 |
| ------------------ | --------------------------------------------------------------------------- |
| **Authentication** | Login, multi-step sign-up with referral code validation, password reset     |
| **Dashboard**      | Greeting header, quick stats, navigation grid to all modules                |
| **Complaints**     | Create & track complaints (Maintenance, Electrical, Plumbing, etc.)         |
| **Leave Requests** | Apply for leave (Home, Medical, Personal, Emergency, Academic)              |
| **Gate Passes**    | Request gate passes with destination & dates                                |
| **Fee Management** | View total, paid & pending fees with summary cards                          |
| **Attendance**     | View personal attendance records with check-in/check-out times              |
| **Meal Menu**      | Browse weekly mess menu (Breakfast, Lunch, Snacks, Dinner)                  |
| **Announcements**  | View hostel announcements (urgent & normal)                                 |
| **Room Info**      | View room details, occupancy & amenities                                    |
| **Profile**        | View and edit personal information                                          |

### Warden App

| Module                 | Description                                                         |
| ---------------------- | ------------------------------------------------------------------- |
| **Dashboard**          | Stats overview — students, pending requests, room occupancy, fees   |
| **Student Management** | Search & browse all students by name, roll number, or room          |
| **Complaint Mgmt**     | Review, respond to, and resolve student complaints                  |
| **Leave Approval**     | Approve or reject leave applications with remarks                   |
| **Gate Pass Approval** | Approve or reject gate pass requests                                |
| **Room Management**    | Add rooms, view occupancy stats, assign students to rooms           |
| **Attendance**         | Mark and view daily attendance records                              |
| **Mess Menu Mgmt**     | Add, edit & delete daily meal menus per day of the week             |
| **Announcements**      | Create, edit & delete announcements with urgency & expiry settings  |
| **Fee Management**     | View fee collection data and student payment status                 |

---

## 🗂️ Project Structure

```
hostel_app/
├── backend/                 # Node.js backend (scaffolded)
│   ├── api/
│   │   ├── announcements/
│   │   ├── attendance/
│   │   ├── auth/
│   │   ├── complaints/
│   │   ├── dashboard/
│   │   ├── fees/
│   │   ├── gate-passes/
│   │   ├── leaves/
│   │   ├── meal-preferences/
│   │   ├── meals/
│   │   ├── rooms/
│   │   └── students/
│   ├── db/
│   └── lib/
│
├── student_app/             # Flutter Student App
│   └── lib/
│       ├── main.dart
│       ├── firebase_options.dart
│       ├── models/          # Data models (9 models)
│       ├── providers/       # AuthProvider, DataProvider
│       ├── screens/         # UI screens per module
│       ├── services/        # AuthService, FirestoreService
│       └── utils/           # Constants, Theme
│
├── warden_app/              # Flutter Warden App
│   └── lib/
│       ├── main.dart
│       ├── firebase_options.dart
│       ├── models/
│       ├── providers/
│       ├── screens/
│       ├── services/
│       └── utils/
│
└── package.json             # Backend dependencies
```

---

## 📊 Data Models

| Model               | Key Fields                                                                 |
| -------------------- | ------------------------------------------------------------------------- |
| **Student**          | name, email, phone, rollNumber, department, branch, year, roomNumber, hostelBlock, foodPreference |
| **Complaint**        | category, title, description, status, assignedTo, response               |
| **Leave Application**| reason, leaveType, fromDate, toDate, status, destination                 |
| **Gate Pass**        | reason, destination, outDate, expectedReturnDate, status, wardenRemarks  |
| **Fee**              | feeType, amount, paidAmount, status, semester, academicYear, dueDate     |
| **Attendance**       | studentId, date, status, checkInTime, checkOutTime, markedBy             |
| **Meal Menu**        | day, breakfast, lunch, snacks, dinner, weekStartDate                     |
| **Room**             | roomNumber, block, floor, capacity, occupied, roomType, amenities        |
| **Announcement**     | title, content, category, postedBy, isUrgent, expiresAt                  |

---

## 🔥 Firestore Collections

```
├── students
├── wardens
├── complaints
├── leave_applications
├── rooms
├── fees
├── meal_menus
├── meal_preferences
├── announcements
├── attendance
└── gate_passes
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or later)
- [Firebase CLI](https://firebase.google.com/docs/cli) & [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- A Firebase project with **Authentication** and **Cloud Firestore** enabled
- [Node.js](https://nodejs.org/) (for backend, optional)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/<your-username>/hostel-hub.git
   cd hostel-hub
   ```

2. **Configure Firebase**
   ```bash
   firebase login
   flutterfire configure
   ```
   This generates `firebase_options.dart` for both apps.

3. **Run the Student App**
   ```bash
   cd student_app
   flutter pub get
   flutter run -d chrome
   ```

4. **Run the Warden App**
   ```bash
   cd warden_app
   flutter pub get
   flutter run -d chrome
   ```

---

## 📦 Dependencies

| Package            | Version   | Purpose                  |
| ------------------ | --------- | ------------------------ |
| `firebase_core`    | ^3.12.1   | Firebase initialization  |
| `firebase_auth`    | ^5.5.1    | Authentication           |
| `cloud_firestore`  | ^5.6.5    | Real-time database       |
| `provider`         | ^6.1.2    | State management         |
| `intl`             | ^0.20.2   | Date/time formatting     |
| `cupertino_icons`  | ^1.0.8    | iOS-style icons          |

---

## 🎨 Theming

| App           | Primary Color       | Layout Style              |
| ------------- | ------------------- | ------------------------- |
| **Student**   | Indigo (`#4F46E5`)  | Bottom Navigation Bar     |
| **Warden**    | Green (`#1B5E20`)   | Side Navigation Rail      |

Both apps use **Material 3** design with rounded cards, consistent spacing, and responsive layouts.

---

## 🔑 Key Highlights

- **Real-time Sync** — All data flows through Firestore streams for instant updates
- **Role-based Access** — Separate apps with tailored UIs for students and wardens
- **Multi-step Registration** — Student sign-up collects personal, academic, family, and preference data
- **Referral Code System** — Prevents unauthorized student registrations
- **Approval Workflows** — Complaints, leaves, and gate passes follow a request → review → approve/reject pipeline
- **Responsive Design** — Student app is mobile-first; Warden app is optimized for desktop/web

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---

<p align="center">
  Built with ❤️ using Flutter & Firebase
</p>
