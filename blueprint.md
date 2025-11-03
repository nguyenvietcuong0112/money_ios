
# Blueprint: Money Manager App Refactoring

## Overview

This document outlines the plan to refactor the Money Manager application from using the `provider` package for state management to `GetX`. This change will professionalize the codebase, making it more concise, organized, and performant.

## Current Architecture (Provider)

*   **State Management:** `ChangeNotifierProvider`, `ChangeNotifier`, `Consumer`, and `Provider.of` are used throughout the app.
*   **Dependencies:** Providers are injected at the top of the widget tree in `main.dart`.
*   **Navigation:** Standard `Navigator.push` and `MaterialPageRoute` are used for routing.

## Proposed Architecture (GetX)

*   **State Management:** We will replace `ChangeNotifier` with `GetxController`. Widgets will be updated using `GetBuilder`.
*   **Dependency Injection:** Dependencies will be managed using `Get.put()` and accessed with `Get.find()`.
*   **Navigation:** We will replace `Navigator` calls with `Get.to()`, `Get.back()`, etc., and use `GetMaterialApp`.

## Refactoring Plan

1.  **Add Dependency:** Add the `get` package to `pubspec.yaml`.
2.  **Create Controller Directory:** Create a new directory `lib/controllers` to store all GetX controllers.
3.  **Migrate Providers to Controllers:**
    *   `lib/providers/app_provider.dart` -> `lib/controllers/app_controller.dart`
    *   `lib/providers/theme_provider.dart` -> `lib/controllers/theme_controller.dart`
    *   `lib/providers/transaction_provider.dart` -> `lib/controllers/transaction_controller.dart`
    *   `lib/providers/wallet_provider.dart` -> `lib/controllers/wallet_controller.dart`
4.  **Update `main.dart`:**
    *   Initialize all `GetxController`s using `Get.put()`.
    *   Replace `ChangeNotifierProvider` with the GetX dependency injection setup.
    *   Change `MaterialApp` to `GetMaterialApp`.
5.  **Refactor UI Screens:**
    *   Update all screens (`home_screen.dart`, `record_screen.dart`, `settings_screen.dart`, etc.) to use `Get.find()` instead of `Provider.of`.
    *   Replace `Consumer` widgets with `GetBuilder`.
    *   Update all `Navigator.push` calls to `Get.to()`.
6.  **Cleanup:**
    *   Delete the now-unused `lib/providers` directory.
    *   Run `flutter format` to ensure consistent code style.
7.  **Verification:** Thoroughly test the application to ensure all features work as expected after the refactoring.
