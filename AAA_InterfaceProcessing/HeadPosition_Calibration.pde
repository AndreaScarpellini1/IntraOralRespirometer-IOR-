// Variable to store the countdown for baseline acquisition
float headposcountdown = 0; 

// Variable to store the current time during baseline acquisition
long time_current_headpos;
boolean headposacquired = false;

/**
 * Function to handle the timer for calibration acquisition.
 * This function calculates the calibration countdown and, upon completion,
 * processes the baseline data and resets necessary variables.
 */
void timer_for_headpos_calibration() {
  // Record the current time in milliseconds
  time_current_headpos = millis();
  
  // Calculate the baseline countdown in seconds (negative value indicates counting down)
  headposcountdown = -(start_time_headpos - time_current_headpos) / 1000;
  println(headposcountdown);
  // Check if the countdown has reached the threshold (10 seconds)
  if (headposcountdown > 4.99) { 
      DivisionForCalibration(roundcal);
      // Indicate that baseline has been acquired
      headposacquired = true;
      start_headpos = false;
      roundcal = 0;
      pitch_sum = 0;
      roll_sum=0;
      
  }
}

/**
 * Function to calculate the baseline values by dividing the accumulated
 * sensor data by the number of samples collected (round).
 * This function also logs the sampling frequency.
 *
 * @param round The number of samples collected during baseline acquisition.
 */
void DivisionForCalibration(int round) {
  // Calculate true head position angles 
  pitch_cal = pitch_sum / round;
  roll_cal = roll_sum / round;
}
