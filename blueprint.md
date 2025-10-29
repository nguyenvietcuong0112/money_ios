# Money Manager App Blueprint

## Overview

A simple and intuitive money management app to track income and expenses.

## Features

- **Home Screen:** Displays a summary of recent transactions and account balances.
- **Record Screen:** A calendar-based view to record and view daily income and expenses.
- **Budget Screen:** Allows users to set and track budgets for different categories.
- **Statistics Screen:** Provides visual charts and graphs to analyze spending habits.
- **Settings Screen:** Users can customize language, currency, and theme (light/dark mode).
- **Localization:** Supports English, French, and Vietnamese.

## Current Task: Redesign Transactions Screen & Connect to Data

- **Objective:** Replace the old `TransactionsScreen` with a new `RecordScreen` and connect it to the `BudgetProvider` to display real transaction data.
- **Steps:**
    1.  **Update Navigation:** Changed the bottom navigation bar item from "Transactions" to "Record".
    2.  **Add Dependency:** Added the `table_calendar` package for the calendar UI.
    3.  **Create New Screen:** Implemented the `RecordScreen` with the following components:
        - Month/Year picker.
        - Calendar view with daily income/expense summary.
        - Overall income, expense, and total summary.
        - A list of transactions for the selected day.
    4.  **Update Provider:** Added `getTransactionsByMonth` and `getDailySummary` methods to `BudgetProvider` to process and group transaction data.
    5.  **Connect to Data:** Used a `Consumer<BudgetProvider>` in `RecordScreen` to fetch and display live transaction data.
    6.  **Dummy Data:** Added initial dummy data to `BudgetProvider` for demonstration purposes.