# Property Listing App (Flutter)

A Flutter app for browsing property rentals — apartments, villas, motels, cabins — built as the client half of a full-stack learning project. The backend is a hand-built [NestJS API](#) (see its own README for details); this app exercises every layer of it: public browsing, JWT auth, and an owner-facing flow for managing listings.

## Features

- **Browse & filter** — property cards with cover photos, price, and specs, filterable by type via a multi-select bottom sheet
- **Property detail** — photos, description, amenities, and the owner's contact email and phone
- **Favorites** — tap to save a property, persisted on-device so it survives app restarts
- **Authentication** — register and log in against the API, session persisted locally
- **Role-aware UI** — "My Listings" only appears in Settings for accounts with `OWNER` or `ADMIN` role; a `USER` account never sees listing-management controls
- **Manage listings** (owner/admin only) — a 4-step wizard (basics → location → amenities → review) to create or edit a property, publish/unpublish, and delete
- **Photo management** — upload from the device gallery, set a cover photo, delete photos
- **Dark mode**, with the toggle persisted via its own Bloc

## Tech stack

- **Flutter** + **flutter_bloc** — state management, using the Bloc (event/state) pattern throughout, not Cubit, kept consistent across every feature
- **http** — talks to the REST API directly; no codegen, models are hand-written
- **shared_preferences** — persists favorites and the auth session locally
- **image_picker** — gallery access for listing photos
- **equatable** — value equality for Bloc states, so `BlocBuilder` only rebuilds when something actually changed

## Getting started

### Prerequisites

- Flutter SDK (stable channel)
- The companion [NestJS API](https://github.com/Yhwach14/Property-API) running locally — this app has no backend of its own

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Point the app at your API

`lib/core/api_config.dart` picks a sensible default per platform automatically:

| Where you're running | Default base URL |
|---|---|
| Android emulator | `http://10.0.2.2:3000/api/v1` |
| iOS simulator / desktop | `http://localhost:3000/api/v1` |

For a **real device** on the same Wi-Fi, override it explicitly with your machine's LAN IP:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-LAN-IP>:3000/api/v1
```

### 3. Run it

```bash
flutter run
```

Make sure the API is running first (`npm run start:dev` in the backend repo) — the app has an 8-second request timeout and shows a "could not reach the server" state rather than hanging if it isn't.

### Android cleartext HTTP (local development only)

Since the API runs over plain HTTP locally, `android/app/src/main/AndroidManifest.xml` has `android:usesCleartextTraffic="true"` set on `<application>`. Remove this before any real release build — it should only ever be on for pointing at a local dev server.

## Logging in

register a new account from Settings → Log in → Register — new accounts get the `USER` role by default and won't see listing management until an admin promotes them (`PATCH /users/:id/role` on the API side; there's no in-app UI for this, by design — it mirrors a real "become a host" approval flow).
Or you can use the backend's seeded accounts to try the owner-side features.
