import 'package:http/http.dart' as http;
import 'dart:convert';

// Class MovieService that encapsulates logic to handle HTTP request/response.
class MovieService {
  // Static so the class can access it without an instance and const because it does not change
  static const String _apiKey = "0e4a7191ffaa0d1f7306e7880c6480cb";
  static const String _baseUrl = "https://api.themoviedb.org/3";

  /* Method fetching movies from API, returning the raw JSON response
     Since asynchronous calculations do not provide immediate result
     at start, 'Future' allows code to run without being blocked. This by
     returning a 'Future' which will, in time, be completed with the
     result. https://api.flutter.dev/flutter/dart-async/Future-class.html */
  Future<Map<String, dynamic>> fetchMovies(int page) async {
    // Creates the URL by dynamic construction, baseUrl + endpoint (/movie/top_rated), and parameters (language/page)
    final url =
        '$_baseUrl/movie/top_rated?api_key=$_apiKey&language=en-US&page=$page';

    // Sending a HTTP GET request to the url, awaiting (pausing) execution until result is received.
    final result = await http.get(Uri.parse(url));

    /* We check if HTTP statuscode is 200 since that means that the request
       was successfull (https://blog.postman.com/what-are-http-status-codes/) 
       
       On success decodes the JSON response into Map<String, dynamic> through json.decode.
       In dart the keys are strings and we have dynamic values (can be anything, unknown until runtime, 
       handled in movie.dart). Reason why I don't handle it here is due to (Single Responsibility Principle, SOLID)
       https://docs.flutter.dev/data-and-backend/serialization/json */
    if (result.statusCode == 200) {
      return json.decode(result.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          "Failed to fetch movies. Error Code: ${result.statusCode}");
    }
  }
}
