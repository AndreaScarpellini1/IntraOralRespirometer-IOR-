// ---------------------------------------------------------------------
// KalmanFilter.pde
// Place this in a separate tab in your Processing sketch
// ---------------------------------------------------------------------

// We keep some "state" variables around so the function can remember
// the previous step’s Kalman angle & uncertainty.
float kalmanAngleRoll  = 0.0;    // Current best estimate of Roll
float kalmanUncertRoll = 4.0;    // Some initial guess of Roll uncertainty (2^2)
float kalmanAnglePitch = 0.0;    // Current best estimate of Pitch
float kalmanUncertPitch= 4.0;    // Some initial guess of Pitch uncertainty (2^2)

// This will hold the temporary output of the 1D Kalman filter.
float[] kalman1DOutput = new float[2];

// *** Changed from 0.004 to 0.02 for 50 Hz (1/50 = 0.02 s) ***
final float DT = 0.02;  

// Process noise: you may tweak this if you have different sensor behavior
// (used when we "predict" the new angle).
final float GYRO_NOISE_STD_DEG_PER_S = 2.0;  // ~2 deg/s (from your Arduino code)
final float R_GYRO = GYRO_NOISE_STD_DEG_PER_S * GYRO_NOISE_STD_DEG_PER_S; // = 4

// Measurement noise: we assume the accelerometer angle measurement
// has about ~3 degrees of uncertainty. Adjust as needed.
final float MEAS_NOISE_STD = 3.0; // from your Arduino code
final float R_MEAS = MEAS_NOISE_STD * MEAS_NOISE_STD;  // = 9


//global angles  
float pitch =0;
float roll = 0;
/**
 * 1D Kalman update for angle + rate sensor:
 *
 * @param KalmanState           Current angle estimate (before update).
 * @param KalmanUncertainty     Current angle uncertainty (before update).
 * @param gyroRate              Angular rate from gyro (deg/s).
 * @param accAngle              Angle measurement from accelerometer (deg).
 */
void kalman1D(
  float KalmanState, 
  float KalmanUncertainty, 
  float gyroRate, 
  float accAngle
) {
  // 1) Predict step
  // Predict the angle after time DT, given the gyro rate:
  KalmanState = KalmanState + DT * gyroRate;

  // Increase the prediction uncertainty by the process noise:
  //   (the process noise is roughly (GYRO_NOISE_STD_DEG_PER_S^2) * (DT^2), 
  //    but for simplicity we use a scaled factor from your original code.)
  KalmanUncertainty = KalmanUncertainty + (DT * DT) * R_GYRO;

  // 2) Measurement Update
  // Kalman Gain = P / (P + R_meas)
  float KalmanGain = KalmanUncertainty / (KalmanUncertainty + R_MEAS);

  // Update angle with accelerometer measurement
  KalmanState = KalmanState + KalmanGain * (accAngle - KalmanState);

  // Update uncertainty
  KalmanUncertainty = (1.0 - KalmanGain) * KalmanUncertainty;

  // Store results so we can retrieve them
  kalman1DOutput[0] = KalmanState;
  kalman1DOutput[1] = KalmanUncertainty;
}

/**
 * computeAngles() - This function takes 6 sensor inputs and returns the
 *                   fused (Roll, Pitch) angles in degrees, using two 1D
 *                   Kalman filters (one for Roll, one for Pitch).
 *
 * @param accX   Acceleration along X axis   (g)
 * @param accY   Acceleration along Y axis   (g)
 * @param accZ   Acceleration along Z axis   (g)
 * @param gyroX  Gyroscope reading X         (deg/s or rad/s, depends on your usage)
 * @param gyroY  Gyroscope reading Y
 * @param gyroZ  Gyroscope reading Z
 * @return float[] { rollAngleDeg, pitchAngleDeg }
 */
float[] computeAngles(
  float accX, float accY, float accZ, 
  float gyroX, float gyroY, float gyroZ
) {
  // ---------------------------------------------------------
  // 1) Convert ACC readings into angles (in degrees).
  //    Similar to the Arduino code: 
  //        AngleRoll  = atan(AccY / sqrt(AccX^2 + AccZ^2)) * (180/PI);
  //        AnglePitch = atan(AccX / sqrt(AccY^2 + AccZ^2)) * (180/PI);
  //    Processing provides "atan2", so you can also consider using that.
  // ---------------------------------------------------------
  float angleRollAcc  = degrees(atan( accY / sqrt(accX*accX + accZ*accZ) ));
  float anglePitchAcc = degrees(atan( accX / sqrt(accY*accY + accZ*accZ) ));

  // ---------------------------------------------------------
  // 2) Convert gyro readings to deg/s if needed
  //    (In your original code, you divide by 70 if LSM6DS3 output was deg/s * 70)
  //    Adjust this factor to match your actual sensor’s sensitivity
  //    in your Processing environment.
  // ---------------------------------------------------------
  float rateRoll  = gyroX / 70.0;  
  float ratePitch = gyroY / 70.0;
  // float rateYaw   = gyroZ / 70.0; // not used for roll/pitch filtering

  // ---------------------------------------------------------
  // 3) Kalman for ROLL
  // ---------------------------------------------------------
  kalman1D(kalmanAngleRoll, kalmanUncertRoll, rateRoll, angleRollAcc);
  kalmanAngleRoll  = kalman1DOutput[0];
  kalmanUncertRoll = kalman1DOutput[1];

  // ---------------------------------------------------------
  // 4) Kalman for PITCH
  // ---------------------------------------------------------
  kalman1D(kalmanAnglePitch, kalmanUncertPitch, ratePitch, anglePitchAcc);
  kalmanAnglePitch  = kalman1DOutput[0];
  kalmanUncertPitch = kalman1DOutput[1];

  // Return the filtered angles in degrees
  return new float[]{ kalmanAngleRoll, kalmanAnglePitch };
}
