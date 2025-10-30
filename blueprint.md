# Money Manager App Blueprint

## Overview

This document outlines the structure and features of the Money Manager app, a Flutter application designed to help users track their income and expenses.

## Features

### Core Features

*   **Multi-Wallet Management:** Users can create and manage multiple wallets, each with its own balance.
*   **Transaction Tracking:** Users can add income and expense transactions to their wallets.
*   **Category Management:** Transactions can be assigned to categories, each with its own name, icon, and color.
*   **Data Persistence:** All data is stored locally using Hive.

### Screens

*   **Home Screen:** Provides an overview of the user's finances, including total balance, recent transactions, and a summary of income and expenses.
*   **Add Transaction Screen:** Allows users to add new income or expense transactions.
*   **Wallet Screen:** Displays a list of all wallets, with options to add, delete, and view the details of each wallet.
*   **Wallet Detail Screen:** Shows the balance and a list of all transactions for a specific wallet.
*   **Statistics Screen:** Provides a detailed overview of the user's spending habits, with a pie chart showing spending by category, a spending limit feature, and the ability to filter by month or view all-time data.
*   **Settings Screen:** Allows users to customize the app, with options for dark mode, language, currency, notifications, and security.

## Project Structure

```
lib
├── main.dart
├── app.dart
├── localization
│   ├── app_localizations.dart
│   └── languages
│       ├── en.json
│       └── es.json
├── models
│   ├── category_model.dart
│   ├── transaction_model.dart
│   └── wallet_model.dart
├── providers
│   ├── app_provider.dart
│   ├── transaction_provider.dart
│   ├── theme_provider.dart
│   └── wallet_provider.dart
└── screens
    ├── add_transaction_screen.dart
    ├── add_wallet_screen.dart
    ├── currency_selection_screen.dart
    ├── home_screen.dart
    ├── language_selection_screen.dart
    ├── settings_screen.dart
    ├── statistics_screen.dart
    ├── wallet_detail_screen.dart
    └── wallet_screen.dart
```

## Current Plan

*   **Improve `SettingsScreen`:**
    *   Restructure the UI using `Card` widgets.
    *   Add icons to each setting.
    *   Add "Notifications" and "Security" settings.
    *   Add a "Help & Support" section.
