# 💱 Currency Converter App

A **feature-rich Flutter currency converter** that delivers **real-time exchange rates** via an external API. The app focuses on a clean, modern user experience with an updated UI, light & dark themes, favorites, charts, conversion history, and intelligent error handling

---

## 🚀 Overview

This app allows users to convert currencies using **live exchange rates** fetched from an API. It tracks user preferences through favorites and conversion history, and includes error handling for a smoother experience.

---

## ✨ Features

* 🔄 **Real-time currency conversion** using live exchange rate API
* ⭐ **Favorite currencies** for faster access
* 📈 **Exchange rate chart** (currently using dummy data)
* 🕘 **Conversion history** to track previous conversions
* ⚠️ **Error handling** for:

  * API fetch failures
  * Selecting the same currency for conversion
* 🌗 **Light & Dark mode** support
* 🎨 **Updated clean and modern UI**
* ⚡ Smooth performance with simple state management

---

## 🛠️ Tech Stack

* **Flutter (Dart)**
* **REST API** for real-time exchange rates
* Material Design
* Basic state management

---

## 📸 Screenshots

> Replace the image paths below with your actual screenshots

| Light Mode                                | Dark Mode                               |
| ----------------------------------------- | --------------------------------------- |
| ![Light Mode]() | ![Dark Mode]() |

| Favorites                               | Conversion History                  |
| --------------------------------------- | ----------------------------------- |
| ![Favorites]() | ![History]() |

| Chart View                      | Error Message Example           |
| ------------------------------- | ------------------------------- |
| ![Chart]() | ![Error]() |

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Dart
* Android Emulator / iOS Simulator or physical device

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/hassanbuilds/currency_converter_flutter.git
   ```
2. Navigate to the project directory:

   ```bash
   cd currency_converter_flutter
   ```
3. Install dependencies:

   ```bash
   flutter pub get
   ```
4. Run the app:

   ```bash
   flutter run
   ```

---

## 🔑 API Configuration

* This app uses an external API to fetch **real-time currency exchange rates**.
* Add your API key (if required) inside the API service file.
* **Do not commit API keys** to public repositories.

---

## 📂 Project Structure

The project follows a **clean architecture–inspired structure** for better scalability and maintainability:

```
lib/
 ├── core/            # Common utilities, constants, themes, helpers
 ├── data/            # Data sources, API services, models, repositories
 ├── domain/          # Business logic, entities, use cases
 ├── presentation/    # UI layer (screens, widgets, state management)
 └── main.dart        # App entry point
```

> Each layer may contain multiple subfolders and files based on features and responsibilities.

---

## 🔮 Future Improvements

* Replace dummy chart data with real historical data
* Offline support
* Advanced state management (Provider / Riverpod / Bloc)
* Multi-language support

---

## 🤝 Contributing

Contributions are welcome! Fork the repository and submit a pull request.

---

## 📄 License

This project is licensed under the **MIT License**.
