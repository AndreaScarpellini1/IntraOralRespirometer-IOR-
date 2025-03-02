/**
 * Function to write the headers of the CSV file.
 * This defines the column names for the output data.
 */
void writeHeaders() {
  // Write column headers to the CSV file
  output.println("Pressure_Rel,GyroX_Rel,GyroY_Rel,GyroZ_Rel,AccX_Rel,AccY_Rel,AccZ_Rel,Timestamp,Pressure_abs,HeartRate,Oxygen,Status,GyroX,GyroY,GyroZ,AccX,AccY,AccZ");
}

/**
 * Function to finalize the data writing process.
 * It ensures all data is saved and the file is properly closed.
 */
void finishDataWriting() {
  output.flush();  // Ensure any buffered data is written to the file
  output.close();  // Close the file to prevent data loss
  println("Data writing completed and file closed.");  // Log confirmation
}

/**
 * Function to generate a formatted timestamp.
 * The format is: YYYY-MM-DD_HH-MM-SS.
 *
 * @return A string containing the formatted timestamp.
 */
String getFormattedTimestamp() {
  // Format the timestamp using the current date and time
  return year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "_" 
         + nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
}

// Flag to indicate if the CSV headers have been written (only for the first call)
boolean isFirstCall_csv = true;

/**
 * Function to save the current data to a CSV file.
 *
 * @param timestamp The current timestamp for the data entry.
 * @param values An array of string values for absolute sensor data and status.
 * @param values_rel An array of float values for relative sensor data.
 */
void saveCurrentDataToCSV(long timestamp, String[] values, float[] values_rel) {
    // If this is the first call, perform any setup tasks (e.g., logging or initialization)
    if (isFirstCall_csv) {
        print("...");  // Log to indicate the first call
        isFirstCall_csv = false;  // Update the flag to prevent repeat execution
    }
    
    // Format the data as a CSV string by combining relative values, timestamp, and other data
    String csvData = values_rel[0] + "," + values_rel[1] + "," + values_rel[2] + "," + 
                     values_rel[3] + "," + values_rel[4] + "," + values_rel[5] + "," + 
                     values_rel[6] + "," + timestamp + "," + join(values, ",");
                     
    // Write the CSV string to the output file
    output.print(csvData);
    
    // Flush the output to ensure the data is written immediately
    output.flush();
}
