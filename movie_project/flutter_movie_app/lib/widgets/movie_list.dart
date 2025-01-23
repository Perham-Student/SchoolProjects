import 'package:flutter/material.dart';
import '../objects/movie.dart';

// Stateless MovieList widget to display a scrollable list of movies, stateless because the state is handled by external managment (constructor parameters)
class MovieList extends StatelessWidget {
  // Display list for movies objects
  final List<Movie> movies;
  // Manages the scroll functionality for ListView
  final ScrollController scrollController;
  // A callback function (function passed as argument to another function) triggered at user interaction with synopsis button
  final Function(int) onToggleSynopsis;
  // Tracks the current page of movies for indexing
  final int currentPage;

  // Constructor with required(must have). The key properties passed in via the constructor
  const MovieList({
    required this.movies,
    required this.scrollController,
    required this.onToggleSynopsis,
    this.currentPage = 1,
    /* Key is used as identification of instances for widgets (allowing optimization of rendering). By using the same key (super key) we can assure
      that flutter understands that this instance is the same widget so it can keep the state
       https://medium.com/@yetesfadev/understanding-keys-in-dart-and-flutter-use-cases-examples-advantages-and-disadvantages-efff26b2d6e8 */
    Key? key,
  }) : super(key: key);

  /* Flutter uses a tree of widgets, which draws the UI based on this
    widget tree. */
  @override
  Widget build(BuildContext context) {
    // The root widget
    return ListView.builder(
      // Attaching the scrollcontroller
      controller: scrollController,
      // Number of items will be the length of the list of movies (movies amount)
      itemCount: movies.length,
      itemBuilder: (context, index) {
        // Each item is built dynamically, with index keeping track of current item. Movie information/data for current index
        final movie = movies[index];
        // Calculation of global index for the movie position in the list across all pages
        final globalIndex = (currentPage - 1) * 20 + (index + 1);

        return Column(
          // Align content to the left https://api.flutter.dev/flutter/rendering/CrossAxisAlignment.html
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                // Align items at the top
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Widget with own bounds that clips a child useing a base rectangle for our movie poster image https://api.flutter.dev/flutter/widgets/ClipRRect-class.html
                  ClipRRect(
                    // Makes the corners rounded with inspiration from imdb
                    borderRadius: BorderRadius.circular(8.0),
                    // Image.network widget works as constructor to work with images from a URL https://docs.flutter.dev/cookbook/images/network-image
                    child: Image.network(
                      "https://image.tmdb.org/t/p/w200${movie.posterPath}",
                      // Should look up MediaQuery/LayoutBuilder for scaling
                      width: 50,
                      height: 75,
                      // Ensures proper scaling of the image (as small as possible while covering the target box) https://api.flutter.dev/flutter/painting/BoxFit.html
                      fit: BoxFit.cover,
                      // Builder function handling error at image loading https://api.flutter.dev/flutter/widgets/Image/errorBuilder.html
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                            'Image failed to load'); // Error handling text, could be replaced with broken image
                      },
                    ),
                  ),
                  // SizedBox class as a space between image and details https://api.flutter.dev/flutter/widgets/SizedBox-class.html
                  const SizedBox(width: 10),

                  // Movie details (title, release year, rating)
                  Expanded(
                    child: Column(
                      // Align text to the left
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Displays movie title with global index
                        Text(
                          "$globalIndex. ${movie.title}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4), // Vertical spacing

                        // Row for release year and rating
                        Row(
                          children: [
                            // Displays the release year
                            Text(
                              // Splits at each '-' (year representation in data) and takes the first index (0) which is the year https://api.flutter.dev/flutter/dart-core/String/split.html
                              movie.releaseDate.split("-")[0],
                              style: const TextStyle(
                                // Grey color
                                color: Color.fromARGB(255, 158, 158, 158),
                                // Smaller font for details
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 10), // Horizontal spacing

                            // Rating with star icon
                            const Icon(
                              Icons.star,
                              color: Colors.yellow, // Yellow star icon
                              size: 16, // Star size
                            ),
                            const SizedBox(width: 4), // Horizontal spacing
                            Text(
                              // Rounded rating using abstract method. 1 stands for how many numbers after the decimal https://api.flutter.dev/flutter/dart-core/num/toStringAsFixed.html
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                // Grey color
                                color: Color.fromARGB(255, 158, 158, 158),
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(width: 10), // Horizontal spacing

                            // Vote count display
                            Text(
                              "(${movie.voteCount})", // Displays vote count in parentheses
                              style: const TextStyle(
                                // Grey color
                                color: Color.fromARGB(255, 158, 158, 158),
                                fontSize: 14, // Smaller font for details
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Flutter widget Iconbutton that displays an icon and causes an action when pressed. https://api.flutter.dev/flutter/material/IconButton-class.html
                  IconButton(
                    // Icon determined by movie.isExpanded state
                    icon: Icon(movie.isExpanded
                        ? Icons
                            .expand_less // If isExpanded is true, display collapse arrow https://api.flutter.dev/flutter/material/Icons/expand_less-constant.html
                        : Icons
                            .expand_more), // If isExpanded is false, display expand arrow https://api.flutter.dev/flutter/material/Icons/expand_more-constant.html
                    onPressed: () => onToggleSynopsis(
                        index), // On pressed calls the onToggleSynopsis function for that movie index
                  ),
                ],
              ),
            ),

            // Expanded synopsis (aligned below title and details)
            if (movie.isExpanded)
              // Changing text alignment with transform.translate https://api.flutter.dev/flutter/widgets/Transform/Transform.translate.html
              Transform.translate(
                offset: const Offset(0, -25), // Move the text up by 20 pixels
                child: Padding(
                  // Padding for text
                  padding: const EdgeInsets.only(left: 68, right: 16),
                  child: Text(
                    movie.overview,
                    style: const TextStyle(
                      fontSize: 14, // Consistent font size
                    ),
                  ),
                ),
              ),
            // Horizontal divider line between movies https://api.flutter.dev/flutter/material/Divider-class.html
            const Divider(),
          ],
        );
      },
    );
  }
}
