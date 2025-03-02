// ----------------------------------------------------
// BreathingRateCalculator.pde
// ----------------------------------------------------
// Place this code in a separate tab. In your main tab,
// simply call updateBreathingRate(filteredPressure, timestamp)
// to update the global breathingRateBPM in real time.

// ----------------------------------------------------
// CONFIGURABLE GLOBALS
// ----------------------------------------------------

// 1) Low-pass filter parameter
float alpha = 0.9;         // 0 < alpha <= 1 (smaller = stronger smoothing)
float smoothedPressure = 0; // holds the filtered signal

// 2) Threshold-based breath detection
float threshold = 0.3;     // crossing above this triggers a "breath event"
float prevPressure = 0;    // store the *filtered* previous pressure sample
float prevCrossingTime = 0; // timestamp (ms) of the last detected crossing

// 3) Rolling average for BPM
final int NUM_BREATHS_TO_AVERAGE = 2;
float[] recentBPMs = new float[NUM_BREATHS_TO_AVERAGE];
int bpmIndex = 0;

// 4) The GLOBAL breathing rate variable (updated in real time)
float breathingRateBPM = 0; 


// ----------------------------------------------------
// INITIALIZATION (optional helper, if you want one)
// ----------------------------------------------------
// Call this once in your setup() to initialize arrays & timers
void initBreathingRateCalculator() {
  prevCrossingTime = millis();  
  for (int i = 0; i < NUM_BREATHS_TO_AVERAGE; i++) {
    recentBPMs[i] = 0;
  }
  // Optionally set smoothedPressure to the initial reading
  // so we don't get a big jump on the first sample.
}


// ----------------------------------------------------
// LOW-PASS FILTER
// ----------------------------------------------------
// Call this to smooth out high-frequency noise from your sensor
float lowPassFilter(float rawValue) {
  smoothedPressure = alpha * rawValue + (1 - alpha) * smoothedPressure;
  return smoothedPressure;
}


// ----------------------------------------------------
// updateBreathingRate
// ----------------------------------------------------
// 1) Applies threshold-based detection to find breath starts
// 2) Ignores implausibly short intervals
// 3) Updates a rolling average of BPM
// ----------------------------------------------------
// REQUIRED INPUTS:
//    currentPressure : your *filtered* (or raw) sensor value
//    currentTimeMs   : timestamp in milliseconds (e.g., millis())
//
// GLOBAL OUTPUT:
//    breathingRateBPM (float)
void updateBreathingRate(float currentPressure, float currentTimeMs) {
  
  // Detect an upward crossing over 'threshold'
  if (currentPressure >= threshold && prevPressure < threshold) {
    
    // Calculate time difference in seconds
    float deltaTimeSec = (currentTimeMs - prevCrossingTime) / 1000.0;

    // Ignore intervals that are too short to be a real breath (e.g., <0.3 s => >200 BPM)
    if (deltaTimeSec > 0.3) {
      float currentBPM = 60.0 / deltaTimeSec;

      // Update rolling array
      recentBPMs[bpmIndex] = currentBPM;
      bpmIndex = (bpmIndex + 1) % NUM_BREATHS_TO_AVERAGE;

      // Compute average BPM
      float sum = 0;
      for (int i = 0; i < NUM_BREATHS_TO_AVERAGE; i++) {
        sum += recentBPMs[i];
      }
      breathingRateBPM = sum / NUM_BREATHS_TO_AVERAGE;
      breathingRateBPM = breathingRateBPM/2;
      // Update crossing time
      prevCrossingTime = currentTimeMs;
    }
  }

  // Save current pressure for next iteration
  prevPressure = currentPressure;
}
