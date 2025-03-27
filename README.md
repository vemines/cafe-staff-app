# Cafe Staff App

A Flutter application designed for cafe staff (servers, cashiers) and administrators to manage orders, tables, menus, payments, and view statistics for a cafe environment.

## Features

**Common:**

- Authentication (Login/Logout)
- Settings (Theme, Language, Change Password)

**Staff (Serve/Cashier Roles):**

- View table layout by area with real-time status (Pending, Served, Completed).
- Create new orders for tables.
- Add items to existing orders.
- Mark orders as 'Served'.
- Split items from one order to a new empty table.
- Request to merge items from one order to another existing order.
- View order history.

**Cashier Specific:**

- Complete orders and record payment methods.
- Approve/Reject merge order requests.

**Admin Role:**

- Dashboard displaying key statistics (Revenue, Orders, Feedback, Best Selling Items).
- Weekly, and Monthly revenue charts.
- Detailed statistics view.
- User Management (View, Create, Edit, Activate/Deactivate staff users - excludes admin management).
- Menu Management (CRUD operations for Categories, Subcategories, and Menu Items, including activation status).
- Table Management (CRUD operations for Areas and Tables).
- Payment Method Management (CRUD operations, including activation status).
- View detailed Order History with filtering (Date Range, Payment Method).
- View Customer Feedback with filtering (Rating, Date Range).

## Tech Stack & Architecture

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Bloc / Cubit
- **Routing:** go_router
- **Dependency Injection:** get_it
- **Networking:** Dio (HTTP), socket_io_client (Real-time tables updates)
- **Local Storage:** shared_preferences (Theme/Locale), flutter_secure_storage (User Session)
- **UI:** Material Design, syncfusion_flutter_charts
- **Architecture:** Feature-first approach with layers for data (datasources, models), domain (entities, repositories, usecases), and presentation (blocs, pages).
- **Backend:** Relies on a separate `json-server` based backend (details below).

## Prerequisites

- Flutter SDK (Latest stable recommended)
- Node.js and npm (or yarn) for the backend server.

## Setup & Running

**1. Backend Server (`json-server`)**

- Navigate to the directory containing the `index.js` and `db.json` files.
- Install dependencies:
  ```bash
  npm install
  # or
  yarn install
  ```
- Start the server:
  ```bash
  npm start
  # or
  npm run dev
  ```
- The server should now be running, typically on `http://localhost:3000`.

**2. Frontend (Flutter App)**

- Clone the repository.
- Navigate to the project directory: `cd cafe_staff_app`
- Install Flutter dependencies:
  ```bash
  flutter pub get
  ```
- **Run the app:** The project uses flavors for different environments (development, staging, production).
- **Development (Connects to `localhost` or `10.0.2.2`):**
  ```bash
  flutter run -t lib/main_development.dart
  ```
  _(Includes DevicePreview)_
- **Staging:**
  ```bash
  flutter run -t lib/main_staging.dart
  ```
  _(Ensure `baseUrl` in `lib/configs/flavor_config.dart` under `FlavorValues.staging` points to your staging backend)_
- **Production:**
  ```bash
  flutter run -t lib/main_production.dart
  ```
  _(Ensure `baseUrl` in `lib/configs/flavor_config.dart` under `FlavorValues.prod` points to your production backend)_

## Project Structure

- `lib/app/`: Core application setup (App widget, routing, theme, localization, global cubits).
- `lib/configs/`: Configuration files (App name, Flavor settings, Locale settings).
- `lib/core/`: Shared utilities, extensions, constants, error handling, network info.
- `lib/features/`: Main application features, separated by domain (auth, menu, order, user, etc.). Each feature typically contains:
  - `blocs/`: State management logic (Cubits/Blocs).
  - `datasources/`: Data fetching/persisting logic (remote/local).
  - `entities/`: Domain models (plain Dart objects).
  - `models/`: Data transfer objects (usually extending entities, with `fromJson`/`toJson`).
  - `repositories/`: Abstract definitions for data operations.
  - `usecases/`: Business logic units coordinating repositories.
  - `pages/` or `widgets/`: UI components.
- `lib/injection_container.dart`: Dependency injection setup using `get_it`.
- `lib/main_*.dart`: Entry points for different build flavors.

## Notes

- The development flavor uses `DevicePreview` for easier UI testing across different screen sizes. Remove it in app/app.dart.
- All staff pages should be landscape
- Real-time updates for table status and orders are handled via Socket.IO. Ensure the backend server is running and accessible.
- Error handling is implemented using `dartz` (Either) and custom Exception/Failure classes.
- There is still bug in json-server
