# BottleBuddy

Bottle Buddy is a Internet connected smart scale to monitor the amount of product in a bottle.

## Uses

* Stock control of bottled products
** Chemicals in a lab
** Reagents at a testing station
** Shampoo in a salon
** Domestic products (bleach, shampoo, etc) in the home.
** Liquors/spirits in a bar
* Monitoring chemicals in a lab to track usage (e.g. poisons usage)
* Refilling of reagents bottles
* Supply management to facilitate re-ordering as the bottle gets empty or used.
* Predictive ordering based on use
* Shelf life tracking from initial receipt and first use

### Example use case:

A river polution testing laboratory uses pH 4 and 7 buffer solutions to calibrate their pH Electrodes. 
Tests are run most days the electrodes are calibrated at least once, they use approximatly 25-75ml from each buffer solution.
The buffer solution which comes in 1L bottles with each bottle costs $70.
Once the buffer is opened it needs to be used within 28 days and has a shelf life of 1 year from the date of delivery.

Due to the cost and shelf life the lab only orders a new bottle of each buffer solution when they are getting low allowing for about a 3 day delivery time.

The lab is a remote testing station which is only occupied whilst the technician is there for a few hours running the tests, the technician is responsible 
for brining the required reagents with them as and when new stock is needed.

#### How Bottle Buddy helps

Delivery of new Reagents:

When new buffer solutions are brought a RFID sticked is placed on the bottom of the bottle to track it. The bottle is then placed on the Bottle Buddy where it
registers the RFID identifier and an initial weight, this is logged and as the RFID token is new the bottle assigned a delivery date to ensure that the 
shelf life restriction is monitored. 

By knowing the location of the Bottle Buddy the system also knows the location of this reagent, the technician can then use their phone or computer to 
assign additional details to the bottle as required and possibly print out a more human readable label to go with the bottle. This additional data may have been pre-programmed 
into the FRID tags (e.g. they may have tags specifically for the pH 7 buffer which include meta-data about shelf life, reagent name, etc.), or they may use a 
special identity tag after the reagent has been placed on Bottle Buddy to indicate it's type.

Day to day usage:

Once the technician has finished for the day they clean up and put away the equipment, part of this includes dropping each of the buffer
solution bottles onto Bottle Buddy, which then measures the weight of the bottle and records this. When the bottle weight drops below a 
pre-defined level, or the system determins the bottle will be empty within a certain timeframe an email is sent to the purchasing 
department or stores requesting a new bottle be delivered to the technician.

By tracking the weight of the bottle the tracking applicaiton can tell that the reagent is in use (i.e. the weight has decreased indicating it has
been opened and is in use), this allows the tracking of the shortened shelf life to ensure that a replacement is available before the 28 day usage is up.

Emails sent to the purchasing department can include details of when this reagent is required by, how much is typically used and who needs it, order codes and other information required for purchasing.

Other than the very brief initial RFID token assignment and the few seconds required to put the reagen on Bottle Buddy at the end of the day no time is 
lost with requesting replacement reagents, or discovering that the reagent has run out because the technician forgot to re-order any, good quality
reagent can be assured by the tracking of shelf life, and improved planning by usage monitoring can be achieved.


## Features: 

### V1.0

* Weight measurement with HX711 PCB and Load Cell
* Potential to drive NeoPixel ring (needs to be run from battery as 5V USB supply will cause problems).
* WiFi connectivity with Particle Photon
* Doesn't provide much in the way of power saving options, the Photon can be put to sleep and woken to check for an item on the scale. An accelerometer
can be added by connecting the wires to the appropriate I2C and power pins and glued to the PCB.
* Simple construction, can be hand soldered.


### V1.1

* Has an accelerometer (MMA8452Q)to detect a pulse when something is placed on the scale
* Photon can be kept in deep sleep and woken by the accelerometer to enable longer battery life.
* Power to the NFC PCB and optional NeoPixels can be controlled via p-Channel MOSFET switches.
* Charge monitoring for Li-Ion batteries with a Max1704x
* Simple temperature measurements with a DS18B20 (which could be glued to the load cell for better accuracy if needed)
* Temperature, humidity and pressure measurements with a BME280
* Swapped to headerless Photon to reduce depth of PCB on both sides
* Piezo buzzer to provide user feedback
* Single point LED at the front of the top to provide simple user feedback
* Needs reflow soldering / stencil for the BME280, Max1704x and MMA8452Q - these can all be left off through for more basic functionality

## Modes of operation




## 3D Printable

Boddle Buddy is made of two main shells, a top and a bottom. Both are designed so that the user facing part should have a nice smooth finish.

### Base - BottleBuddyBase.scad/.stl

This is the lower half of the assembly, it has holes for the the counter sunk M5x16 machine screws required by the load cell, [currently] a hole for 
the HX711 load cell amplifier PCB to be mounted (this is expected to be PCB mounted from V1.1 of the PCB), and a compartment for the battery to 
sit in.

It has 4 10mm recesses for feet to be placed in so that the floor isn't resting on a possibly uneven surface.

It may also have a hole to provide power in (depending on options


### Top - BottleBuddyTop.scad/.stl

This is the upper half, the PCB is mounted to the inside of this. This is connected to the lower half only by means of the load cell.

A skirt is printed aroud below the top half to prevent ingress of liquid into the lower half from above and to improve the look (rather than having a void). The skirt has a clearance around it to 

The load cell uses 2x M4x20 counter sunk machine screws from the top.

Inset in the top is a PN532 NFC reader (e.g. http://www.ebay.co.uk/itm/NXP-PN532-NFC-RFID-Module-V3-Kits-Reader-Writer-For-Arduino-Android-Phone-Module-/291939590305?hash=item43f8f4a0a1:g:p2kAAOSwnbZYJTmy)

This requires connecting up through the I2C connection with a 4 way header (solder into the NFC module first) through to the lower PCB, as well as 2 wires from the RSTO and IRQ pads connecting to the appropriate "test points" on the PCB.

The main PCB should be fitted inside with 2x self tappers through the holes either side of the load cell. 

The open hole for the LED on the V1.1 PCB (not present on the V1.0 PCB) should be covered with electrical tape to prevent resin coming through when poured onto the top.

When everything is mounted it can be tested to check for connection problems and then a layer of clear epoxy resin poured onto the top to the level of the raised lip (or just below to prevent overflow!)


