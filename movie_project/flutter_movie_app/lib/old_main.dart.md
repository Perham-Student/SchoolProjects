import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // https://dart.dev/tutorials/server/fetch-data

// A lot of inspiration from https://stackoverflow.com/questions/71377107/flutter-dart-json-list-to-display-in-widget-shows-only-one-value
void main() {
  runApp(const MovieApp());
}

/* StatefulWidget instead of stateless because we can update the UI while stateless stays after being built
  We use the State Class _MovieAppState to manage the app state. Start with creating widget MovieApp
  which extends StatefulWidget which allows for dynamic changes. It doesn't store the state but lets 
  MovieAppState do it
*/
class MovieApp extends StatefulWidget {
  /* Constructor for MovieApp calling constructor of baseclass (StatefulWidget), super.key gives a unique key (id) 
    that helps with optimizations https://stackoverflow.com/questions/54968561/what-does-super-and-key-do-in-flutter.
    Const makes it immutable
  */
  const MovieApp({super.key});

  // Creates the object (state) for MovieApp. The movie list is stored here. Everything happens in here.
  @override
  _MovieAppState createState() => _MovieAppState();
}

@override
class _MovieAppState extends State<MovieApp> {
  List<dynamic> movies = []; // List to store the movies
  int currentPage = 1; // Current page tracking
  int totalPages = 1; // Total pages tracker (default value)
  late ScrollController
      _scrollController; // Declaring a controller for the ListView position adjusting. Late allows to initialize the variable later.

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // Iniatilizing the ScrollController
    fetchMovies(1); // Call API at app start
  }

  // Disposer for the scrollcontroller
  @override
  void dispose() {
    _scrollController.dispose(); // Disposal of the ScrollController
    super.dispose(); // Calling the superclass method (dispose)
  }

  /* To create an async method allowing us to take time and pause while waiting for API response
      Method gets an web address (endpoint) where we can fetch the TMBD data
      using a constant apiUrl to store the API URL. Request is top rated movies first page.
      Then we send a GET-request to the server and use await to pause until TMDB replies. 
      We store it as result and use the Uri.parse to make it understandable for flutter.
  */
  Future<void> fetchMovies(int page) async {
    setState(() {
      currentPage = page;
    });

    final String apiUrl =
        "https://api.themoviedb.org/3/movie/top_rated?api_key=0e4a7191ffaa0d1f7306e7880c6480cb&language=en-US&page=$page";
    final result = await http
        .get(Uri.parse(apiUrl)); // https://dart.dev/tutorials/server/fetch-data

    /* We check if HTTP statuscode is 200 since that means that the request
      was successfull (https://blog.postman.com/what-are-http-status-codes/)
    */
    if (result.statusCode == 200) {
      print("API successfully recieved!");
      /* Since Data is already in JSON I use built-in json.decode (dart convert library) to convert the raw string to dart objects.
        To convert the JSON String into a Dart Map, I use Map<String, dynamic>
        To get a hash-like map with key and value structures for easier handling
        and then store the array of movies like a list
      */
      final Map<String, dynamic> jsonData = json.decode(result.body);

      /* 
        Variable can be modified but not reassigned with final, List<Dynamic> specifies that it is a list containing dynamic values.
        recievedMovies is the variable name that stores the movies. jsonData[results] extracts the result array (see above) from the API response I got.
        Easier to think of it as getting the result key from the key-value above.
      */
      final List<dynamic> recievedMovies = jsonData["results"];

      // State update, change in method that is passed to the setState https://api.flutter.dev/flutter/widgets/State/setState.html
      setState(() {
        // Map (iterable) over the recievedMovies list to be able to modify each movie object. Method will copy each key-value pairs and add the isExpanded key with value false.
        // Iterable is a type of object that can be looped through, which the map() method returns. The iterable is converting back to list form.
        movies = recievedMovies.map((movie) {
          // Returning new object for each movie with spread operator '...'
          return {
            ...movie, // Copies all key-value pairs from the movie object (spread operator) https://medium.com/@chetan.akarte/what-is-the-recommended-way-to-clone-a-dart-list-map-and-set-4dcbe65fe2b7
            "isExpanded":
                false, // New key 'isExpanded' with default of false for each movie https://stackoverflow.com/questions/53908405/how-to-add-a-new-pair-to-map-in-dart
          };
        }).toList(); // Converting the updated list from map back to list form https://stackoverflow.com/questions/57234575/dart-convert-map-to-list-of-objects
        totalPages = jsonData[
            "total_pages"]; // Update total number of pages based on API reply
      });

      // Instantly moves controller to position 0 (top)
      _scrollController.jumpTo(0.0);
    } else {
      print(
          "Failed to recieve results."); // Will look into adding error status code later
    }
  }

  // Toggle the expanded synopsis for a movie
  void toggleSynopsis(int index) {
    setState(() {
      movies[index]["isExpanded"] = !movies[index]["isExpanded"];
    });
  }

  /* Flutter uses a tree of widgets, which draws the UI based on this
    widget tree. The setState is called to update (rebuild) only the affected parts
  */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Hides the debug text top right corner
      home: Scaffold(
        // Sets up page with body, bars etc (app screen foundation)
        appBar: AppBar(
          title: const Text("Top Rated"), // Setting the Header text
          centerTitle: true, // Centralizing the text
        ), // The "Header" text bar
        body:

            // Movie List with ListView.builder
            Column(
          children: [
            // Expanded makes ListView builder able to take up column's remaining space
            Expanded(
              child: movies
                      .isEmpty // Body is the main content, similar to sidebar/article in css grid, checks if movies is empty
                  // ? (if-else) if true (empty) => loading, else create item with movies
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Shows loading circle, puts the indicator in the middle

                  //If false the widget creating scrollable list dynamically of items https://techdynasty.medium.com/listview-builder-in-flutter-e54a8fa2c7a0
                  : ListView.builder(
                      // Attaching the scroll controller
                      controller: _scrollController,
                      // Number of items will be the length of the list of movies
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        // Each item is built dynamically, with index keeping track of current item. Movie information/data for current index
                        final movie = movies[index];

                        // Creates full image URL from poster_path in API
                        final String imageUrl =
                            "https://image.tmdb.org/t/p/w200${movie["poster_path"]}";

                        // Calculation of global index for the movie based on page and index
                        final globalIndex =
                            (currentPage - 1) * 20 + (index + 1);

                        return Column(
                          // Wrapping each movie with column for details (ratings etc) and a seperating line (divider)
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(
                                  7.0), // 7 pixels of padding on every side
                              child: Row(
                                // top alignment of items
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Top alignment for items https://api.flutter.dev/flutter/rendering/CrossAxisAlignment.html
                                children: [
                                  // Poster image with CliptRRect class https://api.flutter.dev/flutter/widgets/ClipRRect-class.html
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Adding rounded corners
                                    child: Image.network(
                                      // Fetching image from URL with https://docs.flutter.dev/cookbook/images/network-image
                                      imageUrl, // Url to fetch image
                                      width: 50, // Width of image
                                      height: 75, // Height of image
                                      fit: BoxFit
                                          .cover, // Makes image as small as possible while still covering the entire targetted box https://api.flutter.dev/flutter/painting/BoxFit.html
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // Error handling https://pub.dev/packages/flutter_network_image/example
                                        return const Text(
                                            'Loading image failed!'); // Might try to find a broken image icon later
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Space between image and details

                                  // Index position, title and data for movie
                                  Expanded(
                                    // Expanded to make sure that title and details covers remaining horizontal space
                                    child: Column(
                                      // Verticale arranging of title and details
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Left alignment for text
                                      children: [
                                        // Movie Title
                                        Text(
                                          "${globalIndex}. ${movie["title"]}", // Displays the the title from the API
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold, // Bold Title
                                            fontSize:
                                                16, // Font size for number and title
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                4), // 4 pixels vertical space

                                        // Details for movie (Displays year, rating and vote count amount)
                                        Row(
                                          children: [
                                            // Year of release
                                            Text(
                                              movie["release_date"]
                                                      /* Extracts the year from release_date if available, otherwise fallback to N/A. Credits to ChatGPT to get this to work
                                                         This is a so called Dart null-aware expression to handle potential null values combined with part of string extraction (safe)
                                                         It starts off with assessing the release_date where it retrieves the associated value with 'release_date' as a key (movie map)
                                                         If the release_date is missing/non-existant it will return null. The "?." is the null-aware that ensures that split("-")
                                                         will only be called if release_date is not null. If the release_date is null it will make the entire expression to null
                                                         to avoid causing an error. So if null split will not be executed and the expression will instead return null.
                                                         The split function uses the "-" to split the string at those parts. Since release_date in my API is presented as XXXX-XX-XX,
                                                         e.g 2010-10-10 would split into an array of 3 parts, "2010", "10", "10". Then the [0] will take the first part (2010).
                                                         REMINDER: This is only done if release_date is not null due to "?.".

                                                         The ?? is an operator called null-coalescing operator. It works as a fallback value in case the left side is null. If left side
                                                         returns null then the default value of "N/A" will be used instead as a result                                               
                                                      */
                                                      ?.split("-")[0] ??
                                                  "N/A",
                                              style: TextStyle(
                                                color: const Color.fromARGB(
                                                    255,
                                                    158,
                                                    158,
                                                    158), // Grey text color
                                                fontSize:
                                                    14, // Smaller font than title (description)
                                              ),
                                            ),
                                            const SizedBox(
                                                width:
                                                    10), // 10 pixels of horizontal spacing

                                            // Rating displayed as star icon and rounded rating number
                                            Row(
                                              children: [
                                                const Icon(
                                                  // Icon from Icons class https://api.flutter.dev/flutter/material/Icons-class.html
                                                  Icons.star,
                                                  color: Colors
                                                      .yellow, // Change star color to yellow
                                                  size: 16, // Star size 16
                                                ),
                                                const SizedBox(
                                                    width:
                                                        4), // Adding 4 pixels of space between star and rating text
                                                Text(
                                                  movie["vote_average"]
                                                      .toString(), // Displaying the average rating, first changing raw rating to string
                                                  style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255,
                                                        158,
                                                        158,
                                                        158), // Color set to grey
                                                    fontSize:
                                                        14, // Repetition design, detail font
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                                width:
                                                    10), // 10 pixels of horizontal spacing

                                            // Vote count
                                            Text(
                                              "(${movie["vote_count"]})", // Displays the total count in parentheses
                                              style: TextStyle(
                                                color: const Color.fromARGB(
                                                    255,
                                                    158,
                                                    158,
                                                    158), // Text color to grey
                                                fontSize:
                                                    14, // Repetition design, detail font
                                              ),
                                            ),
                                          ],
                                        ),

                                        // GestureDetector class to handle arrow taps and toggling of synopsis https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
                                        GestureDetector(
                                          onTap: () => toggleSynopsis(
                                              index), // Toggles expanded state for chosen movie
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .end, // .end aligns arrow to the far right
                                            children: [
                                              AnimatedRotation(
                                                // Usage of https://api.flutter.dev/flutter/widgets/AnimatedRotation-class.html
                                                turns: movie[
                                                        "isExpanded"] // Arrow Rotation 180 degrees
                                                    ? 0.5
                                                    : 0,
                                                duration: const Duration(
                                                    milliseconds:
                                                        300), // Rotation animation for the arrow
                                                child: const Icon(Icons
                                                    .keyboard_arrow_down), // Arrow icon
                                              ),
                                            ],
                                          ),
                                        ),

                                        // AnimatedCrossFade to switch between collapsed and expanded synopsis https://api.flutter.dev/flutter/widgets/AnimatedCrossFade-class.html
                                        AnimatedCrossFade(
                                          duration: const Duration(
                                              milliseconds:
                                                  300), // Animation duration
                                          firstChild: const SizedBox
                                              .shrink(), // Empty space/area when collapsed
                                          secondChild: Text(
                                            movie["overview"] ??
                                                "No synopsis available.", // Dislays the synopsis or fallback text with the null handling operator
                                            style: const TextStyle(
                                                fontSize:
                                                    14), // Repetition design for details
                                          ),
                                          crossFadeState: movie["isExpanded"]
                                              ? CrossFadeState
                                                  .showSecond // Shows full text (synopsis) when expanded
                                              : CrossFadeState
                                                  .showFirst, // Hides the text when collapsed (isExpanded flag)
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Adds Horizontal line as separator (divider) https://api.flutter.dev/flutter/material/Divider-class.html
                            const Divider(
                              thickness: 1, // Line thickness 1 (similar to CSS)
                              color: Colors.grey, // Grey color of line
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Pagination buttons - Maybe future method call since buttons uses same methods
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First Button to First Page. Usage of ElevatedButton with onPressed VoidCallback https://api.flutter.dev/flutter/material/ElevatedButton-class.html
                ElevatedButton(
                  onPressed: currentPage > 1
                      ? () {
                          fetchMovies(1); // Since first page is always 1
                        }
                      : null, // Button is disabled on first page (obsolete)
                  style: ElevatedButton.styleFrom(
                    shape:
                        const CircleBorder(), // Trying shape in ElevatedButtons (round) https://api.flutter.dev/flutter/material/ElevatedButton/styleFrom.html
                    padding: const EdgeInsets.all(
                        15), // Adding padding for the shape
                  ),
                  child: const Text(
                      "First"), // Text for first button will always display 'First'
                ),

                // Second Button for previous page
                ElevatedButton(
                  onPressed: currentPage > 1
                      ? () {
                          fetchMovies(
                              currentPage - 1); // Go to the previous page
                        }
                      : null, // Button is disabled on first page (obsolete)
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(), // Round Shape
                    padding: const EdgeInsets.all(
                        15), // Adding padding for the shape
                  ),
                  child: const Text(
                      "<"), // Text for second button will always be '<'
                ),

                // Third button (not a button but a displayer) (Displaying current page) https://api.flutter.dev/flutter/widgets/Container-class.html
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical:
                          10), // Immutable offset https://api.flutter.dev/flutter/painting/EdgeInsets-class.html
                  decoration: BoxDecoration(
                    // https://api.flutter.dev/flutter/painting/BoxDecoration-class.html
                    color: const Color.fromARGB(255, 243, 241, 241),
                    border: Border.all(
                      // Adding border to button
                      color: Colors.grey, // Border color
                      width: 1, // Border thickness
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$currentPage", // Showing the curent page
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Fourth button for next page
                ElevatedButton(
                  onPressed: currentPage < totalPages
                      ? () {
                          fetchMovies(currentPage + 1); // Go to the next page
                        }
                      : null, // Button is disabled on last page (obsolete)
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(), // Round Shape
                    padding: const EdgeInsets.all(
                        15), // Adding padding for the shape
                  ),
                  child: const Text(
                      ">"), // Text for fourth button will always be '>'
                ),

                // Fifth button for the last page
                ElevatedButton(
                  onPressed: currentPage < totalPages
                      ? () {
                          fetchMovies(totalPages); // Go to the last page
                        }
                      : null, // Button is disabled on last page (obsolete)
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(), // Round Shape
                    padding: const EdgeInsets.all(
                        15), // Adding padding for the shape
                  ),
                  child: const Text(
                      "Last"), // Text for fifth button will always be 'Last'
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
