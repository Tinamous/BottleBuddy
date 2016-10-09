$fn = 90;
bottleDiameter = 100;
wallThickness = 2;
bottlePadding = 2;

//height = 100;
height = 40;

loadcellHeight = 12.75;
loadcellWidth = 12.75;
loadcellLength = 80;

module bottle() {
    cylinder(d=bottleDiameter, h=225);
}

module nfcPcb() {
    // todo...
    // 85x54mm
    translate([-(86/2)+6,-(55/2),0]) {
        cube([86, 55,3]);
    }
}

module loadCell() {

    
    translate([-30,-(loadcellWidth/2),-2]) {
        color("Gainsboro", 50) { 
            difference() {
                union() {
                    cube([loadcellLength, loadcellWidth, loadcellHeight]);
                    // strain gauge placement + goo
                    translate([(loadcellLength/2)-15,0,loadcellHeight]) {
                        cube([30,loadcellWidth,1]);
                    }
                    translate([(loadcellLength/2)-15,0,-1]) {
                        cube([30,loadcellWidth,1]);
                    }
                }
                union() {
                    translate([6, (12.75/2),0]) {
                        cylinder(d=4, h=13);
                    }
                    translate([21, (12.75/2),0]) {
                        cylinder(d=4, h=13);
                    }
                    
                    translate([59, (12.75/2),0]) {
                        cylinder(d=4, h=13);
                    }
                    translate([74, (12.75/2),0]) {
                        cylinder(d=4, h=13);
                    }
                }
            }
        }
    }
}

module M4Bolts() {
}

module bottleHolder() {
h = 40; //22 //height;    
baseHeight = 20;
    

    difference() {
        union() {
            cylinder(d=bottleDiameter + bottlePadding + wallThickness, h=h);
        }
        union() {
            translate([-30,-(loadcellWidth/2)-1,-2]) {
                // Load Cell
                cube([loadcellLength+2, loadcellWidth+2, loadcellHeight]);
                // Cut out extra to allow for top 
                // surface of the load cell.
                translate([25,0,2]) {
                    cube([loadcellLength - 20, loadcellWidth+2, loadcellHeight]);
                }
                
                //  bolt holes
                translate([6, (12.75/2)+1,loadcellHeight + 0]) {
                    #cylinder(d=4, h=53);
                    translate([0,0,15-loadcellHeight ]) {
                        // High enough to 
                        cylinder(d=10, h=6);
                    }
                }
                translate([21, (12.75/2)+1,loadcellHeight + 0]) {
                    cylinder(d=4, h=53);
                    translate([0,0,15-loadcellHeight ]) {
                        cylinder(d=10, h=6);
                    }
                }
            }
            
            // PCB
            // Make the PCB slot in from 
            translate([-(86/2)+6,-(55/2),17]) {
                #cube([86+30, 55,3.1]);
                // TODO: Add holes for PCB when we know where they go!
            }
            
            translate([0,0,baseHeight]) {
                #cylinder(d=bottleDiameter + bottlePadding, h=(height - baseHeight)+0.1);
            }
        }
    }
}


module showModels() {
    loadCell();
    
    translate([0,0,17]) {
        nfcPcb();
    }
    // 3mm up due to PCB + 2mm layer
    translate([0,0,35]) {
        //bottle();
    }
}

showModels();

bottleHolder();