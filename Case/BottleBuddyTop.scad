$fn=360;

// Size of the bottle.
// 100mm Minimum to fit the PCB and allow space for the load cell
bottleDiameter = 100;
wallThickness = 3;
bottlePadding = 2;

// Overall height. If using "sliceTop" to slice the top lowering
// this will reduce the height to the flat part.
// otherwise this govenrs the overall outer wall
// height for the bottle to drop into.
height = 30;

loadcellHeight = 12.75;
loadcellWidth = 12.75;
loadcellLength = 80;
loadCellOffset = -48;

baseHeight = 2 + 9; // 2mm for loadcell scren + 12 mm for. (PCB?)

neoPixelPcbDepth = 3.4;
pcbDepth = neoPixelPcbDepth + 2;

// Size of the NFC PCB in the top of the unit
nfcPcbLength = 43;
nfcPcbWidth = 40;

// The area that gets cutout for the NFC PCB
paddedNfcPcbLength = nfcPcbLength+4; // 43
paddedNfcPcbWidth = nfcPcbWidth+5; // 40  

// Causes a diagonal cut through the top.
// If not set uses just a cylinder as the bottle holder.
sliceTop = true;

// We cover the NFC PCB and area
// with Epoxy to provide a water resitant
// seal for the NFC and inner electronics.
// How deep should this be.. (mm).
// Essentially governs the depth of the out rim of the 
// unit.
epoxyDepth = 4;

// NeoPixels.
includeNeoPixels = false;

// 0 : No skirt
// 2 : Version 2 Skirt
// 3 : Version 3 skirt
skirtOption = 2;

// PCB Pad height
// Gap between the base and the PCB.
// remember photon lets sticking through
// The lower the better to allow more room
// for the battery etc.
padHeight = 2;

// How much to reduce the PCB pad
// that the LED goes through.
// V1 PCB - reduce down by 2mm or so (padHeight) to allow for a regular
// 3mm LED to be inserted
// V1.1 PCB set to 0
ledPadAdjust = 3;

// ==============================================================
// Models to help visualise
// ==============================================================

module showModels() {
        
    //%loadCell();
    translate([0,0,-12.75]) {
        %importLoadCellModel();
    }
    
    
    translate([0,0,baseHeight - pcbDepth]) {
        rotate([0,0,180]) {
            % nfcPcb();
        }
    }
    
    if (includeNeoPixels) {
        translate([0,0,baseHeight - neoPixelPcbDepth]) {
            % neoPixelCirclePcb();
        }
    }
    
    // 3mm up due to PCB + 2mm layer
    translate([0,0,loadcellHeight + 5 + 5]) {
      //%bottle();
    }
}

module bottle() {
    cylinder(d=bottleDiameter, h=225);
}

module neoPixelCirclePcb() {
    
    difference() {
        union() {
            cylinder(d=66, h=3.4);
        }
        union() {    
            translate([0,0,-0.01]) {
                cylinder(d=52, h=3.42);
            }
        }
    }
}

module nfcPcb() {
nfcPcbHeight = 5;
    translate([-(43/2),-(40/2),16]) {
        
        difference() {
            union() {
                cube([43, 40,1.6]);
                // Dip switch. the tallest thing.
                translate([8.6,8.6,1.6]) {
                    cube([6,4,3]);
                }
                
                // I2C Connection
                translate([5,20-6,-18]) {
                    cube([4,12,18]);
                }
                
                // IRQ and Reset pins
                translate([29,32,-18]) {
                    cube([7,4,18]);
                }
                
                // The other Reset pin.... 
                translate([27,8,-18]) {
                    cube([5,4,18]);
                }
            }
            union() {
                // Mounting holes.                
                translate([43-7.5, 7.5,0]) {
                    #cylinder(d=3, h=nfcPcbHeight+0.01);
                }
                
                translate([7.5, 40-7.5,0]) {
                    #cylinder(d=3, h=nfcPcbHeight+0.01);
                }
            }
        }
    }
}

module importLoadCellModel() {
    import("LoadCellModel.stl");
}

module loadCell() {
    
    rotate([0,0,90]) {
        translate([loadCellOffset, -(loadcellWidth)/2 ,-0.1]) {
        
            difference() {
                union() {
                    cube([loadcellLength, loadcellWidth, loadcellHeight]);
                    // strain gauge placement + goo
                    translate([(loadcellLength-26)/2,0,loadcellHeight]) {
                        cube([26,loadcellWidth,1]);
                    }
                    translate([(loadcellLength-26)/2,0,-1]) {
                        cube([26,loadcellWidth,1]);
                    }
                }
                union() {
                    translate([5.0, (12.75/2),0]) {
                        // Bigger top connector holes
                        // to help align with top when visual testing
                        #cylinder(d=4, h=40);
                    }
                    translate([20, (12.75/2),0]) {
                        #cylinder(d=4, h=40);
                    }
                    //60
                    translate([60, (12.75/2),0]) {
                        cylinder(d=4, h=13);
                    }
                    translate([75, (12.75/2),0]) {
                        cylinder(d=4, h=13);
                    }
                }
            }
        }
    }
}

// ==============================================================

module loadCellHoles() {
    
    loadcellHeightOffset = 2;
    
    //translate([-30,-(loadcellWidth/2)-1,-2]) {
    translate([+(loadcellWidth/2),loadCellOffset,0]) {
            rotate([0,0,90]) {
            // Load Cell cutout to allow for movement.
            // Cut out extra to allow for top 
            // surface of the load cell.
            translate([26,-1, 0]) {
                cube([loadcellLength - 20, loadcellWidth+4, loadcellHeightOffset+2]);
            }
            
            //  bolt holes
            // Outside
            // Raise the bolt up x mm's so it has more material underneath
            translate([5.0, (12.75/2), 0]) {
                translate([0, 0, -10]) {
                    cylinder(d=4.8, h=11);
                }
            
                cylinder(d=4.8, h=7);
                
                // Countersink
                translate([0,0,5]) {
                    cylinder(d1=4.8, d2=9, h=4);
                }
                
                // Hollow out the remaining hole
                translate([0,0,8]) {
                    cylinder(d=10, h=9);
                }
            }

            // Inside
            translate([20.0, (12.75/2), 0]) {
                translate([0, 0, -10]) {
                    cylinder(d=4.8, h=11);
                }
                cylinder(d=4.8, h=7);
                
                // Countersink
                translate([0,0,5]) {
                    cylinder(d1=4.8, d2=9, h=4);
                }
                
                // Hollow out the remaining hole
                translate([0,0,8]) {
                    cylinder(d=10, h=9);
                }
            }
        }
    }
}

// Cutout in the top for the NFC pcb to rest in.
// and for holes to the lower PCB
module nfcPcbCutout() {

    
    // PCB
    // Make the PCB slot 
    translate([-paddedNfcPcbLength/2,-paddedNfcPcbWidth/2, baseHeight - pcbDepth + 0.1]) {
        cube([paddedNfcPcbLength, paddedNfcPcbWidth, pcbDepth]);
    }
    
    // PCB Cables, through to the bottom compartment
    translate([-nfcPcbLength/2,-nfcPcbWidth/2, baseHeight - pcbDepth + 0.1]) {    
        // I2C Connection
        translate([3,(nfcPcbWidth/2)-6,-8.1]) {
            cube([5,12,8.2]);
        }
        
        // IRQ and Reset pins
        translate([29,32,-8.1]) {
            cube([7,4,8.2]);
        }
        
        // The other Reset pin.... 
        translate([27,8,-8.1]) {
            cube([5,4,8.2]);
        }
    }
        
    translate([28,0,0]) {
        translate([-1,-13,0]) {
            //cube([3, 26, 8]);
        }
        translate([0,9-5,0]) {
            //#cube([2, 5, 8]);
        }
    }
}

// PCB goes directly on the base
// These are wrong at present, PCB holes have changed for Neopixels so these need to be updated.
module nfcPcbPins() {
nfcPcbHeight = 2;
    translate([-(nfcPcbLength/2),-(nfcPcbWidth/2), baseHeight - pcbDepth]) {
        // Mounting pins.                
        translate([nfcPcbLength-7.5, 7.5,0]) {
            cylinder(d1=3,d2=2, h=nfcPcbHeight+0.01);
        }
        
        translate([7.5, nfcPcbWidth-7.5,0]) {
            cylinder(d1=3,d2=2, h=nfcPcbHeight+0.01);
        }
    }
}


// Cutout for the neopixel circle
// This is optional
module neoPixelCutout() {
    difference() {
        union() {
            cylinder(d=67, h=3.41);
            
            // Holes for wires.
            // Data in
            translate([-(53/2) - 5,0,-10]) {
                cylinder(d=3, h=11);
            }
            
            // GND
            translate([+(53/2),+16.0,-10]) {
                cylinder(d=3, h=11);
            }
            
            // +
            translate([+(53/2), -16.0,-10]) {
                cylinder(d=3, h=11);
            }
        }
        union() {    
            translate([0,0,-0.01]) {
                cylinder(d=51, h=3.43);
            }
        }
    }
}

module photonLedLens() {
photonLedOffset = 20;
    difference() {
        union() {
            translate([pcbBoxDepth +pcbBoxExtraDepth - photonLedOffset, 0, -2]) {
                    cylinder(d=6, h=4);
                }
            }
        union() {
            // Hole in lid for Photon LED.
            translate([pcbBoxDepth +pcbBoxExtraDepth - photonLedOffset, 0, -3]) {
                cylinder(d=4, h=6);
            }
        }
    }
}

// A small hole to allow liquid to drain from the container rather than 
// sit in it. (Also useful for epoxy fill overflow.
module liquidEscapeHole() {
    translate([-(bottleDiameter/2),0,baseHeight+4]) {
        rotate([0,-120,0]) {
            cylinder(d=4, h=8);
        }
    }
}

// **********************************************************

// Add individual PCB mounting pad.
module addPcbMount(x,y,padHeight) {
    translate([x,y,-padHeight]) {
        cylinder(d=9, h=padHeight+2);
    }
}

// Add the PCB mounting Pads
module addPcbMounts(padHeight) {
    addPcbMount(14,-43, padHeight);
    addPcbMount(-14,-43,padHeight);
    addPcbMount(0,45,padHeight);
    
    // Pads only to rest PCB on, no hold in PCB
    addPcbMount(47,0,padHeight);
    
    // This is the pad for the LED 
    addPcbMount(-47,0,padHeight - ledPadAdjust);
}

// Holds in PCB mounting pads.
// Extra holes into the base for the PCB mounts.
module addPcbMountHoles() {
    // 2mm for small self tapper hole (v1.1 PCB)
// 3mm for self tappers.
// 4.2mm for inserts
holeDiameter = 3; 
    
    addPcbMountHole(14,-43,8, holeDiameter);
    addPcbMountHole(-14,-43,8, holeDiameter);
    addPcbMountHole(0,45,8, 2);
}

module addPcbMountHole(x,y, height, holeDiameter, holeDiameterTop) {
// 2mm for small self tapper hole (v1.1 PCB)
// 3mm for self tappers.
// 4.2mm for inserts
    
    translate([x,y,-2]) {
        #cylinder(d=holeDiameter, h=height);
        // Finish the hole off to a cone shape to 
        // try and stop Cura putting supports in
        translate([0,0,4]) {
            #cylinder(d1=holeDiameter, d2=0, h=height-4);
        }
    }
}

// Hole for the LED fitted on the PCB
// (V1.1 PCB)
module addPcbLedHole() {
    translate([-47,0, 0]) {
        // 3.2mm to allow a 3mm LED to be pushed in.
        cylinder(d=3.2, h=20);
    }
    
    translate([-47,0, 7]) {
        rotate([0,-60,0]) {
            cylinder(d=3, h=20);
        }
    }
}

// **********************************************************

module bottleHolder() {
h = height;
    
    // Main Body
    difference() {
        union() {
            cylinder(d=bottleDiameter + bottlePadding + wallThickness, h=h);
        }
        union() {
            
            // Cut out a recess for the PCB to sit in.
            translate([0,0,-0.1]) {
                // Don't size with bottleDiameter
                // to provide greater support for larger bottles
                cylinder(d=102, h=4.1);
            }
            
            
            // Cout out the bulk of the inside, except 
            // give a 4mm lip 2mm high to guide the resin
            // pouring.
            translate([0,0,baseHeight+epoxyDepth]) {
                cylinder(d=bottleDiameter + bottlePadding, h=(h - baseHeight)+0.1);
            }
            
            translate([0,0,baseHeight]) {
                // possibly + bottlePadding
                cylinder(d=bottleDiameter + bottlePadding, h=(h - baseHeight)+0.1);
            }
                               
            loadCellHoles();
            
            rotate([0,0,180]) {
                nfcPcbCutout();
            }
            
            if (includeNeoPixels) {
                // Neopixel is about 3.4mm deep
                translate([0,0,baseHeight-3.4]) {
                    neoPixelCutout();            
                }
            }
            
            translate([0,0,4]) {
                addPcbMountHoles();
            }
            
            addPcbLedHole();
        }
    }
    
    // Made some additions after hollowing out the base a bit.
    difference() {
        union() {                
            // Alternative PCB mounting for circular PCB
            // use 0 for an easier (flat) print with little support structure 
            // neeed but added washers required to pull the PCB away from the 
            // plastic.
            // HOWEVER, with the skirt printed that will need a large support fill area.
            // so it won't matter.
            // 1mm high so it's lifted off the base slightly
            // to help with rough bottom from printing
            translate([0,0,4]) {
                addPcbMounts(padHeight);
            }
            
            // Add a bit of padding back to the load cell area
            translate([-(loadcellWidth/2),loadCellOffset, 0]) {
                // Increase this height to give the top more clearance from the base.
                cube([loadcellWidth, 25, 4.1]);
            }
        } 
        union() {
            addPcbMountHoles();
            
            // Add the load cell holes back in again.
            loadCellHoles();
            
            // Ensure the LED hole goes through the PCB mounting holes as well
            addPcbLedHole();
        }
    }
    
    // vertical Pins for the NFC PCB to align it
    rotate([0,0,180]) {
        nfcPcbPins();
    }
}

// ==============================================================
// Skirt options
// ==============================================================

module skirtV2() {
    translate([0,0,-10]) {
        difference() {
            cylinder(d1=bottleDiameter+16, d2=bottleDiameter+5, h=15);
            translate([0,0,-0.01]) {
                // 4mm smaller (gives 2mm wall width)
                cylinder(d1=bottleDiameter+10, d2=bottleDiameter+1, h=15.02);
            }
        }
    }
    
    // Base is about 16.2mm height (excluding feet)
    translate([0,0,-21]) {
        difference() {
            cylinder(d=bottleDiameter+16, h=11);
            translate([0,0,-0.01]) {
                cylinder(d=bottleDiameter+ 10, h=13.02);
            }
        }
    }
}

module skirtV3a(baseDiameter, topDiameter) {
    hull() {
        // Base polygon. Number of sides set by $fn
        // Base is about 16.2mm height (excluding feet)
        union() {
            translate([0,0,-15]) {
                cylinder(d=baseDiameter, h=8, $fn=12);
            }
        }
        
        // Upper cicle that joins the main bottle holder top
        union() {
            translate([0,0,9]) {
                #cylinder(d=topDiameter, h=1);
            }
        }
    }
}

module skirtV3() {
    // Create a hull and then empty the inside.
    difference() {
        skirtV3a(116, 104);
        skirtV3a(114, 102);
    }
}

// ==============================================================

module computeVolumeEpoxyNeeded() {
    echo("================================="); 
    echo("Epoxy volume required: "); 
    echo("---------------------------------"); 
    
    // width/length are in mm.
    // use cm to give a nice cm3 (ml) value.
    // cm * cm => cm2 * cm => cm3
    pcbVolume = paddedNfcPcbLength/10 * paddedNfcPcbWidth/10 * (pcbDepth/10);
    echo("Volume of epoxy for PCB cutout is about (ml)", pcbVolume); 
    
    // radius of the cylinder for the epoxy
    r = (bottleDiameter + bottlePadding) /2;
    
    // r is in mm.
    // epoxyDepth is in mm.
    // work in cm's to give cm3
    // cm2 x cm => cm3
    cylinderVolume = 3.14 * pow(r/10, 2) * (epoxyDepth/10);
    echo("Volume of epoxy for cylinder cutout is about (ml)", cylinderVolume); 
    
    volume = cylinderVolume + pcbVolume;
    
    echo("Volume of epoxy required is about (ml)", volume); 
    oneThird = volume/3;
    echo("Assume 1g == 1ml of epoxy (it doesn't)"); 
    echo("Part A = ", oneThird * 2); 
    echo("Part B = ", oneThird); 
    echo("================================="); 
}


// ==============================================================
// Main
// ==============================================================

showModels();

computeVolumeEpoxyNeeded();

difference() {
    union() {
        bottleHolder();
        
        if (skirtOption == 2) {
            skirtV2();
        } else if (skirtOption == 3) {
            skirtV3();
        }
    }
    union() {
        
        if (sliceTop) {
            // Cut out front half of the upper.
            translate([-bottleDiameter-10,-(bottleDiameter+14)/2,baseHeight+epoxyDepth]) {
                cube([bottleDiameter+10,bottleDiameter+14,30]);
            }
            
            // Cut out front half of the upper.
            translate([0,-(bottleDiameter+14)/2,baseHeight+epoxyDepth]) {
                rotate([0,-20,0]) {
                    cube([bottleDiameter+10,bottleDiameter+14,30]);
                }
            }
        } else {
            liquidEscapeHole();
        }
        
    }
}