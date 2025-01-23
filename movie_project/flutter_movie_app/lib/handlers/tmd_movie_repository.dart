import '../objects/movie.dart';
import 'movie_service.dart';
import 'movie_repository.dart';

// TMDBMovieRepository is a concrete implementation of the abstract method in the MovieRepository interface, two methods for SRP
class TMDBMovieRepository implements MovieRepository {
  // Private instance of MovieService for API calls, immutable (ref doesn't change)
  final MovieService _movieService = MovieService();

  // The getMovies implementation
  @override
  Future<List<Movie>> getMovies(int page) async {
    // Fetches movie (MovieService) from API for specific page and awaits result (raw JSON)
    final movieServiceResult = await _movieService.fetchMovies(page);
    // Extracts the results from JSON (List of Movie Data), might be a good idea with a throw exception in case it is not a list
    final moviesJson = movieServiceResult['results'] as List;

    /* moviesJson is a List<dynamic> containing the JSON objects that
       represents movies extracted from the results field of the API response.
       Then .map is used to transform/map the JSON objects in moviesJson to a
       movie object through the Movie.fromJson factory constructor (movie.dart).
       The result from .map() produces an iterable (collection of values/elements
       that through using the iterator getter can step through each value) 
       of Movie objects.

       The iterables returned by the .map() operator are then converted to
       a List<Movie> (list of movie objects) through the toList(). This makes the
       method return a list of Movie objects instead of the iterables.

       We return this with the 'return' keyword to the caller of this getMovies method,
       through this way the caller of the method will get a list of movie objects to work with. 

       Sources: https://api.dart.dev/dart-core/Iterable/toList.html
                https://api.dart.dev/dart-core/Iterable-class.html
                https://codewithandrea.com/articles/parse-json-dart/

    */

    // Iteration over each item in moviesJson, current json object is assigned to 'json' parameter (represents each individual item)
    return moviesJson.map((json) => Movie.fromJson(json)).toList();
  }

  // Method to fetch total pages from the API. Maybe implement logging for page/API result
  Future<int> fetchTotalPages(int page) async {
    // Calls fetchMovies to get data for the page
    final totalPages = await _movieService.fetchMovies(page);
    // Extracts the total_pages from the result and using null awareness operator we put 1 as fallback in case of null.
    return totalPages['total_pages'] ?? 1;
  }
}
