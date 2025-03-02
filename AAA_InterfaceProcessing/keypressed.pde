// Declare variables to store the start time and current time for the baseline process
long start_time_baseline; // Timestamp for when the baseline process starts
long current_time_baseline; // Timestamp to track the current time during baseline acquisition
boolean start_headpos = false; //Boolean for head calibration phase 
long start_time_headpos; //Timestamp for when the calibration for head movement start 
/**
 * Function triggered when a key is pressed.
 * If the 's' or 'S' key is pressed, it finalizes data writing, closes the file, 
 * and informs the user that the file has been saved with a new name.
 */
void keyPressed() {
  // Check if the key pressed is 's' or 'S'
  if (key == 's' || key == 'S') {
    finishDataWriting();  // Call function to finish writing data and close the file
    println("CLOSING AND SAVING THE FILE UNDER NEW NAME"); // Inform the user about the file being saved
  }
}

/**
 * Function triggered when the mouse is clicked.
 * If the mouse click occurs within the bounds of a specified rectangle,
 * it starts the baseline acquisition process by setting flags and recording the start time.
 * it starts also the claibration for the head position
 */
void mousePressed() {
  // Check if the mouse click occurred within the defined rectangle area
  // Rectangle bounds: Centered at (150, 310), width = 200, height = 100
  if (mouseX >= 150 - 100 && mouseX <= 150 + 100 && mouseY >= 310 - 50 && mouseY <= 310 + 50) {
      start_baseline = true; // Flag to indicate the baseline acquisition has started
      baseline_acquired = false; // Reset the flag indicating baseline acquisition completion
      start_time_baseline = millis(); // Record the starting time of the baseline process
  }
  if (mouseX >= 851 && mouseX <= 851 + 320 && mouseY >= 850 && mouseY <= 850 + 40) {
    start_headpos = !start_headpos;
    headposacquired = false;
    start_time_headpos = millis(); // Record the starting time of the baseline process
  }
}
