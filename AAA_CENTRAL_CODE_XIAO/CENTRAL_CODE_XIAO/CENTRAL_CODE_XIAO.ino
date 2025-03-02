#include <Wire.h>
#include <SPI.h>
#include <bluefruit.h>

//***********************************************************************************************************
#define FAST                    // compiler option : parameters setting for fast transmission
                                // if default setting, comment out
#define MAX_PACKET  200         // maximum number of data packets allowed by FIFO
#define FIFO_SIZE DATA_NUM * MAX_PACKET  // FIFO size, push and pop on a packet-by-packet basis
#ifdef FAST
  #define DATA_NUM  244         // number of bytes in data packet
#else
  #define DATA_NUM  20          // number of bytes in data packet
#endif
//***********************************************************************************************************

union unionData {               // Union for data type conversion
  uint32_t  dataBuff32[DATA_NUM/4];
  uint8_t   dataBuff8[DATA_NUM];
};
union unionData ud; 

uint16_t conn;                  // connect handle
bool notifyFlag = false;        // set by notify callback
bool connectedFlag = false;     // set by connect callback

// Custom Service and Characteristic
// 55c40000-8682-4dd1-be0c-40588193b485 for example
#define customService_UUID(val) (const uint8_t[]) { \
    0x85, 0xB4, 0x93, 0x81, 0x58, 0x40, 0x0C, 0xBE, \
    0xD1, 0x4D, (uint8_t)(val & 0xff), (uint8_t)(val >> 8), 0x00, 0x00, 0xC4, 0x55 }

BLEClientService        customService       (customService_UUID(0x0000));
BLEClientCharacteristic customCharacteristic  (customService_UUID(0x0030));

unsigned long startTime = 0;
unsigned long packetCount = 0;
unsigned long totalDataReceived = 0; // in bytes
const unsigned long interval = 2000; // 10 seconds

void setup() {
    delay(2000);
    Serial.begin(115200);
    delay(2000);

    // LED initialization
    pinMode(LED_RED, OUTPUT);
    pinMode(LED_GREEN, OUTPUT);
    pinMode(LED_BLUE, OUTPUT);

    Serial.println("------ Central Board ------");
    Serial.println("Start Initialization");
    
    // Initialization of Bluefruit
    Bluefruit.configCentralBandwidth(BANDWIDTH_MAX);  
    Bluefruit.begin(0, 1);
    Bluefruit.setName("XIAO BLE Central");

    // Custom Service Settings
    customService.begin();
    customCharacteristic.setNotifyCallback(data_notify_callback);
    customCharacteristic.begin();
    

    // Blue LED blinking interval setting
    Bluefruit.setConnLedInterval(100);

    // Callbacks
    Bluefruit.Central.setDisconnectCallback(disconnect_callback);
    Bluefruit.Central.setConnectCallback(connect_callback);
    
    // Scanner settings
    Bluefruit.Scanner.setRxCallback(scan_callback);
    Bluefruit.Scanner.restartOnDisconnect(true);
    Bluefruit.Scanner.setIntervalMS(100, 50);    
    Bluefruit.Scanner.filterUuid(customService.uuid);
    Bluefruit.Scanner.useActiveScan(false);
    Bluefruit.Scanner.start(0);                  

    Serial.println("End of initialization");
    startTime = millis();
}

void loop() {
    unsigned long currentTime = millis();

    if (currentTime - startTime >= interval) {
        // Calculate the sampling rate (packets per second)
        float samplingRate = (float)packetCount / (interval / 1000.0);

        // Calculate the bit rate (bits per second)
        float bitRate = (totalDataReceived * 8) / (interval / 1000.0);

        Serial.print("Sampling Rate: ");
        Serial.print(samplingRate);
        Serial.println(" packets/second");

        Serial.print("Bit Rate: ");
        Serial.print(bitRate);
        Serial.println(" bits/second");

        // Reset counters and timer
        packetCount = 0;
        totalDataReceived = 0;
        startTime = millis();
    }
}

//*************************************************************************************************************************************************************************************
// THE CONNECTION IS ESTABLISHED 
//*************************************************************************************************************************************************************************************
// FUNCTIONS FOR CONNECTION with the peripheral 
void scan_callback(ble_gap_evt_adv_report_t* report)
{
  Bluefruit.Central.connect(report);
}

void connect_callback(uint16_t conn_handle){
    conn = conn_handle;
    connectedFlag = false;
    if (!customService.discover(conn_handle))
    {
        Serial.println("【connect_callback】 Service not found, disconnecting!");
        Bluefruit.disconnect(conn_handle);
        return;
    }
    if (!customCharacteristic.discover())
    {
        Serial.println("【connect_callback】 Characteristic not found, disconnecting!");
        Bluefruit.disconnect(conn_handle);
        return;
    }

    // After discovering the characteristic, enable notifications
    if (!customCharacteristic.enableNotify()) {
        Serial.println("Failed to enable notifications");
    } else {
        Serial.println("Notifications enabled");
    }

    connectedFlag = true;
    Serial.println("【connect_callback】connected");
}

void disconnect_callback(uint16_t conn_handle, uint8_t reason){
  (void) conn_handle;
  (void) reason;

  Serial.print("【disconnect_callback】 Disconnected, reason = 0x");
  Serial.println(reason, HEX);
  connectedFlag = false;
}
//*************************************************************************************************************************************************************************************
//*************************************************************************************************************************************************************************************

// Callback when new data is available on the characteristic
void data_notify_callback(BLEClientCharacteristic* chr, uint8_t* data, uint16_t len) {
    // Count the packets and accumulate the total data received
    packetCount++;
    totalDataReceived += len;
    
    // Process the received data
    sendDataThroughSerial((char*)data, len);
}

// Function to send data through the serial port
void sendDataThroughSerial(char* data, uint16_t len) {
    Serial.print(data);  // This sends the string up to the null terminator
    Serial.println();
}
