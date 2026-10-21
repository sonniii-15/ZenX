# ZenX | Location-Based Gamified Fitness Application

**A mobile fitness application that combines GPS activity tracking with territory capture, experience points, and social competition.**

## 1. Project Overview

ZenX is a Flutter-based mobile application developed to make physical activity more engaging through location-based gameplay. Instead of limiting fitness tracking to distance and duration, ZenX introduces a territory-capture mechanic in which users can record their movement, trace activity routes, and earn experience points by capturing mapped areas.

The application combines activity tracking, map-based interaction, user profiles, and a social activity feed within a dark interface designed around a competitive fitness experience.

**Project type:** Undergraduate Engineering Major Project  
**Domain:** Mobile Application Development, Location-Based Systems, Gamification  
**Platform:** Flutter

## 2. Problem Statement

Conventional fitness tracking applications primarily present activity metrics such as distance, duration, and pace. Although useful, these metrics do not necessarily provide a persistent sense of progression or competition.

ZenX explores a different approach by connecting physical movement with a game mechanic: users can capture territories through GPS-tracked activity and receive experience points for successful captures.

The project focuses on integrating location-aware activity tracking with gamification and social interaction in a single mobile application.

## 3. Core Features

### GPS-Based Activity Tracking
- Access device location to support activity tracking.
- Display the user's position on an interactive map.
- Track activity duration, distance, pace, and estimated calories.
- Visualise movement on the map during an activity.

### Territory Capture
- Represent tracked movement on a map.
- Trace territory boundaries during an activity.
- Provide a capture confirmation when a territory is successfully acquired.
- Award experience points for successful captures.

### Gamification and Progression
- Award XP for territory capture.
- Display the user's level and XP progress.
- Provide a profile area for achievements and activity statistics.
- Include a ranking section for competitive fitness activity.

### Social Activity Feed
- Display recent activity posts.
- Provide a home screen with activity statistics and recent updates.
- Include engagement controls on activity posts.

### User Authentication and Profile
- Provide a registration interface.
- Integrate Firebase services for authentication and backend functionality.
- Present user profile information, progression, and activity statistics.

## 4. Technology Stack

| Technology | Role |
|---|---|
| Flutter | Cross-platform mobile application development |
| Dart | Application programming language |
| Firebase | Authentication and backend services |
| Geolocator | Device location and GPS access |
| Flutter Map | Interactive map interface |
| latlong2 | Geographic coordinates and latitude/longitude utilities |
| Git and GitHub | Version control and source-code hosting |

## 5. System Design

ZenX brings together four main functional areas:

1. **Location acquisition:** The device provides location updates for activity tracking.
2. **Activity tracking:** Movement is tracked and activity metrics are presented to the user.
3. **Territory and reward logic:** The tracked route supports territory capture, with XP awarded when a capture succeeds.
4. **Application interface and backend:** The mobile interface presents activity, progression, profile, and social features, while Firebase supports the configured backend functionality.

The implementation connects GPS-based movement with the territory-capture experience, making location data part of the application's gameplay rather than simply a record of exercise.

## 6. Repository Structure

```text
ZenX/
├── android/          # Android platform configuration
├── ios/              # iOS platform configuration
├── assets/           # Application assets
├── lib/              # Main Dart application source
├── test/             # Test files
├── web/              # Web platform configuration
├── macos/            # macOS platform configuration
├── windows/          # Windows platform configuration
├── linux/            # Linux platform configuration
├── pubspec.yaml      # Dependencies and project configuration
├── firebase.json     # Firebase CLI configuration
├── firestore.rules   # Firestore security rules
├── storage.rules     # Firebase Storage security rules
└── README.md         # Project documentation
```

## 7. Installation and Execution

### Prerequisites

- Flutter SDK and Dart
- Git
- VS Code or Android Studio
- An Android emulator or compatible physical device
- Access to the required Firebase project configuration

### Clone the repository

```bash
git clone https://github.com/sonniii-15/ZenX.git
cd ZenX
```

### Install dependencies

```bash
flutter pub get
```

### Configure Firebase

Ensure the Firebase configuration matches the development environment. The repository contains Firebase configuration files, but a fresh environment may require additional project setup, platform configuration, or appropriate access to Firebase services.

Private service-account keys and other secrets should not be committed to the repository.

### Run the application

Start a compatible emulator or connect a device, then run:

```bash
flutter run
```

If the application does not start in a new environment, verify the installed Flutter version, platform requirements, Firebase configuration, and available device targets.

## 8. Engineering Focus

The project brings together several practical software engineering concepts:

- Integration of device location services into a mobile application.
- Rendering geographic data through an interactive map.
- Connecting tracked movement with a territory-capture mechanic.
- Implementing experience-point progression within an application workflow.
- Integrating authentication and backend services.
- Organising a cross-platform application using Flutter.

## 9. Future Development

Potential extensions include:

- More detailed activity analytics and historical summaries.
- Expanded territory statistics and competition modes.
- Additional achievement and progression mechanics.
- Further development of sustainability-related rewards.
- Expanded testing of GPS accuracy and territory-capture behaviour across devices.

## 10. Project Access

**Repository:** [github.com/sonniii-15/ZenX](https://github.com/sonniii-15/ZenX)

ZenX is an academic major project exploring the intersection of mobile development, geolocation, gamification, and fitness applications.

---

*ZenX — Move. Conquer. Own.*
