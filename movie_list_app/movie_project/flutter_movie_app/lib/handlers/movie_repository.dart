import '../objects/movie.dart';

/* Abstract method for fetching movies (Interface)
   Method returns a Future that eventually result in List<Movie>
   This makes it an async operation. Parameter is the specific page and there 
   is no method body.
   
   This is done to create a WHAT needs to be done and not how.
   while the implementation is taken care of the tmd_movie_repository which
   implements how it is done. Allows for an easier time when testing (swapping implementation). 
   It also allows for app testing without making a real API data in case I decide to implement testing.
   
   Honestly, in this case it was implemented to try out creating an abstract class in Dart. Maybe data conversion in future */
abstract class MovieRepository {
  Future<List<Movie>> getMovies(int page);
}


/* Example of a test class would be:
class TestMovieRepository implements MovieRepository {
  @override
  Future<List<Movie>> getMovies(int page) async {
    return [
      Movie(
        title: "OOP 1",
        posterPath: "/OOP1.jpg",
        releaseDate: "2024-10-10",
        voteAverage: 10.0,
        voteCount: 10,
        overview: "This is not a real movie.",
      ),
      Movie(
        title: "OOP 2",
        posterPath: "/OOP2.jpg",
        releaseDate: "2025-01-01",
        voteAverage: 9.9,
        voteCount: 9,
        overview: "Another fake movie.",
      ),
    ];
  }
}

void testMockRepository() async {
  final repository = TestMovieRepository();
  final movies = await repository.getMovies(1);
  assert(movies.length == 2);
  assert(movies[0].title == "OOP 1");
}
 */