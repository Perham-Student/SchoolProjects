import 'package:flutter/material.dart';

// Stateless widget providing navigation UI
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChange;

// Constructor with required (must have)
  const PaginationControls({
    // Current page being viewed, used for handling buttons enabling/disabling and visual display of middle button
    required this.currentPage,
    // Total number of available pages, used to handle 'Next' and 'Last' button
    required this.totalPages,
    // Callback function triggered by user interaction with any button.
    // It sends the target page number to the parent (main.dart), where fetchMovies is called that requests data for the new page.
    // This triggers a new API call for us and rebuilds UI with the new updated data.
    required this.onPageChange,
    Key? key,
  }) : super(key: key);

// Helper function to create a button
  Widget buildButton({
    required String label,
    required bool isEnabled,
    // Represents a function without parameters and return value. '?' indicates that parameter can be null. If onPressed is null it will disable the button.
    // https://api.flutter.dev/flutter/dart-ui/VoidCallback.html
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      // To enable and disable the button
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(), // Circular button
        padding: const EdgeInsets.all(15), // Padding for the shape
      ),
      child: Text(label), // Label parameter is the text
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // First Button: Go to the first page. Call to helper function
        buildButton(
          // Declaring label (text) parameter as 'First'
          label: "First",
          // isEnabled parameter is checks if statement for currentPage greater than 1, true/false
          isEnabled: currentPage > 1,
          // OnPressedParameter is a callback function that triggers onPageChange for page 1 https://stackoverflow.com/questions/53894273/how-to-execute-the-voidcallback-in-flutter
          onPressed: () => onPageChange(1),
        ),

        // Second Button: Go to the previous page. Call to helper function
        buildButton(
          label: "<",
          isEnabled: currentPage > 1,
          onPressed: () => onPageChange(currentPage - 1),
        ),

        // Current page display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            // White color
            color: const Color.fromARGB(255, 243, 241, 241),
            // Adding a thin grey border to distinguish button
            border: Border.all(color: Colors.grey, width: 1),
            // Making the button like a circle
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$currentPage", // Showing the current page
            style: const TextStyle(fontSize: 16),
          ),
        ),

        // Fourth Button: Go to the next page. Call to helper function
        buildButton(
          label: ">",
          isEnabled: currentPage < totalPages,
          onPressed: () => onPageChange(currentPage + 1),
        ),

        // Fifth Button: Go to the last page. Call to helper function
        buildButton(
          label: "Last",
          isEnabled: currentPage < totalPages,
          onPressed: () => onPageChange(totalPages),
        ),
      ],
    );
  }
}
