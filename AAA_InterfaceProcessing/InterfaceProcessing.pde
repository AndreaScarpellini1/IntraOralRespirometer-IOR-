import processing.serial.*;
import java.io.PrintWriter;  // Import for file writing
import org.gicentre.utils.stat.*;
import org.gicentre.utils.stat.AbstractChart;


Serial myPort;

int currentIndex = 0;
boolean isFull = false;
boolean baseline_acquired = false;
boolean start_baseline = false;
PrintWriter output;
long timeref = 0;


//Variables used for baseline 
float [] values_rel;
float Pressure_bas = 0;
float AccX_bas = 0;
float AccY_bas = 0;
float AccZ_bas=0;
float GyroX_bas = 0;
float GyroY_bas= 0;
float GyroZ_bas=0;
float Pressure_sum = 0;
float AccX_sum = 0;
float AccY_sum = 0;
float AccZ_sum=0;
float GyroX_sum = 0;
float GyroY_sum = 0;
float GyroZ_sum=0;
int round =0;
float HR = 0;
float oxy = 0;
float pitch_sum = 0; 
float roll_sum = 0;
float pitch_cal = 0;
float roll_cal =0; 

// Variables for continous baseline 
int BUFFER_SIZE = 100;
float[] buffer = new float[BUFFER_SIZE];   // Circular buffer to hold the last 100 pressure values
int bufferIndex = 0;                       // Index to keep track of the current position in the buffer
int numValues = 0;                         // Number of values currently in the buffer (up to BUFFER_SIZE)
float sum = 0;                             // Sum of the values currently in the buffer
float CB_pressure;
int roundcal = 0 ;
/**
 * Setup function: Initializes the program, serial port, and output file.
 * Also sets up the plotting environment and baseline variables.
 */
void setup() {
    size(1600, 1000);                                  // Set canvas size for visualizations
    values_rel = new float[] {0, 0, 0, 0, 0, 0, 0, 0}; // Initialize array for adjusted values
    String[] portList = Serial.list();                 // Get list of available serial ports
    printArray(Serial.list());                         // Print the available serial ports for debugging
    
    if (portList.length > 1 || portList.length == 1) {
        try {
            myPort = new Serial(this, portList[1], 250000); // Open the 7th serial port with a baud rate of 250,000
            println("Connected to " + portList[1]);
        } catch (Exception e) {
            println("Error opening serial port " + portList[0] + ": " + e.getMessage());
            return; // Exit if serial connection fails
        }
    } else {
        println("Not enough serial ports.");
        return; // Exit if no serial ports are available
    }

    String timestamp = getFormattedTimestamp();          // Generate a timestamp for the output file --> {CSVSaving TAB} 
    output = createWriter("data_" + timestamp + ".csv"); // Create a CSV file for saving data
    writeHeaders();                                      // Write headers to the CSV file --> {CSVSaving TAB}
    timeref = System.currentTimeMillis();                // Set reference time for the program
    
    // Initialize plots for visualizing data
    //graph_setup_breathing();
    //graph_setup_breathingSIGN();
    CB_graph_setup_breathing();
}

/**
 * Draw function: Continuously executes while the program is running.
 * Updates the visualization and manages baseline acquisition.
 */
void draw() {
    drawBackground();         // Draw the background of the visualization
    if (start_baseline) {
        timer_for_baseline(); // Manage baseline acquisition if the process is started --> {Baseline TAB}
    }
    if (start_headpos & baseline_acquired){
        timer_for_headpos_calibration();
     }
}

/**
 * Handles incoming serial data from the connected device.
 * Processes sensor data when a complete packet is received.
 * @param myPort The serial port object used for communication.
 */
void serialEvent(Serial myPort) {
    String tempVal = myPort.readStringUntil('\n');// Read serial data until a newline character is encountered
    
    if (tempVal != null) {
        if (tempVal.startsWith("V")) {            // Process sensor data if it starts with "V"
            processSensorData(tempVal); 
            if (!baseline_acquired) {
                println(tempVal);                 // Print raw sensor data for debugging if baseline is not yet acquired
            }
        }
    }
}

boolean isFirstCall_dc = true;
/**
 * Processes incoming sensor data, computes baseline, adjusts values, and saves data.
 * Handles both raw and adjusted data based on baseline status.
 * @param data The raw data string received from the serial device.
 */
void processSensorData(String data) {
    if (isFirstCall_dc) {                            // Debugging information for the first call
        isFirstCall_csv = true;
        //println();
        //print("DC");
        isFirstCall_dc = false;                      // Reset the flag after the first call
    }
    String[] values = split(data.substring(1), ','); // Split the string data into individual values

    if (values.length == 10) {                       // Ensure the data is complete (10 values expected)
        if (start_baseline) {                        // If baseline acquisition is active
            round++;
            Pressure_sum += float(values[0]);        // Accumulate pressure data
            AccX_sum += float(values[7]);
            AccY_sum += float(values[8]);
            AccZ_sum += float(values[9]);
            GyroX_sum += float(values[4]) / 70;      // Apply conversion factor to gyroscope data
            GyroY_sum += float(values[5]) / 70;
            GyroZ_sum += float(values[6]) / 70;
        }

        // Update heart rate and oxygenation values
        HR = float(values[1]);
        oxy = float(values[2]);

        if (baseline_acquired) {                               // If baseline calculation is complete
            values_rel[0] = float(values[0]) - Pressure_bas;   // Adjust pressure
            values_rel[1] = float(values[4]) / 70 - GyroX_bas; // Adjust gyroscope X
            values_rel[2] = float(values[5]) / 70 - GyroY_bas; // Adjust gyroscope Y
            values_rel[3] = float(values[6]) / 70 - GyroZ_bas; // Adjust gyroscope Z
            values_rel[4] = float(values[7]);                  // Accelerometer values remain unchanged
            values_rel[5] = float(values[8]);
            values_rel[6] = float(values[9]);

            long currentTime = System.currentTimeMillis() - timeref; // Calculate elapsed time
            saveCurrentDataToCSV(currentTime, values, values_rel);   // Save adjusted data to CSV --> {CSV Saving TAB}
            extractPressureAndTime(currentTime, values_rel[0]);      // Process pressure data for plotting
           
            float[] angles = computeAngles( values_rel[4], values_rel[5],  values_rel[6],  values_rel[1], values_rel[2], values_rel[3]);
            //'/println("Filtered Roll = " + angles[0] + " deg, Pitch = " + angles[1] + " deg");
            pitch = angles[1];
            roll = angles[0];
            println(pitch,"-",roll,"||",pitch_cal,"-",roll_cal);
            if(start_headpos){
              println(pitch_sum,"-",roll_sum,"||",pitch_cal,"-",roll_cal);
              roundcal++;
              pitch_sum += pitch; 
              roll_sum += roll;
            }
            
            
            
            
        } else if (!start_baseline) {
            long currentTime = System.currentTimeMillis() - timeref; // Save unadjusted data
            saveCurrentDataToCSV(currentTime, values, values_rel);
        }
    }
}

/**
 * Extracts pressure and time values for plotting and breathing rate calculation.
 * @param timestamp The timestamp of the current data point.
 * @param pressure The pressure value.
 */
void extractPressureAndTime(long timestamp, float pressure) {
    CB_pressure = continousBaseline(pressure);            // Compute zero-centered pressure using a continuous baseline
    //println(CB_pressure);                               // Debugging: Print zero-centered pressure
    CB_graph_serialEvent_lungs(CB_pressure, timestamp);   // Update centered graph
    updateBreathingRate(CB_pressure, timestamp);          // Perform feature calculations --> FEature Calculation TAB
}

/**
 * Computes a continuous baseline and returns the zero-centered pressure value.
 * Uses a circular buffer to manage baseline values.
 * @param pressure The current pressure value.
 * @return The zero-centered pressure value.
 */
float continousBaseline(float pressure) {
    if (numValues == BUFFER_SIZE) { // If buffer is full, remove the oldest value
        sum -= buffer[bufferIndex];
    } else {
        numValues++;                // Increment the count of values in the buffer
    }

    sum += pressure;                // Add new pressure value to the sum
    buffer[bufferIndex] = pressure; // Store the new value in the buffer

    bufferIndex = (bufferIndex + 1) % BUFFER_SIZE;     // Update buffer index (circular buffer)

    float meanValue = sum / numValues;                 // Calculate mean value (baseline)
    float zeroCenteredPressure = pressure - meanValue; // Calculate zero-centered pressure

    //println("Sum: " + sum + " | Pressure: " + pressure + " | Count: " + numValues +
    //       " | Zero-Centered Pressure: " + zeroCenteredPressure); // Debugging information

    return zeroCenteredPressure;
}
