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

module photonPcb() {
    //color("Blue", 50) {
        // NB Max PCB Height == ... (10)
        // Can't socket mount Photon. Perhaps
        // use SMD version.
        cube([55, 70, 10]);
    //}
}

module loadCellPcb() {
    cube([30, 50, 6]);
}

module loadCell() {

    
    //translate([-30,-(loadcellWidth/2),-2]) {
    translate([+(loadcellWidth/2)+1,-46,-0.1]) {
        rotate([0,0,90]) {
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
}

baseFloorThickness = 5;

// Holes for the Load Cell
module loadCellHoles() {
    //translate([-30,-(loadcellWidth/2)-1,-0.1]) {
    translate([+(loadcellWidth/2)+1,-46,-0.1]) {
        rotate([0,0,90]) {
                
                // allow more cutout space for the load cell to hover over
                translate([-3,-1,baseFloorThickness-2.5]) {
                    cube([56,loadcellWidth+4,3]);
                }
                
                //  bolt holes
                translate([61, (12.75/2)+1,0]) {
                    // M5 thread in load cell
                    cylinder(d=6, h=53);
                    translate([0,0,0]) {
                        // High enough to 
                        cylinder(d=12, h=3);
                    }
                }
                translate([76, (12.75/2)+1,0]) {
                    // M5 thread in load cell
                    cylinder(d=6, h=53);
                    translate([0,0,0]) {
                        cylinder(d=12, h=3);
                    }
                }        
               
            }
        }
}

module pcbSupport() {
    difference() {
        union() {
            cylinder(d=7, h=8);
        }
        union() {
            translate([0,0,1.5]) {
                cylinder(d=4, h=8);
            }
        }
    }
}

module pcbSupports() {
    // Back supports
    translate([25,0,0]) {
        translate([0,20,0]) {
            pcbSupport();
        }
        translate([0,-20,0]) {
            pcbSupport();
            
        }
    }
    
    // Front supports (for load cell amplifier.
    translate([-40,0,0]) {
        translate([0,20,0]) {
            pcbSupport();
        }
        translate([0,-20,0]) {
            pcbSupport();
            
        }
    }
    
    translate([-15,0,0]) {
        translate([0,20,0]) {
            pcbSupport();
        }
        translate([0,-20,0]) {
            pcbSupport();
            
        }
    }
}

module pcbSupportHoles() {
    // Back supports
    translate([25,0,1.5]) {
        translate([0,20,0]) {
            cylinder(d=4, h=8);
        }
        translate([0,-20,0]) {
            cylinder(d=4, h=8);
            
        }
    }
    
    // Front supports (for 
    translate([-40,0,1.5]) {
        translate([0,20,0]) {
            cylinder(d=4, h=8);
        }
        translate([0,-20,0]) {
            cylinder(d=4, h=8);
            
        }
    }
    
    translate([-15,0,1.5]) {
        translate([0,20,0]) {
            cylinder(d=4, h=8);
        }
        translate([0,-20,0]) {
            cylinder(d=4, h=8);
            
        }
    }
}

module base() {


// Load cell sticks out 2mm from the bottle holder part.
h=baseFloorThickness+1.5 + loadcellHeight;
pcbBoxDepth = 45;
pcbBoxHeight = h;
    
    difference() {
        union() {
            cylinder(d=bottleDiameter + bottlePadding + wallThickness, h=h);
            
            // Read Box
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
            #loadCellHoles();
            
            
            // Hollow out QI receier holder.
            translate([+31,-75/2,1]) {
               cube([45, 75,baseFloorThickness+1]);
            }
            
            #pcbSupportHoles();
        }
    }    
    
    // PCB Supports
    pcbSupports();
}

module showModels() {
    
    //PhotonPcb();
    
    translate([-26,-75/2,0.6]) {
        //QIReceiver();
    }
    
    // 7mm for 
    translate([-1,2,7]) {
        //showTop();
        loadCell();
    }
    
    translate([20,-35,8]) {
        %photonPcb();
    }
    
    translate([-42,-25,7]) {
        %loadCellPcb();
    }
        

}

//showModels();

base();

