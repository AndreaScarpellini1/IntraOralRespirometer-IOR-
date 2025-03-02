#include <Wire.h>
#include "SPI.h"
#include <SparkFun_MS5803_I2C.h>
#include <SparkFun_Bio_Sensor_Hub_Library.h>
#include <bluefruit.h>
#include <Adafruit_LittleFS.h>
#include <InternalFileSystem.h>
#include "LSM6DS3.h"

//#####################################################################################################################
//BLE and data transmission Settings 
#define FAST  
#ifdef FAST
  #define CONN_PARAM  6         // connection interval *1.25mS, min 6
  #define DATA_NUM    244       // max 244
#else
  #define CONN_PARAM  16        // connection interval *1.25mS, default 16
  #define DATA_NUM    20        // default 20
#endif 
union unionData {               // Union for data type conversion
  uint32_t  dataBuff32[DATA_NUM/4];
  uint8_t   dataBuff8[DATA_NUM];
};
union unionData ud;
uint16_t conn;					        // connect handle
bool connectedFlag = false;     // set by connect callback
// Custum Service and Characteristic
// 55c40000-8682-4dd1-be0c-40588193b485 for example
#define customService_UUID(val) (const uint8_t[]) { \
    0x85, 0xB4, 0x93, 0x81, 0x58, 0x40, 0x0C, 0xBE, \
    0xD1, 0x4D, (uint8_t)(val & 0xff), (uint8_t)(val >> 8), 0x00, 0x00, 0xC4, 0x55 }

BLEService        customService        (customService_UUID(0x0000));
BLECharacteristic customCharacteristic   (customService_UUID(0x0030));

BLEDfu  bledfu;
BLEDis  bledis;
BLEUart bleuart;
BLEBas  blebas;
//#####################################################################################################################
//Sensor Settings
MS5803 sensor(ADDRESS_HIGH);
double pressure_baseline = 0;

// Reset pin, MFIO pin for PPG
int resPin = 1;
int mfioPin = 2;
// Takes address, reset pin, and MFIO pin.
SparkFun_Bio_Sensor_Hub bioHub(resPin, mfioPin); 

LSM6DS3 myIMU(I2C_MODE, 0x6A);
float GyroX = 0.0;
float GyroY= 0.0;
float GyroZ= 0.0;
float AccX = 0.0;
float AccY = 0.0;
float AccZ = 0.0;
bioData body;  

// Function prototypes
void setupBLE();
void startAdv();
void getValues();
void PressureSetup();
void updateBaseline();
void sensorsSetup();

bool isCollectingData = false; // for keeping track of state (collecting | not collecting);
bool setupok = false;

void setup() {
  delay(2000);
  Serial.begin(115200);
  delay(2000);

  // Pin initialization
  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE, OUTPUT); 

  digitalWrite(LED_RED, HIGH);
  digitalWrite(LED_GREEN, HIGH);
  digitalWrite(LED_BLUE, HIGH);
  // BLE 
  setupBLE();

  //Sensors
  sensorsSetup();

  
}

void loop(){
  if (connectedFlag) {  // If connected to the central
    if (setupok) {
      getValues();    
      delay(1);
      getValues();  
      //delay(5);
    } else {
      Serial.println("Setup not complete, skipping VALUES");
    }
  } else {
    Serial.println("Not connected, waiting for connection.");
  }

  if(!setupok && connectedFlag){
    sensorsSetup();
  }
}
//#############################################################################################################
// SENSOR FUNCTIONS
void getValues() {
  //commented in order to not lose time during sampling 
  // pressure sensor reading
  //float temperature_c = sensor.getTemperature(CELSIUS, ADC_512);
  //float temperature_f = sensor.getTemperature(FAHRENHEIT, ADC_512);
  //- pressure_baseline; The baseline is acquired direclty in processing
  //pressure_abs *= 100;
  //pressure_abs = (int)pressure_abs;
  //pressure_abs = (double)pressure_abs / 100;
  
  //Pressure sensor reading 
  float pressure_abs = sensor.getPressure(ADC_256); 
  //PPG sensor Reading
  body = bioHub.readBpm();    

  //Accelerometer sensor readings
  GyroX=myIMU.readFloatGyroX();
  GyroY=myIMU.readFloatGyroY();
  GyroZ=myIMU.readFloatGyroZ();
  AccX = myIMU.readFloatAccelX();
  AccY = myIMU.readFloatAccelY();
  AccZ = myIMU.readFloatAccelZ();

  // formatting data into single data structure to send over charateristic in string/byte array
  //original
  char dataPacket[128];
  memset(dataPacket, 0, sizeof(dataPacket));
  snprintf(dataPacket, sizeof(dataPacket), "V%.2f,%d,%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f", pressure_abs, body.heartRate, body.oxygen, body.status, GyroX, GyroY, GyroZ, AccX, AccY, AccZ);
  //
  //snprintf(dataPacket, sizeof(dataPacket), "V%.2f", pressure_abs);
  //try

  // Write the data to the BLE characteristic
        if (!customCharacteristic.notify((uint8_t*)dataPacket, sizeof(dataPacket) - 1)) {
      Serial.println("Failed to send notification");
    } 
  //for debugging but commented to save time 
  //  else {
  //Serial.println("Sensors Values Sent");
  //  }
  //bleuart.print("Data Packet: "); // sends data packet to BlueFruit LE app
  //bleuart.println(dataPacket);
}

void PressureSetup() {
  
  //digitalWrite(LED_RED, LOW);
  Wire.begin();
  sensor.reset();
  sensor.begin();
  Serial.println("Pressure setup okay.");
  // int numberOfSamples = 120;
  // unsigned long previousMillis = 0; // Stores the last time the update occurred
  // const long interval = 1000 / 12; // Interval at which to sample (1000ms/12) // 100hZ
  // unsigned long countdownStart = millis();
  // int countdownTime = 10;
  // char dataPacket[128]; // to send base line to ui
  // memset(dataPacket, 0, sizeof(dataPacket));
  
  // for (int index = 0; index < numberOfSamples;) { // Remove the increment from here
  //   unsigned long currentMillis = millis();
  //   // update countdown every  1 sec
  //   if (currentMillis - countdownStart >= 1000) { 
  //     countdownStart = currentMillis;
  //     countdownTime--;
  //     Serial.print(countdownTime);
  //     Serial.println("seconds until baseline aquired");
  //   }
  //   // sample pressure at 12hz intervals
  //   if (currentMillis - previousMillis >= interval) { 
  //     previousMillis = currentMillis; // Save the last time you sampled the pressure
  //     pressure_baseline += sensor.getPressure(ADC_4096);  // Sample the pressure
  //     bleuart.println(pressure_baseline);
  //     snprintf(dataPacket, sizeof(dataPacket), "B%.2f", pressure_baseline);
  //     // Write the data to the BLE characteristic
  //     if (!customCharacteristic.notify((uint8_t*)dataPacket, sizeof(dataPacket) - 1)) {
  //     Serial.println("Failed to send notification");
  //   } else {
  //     Serial.println("A baseline Value has been sent");
  //   }

  //     index++; 
  //   } 
  // }
  // pressure_baseline /= numberOfSamples;

  // bleuart.println("Baseline has been acquired (100Hz): ");
  // bleuart.println(pressure_baseline);
  // snprintf(dataPacket, sizeof(dataPacket), "B%.2f", pressure_baseline);
  // // Write the data to the BLE characteristic
  // if (!customCharacteristic.notify((uint8_t*)dataPacket, sizeof(dataPacket) - 1)) {
  //     Serial.println("Failed to send notification");
  //   } else {
  //     Serial.println("The Final Baseline Value has been sent.");
  //   }
  // Serial.print("Baseline has been acquired (100Hz): ");
  // Serial.println(pressure_baseline);
  // Serial.println("----------------------------------------------------------------------------------");
  // digitalWrite(LED_RED, HIGH);
  // Serial.println("Sensor Setup Started.");
}

void ppgSetup(){
  int result = bioHub.begin();
  if (result == 0) 
    Serial.println("Sensor started!");
  else
    Serial.println("Could not communicate with the sensor!");
 
  Serial.println("Configuring Sensor...."); 
  int error = bioHub.configBpm(MODE_TWO); // Configuring just the BPM settings. 
  if(error == 0){                         // Zero errors
    Serial.println("Sensor configured.");
  }
  else {
    Serial.println("Error configuring sensor.");
    Serial.print("Error: "); 
    Serial.println(error); 
  }
}

void accSetup(){
  if (myIMU.begin() != 0) {
    Serial.println("Device error");
  }
  Serial.println("Accelerometer okay!");
}

void sensorsSetup(){
  Serial.println("Sensor Setup Started.");
  Serial.println("Pressure Sensor...");
  PressureSetup();
  Serial.println("PPG...");
  ppgSetup();
  Serial.println("Accelerometer...");
  accSetup();
  Serial.println("Sensor Setup Ended");
  setupok = true;
}


//#############################################################################################################
// BLE FUNCTIONS
void connect_callback(uint16_t conn_handle)
{
  connectedFlag = false;
  
  Serial.print("【connect_callback】 conn_Handle : ");
  Serial.println(conn_handle, HEX);
  conn = conn_handle;

  // Get the reference to current connection
  BLEConnection* connection = Bluefruit.Connection(conn_handle);

  // request to chamge parameters
#ifdef FAST
  connection->requestPHY();                              // PHY 2MHz (2Mbit/sec moduration) 1 --> 2
  delay(1000);                                           // delay a bit for request to complete
  //Serial.println(connection->getPHY());
  connection->requestDataLengthUpdate();                 // data length  27 --> 251
#endif  
  connection->requestMtuExchange(DATA_NUM + 3);          // MTU 23 --> 247
  connection->requestConnectionParameter(CONN_PARAM);    // connection interval (*1.25mS)   
  delay(1000);                                           // delay a bit for request to complete  
  Serial.println();
  Serial.print("PHY ----------> "); Serial.println(connection->getPHY());
  Serial.print("Data length --> "); Serial.println(connection->getDataLength());
  Serial.print("MTU ----------> "); Serial.println(connection->getMtu());
  Serial.print("Interval -----> "); Serial.println(connection->getConnectionInterval());      

  char central_name[32] = { 0 };
  connection->getPeerName(central_name, sizeof(central_name));
  Serial.print("【connect_callback】 Connected to ");
  Serial.println(central_name);

  connectedFlag = true;
}

void disconnect_callback(uint16_t conn_handle, uint8_t reason)
{
  (void) conn_handle;
  (void) reason;

  Serial.print("【disconnect_callback】 reason = 0x");
  Serial.println(reason, HEX);
  connectedFlag = false;
  setupok = false;
}

void setupBLE()
{

  Serial.print("Start BLUETOOTH Initialization");
  // Initialization of Bruefruit class
  Bluefruit.configPrphBandwidth(BANDWIDTH_MAX);
  Bluefruit.configUuid128Count(15);

  Bluefruit.begin();
  #ifdef FAST  
    Bluefruit.setTxPower(0);    // Central is close, 0dBm
  #else
    Bluefruit.setTxPower(4);    // default +4dBm
  #endif  
  Bluefruit.setConnLedInterval(50);
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

  // Custom Service Settings
  customService.begin();
  customCharacteristic.setProperties(CHR_PROPS_NOTIFY);
  customCharacteristic.setFixedLen(DATA_NUM);
  customCharacteristic.begin();

  // Advertisement Settings
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  Bluefruit.Advertising.addService(customService);
  Bluefruit.ScanResponse.addName();
  
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setIntervalMS(20, 153);     // fast mode 20mS, slow mode 153mS
  Bluefruit.Advertising.setFastTimeout(30);         // fast mode 30 sec
  Bluefruit.Advertising.start(0);                   // 0 = Don't stop advertising after n seconds

  Serial.println("End of BLUETOOTH initialization");

  // Connecting to Central
  Serial.println("Connecting to Central ................");
  while(!Bluefruit.connected()) {
    Serial.print("."); delay(100);
  }
  Serial.println();
  Serial.println("Connected to Central");
  delay(5000);
}
//#############################################################################################################


