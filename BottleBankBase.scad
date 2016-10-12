$fn = 190;
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

loadCellPcbXOffset = -34;
loadCellPcbYOffset = -35;
loadCellPcbWidth = 21;

module showBottleHolder() {
    import("BottleBuddyTop.stl");
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

loadCellPcbSpaceBetweenHoles = 15;

module loadCellPcb() {
    cube([21, 36, 6]);
    
    translate([2.5,2.5, -3]) {
        cylinder(d=2, h=20);
    }
    
    // 15mm gap between screws
    
    translate([2.5 + loadCellPcbSpaceBetweenHoles,2.5, -3]) {
        cylinder(d=2, h=20);
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
            translate([60, (12.75/2)+1,0]) {
                // M5 thread in load cell
                cylinder(d=5.5, h=23);
                translate([0,0,0]) {
                    // Holt head.
                    cylinder(d=11, h=3);
                }
            }
            translate([75, (12.75/2)+1,0]) {
                // M5 thread in load cell
                cylinder(d=5.5, h=23);
                translate([0,0,0]) {
                    cylinder(d=11, h=3);
                }
            }        
           
        }
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

module pcbSupports() {
    // Back supports
    translate([23,0,0]) {
        translate([0,20,0]) {
            pcbSupport(4);
        }
        translate([0,-20,0]) {
            pcbSupport(4);
            
        }
    }
    
    // Front supports (for load cell amplifier.
    translate([loadCellPcbXOffset,loadCellPcbYOffset,0]) {
        
        // Offset from top right corder for 
        // the pcb hole.
        translate([+2.5,+2.5,0]) {
            pcbSupport(2);
            
        }
        
        // left hand corner
        translate([+2.5 + loadCellPcbSpaceBetweenHoles, +2.5, 0]) {
            pcbSupport(2);
        }
    }
    
    // left hand corner
    
}
module pcbSupportHoles() {
    // Back supports
    translate([23,0,1.5]) {
        translate([0,20,0]) {
            cylinder(d=4, h=8);
        }
        translate([0,-20,0]) {
            cylinder(d=4, h=8);
            
        }
    }
    
    // Front supports (for 
    translate([loadCellPcbXOffset,loadCellPcbYOffset,1]) {
        translate([+2.5,+2.5,0]) {
            #cylinder(d=2, h=8);
            
        }
    
        translate([+2.5 + loadCellPcbSpaceBetweenHoles, +2.5, 0]) {
            #cylinder(d=2, h=18);
            
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
            
            // Rear Box
            //translate([32, -40,0]) {
                //cube([pcbBoxDepth,80, pcbBoxHeight]);
            translate([0, -52.5,0]) {
                cube([pcbBoxDepth+32,105, pcbBoxHeight]);
            }
        }
        union() {
            // Holes for the Load Cell
            loadCellHoles();
            
            // Hollow out the cylidrical base.
            translate([0,0,baseFloorThickness]) {
                cylinder(d=bottleDiameter + bottlePadding, h=pcbBoxHeight+10);
            }
            
            // Hollow out the rear comparetment
            translate([13, -47, baseFloorThickness]) {
                //cube([pcbBoxDepth,76, pcbBoxHeight-baseFloorThickness +0.1]);
                cube([pcbBoxDepth+16,94, pcbBoxHeight-baseFloorThickness +0.1]);
            }
            
            // Hollow out the rest or read comparment of PCB.
            // Not very tidy at this time!
            // match PCB height
            translate([10.5, -51, 8]) {
                //cube([pcbBoxDepth,76, pcbBoxHeight-baseFloorThickness +0.1]);
                cube([pcbBoxDepth+18.5,102, pcbBoxHeight-baseFloorThickness +0.1]);
            }
                        
            // Hollow out QI receier holder.
            translate([+29,-75/2,1]) {
               cube([45, 75,baseFloorThickness+1]);
            }
            
            pcbSupportHoles();
        }
    }    
        
    // PCB Supports
    pcbSupports();
    
    loadCellGuard();
}

module showModels() {
    
    //PhotonPcb();
    
    translate([0,0,baseFloorThickness]) {
        %importLoadCellModel();
        //%loadCell();
    }
    
    translate([-26,-75/2,0.6]) {
        //QIReceiver();
    }
    
    // 7mm for 
    translate([0,0,17.5]) {
        showBottleHolder();
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

