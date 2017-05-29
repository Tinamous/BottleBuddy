$fn=360;
bottleDiameter = 100;
wallThickness = 3;
bottlePadding = 2;

//height = 100;
height = 40;

loadcellHeight = 12.75;
loadcellWidth = 12.75;
loadcellLength = 80;
loadCellOffset = -48;

baseHeight = 2 + 9; // 2mm for loadcell scren + 12 mm for. (PCB?)

neoPixelPcbDepth = 3.4;
pcbDepth = neoPixelPcbDepth + 2;

nfcPcbLength = 43;
nfcPcbWidth = 40;

// How thick the PCB is.
pcbThickness = 2;
// Space above the PCB 
// to allow for wire poking through on connector
pcbOffsetFromTop = 1;

pcbBoxWidth = 105;


sliceTop = true;

// When showing the cutout make the epoxy thicker 
// top help the Neopixels shing though.
epoxyDepth = 4;


// NeoPixels.
includeNeoPixels = false;

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
    
    //translate([-30,-(loadcellWidth/2),-2]) {
    rotate([0,0,90]) {
        translate([loadCellOffset, -(loadcellWidth)/2 ,-0.1]) {
        
        //color("Gainsboro", 50) { 
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
          //  }
        }
    }
    }
}


pcbBoxDepth = 45;
pcbBoxExtraDepth =37;
module wideLid(yWidth, pcbBoxHeight, hollow = false) {

//pcbBoxHeight = 1;
//yWidth = 105;

yOffset = -(yWidth/2);
    
    translate([0, yOffset, 0]) {
        difference() {
            union() {
                cube([pcbBoxDepth+pcbBoxExtraDepth,yWidth, pcbBoxHeight]);
            }
            union() {
                // Hollow out the PCB Comparetment
                translate([-2, 1, -2]) {
                    if (hollow) {
                     //   cube([pcbBoxDepth+34, yWidth-2, pcbBoxHeight]);
                    }
                }
            }
        }
    }
}

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

module nfcPcbCutout() {

paddedNfcPcbLength = nfcPcbLength+4; // 43
paddedNfcPcbWidth = nfcPcbWidth+5; // 40    

    
    // PCB
    // Make the PCB slot 
    translate([-paddedNfcPcbLength/2,-paddedNfcPcbWidth/2, baseHeight - pcbDepth + 0.1]) {
        cube([paddedNfcPcbLength, paddedNfcPcbWidth, pcbDepth]);
    }
    
    // PCB Cables, through to the bottom compartment
    translate([-nfcPcbLength/2,-nfcPcbWidth/2, baseHeight - pcbDepth + 0.1]) {    
        // I2C Connection
        translate([3,(nfcPcbWidth/2)-6,-8]) {
            cube([5,12,8.01]);
        }
        
        // IRQ and Reset pins
        translate([29,32,-8]) {
            cube([7,4,8.01]);
        }
        
        // The other Reset pin.... 
        translate([27,8,-8]) {
            cube([5,4,8]);
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

module skirt(diameter, h) {
    cylinder(d=diameter, h=h);
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

// Add an outline of a the base with a gap around the base
// so that liquid doesn't get into the base
// and to cover the gap between base and top.
module addSkirtV1() {
innerDiameter = bottleDiameter + bottlePadding + wallThickness;

overlapOnTop = 16.5;// 30
skirtHeight = overlapOnTop + 16; // bottom is 16mm deep.
    
zBottom = -skirtHeight + overlapOnTop -0;
padding = 6;
photonLedOffset = 20;
    
    translate([0,0,zBottom]) {
        difference() {
            union() {                
                skirt(innerDiameter +padding , skirtHeight);
                wideLid(pcbBoxWidth +padding, skirtHeight - overlapOnTop+2, true);
                
                // "Lens" for Photon LED.
                

                
            }
            union() {
                // Move up to the  top of the skirt
                // this should be the bottom of the top
                translate([0,0,skirtHeight - overlapOnTop]) {
                    // Top overlap. Needs to merge into top shell.
                    skirt(innerDiameter-1.5, overlapOnTop+0.01);
                }
                // Bottom overlap, slightly larger than the bottom
                // so it moves freely.
                skirt(innerDiameter+2 , skirtHeight - overlapOnTop +0.01);
                
                // Hollow out the PCB Comparetment
                translate([-2, -(pcbBoxWidth/2) -1, -2]) {
                    cube([pcbBoxDepth+37, pcbBoxWidth+2, skirtHeight - overlapOnTop+2]);
                }
                
                // Hole in lid for Photon LED.
                translate([pcbBoxDepth +pcbBoxExtraDepth - photonLedOffset, 0, -zBottom]) {
                        cylinder(d=4, h=40);
                }
                
                // USB cutout.
                translate([pcbBoxDepth +pcbBoxExtraDepth-5, (-15/2), -2]) {
                    #cube([10,15,skirtHeight - overlapOnTop]);
                }
            }
        }
    }
    
    photonLedLens();
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
    addPcbMount(43,0,padHeight);
    addPcbMount(-43,0,padHeight);
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
    addPcbMountHole(0,45,6, 2);
}

module addPcbMountHole(x,y, height, holeDiameter, holeDiameterTop) {
// 2mm for small self tapper hole (v1.1 PCB)
// 3mm for self tappers.
// 4.2mm for inserts
    
    translate([x,y,-2]) {
        cylinder(d=holeDiameter, h=height);
        // Finish the hole off to a cone shape to 
        // try and stop Cura putting supports in
        translate([0,0,6]) {
            #cylinder(d1=holeDiameter, d2=0, h=height-2);
        }
    }
}

// Hole for the LED fitted on the PCB
// (V1.1 PCB)
module addPcbLedHole() {
    translate([-43,0, 0]) {
        cylinder(d=3, h=20);
    }
}



// **********************************************************

module bottleHolder() {
h = 30; //22 //height;    

    // Main Body
    difference() {
        union() {
            cylinder(d=bottleDiameter + bottlePadding + wallThickness, h=h);
            
            //hollowBox(h);
            //boxLid(h);
            //wideLid(pcbBoxWidth, 1);
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
                // remember photon lets sticking through
                padHeight = 2;
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
    
    // PCB Pins for the NFC PCB
    rotate([0,0,180]) {
        nfcPcbPins();
    }
        
    //addSkirtV1();
}

module skirtV2() {
    translate([0,0,-5]) {
        difference() {
            cylinder(d1=bottleDiameter+16, d2=bottleDiameter+5, h=15);
            translate([0,0,-0.01]) {
                // 4mm smaller (gives 2mm wall width)
                #cylinder(d1=bottleDiameter+10, d2=bottleDiameter+1, h=15.02);
            }
        }
    }
    
    // Base is about 16.2mm height (excluding feet)
    translate([0,0,-15]) {
        difference() {
            cylinder(d=bottleDiameter+16, h=10);
            translate([0,0,-0.01]) {
                cylinder(d=bottleDiameter+ 10, h=10.02);
            }
        }
    }
}

module skirtV3a(size1, size2) {
    hull() {
            // Base is about 16.2mm height (excluding feet)
        union() {
            translate([0,0,-15]) {
                cylinder(d=size1, h=12, $fn=10);
            }
        }
        
        union() {
            translate([0,0,10]) {
                cylinder(d=size2, h=1);
            }
        }
    }
}

module skirtV3() {
    difference() {
        skirtV3a(114, 106);
        skirtV3a(112, 104);
    }
}


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

showModels();

difference() {
    union() {
        bottleHolder();
        skirtV2();
        //skirtV3();
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