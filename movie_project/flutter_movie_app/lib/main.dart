import 'package:flutter/material.dart';
import 'objects/movie.dart';
import 'handlers/tmd_movie_repository.dart';
import 'widgets/movie_list.dart';
import 'widgets/pagination_controls.dart';

void main() {
  runApp(const MovieApp());
}

// StatefulWidget due to dynamic changes (dynamic list, rebuilds)
class MovieApp extends StatefulWidget {
  // ID key for widget and building widget trees, needed due to StatefulWidgets' parameter
  const MovieApp({super.key});

  @override
  _MovieAppState createState() => _MovieAppState();
}

// Private class '_' extending State since it handles lifecycle and state of MovieApp (brain of operation, handles displayed layout and data)
class _MovieAppState extends State<MovieApp> {
  // Creating final instance of TMDBMovieRepository that handles TMDB API
  final TMDBMovieRepository movieRepository = TMDBMovieRepository();
  // Initializing list of movies, empty and updated dynamically.
  List<Movie> movies = [];
  // Tracker for current displaying page, default 1 (first page)
  int currentPage = 1;
  // Tracker for total pages, default is 1 but will be updated when info is retrieved from API
  int totalPages = 1;
  // Handles scroll behaviour of widget. Late means that initailization occurs later but will be done before usage. Unnecessary to initialize this early.
  late ScrollController scrollController;

  // Special method called once after state object is created before widget is displayed https://api.flutter.dev/flutter/widgets/State/initState.html
  @override
  void initState() {
    // Ensures proper internal setup of default behavior (proper functionality, e.g state object connection with widget tree)
    super.initState();
    // Easier handling/reference to the ScrollController instance, e.g jumpTo.
    scrollController = ScrollController();
    // Call fetchmovies method for page 1, ensures initial loading (async) before user interraction
    fetchMovies(1);
  }

  // Async method using Future<T> class to immediately returning a Future to avoid blocking computation, completes eventually. https://api.flutter.dev/flutter/dart-async/Future-class.html
  Future<void> fetchMovies(int page) async {
    // Calls fetch method for movie list for specific page from movieRepository (awaits API call to not block)
    final fetchedMovies = await movieRepository.getMovies(page);

    // Extracting totalPages from API for pagination
    final fetchedTotalPages = await movieRepository.fetchTotalPages(page);

    // setState to tell that widget state has been changed, triggering a rebuild with updated data
    setState(() {
      movies = fetchedMovies; // Movie list updated with placeholder from above
      currentPage = page; // Current page is updated to the fetched page
      totalPages =
          fetchedTotalPages; // Updated total number of pages from API, used for pagination and enabling of 'Next' button.
    });

    scrollController.jumpTo(0.0); // Reset scroll position to top of the list
  }

  // Void return since it performs an action. It takes parameter of the index of the movie where synopsis will be toggled
  void toggleSynopsis(int index) {
    setState(() {
      // '!' to invert current value to change isExpanded to the opposite value, which then is assigned to the isExpanded flag.
      movies[index].isExpanded = !movies[index].isExpanded;
    });
  }

  // Overriding the build method of parent (State) class. Method is respondible for describing and rebuilding UI of MovieApp widget.
  @override
  // Represents the widget location in the widget tree and providing access to functionality
  Widget build(BuildContext context) {
    // Root widget of the app
    return MaterialApp(
      // Hides the debug text top right corner
      debugShowCheckedModeBanner: false,
      // Primary structure of screen app https://api.flutter.dev/flutter/material/Scaffold-class.html
      home: Scaffold(
        // Provides the top bar (header) with the text Top Rated
        appBar: AppBar(title: const Text("Top Rated")),
        // Scaffold body with column widget to be able to stack child widgets vertically (MovieList and PaginationControls)
        body: Column(
          children: [
            // To make sure that MovieList widget covers the available space in vertical layout
            Expanded(
              // The scrollable movie list widget (custom)
              child: MovieList(
                // Key property movies passes list of movies to be displayed in list
                movies: movies,
                // Key property providing the controller to handle scroll behaviour of movie list
                scrollController: scrollController,
                // Key property passing toggleSynopsis function for user interaction of expanding/closing movie synopsis
                onToggleSynopsis: toggleSynopsis,
                // To display which page of the movie list is currently being shown
                currentPage: currentPage,
              ),
            ),
            // Custom widget for displaying and managing pagination controls/buttons
            PaginationControls(
              // Key property passing current page to be able to display/enable/disable buttons
              currentPage: currentPage,
              // Key property passing total pages to indicate available pages
              totalPages: totalPages,
              // Passing fetchMovies method to retrieve movie data for a different page at user interaction.
              onPageChange: fetchMovies,
            ),
          ],
        ),
      ),
    );
  }
}
