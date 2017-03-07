$fn = 90;
bottleDiameter = 100;
wallThickness = 3;
bottlePadding = 2;
baseFloorThickness = 5;

loadcellHeight = 12.75;
loadcellWidth = 12.75;
loadcellLength = 79.5;
loadCellOffset = -48;

gabBetweenTopAndBottom = 1.5;
wallHeight=baseFloorThickness + loadcellHeight - gabBetweenTopAndBottom;
echo ("WallHeight (i.e. total height)=" ,wallHeight);

loadCellPcbXOffset = -42;
loadCellPcbYOffset = -15;
loadCellPcbWidth = 21;
loadCellPcbSpaceBetweenHoles = 18;

module showBottleHolder() {
    import("BottleBuddyTop.stl");
}

module QIReceiver() {
    color("Black", 50) {
        cube([45, 75,1]);
    }
}

module loadCellPcb() {
    cube([23, 33, 6]);
    
    translate([2.5,2.5, -3]) {
        cylinder(d=2, h=20);
        
        translate([0,25, 0]) {
            cylinder(d=2, h=20);
        }
    }
    
    // 15mm gap between screws
    
    translate([2.5 + loadCellPcbSpaceBetweenHoles,2.5, -3]) {
        cylinder(d=2, h=20);
        
        translate([0,25, 0]) {
            cylinder(d=2, h=20);
        }
    }
}

module importLoadCellModel() {
    import("LoadCellModel.stl");
}

// Load cell model to project into the design for fit.
module loadCell() {
    //import("LoadCellModel.stl");
    
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



// Holes for the Load Cell
module loadCellHoles() {
    //translate([-30,-(loadcellWidth/2)-1,-0.1]) {
    rotate([0,0,90]) {
        translate([loadCellOffset,-(loadcellWidth+2)/2, -0.1]) {
            // allow more cutout space for the load cell to hover over
            translate([-2,0, 1]) {
                cube([56,loadcellWidth+2,baseFloorThickness]);
            }
            
            //  bolt holes
            translate([00,(12.75/2)+1,0]) {
                translate([60,0,0]) {
                    loadCellHole();
                }
                translate([75, 0,0]) {
                    #loadCellHole();
                }        
            }
           
        }
    }
}
module loadCellHole() {
    // M5 thread in load cell
    #cylinder(d=10, h=1);
    // Counter sink
    translate([0,0,1]) {
        #cylinder(d1=10, d2=5.5,h=3.5);
    }
    // hole for threaded bolt part
    translate([0,0,4]) {
            #cylinder(d=5.5, h=10);
    }
}

// A guard around the load cell to allow pouring of 
// potting compound around the electronics without getting into the load cell.
module loadCellGuard() {
    rotate([0,0,90]) {
        translate([loadCellOffset-3,-(loadcellWidth)/2 - 4, baseFloorThickness]) {
            
            difference() {
                union() {
                    cube([loadcellLength+8,loadcellWidth+8,wallHeight-baseFloorThickness]);
                }
                union() {
                    translate([1,+2, 0]) {
                        cube([loadcellLength + 4,loadcellWidth+4,loadcellHeight]);
                    }
                    // cut out wire exit
                    translate([loadcellLength + 4,2, loadcellHeight-4]) {
                        cube([6,4,4]);
                    }
                }
            }
            
        }
    }
}


module loadCellPadding() {
    
        rotate([0,0,90]) {
            translate([loadCellOffset,-(loadcellWidth+2)/2,-0.1]) {
            // allow more cutout space for the load cell to hover over
                translate([56,0,baseFloorThickness]) {
                   //cube([26,loadcellWidth,loadCellZPadding]);
                }
        }
    }
}



module pcbSupport(d) {
    difference() {
        union() {
            cylinder(d=7, h=8);
        }
        union() {
            translate([0,0,1.5]) {
                cylinder(d=d, h=8);
            }
        }
    }
}

module pcbPin() {
    cylinder(d=4, h=8);
    cylinder(d=2, h=9.5);
}

module loadCellPcbMount() {
    // Front supports (for load cell amplifier)
    translate([loadCellPcbXOffset,loadCellPcbYOffset,0]) {
        
        // Offset from top right corder for 
        // the pcb hole.
        translate([+2.5,+2.5,0]) {
            pcbPin(2);
        }
        
        // left hand corner
        translate([+2.5 + loadCellPcbSpaceBetweenHoles, +2.5, 0]) {
            // Hole for a M3 brass fixing.
            pcbSupport(4);
        }
    }
    
    translate([loadCellPcbXOffset,loadCellPcbYOffset + 25,0]) {
        
        // Offset from top right corder for 
        // the pcb hole.
        translate([+2.5,+2.5,0]) {
            pcbPin(2);
            
        }
        
        // left hand corner
        translate([+2.5 + loadCellPcbSpaceBetweenHoles, +2.5, 0]) {
            pcbPin(2);
        }
    }
}

module pcbSupports() {
    loadCellPcbMount();    
}
module pcbSupportHoles() {
   
    // Front supports (for load cell amplifier)
    translate([loadCellPcbXOffset,loadCellPcbYOffset,1]) {
        translate([+2.5,+2.5,0]) {
            #cylinder(d=2, h=8);
            
        }
    
        translate([+2.5 + loadCellPcbSpaceBetweenHoles, +2.5, 0]) {
            #cylinder(d=2, h=18);
            
        }
    }
}

module batteryBox() {
    difference() {
        union() {
            cube([37.5, 55, 12]);
        }
        union() {
            translate([1.5, 1.5,1]) {
                cube([34.5, 52, 12]);
            }
        }
    }
}

module base() {

// Adjust for 
h=wallHeight;
pcbBoxDepth = 45;
pcbBoxHeight = h;
    
    difference() {
        union() {
            cylinder(d=bottleDiameter + bottlePadding + wallThickness, h=h);
        }
        union() {
            // Holes for the Load Cell
            loadCellHoles();
            
            // Hollow out the cylidrical base.
            translate([0,0,baseFloorThickness]) {
                cylinder(d=bottleDiameter + bottlePadding, h=pcbBoxHeight+10);
            }
            
            pcbSupportHoles();
        }
    }    
        
    // PCB Supports
    pcbSupports();
    
    loadCellGuard();
    
    translate([8, -55/2, 3]) {
        batteryBox();
    }
}

module showModels() {
    
    //PhotonPcb();
    
    translate([0,0,baseFloorThickness]) {
        //%importLoadCellModel();
        //%loadCell();
    }
    
    translate([-26,-75/2,0.6]) {
        //QIReceiver();
    }
    
    // top
    translate([0,0, 27.5]) {
        //showBottleHolder();
    }
    
    translate([20,-35,8]) {
        //%photonPcb();
    }
    
    //translate([-42,-25,7]) {
    translate([loadCellPcbXOffset, loadCellPcbYOffset, 5]) {
        %loadCellPcb();
    }
}

showModels();

base();

