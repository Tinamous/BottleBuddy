$fn = 90;
bottleDiameter = 100;
wallThickness = 3;
bottlePadding = 2;

loadcellHeight = 12.75;
loadcellWidth = 12.75;
loadcellLength = 80;


module showTop() {
    import("BottleBank.stl");
}

module QIReceiver() {
    color("Black", 50) {
        cube([45, 75,1]);
    }
}

module PhotonPcb() {
    translate([70,-10,8]) {
        rotate([0,-90,0]) {
            color("Blue", 50) {
                cube([45, 45, 17]);
            }
        }
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

module base() {

baseFloorThickness = 5;
// Load cell sticks out 2mm from the bottle holder part.
h=baseFloorThickness+1.5 + loadcellHeight;
pcbBoxDepth = 45;
pcbBoxHeight = h;
    
    difference() {
        union() {
            cylinder(d=bottleDiameter + bottlePadding + wallThickness, h=h);
            translate([32, -40,0]) {
                cube([pcbBoxDepth,80, pcbBoxHeight]);
            }
        }
        union() {
            // Hollow out the cylidrical base.
            translate([0,0,baseFloorThickness]) {
                cylinder(d=bottleDiameter + bottlePadding, h=pcbBoxHeight+10);
            }
            // Hollow out the PCB Comparetment
            translate([31, -38, baseFloorThickness]) {
                cube([pcbBoxDepth,76, pcbBoxHeight-baseFloorThickness +0.1]);
            }
            
            // Holes for the Load Cell
            translate([-30,-(loadcellWidth/2)-1,-0.1]) {
                
                // allow more cutout space for the load cell to hover over
                translate([-10,-1,baseFloorThickness-2.5]) {
                    #cube([63,loadcellWidth+4,3]);
                }
                
                //  bolt holes
                translate([61, (12.75/2)+1,0]) {
                    // M5 thread in load cell
                    #cylinder(d=6, h=53);
                    translate([0,0,0]) {
                        // High enough to 
                        #cylinder(d=12, h=3);
                    }
                }
                translate([76, (12.75/2)+1,0]) {
                    // M5 thread in load cell
                    cylinder(d=6, h=53);
                    translate([0,0,0]) {
                        #cylinder(d=12, h=3);
                    }
                }        
            }
            
            // Hollow out QI receier holder.
            translate([-26,-75/2,1]) {
               cube([45, 75,baseFloorThickness+1]);
            }
        }
    }
}

module showModels() {
    
    //PhotonPcb();
    
    translate([-26,-75/2,0.6]) {
        //QIReceiver();
    }
    
    // 7mm for 
    translate([0,0,7]) {
        //showTop();
        //loadCell();
    }

}

showModels();

base();

