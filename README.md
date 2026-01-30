# Audio Manager

![Demo Placeholder](https://via.placeholder.com/800x450.png?text=Demo+Recording+Coming+Soon)

## Project State
The **Audio Manager** is a sophisticated Flutter application designed for granular control over device hardware parameters, currently in an **Advanced Prototype** stage. It features a robust profile management system and highly customizable UI components for a premium user experience.

## Architecture Design Logic

This project follows a strict **Clean Architecture** approach combined with the **BLoC (Business Logic Component) Pattern** for state management. This ensures decoupling between the UI, business logic, and data layers, making the app highly testable and maintainable.

### 🏗 Layered Structure
- **Data Layer**: Handles data persistence (SharedPreferences) and low-level hardware interactions (Audio, Brightness, Haptics).
- **Logic Layer (BLoC)**: Orchestrates the state transitions based on user interactions. It consumes services/repositories and emits states that the UI reacts to.
- **Presentation Layer**: Built with highly reusable, custom-drawn widgets for a futuristic aesthetic.

### 🧩 Design Patterns
- **Repository Pattern**: Abstracts data sources, allowing the logic layer to remain agnostic of whether data comes from local storage or an API.
- **Service Pattern**: Segregates hardware-specific logic into dedicated services (e.g., `HapticsService`).
- **Standardized Models**: Uses immutable models (via `copyWith`) to maintain predictable state flow.

## Key Features
- **Hardware Orchestration**: Direct control over device haptics, brightness, and audio levels.
- **Profile Management**: Save and switch between different hardware configurations seamlessly.
- **Premium UI/UX**: Custom-designed circular indicators, vertical sliders, and glassmorphism-inspired elements.
- **Dynamic Theming**: Support for both light and dark modes with smooth transitions.

---

## Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-repo/audio_manager.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```
| Component | Folder | Purpose |
| :--- | :--- | :--- |
| **UI** | `lib/presentation` | Screens and Custom Widgets |
| **State** | `lib/logic` | BLoCs and Cubits |
| **Data** | `lib/data` | Repositories, Models, and Services |
