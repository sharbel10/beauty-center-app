# Lumina — Beauty & Wellness Booking App

Lumina is a Flutter mobile application for discovering beauty and wellness centers, exploring their services, and managing appointments from one place. It was developed as a graduation project with a focus on scalable architecture, reliable API integration, and production-style mobile features.

## Key Features

- Location-based discovery of nearby beauty and wellness centers
- Advanced search, filtering, and paginated results
- Center profiles with services, offers, employees, and image galleries
- Appointment booking, rescheduling, cancellation, and booking history
- Stripe deposit payments
- AI-powered service recommendations from text descriptions or uploaded images
- Favorites, reviews, and reporting flows
- Firebase push notifications and local notifications
- Secure authentication and token storage
- Arabic and English localization with RTL support
- Camera/gallery image upload support

## Architecture & Engineering

- Feature-based project structure
- BLoC / Cubit state management
- Repository Pattern for data access
- Dio for REST API communication
- GetIt + Injectable for dependency injection
- GoRouter for navigation and authentication guards
- Typed error handling using `Either` and failure models
- Secure Storage and SharedPreferences for local persistence
- Debounced search, pagination, and request-state handling

## Tech Stack

`Flutter` · `Dart` · `BLoC/Cubit` · `Dio` · `GetIt` · `Injectable` · `GoRouter` · `Firebase` · `Stripe` · `Geolocation` · `Localization`

## Testing

The project includes unit and widget tests covering data parsing, booking/payment state, filtering logic, and UI behavior.

## Project Structure

```text
lib/
├── core/        # shared services, networking, DI, routing, theme, utilities
└── features/    # feature modules with views, state, models, and repositories
```

## Getting Started

```bash
git clone https://github.com/sharbel10/beauty-center-app.git
cd beauty-center-app
flutter pub get
flutter run
```

Some integrations require environment-specific configuration such as Firebase and Stripe credentials.

## Author

**Sharbel ALMohana** — Software Engineer & Flutter Developer
