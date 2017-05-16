$fn = 360;
bottleDiameter = 100;
wallThickness = 3;
bottlePadding = 2;
baseFloorThickness = 2;

loadcellHeight = 12.75;
loadcellWidth = 12.75;
loadcellLength = 79.5;
loadCellOffset = -48;

gabBetweenTopAndBottom = 1.5;
wallHeight=baseFloorThickness + loadcellHeight - gabBetweenTopAndBottom;
echo ("WallHeight (i.e. total height)=" ,wallHeight);

loadCellPcbXOffset = -36;
loadCellPcbYOffset = -32;
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
            // Load cell is raised slighly now so no need for a cut out.
            // allow more cutout space for the load cell to hover over
            //translate([-2,0, 1]) {
            //    #cube([56,loadcellWidth+2,baseFloorThickness]);
            //}
            
            //  bolt holes
            translate([00,(12.75/2)+1,0]) {
                translate([60,0,0]) {
                    loadCellHole();
                }
                translate([75, 0,0]) {
                    loadCellHole();
                }        
            }
           
        }
    }
}

module loadCellHole() {
    // M5 thread in load cell
    // Small recess for the bolt head
    // so we don't end up with any metal on a surface if
    // no feet are fitted.
    translate([0,0,-0.1]) {
        cylinder(d=10, h=1.21);
    }
    // Counter sink
    translate([0,0,1.1]) {
        cylinder(d1=10, d2=5.5,h=3.5);
    }
    // hole for threaded bolt part
    translate([0,0,3]) {
        cylinder(d=5.5, h=10);
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

// Guard modified to help keep wires out but skipping the battery box.
module loadCellGuard2() {
    rotate([0,0,90]) {
        translate([loadCellOffset-3,-(loadcellWidth)/2 - 4, baseFloorThickness]) {
            
            difference() {
                union() {
                    cube([loadcellLength+8,loadcellWidth+4,wallHeight-baseFloorThickness]);
                }
                union() {
                    translate([1,+2, 0]) {
                        #cube([loadcellLength + 4,loadcellWidth+2,loadcellHeight]);
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

// ******************************************************
// Load cell PCB support pins/pads/holes
// ******************************************************
module pcbSupport(d, h) {
    difference() {
        union() {
            cylinder(d=7, h=h);
        }
        union() {
            translate([0,0,-0.1]) {
                cylinder(d=d, h=h+2);
            }
        }
    }
}

module pcbPin() {
    cylinder(d=4, h=3);
    cylinder(d=2, h=4.5);
}

module loadCellPcbMount() {
    rotate([0,0,180]) {
        // Front supports (for load cell amplifier)
        translate([loadCellPcbXOffset,loadCellPcbYOffset,0]) {
            
            // Offset from top right corder for 
            // the pcb hole.
            translate([+2.5,+2.5,0.5]) {
                pcbPin(2);
            }
            
            // left hand corner
            translate([+2.5 + loadCellPcbSpaceBetweenHoles, +2.5, baseFloorThickness]) {
                // Hole for a M3 bolt to come through
                pcbSupport(3.6, 3.5 - baseFloorThickness);
            }
        }
        
        translate([loadCellPcbXOffset,loadCellPcbYOffset + 25,0]) {
            
            // Offset from top right corder for 
            // the pcb hole.
            translate([+2.5,+2.5,0.5]) {
                pcbPin(2);
                
            }
            
            // left hand corner
            translate([+2.5 + loadCellPcbSpaceBetweenHoles, +2.5, 0.5]) {
                pcbPin(2);
            }
        }
    }
}

module pcbSupports() {
    loadCellPcbMount();    
}

module pcbSupportHoles() {
   rotate([0,0,180]) {
        // Front supports (for load cell amplifier)
        translate([loadCellPcbXOffset,loadCellPcbYOffset,-0.1]) {
            translate([+2.5 + loadCellPcbSpaceBetweenHoles, +2.5, 0]) {
                cylinder(d1=7,d2=3.5, h=2);
                cylinder(d=3.5, h=18);
                
            }
        }
    }
}

// ******************************************************
// Battery/Power
// ******************************************************

module hollowFloorForBattery() {
    // Hollow out a little of the follow so the battery (or rather
    // the QI adaptor is closer to the base) default floor thickness
    // is 2mm, QI works at 3mm, not much tollerence left.
    cube([34, 52, 1]);
}

module batteryBox() {
wallHeight = 8;
    
    difference() {
        union() {
            cube([36.5, 54, wallHeight]);
        }
        union() {
            translate([0, 1,0]) {
                cube([35, 52, 12]);
            }
            
            // Top of battery is wider and needs cable exit.
            translate([3, 1,0]) {
                cube([38.5, 10, 15]);
            }
        }
    }
}

module holeForPowerIn() {
    translate([23,-38,0]) {
        #cylinder(d=10, h=12);
    }
}

// ******************************************************

// Add small indents for the feet to be stuck into
// placed evenly around.
module footPadHoles() {
offset = (bottleDiameter /2) -6;
    
startOffsetAngle    = 45;
    footPadHole(offset,startOffsetAngle);
    footPadHole(offset,90+startOffsetAngle);
    footPadHole(offset,180+startOffsetAngle);
    footPadHole(offset,270+startOffsetAngle);
}

module footPadHole(x,rotateBy) {
    rotate([0, 0, rotateBy]) {
        translate([x,0,-0.01]) {
            cylinder(d=10, h=1.0);
        }
        
    }
}

module usbPowerIn() {
// pcb is 18mm wide by 27mm by 6mm deep.
width = 12;
    translate([(bottleDiameter/2)-5,-(width /2),baseFloorThickness]) {
        cube([10, 12, 10]);
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
            // Raise the loadcell up.
            translate([-15/2,5.5,0]) {
                cube([15,29.5,5]);
            }
        }
        union() {
            // Holes for the Load Cell
            loadCellHoles();
            
            // Hollow out the cylidrical base.
            translate([0,0,baseFloorThickness]) {
                cylinder(d=bottleDiameter + bottlePadding, h=pcbBoxHeight);
            }
            
            pcbSupportHoles();
                        
            footPadHoles();
            
            translate([(-53 +9) , -53/2, 1.1]) {
                #hollowFloorForBattery();
            }
            
            // Bit of a hack for now....
            // a hole to allow power cables to come in.
            holeForPowerIn();
            
            // Optional
            //usbPowerIn();
        }
    }    
        
    // PCB Supports
    pcbSupports();
    
    //loadCellGuard();
    loadCellGuard2();
    
    translate([-53 + 9, -55/2, 1]) {
        batteryBox();
    }
    
    difference() {
        union() {
            // Raise the loadcell up.
            // Helps keep the base thin and allow for the bolts to 
            // be counter sunk.
            translate([-15/2,6,0]) {
                // 29mm on y min.
                // 45mm takes it to the edge.
                cube([15,45,5]);
            }
        }
        union() {
            loadCellHoles();
        }
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
    rotate([0,0,180]) {
        translate([loadCellPcbXOffset, loadCellPcbYOffset, 5]) {
            %loadCellPcb();
        }
    }
}

showModels();

base();

