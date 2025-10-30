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

## Current Task: Redesign Language Selection Screen

- **Objective:** Redesign the `LanguageSelectionScreen` with a modern UI, animations, and improved user experience as requested.
- **Plan:**
    1.  **Add Dependencies:** Add the `lottie` package for animations.
    2.  **Create Animation Asset:** Add a Lottie animation file for the animated hand icon.
    3.  **Update UI:**
        - Create a new stateful widget `LanguageSelectionScreen`.
        - The UI will feature a list of selectable language cards.
        - An animated Lottie hand icon will initially point to the 'English' option.
        - A 'Next' button (checkmark icon) will be placed in the `AppBar`, initially disabled.
    4.  **Implement Animation & Logic:**
        - Use a `Stack` to overlay the animated hand icon.
        - When a language is selected:
            - The 'Next' button becomes enabled.
            - The hand icon will animate its position, moving towards the 'Next' button.
    5.  **State Management:**
        - Manage the selected language and button-enabled state within the widget's state.
        - On pressing 'Next', update the application's locale using the `AppProvider`.
