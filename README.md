# 🏠 RoomShare

A Flutter mobile application for students to find and list affordable rooms, PGs, and shared accommodations near universities and colleges.

Built with **Flutter + Riverpod + Supabase** following **Clean Architecture** principles.

---

## 📱 Screenshots

> _Add screenshots here after taking them from your device_

| Home Screen | Room Detail | Add Post | Profile |
|---|---|---|---|
| ![Home](screenshots/home.png) | ![Detail](screenshots/detail.png) | ![Add](screenshots/add.png) | ![Profile](screenshots/profile.png) |

---

## ✨ Features

- 🔐 **Google Sign-In** — one tap authentication
- 🔍 **Explore Rooms** — browse listings with search and filters
- 🏘️ **Room Details** — image gallery, amenities, location map, Call & WhatsApp
- ➕ **Post a Room** — upload photos, describe your listing
- 💾 **Saved Rooms** — favorite rooms for later
- 👤 **Profile** — edit name, photo, phone, bio
- 📋 **My Posts** — manage active and rented listings
- ✅ **Verified Owner** badge for trusted landlords

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State Management | Riverpod 2.x |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| Architecture | Clean Architecture (Domain / Data / Presentation) |
| Image Caching | cached_network_image |
| Image Picking | image_picker |
| Deep Links | url_launcher |

---

## 🏗 Architecture

This project follows **Clean Architecture** with 3 layers per feature:

```
lib/
├── core/
│   └── constants/
│       └── app_colors.dart
│
└── features/
    ├── auth/
    │   └── presentation/
    │       └── screens/login_screen.dart
    │
    ├── home/                          # Room listing feature
    │   ├── domain/
    │   │   ├── entities/room_entity.dart
    │   │   ├── repositories/room_repository.dart
    │   │   └── usecases/get_rooms_usecase.dart
    │   ├── data/
    │   │   ├── models/room_model.dart
    │   │   ├── datasources/room_remote_datasource.dart
    │   │   └── repositories/room_repository_impl.dart
    │   └── presentation/
    │       ├── providers/home_providers.dart
    │       ├── screens/
    │       │   ├── home_screen.dart
    │       │   ├── room_detail_screen.dart
    │       │   ├── add_post_screen.dart
    │       │   ├── my_posts_screen.dart
    │       │   └── saved_screen.dart
    │       └── widgets/
    │           ├── room_card.dart
    │           ├── room_card_shimmer.dart
    │           └── filter_bottom_sheet.dart
    │
    └── profile/                       # User profile feature
        ├── domain/
        │   ├── entities/profile_entity.dart
        │   ├── repositories/profile_repository.dart
        │   └── usecases/
        │       ├── get_profile_usecase.dart
        │       ├── update_profile_usecase.dart
        │       ├── upload_avatar_usecase.dart
        │       └── sign_out_usecase.dart
        ├── data/
        │   ├── models/profile_model.dart
        │   ├── datasources/profile_remote_datasource.dart
        │   └── repositories/profile_repository_impl.dart
        └── presentation/
            ├── providers/profile_providers.dart
            └── screens/
                ├── profile_screen.dart
                └── edit_profile_screen.dart
```

### Layer Responsibilities

**Domain** — Pure Dart. No Flutter, no Supabase. Defines entities, repository contracts, and business rules (usecases).

**Data** — Implements the domain contracts. The only layer that touches Supabase. Contains models (JSON parsing) and datasources (network calls).

**Presentation** — Flutter UI. Riverpod providers connect data to widgets. Screens and widgets only read from providers — never call Supabase directly.

---

## 🗄 Supabase Schema

### Tables

**profiles**
```
id           uuid  PK → auth.users(id)
full_name    text
avatar_url   text
phone        text
city         text
bio          text
is_verified  bool  default false
created_at   timestamptz
updated_at   timestamptz
```

**rooms**
```
id              uuid  PK
owner_id        uuid  FK → profiles(id)
title           text
description     text
city            text
area            text
price_per_month numeric
area_sqft       numeric
phone           text
room_type       text   (single/shared/pg_hostel/flatmate/entire_apartment)
gender_preference text (any/boys_only/girls_only)
status          text   (active/rented)
has_wifi        bool
has_ac          bool
has_food        bool
has_laundry     bool
has_security    bool
is_available_now bool
students_only   bool
no_brokerage    bool
latitude        float8
longitude       float8
created_at      timestamptz
```

**room_images**
```
id       uuid  PK
room_id  uuid  FK → rooms(id)
url      text
```

**favorites**
```
id       uuid  PK
user_id  uuid  FK → auth.users(id)
room_id  uuid  FK → rooms(id)
```

### Storage Buckets

| Bucket | Public | Purpose |
|---|---|---|
| `avatars` | ✅ | User profile photos |
| `room-images` | ✅ | Room listing photos |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x — [install guide](https://docs.flutter.dev/get-started/install)
- Dart SDK (comes with Flutter)
- A Supabase account — [supabase.com](https://supabase.com)
- Android Studio or VS Code

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/room_share.git
cd room_share
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Set up Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** and run the setup scripts in this order:
   - `supabase/01_tables.sql`
   - `supabase/02_policies.sql`
   - `supabase/03_storage.sql`
   - `supabase/04_triggers.sql`

### 4. Configure environment

Create a `.env` file in the root (or update `lib/main.dart` directly):

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

> ⚠️ Never commit your real keys. The `.env` file is in `.gitignore`.

### 5. Run the app

```bash
flutter run
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1       # State management
  supabase_flutter: ^2.5.0       # Backend
  cached_network_image: ^3.3.1   # Image caching
  shimmer: ^3.0.0                # Loading skeletons
  image_picker: ^1.1.2           # Photo upload
  url_launcher: ^6.3.0           # Call / WhatsApp
```

---

## 🔐 Environment Variables

| Variable | Where to find it |
|---|---|
| `SUPABASE_URL` | Supabase Dashboard → Settings → API |
| `SUPABASE_ANON_KEY` | Supabase Dashboard → Settings → API |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

Built with ❤️ as a learning project for Clean Architecture with Flutter and Supabase.