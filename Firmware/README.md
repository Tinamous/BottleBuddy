# BottleBuddy Firmware

This folder contains the firmware required to run the BottleBuddy as a Reagent Tracker. 

This is based on the Particle Photon. It is assumed you are familiar with programming the Photon via the Particle Build system.


## Programming the Photon

To use the code open a new code application in the Particle Build environment (https://build.particle.io)

Unfortunatly at present Particle don't have a nice way to bundle applications for sharing using the build environment, you can use their console based compiler if you prefer, but this guide is for the web ide.

Create a new Application (<>).

Paste in the bottlebuddy-v1.0.ino code.

Add the following libraries using the Build library manager:

* Adafruit_PN532
* neopixel
* OneWire

Add new tabs using the (+) in the top right:

* HX711
* SparkFunMMQ8452Q

You should get a .cpp and .h tab for each of those. Paste in the appropriate files (note theirs a bit of a bug where pasting in the .cpp code will end up in the .h file as well).

The HX711 library is available through the Particle Library system as HX711ADC however I had some issues with it at the original time of writing so brought it into the project as a C++ file, also the tare function uses an incorrect type (double should be long). 

The MMQ8452Q library didn't support configuration of tap interrupt events so I've modified that slightly from the original SparkFun library to support Tap Interrupts.

You will find the build environment has duplicated the #include statements. Remove the duplicates.

Ensure that the pin definitions in the .ino file match your build, these have changed between V1.0 and V1.1 of the PCB.

Click the verify icon and the application should build.

Ensure you have the correct device selected and the firmware version is set to 6.2 then flash the photon code.


## Post Programming:

Once the Photon has flashed it is going to spend most of its time asleep so we won't be able to re-flash the device without doing something special. 

Their are a few ways to keep the Photon connected to allow firmware updates. The KeepAwake pin (A2) is probably the most useful, particularly on a prototype board set-up. V1.1 of the PCB has a test point that can be soldered too if required.

Alternatively we can place the Photon in Safe Mode. 

To place the photon in Safe Mode, hold both Set-Up and Reset buttons down, release Reset and wait for the LED to flash Purple (it does this almost immediately), then release the Set-Up button. The Photon will now connect to the Particle Cloud and we can updated it, but it won't run any of our code until it is reset (manual or due to firmware update).