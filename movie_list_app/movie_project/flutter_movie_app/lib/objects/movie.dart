// Declares a movie class. Represents a single movie object with properties corresponding to retrieved API data
class Movie {
  // Immutable fields after object creations since the movie objects stays the same (except of isExpanded)
  final String title;
  final String posterPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final String overview;
  bool isExpanded; // The toggle for synopsis box visibility

  // Constructor for the movie object, required represents must be provided parameters
  Movie({
    required this.title,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.overview,
    this.isExpanded = false, // Collapsed box by default
  });

  /* Factory constructor is a special type of constructor which allows for more control.

     Factory constructor advantages:
       1. Allows us to return instance of the class.
       2. Able to process/change input data before creation of the object

     What it does:
       1. We input Map<String, dynamic> (JSON object) which has the movie data retrieved from the API.
       2. We use the factory constructor to process this raw data (JSON) and map it to the properties
          of our Movie class, giving us an initialized Movie object.

     Why did I choose a factory constructor?
      I saw it on https://dart.dev/language/constructors#factory-constructors and also asked ChatGPT 
      about the usage of a factory constructor in my case, and it seemed fitting since it can't access 'this' direct.
      This let's us process input data in the sense of:
       1. Making sure of the final fields immutability, as they are initialized at creation time.
       2. Allowing for conversions (vote_average to int/double).

    
     Explanation of 'null awareness operator' and 'as num?':
      voteAverage: (json['vote_average'] as num?
       We try to read the value of vote_average from the JSON object,
       num? means that we treat the value as a num (int/double) and it is allowed to be null

      ?.toDouble()
       If it is not null we will convert it to a double, so 8 becomes 8.0

      ?? 0.0
       If it is null, or non-existant, we use the null awareness operator to set a default of 0.0

     TLDR:
     1. Take raw API data (JSON object).
     2. Process it to handle null and handling data types (conversion).
     3. Returns fully initialized Movie object for the app to use.
     Source: https://dart.dev/language/constructors */

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? 'Unknown',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? 'N/A',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      overview: json['overview'] ?? 'No synopsis available.',
    );
  }
}
