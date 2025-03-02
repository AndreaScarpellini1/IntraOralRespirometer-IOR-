// Variable to store the countdown for baseline acquisition
float baselinecountdown = 0; 

// Variable to store the current time during baseline acquisition
long time_current_baseline;

/**
 * Function to handle the timer for baseline acquisition.
 * This function calculates the baseline countdown and, upon completion,
 * processes the baseline data and resets necessary variables.
 */
void timer_for_baseline() {
  // Record the current time in milliseconds
  time_current_baseline = millis();
  
  // Calculate the baseline countdown in seconds (negative value indicates counting down)
  baselinecountdown = -(start_time_baseline - time_current_baseline) / 1000;
  
  // Check if the countdown has reached the threshold (10 seconds)
  if (baselinecountdown > 3.99) { 
      // Indicate that baseline has been acquired
      baseline_acquired = true;

      // Process the accumulated data to calculate baseline values
      DivisionForBaseline(round);

      // Reset flags and variables for next baseline measurement
      start_baseline = false;
      Pressure_sum = 0;
      AccX_sum = 0;
      AccY_sum = 0;
      AccZ_sum = 0;
      GyroX_sum = 0;
      GyroY_sum = 0;
      GyroZ_sum = 0;
      round = 0;
  }
}

/**
 * Function to calculate the baseline values by dividing the accumulated
 * sensor data by the number of samples collected (round).
 * This function also logs the sampling frequency.
 *
 * @param round The number of samples collected during baseline acquisition.
 */
void DivisionForBaseline(int round) {
  // Log the sampling frequency, calculated as the number of samples per 10 seconds
  println("Sampling Frequency");
  println(round / 10);
  
  // Calculate average baseline values for each sensor by dividing the sums by the number of samples
  Pressure_bas = Pressure_sum / round;
  AccX_bas = AccX_sum / round;
  AccY_bas = AccY_sum / round;
  AccZ_bas = AccZ_sum / round;
  GyroX_bas = GyroX_sum / round;
  GyroY_bas = GyroY_sum / round;
  GyroZ_bas = GyroZ_sum / round;
}
