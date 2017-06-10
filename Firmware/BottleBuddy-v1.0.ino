// This #include statement was automatically added by the Particle IDE.
#include <OneWire.h>
#include "DS18.h"

// This #include statement was automatically added by the Particle IDE.
#include "SparkFunMMA8452Q.h"

// This #include statement was automatically added by the Particle IDE.
#include <neopixel.h>

// This #include statement was automatically added by the Particle IDE.
#include <Adafruit_PN532.h>
// See: https://github.com/adafruit/Adafruit-PN532/blob/master/examples/iso14443a_uid/iso14443a_uid.pde

// This #include statement was automatically added by the Particle IDE.
#include "HX711.h"
// See https://github.com/bogde/HX711/blob/master/README.md

// Pin out...
//                  V1.0        V1.1
// NFC PN532 device.
// NFC I2C SDA      D0          D0
// NFC I2C SCL      D1          D1
// NFC IRQ          D2          D5
// NFC RSTO         D3          D7
// NFC RSTPDN       D6          D4  

// HX711 Load Cell
// HX711 Data       D4          D2
// HX711 CLK        D5          D3

// Additional
// VIN Sensor       A1          A1
// Red LED          A0          
// Blue LED         A5          
// Reverse LED                  A5

// NeoPixels        -- (was A4) D6
// Buzzer           A4          A4
// Accel IRQ        WKP         WKP

// NeoPizel Power               DAC
// DS18B20 DQ       A3          A3
// Keep Awake       A2          A2

String applicationVersion = "0.34";

// Run WiFi network stuff on a seperate thread.
SYSTEM_THREAD(ENABLED);

// Don't connect unless we need to.
SYSTEM_MODE(SEMI_AUTOMATIC);

//STARTUP(System.enableFeature(FEATURE_RETAINED_MEMORY));

// Memory Mapping
// 
// EEPROM_VERSION_ADDRESS = 0x00;     // Version of the eeprom mapping
// Tare value for the load cell
// TARE_ADDRESS = 0x04;
// What mode we are in (spot weight, continious, ....)
// DEVICE_MODE_ADDRESS = 0x08;

// Tracked weight of the object on the scales.
double currentWeight = 0.0f;
String currentBottleId = "";

// parameter "gain" is ommited; the default value 128 is used by the library
#define SCALE_DATA_PIN D4
#define SCALE_CLOCK_PIN D5
HX711 scale(SCALE_DATA_PIN, SCALE_CLOCK_PIN);

// Raw tare for the load cell.
// Not, a zero value for empty scale (see emptyWeight)
// Should be set on an empty scale
// when powered up. 
long tareValue = 0;

// NFC Set-up
#define NFC_RESET_PIN D3
#define NFC_IRQ_PIN D2
#define NFC_RSTPDN_PIN D6
Adafruit_PN532 nfc(NFC_IRQ_PIN, NFC_RESET_PIN); // I2C Mode
//Adafruit_PN532 nfc(NFC_IRQ_PIN, NFC_RSTPDN_PIN); // I2C Mode

// NeoPixel Setup
//#define PIXEL_PIN A4
//#define PIXEL_COUNT 24
//#define PIXEL_TYPE WS2812B

//Adafruit_NeoPixel strip(PIXEL_COUNT, PIXEL_PIN, PIXEL_TYPE);

// ================================
// Acceleromiter for tap detection
// Create an MMA8452Q object
// Default constructor, SA0 pin is HIGH (addr: 0x1D)
// eBay board has SA0 1k to GND addr: 0x1C
// pulling high = 3mA current consumption baseline.
MMA8452Q accel(MMA8452Q_ADD_SA0_0); 

// ================================
// Environmental
// BME280....
bool hasEnvironmentalSensor = true;
double temperature = 0;
double humidity = 0;
double pressure = 0;

// Temperature from the DS18B20
bool hasValidTemperature = false;
double oneWireTemperature = 0;

DS18 sensor(A3);

// ================================
// Battery monitor
#define VIN_MONITOR_PIN A1
// VIN in terms of ADC bits.
int vin = 0;

// ================================
// LEDs
#define LED_1_PIN A5
#define LED_2_PIN A0
//int led1 = A5;
//int led2 = A0;

// ================================
bool checkBottle = false;
Timer timer(60000, timerTick);

String senml;

// ================================
// Power management
#define KEEP_AWAKE_PIN A2
unsigned long waketime = 0;
bool measuring = false;
bool firstLoop = true;

// measurement variables
double bottleWeight = 0;
double emptyWeight = 0;
// Difference between the bottle weight and the empty weight
double measuredBottleWeight = 0;
bool waitForItemToBeRemoved = false;

bool showDebug = false;

// ================================
// Buzzer
#define BUZZER_PIN A4

int volume = 128;

// Optimum frequency for the Piezo is 4.5kHz
// Farnell 2309143
// Multicomp: MCKPT-G1210-3916
int frequency = 4000;

// ================================
// retained variables
// 

// ========================================================================================
// Setup
// ========================================================================================

void setup() {
    // Reserve 1024 characters for the senml fields
    // Max is 255 for publish
    // However we may accidentally go over that
    // without realising it.
    senml.reserve(1024);
    
    // TODO: Check/Transform as needed.
    long eepromVersion = 1;
    EEPROM.put(0x00, eepromVersion);
    
    Serial.begin(38400);
    Serial.println("Bottle buddy initializing.");
    
    // Try to read the interrupt source early on
    // otherwise it gets lost.
	Wire.begin(); // Initialize I2C
    byte interruptSource = accel.readInterruptSource(); 
    
    setupGPIO();
    
    setupParticleFunctions();

    setupScale();
    
    setupNFCReader();
    
    setupNeoPixels();
    
    setupAccelerometer(interruptSource);
    
    // record the time we woke so we 
    // can force a sleep if no activity
    resetWakeTime();

    // High power mode.
    // Take measurements of the bottle on 
    // timed intervales.
    
    // When in keep awake the timer will cause
    // occasional environmnet checks that would normally
    // happen with the wake from deep sleep
	timer.start();
  
    // And we're ready to go....
    Serial.println("Bottle buddy initialized. " + applicationVersion);
}

void setupGPIO() {
    pinMode(VIN_MONITOR_PIN, INPUT); // Actually analog.
    pinMode(LED_1_PIN, OUTPUT);
    pinMode(LED_2_PIN, OUTPUT);
    pinMode(KEEP_AWAKE_PIN, INPUT_PULLDOWN);
    pinMode(BUZZER_PIN, OUTPUT);
    pinMode(NFC_RSTPDN_PIN, OUTPUT);
    
    // Debug LED (RST on V1.1 PCB so need to becareful)
    pinMode(D7, OUTPUT);
    
    digitalWrite(LED_1_PIN, HIGH);
    digitalWrite(LED_2_PIN, LOW);
}

void setupParticleFunctions() {
    Particle.function("readRfid", readRfid);
    Particle.function("readWeight", readWeight);
    Particle.function("cal", calibrate);
    Particle.function("tare", tare);
}

void setupScale() {
    // this value is obtained by calibrating the scale with known weights; see the README for details
    scale.set_scale(400.8f);
    
    // Need to tare the scales when no bottle is present.
    // This can be done manually via the Particle function
    // or we could do it on bottle removed.
    // Might not be ideal here if restarting with an object on the scales.
    //scale.tare();	
    
    long value;
    EEPROM.get(0x04, value);
    if(value == 0xFFFFFFFF) {
        // EEPROM was empty
        tareValue = 0;
        publishStatus("No tare stored in EEPROM. Please tare scales.");
    } else {
        tareValue = value;
        publishStatus("Tare: " + String(tareValue));
    }
    
    Serial.println("Tare value: " + String(tareValue));
    
    // tareValue is a EEPROM stored value and set via 
    // a particle function.
    scale.set_offset(tareValue);
}

void setupNFCReader() {
    digitalWrite(NFC_RSTPDN_PIN, HIGH);
    delay(250);
    
    // Setup the NFC Reader
	nfc.begin();
	uint32_t versiondata = nfc.getFirmwareVersion();
	Serial.println("NFC Version: " + String(versiondata));

	// Set the max number of retry attempts to read from a card
    // This prevents us from waiting forever for a card, which is
    // the default behaviour of the PN532.
    nfc.setPassiveActivationRetries(0x10);
  
    // configure board to read RFID tags
    nfc.SAMConfig();
}

void setupNeoPixels() {
    // NeoPixel initialize
    /*
    strip.begin();
    strip.show(); // Initialize all pixels to 'off'
    */
}

void setupAccelerometer(byte interruptSource) {
    	// Initialize the accelerometer with begin():
	// begin can take two parameters: full-scale range, and output data rate (ODR).
	// Full-scale range can be: SCALE_2G, SCALE_4G, or SCALE_8G (2, 4, or 8g)
	// ODR can be: ODR_800, ODR_400, ODR_200, ODR_100, ODR_50, ODR_12, ODR_6 or ODR_1
    if (accel.begin(SCALE_2G, ODR_1) == 0) {
        connectToTheCloud();
        Particle.publish("status", "Failed to initialize accel.");
    } else {
    
        setupAccelerometerTaps();
        
        // Check for bit 3 of the interrupt being set
        // to indicate we were woken by a tap
        // NB: Cached value from before begin.
        //byte interruptSource = accel.readInterruptSource(); 
        if (interruptSource && 0x08 == 0x08) {
            // Interrupt was caused by a tap.
            wakeTune();
            // Woken by a tap, so we are measuring.
            measuring = true;
        } else if (interruptSource > 0) {
            // Interrupt caused by something other than a tap
            doubleBeep();
            connectToTheCloud();
            Particle.publish("status", "Woken by a something other than a tap, Int: " + String(interruptSource));
        } else {
            // Woken by timer, don't notify..
            // TODO: Block the sleep tune as well.
            //doubleBeep();
        }
    }
}

void setupAccelerometerTaps() {
    //byte xThs, byte yThs, byte zThs, byte timeLimit = 0xFF, byte latency = 0xFF, byte window = 0xFF
    // zThs - Z Threshold can be tuned to increase or decrease sensitivity
    // to the bottle being placed on the scale.
    accel.setupTap(0xFF, 0xFF, 0x04, 0x50, 0x20, 0x78);
    configureInterrupts();
}

void configureInterrupts() {
    // Configure the WKP to be in a pull down state
    // this pin is used by the system to wake the 
    // Photon from deep sleep mode on a rising edge.
    pinMode(WKP, INPUT_PULLDOWN);
    
    accel.enableTapInterrupts();
}

// ========================================================================================
// Loop
// ========================================================================================

void timerTick() {
    // on the next pass through the loop
    // check the bottle.
    checkBottle = true;
}


void loop() {

    if (waitForItemToBeRemoved) {
        // Initial measurement has been made when the bottle was 
        // placed on the scale. Now we need the user to remove
        // the bottle so that the tare weight can be measured
        // to get a reasonably accurate weight
        doSecondaryMeasurements();
        
        // Indicate that we (have been/are/expect another bottle) in measuring mode
        // so don't sleep until the timeout.
        measuring = true;
    } else {
        
        // Initial measurements from wake.
        
        // Check taps to see if we were tapped (i.e. a bottle placed on 
        // the scale, or removed)
        
        // Reading this will clear the interrupt register.
        byte taps = accel.readTap();
        if (taps > 0) {
            doMeasurements();
        } else if (measuring && firstLoop) {
            // First time after wake up the taps
            // may not properly indicate the status
            // as it may have been reset.
            doMeasurements();
        } else {
            // No tap...
            // Occurs when the powersave mode causes a wake up
            // just publish the battery details.
            // or user has finished and we are just waiting to timeout.
            if (firstLoop || checkBottle) {
                Serial.println("First loop from wake with no tap or timer check. Check battery etc..");
                doEnvironmentMeasurements();
                bool isEmpty = tryReadEmptyWeight();
                publishEnvironmentStatus(isEmpty);
                checkBottle = false;
            }
        }
        
        // Exit here by a sleep if
        // no item on the scale.
        sleepIfRequired();
    } 
    
    // If not measured for x seconds then clear the 
    // measuring flag.
    if (measuring && (millis() - waketime > 30000)) {
        Serial.println("Inactive timeout.");
        measuring = false;
    }
	
	// High Power...
	// If we got here we are not sleeping, ensure cloud is connected
	// to receive firmare updates and for easier publishing when it 
	// is required.
	// If we were woken by a tap then we are in "measuring" mode
	// connect to the cloud to allow cloud functionality.
	// TODO: Eventially remove this or enable only when in 
	// certain modes (high power/connected/etc)
    connectToTheCloud();
    
    firstLoop = false;
    
    delay(1000);
}

void doEnvironmentMeasurements() {
    // Note the battery voltage
    vin = analogRead(VIN_MONITOR_PIN);
    
    // 1 Wire DS18B20 Temperature
    if (sensor.read()) {
        if (sensor.crcError()) {
            hasValidTemperature = false;
            temperature = 0.0;
            Serial.println("CRC Error for temperature sensor");
        } else {
            // Expect only 1 sensor.
            hasValidTemperature = true;
            oneWireTemperature = sensor.celsius();
            Serial.printf("Temperature %.2f C", sensor.celsius());
        }
    }
    
    // TODO: BME280 Temperature, humidity, BP
    hasEnvironmentalSensor = false;
    temperature  = 0.0;
    humidity = 0.2;
    pressure = 9999;
}

void doMeasurements() {
    doEnvironmentMeasurements();
    
    // TODO: Switch on the NFC reader (V1.1 PCB)
    
    // Read the bottle NFC token to identify the bottle
    currentBottleId = readBottleNfcTag();
    
    if (currentBottleId == "") {
        Serial.println("No NFC tag found. Exiting.");
        return;
    }
    
    // currentBottleId will hold the NFC id of the current bottle.
    
    // Give a small delay to allow the bottle/scale to settle.
    delay(2000);
    
    // Read the actual weight of the scales.
    bottleWeight = readScale();
    
    // Need to tare the scale to get an accurate 0
    // as it may (will have) drifted. Wake up is by
    // weight on the unit so need to weight until the item
    // is removed.
    waitForItemToBeRemoved = true;
    
    // Indicate that the initial measurement has been completed.
    // and the user can (should) remove the bottle.
    doubleBeep();
    
    // Switch on LED to indicate that we are waiting for the user.
    digitalWrite(LED_2_PIN, HIGH);
    
    // Reset wake time to extend the timeout
    // as we know theirs a bottle placed on the scale
    // and it might be different from the original one.
    resetWakeTime();
    Serial.println("Reset wake time to increase timeout for user to remove bottle.");
}

void doSecondaryMeasurements() {
    
    // If we already have an empty weight in 
    // memory we could use that...
    emptyWeight = readScale();
    
    // If the change in bottle weight
    // is > 10g then it's most likely 
    // that the bottle was removed.
    if (bottleWeight - emptyWeight > 10) {
        bottleRemoved();
        return;
    } 
    
    // Handle situation where for some reason a tag was seen 
    // but the difference in weight is too small to count
    // (i.e. sticky tag dropped on scale).
    //
    // Check for tag removal rather than constandly beep.
    String bottleId = readBottleNfcTag();

    if (bottleId == "") {
        Serial.println("No NFC tag found. Assume bottle removed.");
        bottleRemoved();
        return;
    }
    
    // Bottle left on the scale. This will cause repeated
    // measurements and high power usage.
    
    // Don't sleep as that shuts off the WiFi and it might only have
    // been milliseconds since the weight was measured.
    // TODO: Timeout or switch to high power mode for bottle tracking.
    
    // Beep every second to annoy the user so they take the bottle off
    delay(1000);
    doubleBeep();
    
    Serial.println("Waiting for bottle to be removed. Bottle Weight:  " + String(bottleWeight) + ", Empty Weight: " + String(emptyWeight));
}

void bottleRemoved() {
    // If the bottle was removed...
    waitForItemToBeRemoved = false;
    measuredBottleWeight = bottleWeight - emptyWeight;
    
    // Waiting for item to be removed. 
    publishBottleDetails();
    
    digitalWrite(LED_2_PIN, LOW);
    Serial.println("Bottle removed. Measured weight: " + String(measuredBottleWeight));
    
    singleBeep(500);
}

// See if the scale is empty, if so
// and read the weight to get a baseline
// of tare values.
bool tryReadEmptyWeight() {
    
    digitalWrite(D7, HIGH);
    // Read the bottle NFC token to identify the bottle
    currentBottleId = readBottleNfcTag();
    digitalWrite(D7, LOW);
    
    // alterhativly just read the weight, ensure it's within 
    // 5g (or so) of the stored emptyWeight and then use 
    // that. If not then we can check for a bottle
    // NFC tag and then decide.
    // Using NFC read requires a lot of power (10-100x of a scale read)
    // so for battery concervation a scale check is simplest.
    
    // If we got anything other than an empty NFC tag
    // then a bottle has been left of the scale.
    // so exit with a fail.
    if (currentBottleId != "") {
        Serial.println("Scale not empty. Unable to measure baseline.");
        return false;
    }
    
    // If no bottle then we have a valid tare weight.
    emptyWeight = readScale();
    
    Serial.println("Empty Weight: " + String(emptyWeight));
    
    return true;
}

// ========================================================================================
// NeoPixels
// ========================================================================================
void rainbow(uint8_t wait) {
    /*
  uint16_t i, j;

  for(j=0; j<256; j++) {
    for(i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel((i+j) & 255));
    }
    strip.setBrightness(20);
    strip.show();
    delay(wait);
  }
  */
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
    /*
  if(WheelPos < 85) {
   return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if(WheelPos < 170) {
   WheelPos -= 85;
   return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170;
   return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
  */
}

// ========================================================================================
// NFC (bottle id) detection
// ========================================================================================
String readBottleNfcTag() {
    // Buffer to store the returned UID
	uint8_t uid[] = { 0, 0, 0, 0, 0, 0, 0 };	
	
	// Length of the UID (4 or 7 bytes depending on ISO14443A card type)
    uint8_t uidLength;				
  
    // Wait for an ISO14443A type cards (Mifare, etc.).  When one is found
    // 'uid' will be populated with the UID, and uidLength will indicate
    // if the uid is 4 bytes (Mifare Classic) or 7 bytes (Mifare Ultralight)
    bool success = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, &uid[0], &uidLength);
    
    if (success) {
        String cardUid = "";
        for (uint8_t i=0; i < uidLength; i++) 
        {
            if (uid[i] < 0x10) {
	            cardUid+= "0";
	        }
	        cardUid+= String(uid[i], HEX);
        }
        
        if (uidLength == 7)
        {
            // Reads the data in the NTAG
            // Don't use this for now
            //readNTag2();
        }
        Serial.println("NFC Card: " + cardUid);
        return cardUid;
        
    } else {
        // If NFC read failed then no or unknown bottle
        Serial.println("No NFC Card");
        return "";
    }
}

void readNTag2() {
    uint8_t data[32];
      
    // We probably have an NTAG2xx card (though it could be Ultralight as well)
    Particle.publish("status","Seems to be an NTAG2xx tag (7 byte UID)");	  
      
    // NTAG2x3 cards have 39*4 bytes of user pages (156 user bytes),
    // starting at page 4 ... larger cards just add pages to the end of
    // this range:
      
    // See: http://www.nxp.com/documents/short_data_sheet/NTAG203_SDS.pdf

    // TAG Type       PAGES   USER START    USER STOP
    // --------       -----   ----------    ---------
    // NTAG 203       42      4             39
    // NTAG 213       45      4             39
    // NTAG 215       135     4             129
    // NTAG 216       231     4             225      
    
    String contents = "";
    String page = "";

    for (uint8_t i = 0; i < 42; i++) 
    {
        // Display the current page number
        String page = "PAGE " + String(i);
        
        bool success = nfc.mifareultralight_ReadPage(i, data);

        // Display the results, depending on 'success'
        if (success) 
        {
            // Dump the page data
            //nfc.PrintHexChar(data, 4);
            String dataString = "";
            for (uint8_t i=0; i < 4; i++) 
            {
                if (data[i] < 0x10) {
	                dataString+= "0";
	            }
	            dataString+= String(data[i], HEX);
            }
            Particle.publish("status", page + " read ok. Data: " + dataString);
            delay(1000);
        }
        else
        {
            Particle.publish("status", "Failed to read page: " + page);
            // exit
            return;
        }
    }     
}

void sleepNfcReader() {
    Serial.println("Sleeping NFC reader.");

    // TODO: Switch off the NFC reader (V1.1 PCB)
    // boolean sendCommandCheckAck(uint8_t *cmd, uint8_t cmdlen, uint16_t timeout = 1000);  
    // Wake on I2C
    byte pn532_packetbuffer[] =  {PN532_COMMAND_POWERDOWN, 0x80 };

    if (! nfc.sendCommandCheckAck(pn532_packetbuffer, 2)) {
        Serial.println("No ACK during sleep NFC!");
        slowDoubleBeep();
    }
    
    // small delay to allow the NFC sleep to happen before forcing
    // the PDN pin low for a proper sleep.
    delay(250);
    
    digitalWrite(NFC_RSTPDN_PIN, LOW);
    delay(250);
}

// ========================================================================================
// Scale (bottle weight) functions
// ========================================================================================

// Read the weight of the bottle.
double readScale() {
    scale.power_up();
    
    int averagesCount = 5;
    double averages[averagesCount];
    double average;
    double min;
    double max;
    int loopCounter = 0;

    do {
        //noInterrupts();
        //interrupts();
        // Take a first hit to get a rough guide.
        average = (double)scale.get_units(2);
        min = average;
        max = average;
        
        for (int i=0; i<averagesCount; i++) {
            average = (double)scale.get_units(2);
            averages[i] = average;
            if (average < min) {
                min = average;
            }
            
            if (average > max) {
                max = average;
            }
            
            // Small delay to ensure the sample is settling.
            delay(100);
        }
        
        // Ensure we are within n grams for min and max.
        if (max - min > 4) {
            Serial.println("Noisy reading. skipping. Noise: " + String (max-min));
            singleBeep(50);
        }
        
        loopCounter++;
    
    // Repeat until we get a stable reading.
    // max of 20 readings.
    } while(max - min > 1);
    
    // put the scale ADC in sleep mode
    scale.power_down();	
    
    // Compute a new average based on the n points
    // excluding the min and max values.
    average = 0;
    uint8_t count = 0;
    for (int i=0; i<averagesCount; i++) {
        // Remove min an max.
        if (averages[i] > min && averages[i] < max) {
            average +=averages[i];
            count++;
        }
    }
    average = average / count;
    
    currentWeight = average;


    
    return average;
}

// Perform initial calibration on the load cell / ADC to get
// a y=mx+c type equation to apply to values read from 
// the scale to convert into grams.
float initialCalibration() {
    Serial.println("Starting initial calibration...");
    
    scale.set_scale();   
    // reset the scale to 0
    scale.tare();				        
    
    Serial.println("Place weight on scale...");
    delay(10000);
    
    Serial.print("get units 10 : \t\t");
    float units = scale.get_units(10);
    Serial.println(units, 1);	
    float scaleFactor = units / 666; // weight used.
    
    Serial.print("Scale factor : \t\t");
    Serial.println(scaleFactor, 5);	
    
    scale.set_scale(scaleFactor);   
    
    return scaleFactor;
}

void debugPrintScaleData() {
    
    noInterrupts();
    Serial.print("read: \t\t");
    Serial.println(scale.read());			// print a raw reading from the ADC
    
    Serial.print("read average: \t\t");
    Serial.println(scale.read_average(20));  	// print the average of 20 readings from the ADC
    
    Serial.print("get value: \t\t");
    Serial.println(scale.get_value(5));		// print the average of 5 readings from the ADC minus the tare weight (not set yet)
    
    Serial.print("get units: \t\t");
    Serial.println(scale.get_units(5), 1);	// print the average of 5 readings from the ADC minus tare weight (not set) divided 
    					// by the SCALE parameter (not set yet)  
	interrupts();
}

// ========================================================================================
// Piezo buzzer.
// ========================================================================================
void wakeTune() {
    for (int f=500; f<5000; f+=250) {
        analogWrite(BUZZER_PIN, volume, f);
        delay(75);
    }
    analogWrite(BUZZER_PIN, 0);
}

void sleepTune() {
    for (int f=3000; f>500; f-=250) {
        analogWrite(BUZZER_PIN, volume/2, f);
        delay(75);
    }
    analogWrite(BUZZER_PIN, 0);
}

void singleBeep(int delayms) {
    analogWrite(BUZZER_PIN, volume, 450);
    delay(delayms);
    analogWrite(BUZZER_PIN, 0);
    delay(delayms);
}

void doubleBeep() {
    for (int i=0; i<2; i++) {
        singleBeep(100);
    }
}

void slowDoubleBeep() {
    for (int i=0; i<2; i++) {
        singleBeep(250);
    }
}

// ========================================================================================
// Power Management
// ========================================================================================

void sleepIfRequired() {
	// after a while go to sleep. Expect to be woken by an interrupt on the WKP line
	if (shouldSleep()) {
	    digitalWrite(D7, LOW);
	    
	    // TODO: Stop playing this as it's annoying :-)
	    sleepTune();
	    
	    sleepNfcReader();
    
	    // TODO: Switch off the NeoPixel LEDs (V1.1 PCB)
	    
	    if (digitalRead(WKP)) {
	        // One last check incase during the delay for sleep tune and nfc sleep
	        // and interrupt has been raised which would keep WKP high
	        // and prevent the Photon from waking up from RTC or INT.
            return;
	    }
	    
	    // Turn off microcontroller and Wi-Fi.
        // Reset after n-seconds.
        // Ultra low power usage.
        System.sleep(SLEEP_MODE_DEEP, 60);
	}
}

bool shouldSleep() {
    
    // iF A0 is low then sleep instantly
	bool keepAwake = digitalRead(KEEP_AWAKE_PIN);
	if (keepAwake) {
	    // Use LED1 to indicate we are in high 
	    // power mode.
	    digitalWrite(LED_1_PIN, HIGH);
	    return false;
	}
	
	digitalWrite(LED_1_PIN, LOW);
    
    // If we are measuring (i.e. woken by a tap
    // then stay awake for a certain timeout.
    if (measuring) {
        return false;
    }
    
    if (digitalRead(WKP)) {
        // Most likely accelerometer is signaling an interrupt (i.e. a tap)
        // if we sleep with WKP high the RTC is unable to 
        // wake the Photon and so then we never wake....
        Serial.println("Not sleeping as WKP pin is HIGH");
        return false;
    }
    
    // If not measuring and not keep awake
    // i.e. timer wake up
    // then sleep immediatly.
    return true;
}

// TODO: What is the value of this on first use
// if we don't connect to the cloud.
void resetWakeTime() {
    waketime = millis();
}

// ========================================================================================
// Publishing
// ========================================================================================

void connectToTheCloud() {
    // See: https://community.particle.io/t/timeout-problem-with-a-blocking-particle-connect/24048
    // for timeout handling of connected.
	if (!Particle.connected()) {
	    Particle.connect();
	    
	    if (!waitFor(Particle.connected, 10000)) {
	        // Go a little crazy to indicate a cloud connect failure.
	        slowDoubleBeep();
	        slowDoubleBeep();
	        slowDoubleBeep();
	        slowDoubleBeep();
	    } else {
	        publishStatus("Bottle buddy initialized. " + applicationVersion);
	    }
	}
}

void publishBottleDetails() {
    senml ="{'n':'weight', 'v':" + String(measuredBottleWeight) + "}";
    senml+=",{'n':'raw', 'v':" + String(bottleWeight) + "}";
    senml+=",{'n':'tare', 'v':" + String(emptyWeight) + "}";
    if (currentBottleId != "") {
        senml+=",{'n':'" + currentBottleId + "', 'v':" + String(measuredBottleWeight) + "}";
    }
    senml+=",{'n':'vin', 'v':" + String(vin) + "}";
    
    // full environmental pushes us over the 255 publish limit.
    if (hasValidTemperature) {
        senml+=",{'n':'T', 'v':'" + String(oneWireTemperature) + "'}";
    }

    publishSenML(senml);
}

// Background publishing just to say the device is alive and what 
// environmental is like.
void publishEnvironmentStatus(bool includeTare) {

    Serial.println("Publish Environmental status.");
    senml ="{'n':'ver', 'sv':'" + applicationVersion + "'}";
    
    // If we don't have a bottle include a tare (empty)
    // weight to help track drift.
    if (includeTare) {
        senml+=",{'n':'tare', 'v':" + String(emptyWeight) + "}";
    }

    appendEnvironmentMeasurements();
    
    publishSenML(senml);
    
    // chances are this is done from a timer wake
    // and is just about to go to sleep.
    // give a small delay to publish the 
    // data.
    delay(2000);
    Serial.println("Published.");
}

// uses global senml
void appendEnvironmentMeasurements() {
    senml+=",{'n':'vin', 'v':" + String(vin) + "}";
    
    if (hasValidTemperature) {
        senml+=",{'n':'T', 'v':'" + String(oneWireTemperature) + "'}";
    }
    
    if (hasEnvironmentalSensor) {
        senml+=",{'n':'T2', 'v':'" + String(temperature) + "'}";
        senml+=",{'n':'H', 'v':'" + String(humidity) + "'}";
        senml+=",{'n':'P', 'v':'" + String(pressure) + "'}";    
    }
}

void publishSenML(String fields) {
    connectToTheCloud();
    
    // TODO: Check that fields is not longer thaan 255 - 8 (247) characters
    // due to Particle limiting
    Particle.publish("senml", "{'e':[" + fields + "]}");
}

void publishStatus(String status) {
    connectToTheCloud();
    
    Particle.publish("status", status);
}

// ========================================================================================
// Particle Functions.
// ========================================================================================
int calibrate(String args) {
    return initialCalibration() * 1000;
}

int tare(String args) {
    
    scale.power_up();
    noInterrupts();
    
    scale.tare(10);
    tareValue = scale.get_offset();
    
    scale.power_down();
    interrupts();
    
    // Write it to EEPROM 4 bytes required
    // Address 0x04 - 0x07
    EEPROM.put(0x04, tareValue);

    publishStatus("Tare set to: " + String(tareValue));
    
    return (int)scale.get_offset();
}

// Read the RFID sensor.
// 0 = Nothing present
// 1 = Unable to read card serial
// 2 = Read new card.
int readRfid(String args) {
    String token = readBottleNfcTag();
    if (token != "") {
        Particle.publish("status", "Bottle present: " + currentBottleId);
        return 1;
    } else {
        Particle.publish("status", "No bottle present.");
        return 0;
    }
}

int readWeight(String args) {
    
    scale.power_up();
    noInterrupts();
    
    double average = (double)scale.get_units(1);
    
    scale.power_down();
    interrupts();
    
    Particle.publish("status", "Bottle weight: " + String(average));
    return (int)average;
}