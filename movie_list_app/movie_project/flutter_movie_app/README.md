# flutter_movie_app

This folder contains the **Flutter-based movie list application**, which is part of my OOP2 course project. The app connects to the TMDB API, fetches a list of top-rated movies, and displays them in a paginated format. It also allows users to expand movie details, like the synopsis.

---

## Getting Started

This project was developed as an introduction to Flutter and Dart, focusing on integrating APIs and building a responsive UI. Below is a simple guide to set it up and run.

### Prerequisites
Before you start, make sure you have the following:
- **Flutter SDK** ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK** (bundled with Flutter)
- An IDE like **VS Code** (the one I used) (with Flutter/Dart plugins) and either an Android Phone or an emulator, such as,  **Android Studio**.

---

### Setup Instructions:<br/>

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/YourRepositoryName.git
   # Example:
   git clone https://github.com/Perham-Student.git
   cd ./movie_project/flutter_movie_app

2. **Install the dependencies inside the _flutter_movie_app_** <br/>
   ```bash
   flutter pub get

4. **Running the App: Launch the app on the connected device or an emulator (Google Chrome also works)** <br/>
   ```bash
   flutter run

5. **Use your TMDB API KEY (or mine) to test the app**
* Open the _movie_service.dart_ file.
* Replace the _apiKey_ value with your own TMDB API key.
* If you don't have an API key, get one [here](https://developer.themoviedb.org/docs/getting-started)

---

### Potential future improvements:
* Adding a drop-down menu to categorize movies by genre.
* Improving the UI with a focus on user-friendliness and a visually pleasing design.
* Implementing a search bar to have an easier time finding specific movies.

---

### Features:
* Paginated Movie List: Fetches and displays movies from the TMDB API as a scrollable list.
* Expandable Movie Details: Tap the expand icon of a movie to toggle and view its synopsis.
* Modular Code Design: Separates API logic, state management, and UI into reusable components, maing the code more future-proof.
* First Flutter Project: This project was my first hands-on learning experience for Flutter, Dart and API integration.


