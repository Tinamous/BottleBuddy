$fn=50;

module showModels() {
    color("red") nfcPcb();
    translate([0,0,2]) {
        color("blue") neoPixelCirclePcb();
    }
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
    translate([-(43/2),-(40/2),0]) {
        
        difference() {
            union() {
                cube([43, 40,1.6]);
                // Dip switch. the tallest thing.
                translate([8.6,8.6,1.6]) {
                    cube([6,4,3]);
                }
                
                // I2C Connection
                translate([5,20-6,-8]) {
                    cube([4,12,8]);
                }
                
                // IRQ and Reset pins
                translate([28,32,-8]) {
                    cube([8,4,8]);
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

////////////////////////////////////////////////////////////////////////

// Cutout for the neopixel circle
module neoPixelCutout() {
    difference() {
        union() {
            cylinder(d=67, h=3.41);
        }
        union() {    
            translate([0,0,-0.01]) {
                cylinder(d=51, h=3.43);
            }
            
            // Holes for wires.
            // Data in
            translate([-(53/2) - 5,0,-10]) {
                #cylinder(d=2, h=11);
            }
            
            // +
            translate([+(53/2) -0.5,+16.5,-10]) {
                #cylinder(d=2, h=11);
            }
            
            // GND
            translate([+(53/2) - 0.5,-16.5,-10]) {
                #cylinder(d=2, h=11);
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////

loadcellHeight = 12.75;
loadcellWidth = 12.75;
loadcellLength = 80;
loadCellOffset = -48;


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
            translate([5.0, (12.75/2), 0]) {
                cylinder(d=4.8, h=7);
                
                // Countersink
                translate([0,0,3]) {
                    #cylinder(d1=4.8, d2=9, h=4);
                }
                
                // Hollow out the remaining hole
                translate([0,0,7]) {
                    cylinder(d=10, h=9);
                }
            }

            translate([20.0, (12.75/2),0]) {
                cylinder(d=4.8, h=7);
                
                // Countersink
                translate([0,0,3]) {
                    cylinder(d1=4.8, d2=9, h=4);
                }
                
                // Hollow out the remaining hole
                translate([0,0,7]) {
                    cylinder(d=10, h=9);
                }
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////

nfcPcbLength = 43; // 43
nfcPcbWidth = 40; // 40

module nfcPcbCutout() {

paddedNfcPcbLength = nfcPcbLength+1; // 43
paddedNfcPcbWidth = nfcPcbWidth+1; // 40    

    
    // PCB
    // Make the PCB slot 
    translate([-paddedNfcPcbLength/2,-paddedNfcPcbWidth/2, baseHeight - pcbDepth + 0.1]) {
        
        cube([paddedNfcPcbLength, paddedNfcPcbWidth, pcbDepth]);
        // TODO: Add holes for PCB when we know where they go!
    }
    
    // PCB Cables, through to the bottom compartment
    translate([-nfcPcbLength/2,-nfcPcbWidth/2, baseHeight - pcbDepth + 0.1]) {    
        // I2C Connection
        translate([5,(nfcPcbWidth/2)-6,-8]) {
            #cube([4,12,8]);
        }
        
        // IRQ and Reset pins
        translate([28,32,-8]) {
            #cube([8,4,8]);
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
nfcPcbHeight = 3;
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

////////////////////////////////////////////////////////////////////////


bottleDiameter = 100;
wallThickness = 3;
bottlePadding = 2;

baseHeight = 2+9; // 2mm for loadcell screen + 9mm for PCB

neoPixelPcbDepth = 3.4;
pcbDepth = neoPixelPcbDepth + 2;

module bottleHolder() {
h = 14; //22 //height;    

    
    difference() {
        union() {
            cylinder(d=bottleDiameter + bottlePadding + wallThickness, h=h);
        }
        union() {
            
            // Cout out the bulk of the inside, except 
            // give a 4mm lip 2mm high to guide the resin
            // pouring.
            translate([0,0,baseHeight+2]) {
                cylinder(d=bottleDiameter + bottlePadding, h=(h - baseHeight)+0.1);
            }
            
            translate([0,0,baseHeight]) {
                cylinder(d=bottleDiameter - 4, h=(h - baseHeight)+0.1);
            }
                               
            loadCellHoles();
            
            nfcPcbCutout();
            
            // Neopixel is about 3.4mm deep
            translate([0,0,baseHeight-3.4]) {
                neoPixelCutout();            
            }
        }
    }
    
    // PCB Pins
    nfcPcbPins();
}

bottleHolder();

translate([0,0,baseHeight - pcbDepth]) {
   // showModels();
}