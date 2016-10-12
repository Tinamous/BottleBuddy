$fn = 190;
bottleDiameter = 100;
wallThickness = 3;
bottlePadding = 2;

//height = 100;
height = 40;

loadcellHeight = 12.75;
loadcellWidth = 12.75;
loadcellLength = 80;
loadCellOffset = -48;

module bottle() {
    cylinder(d=bottleDiameter, h=225);
}

module neoPixelPcb() {
    
    difference() {
        union() {
            cube([10.5, 51.5, 3.5]);
        }
        union() {    
            // 12.8
            // 26mm between centers.
            // todo. add wires...
            
            translate([3,12.8,0]) {
                cylinder(d=3, h=20);
                
                translate([0,26,0]) {
                    cylinder(d=3, h=20);
                }
            }
        }
    }
}

module nfcPcb() {
    // todo...
    // 85x54mm
    translate([-(86/2)+6,-(55/2),0]) {
        cube([86, 55,3]);
    }
}

module nfcPcbRC522() {
    
    // todo...
    // 85x54mm
    translate([-(60/2)+10,-(40/2),0]) {
        difference() {
            union() {
                cube([61, 40,7]);
                
                // Tag center.
                translate([20,20,0]) {
                    cylinder(d=8, h=10);
                }
            }
            union() {
                translate([7,7,0]) {
                    cylinder(d=3, h=4);
                }
                
                translate([7,40-7,0]) {
                    cylinder(d=3, h=4);
                }
                
                
                translate([44,3,0]) {
                    cylinder(d=3, h=4);
                }
                
                translate([44,40-3,0]) {
                    cylinder(d=3, h=4);
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

module M4Bolts() {
}

module boxLid() {
pcbBoxDepth = 45;
pcbBoxHeight = 1;
    
    difference() {
        union() {
            translate([32, -40,0]) {
                cube([pcbBoxDepth,80, pcbBoxHeight]);
            }
        }
        union() {
            // Hollow out the PCB Comparetment
            translate([31, -38, 0]) {
            //    cube([pcbBoxDepth,76, pcbBoxHeight]);
            }
        }
    }
}

module wideLid() {
pcbBoxDepth = 45;
pcbBoxHeight = 1;
    
    difference() {
        union() {
            translate([0, -52.5,0]) {
                cube([pcbBoxDepth+32,105, pcbBoxHeight]);
            }
        }
        union() {
            // Hollow out the PCB Comparetment
            translate([31, -38, 0]) {
            //    cube([pcbBoxDepth,76, pcbBoxHeight]);
            }
        }
    }
}


module hollowBox(h) {
pcbBoxDepth = 45;
pcbBoxHeight = h;
    
    difference() {
        union() {
            translate([32, -40,0]) {
                cube([pcbBoxDepth,80, pcbBoxHeight]);
            }
        }
        union() {
            // Hollow out the PCB Comparetment
            translate([31, -38, 0]) {
                cube([pcbBoxDepth,76, pcbBoxHeight]);
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
            translate([5.0, (12.75/2), 0]) {
                #cylinder(d=4.5, h=53);
                translate([0,0,5-loadcellHeightOffset ]) {
                    // High enough to 
                    cylinder(d=10, h=102);
                }
            }

            translate([20.0, (12.75/2),0]) {
                cylinder(d=4.5, h=53);
                translate([0,0,5-loadcellHeightOffset ]) {
                    cylinder(d=10, h=12);
                }
            }
        }
    }
}

baseHeight = 2 + 11.9; // 2mm for loadcell scren + 12 mm for. (PCB?)
pcbDepth = 9;

// How thick the PCB is.
pcbThickness = 2;
// Space above the PCB 
// to allow for wire poking through on connector
pcbOffsetFromTop = 2;

module bottleHolder() {
h = 30; //22 //height;    

    
    difference() {
        union() {
            cylinder(d=bottleDiameter + bottlePadding + wallThickness, h=h);
            
            //hollowBox(h);
            //boxLid(h);
            wideLid(h);
        }
        union() {
       
            loadCellHoles();
            
            // PCB
            // Make the PCB slot 
            translate([-(60/2)+10,-(40/2), baseHeight - pcbDepth + 0.1]) {
                //cube([86+20, 55,3.1]);
                cube([62, 40, pcbDepth]);
                // TODO: Add holes for PCB when we know where they go!
            }
            
            // PCB Cables, through to the bottom compartment
            translate([38,0,0]) {
                translate([0,-9,0]) {
                    cube([2, 5, 8]);
                }
                translate([0,9-5,0]) {
                    cube([2, 5, 8]);
                }
            }
            
            // Cout out the bulk of the inside, except 
            // give a 4mm lip 2mm high to guide the resin
            // pouring.
            translate([0,0,baseHeight+2]) {
                cylinder(d=bottleDiameter + bottlePadding, h=(h - baseHeight)+0.1);
            }
            
            translate([0,0,baseHeight]) {
                cylinder(d=bottleDiameter -4, h=(h - baseHeight)+0.1);
            }
            
            // Cut out for neopixel strip at front.
            translate([-32,-(52/2) +30,-2]) {
                //cylinder(d=3, h=baseHeight+0.1);
                rotate([30,0,0]) {
                    cube([6,3,baseHeight+0.1+20]);
                }
            }
            translate([-35,-52/2,baseHeight - pcbDepth + 0.1]) {
                cube([12,53,pcbDepth]);
            }
            
        }
    }
    

    
    // PCB Pins
    translate([-(60/2)+11,-(40/2), baseHeight - pcbDepth]) {
        translate([7,7,0]) {
            cylinder(d=4, h=pcbDepth - pcbOffsetFromTop - pcbThickness);
            cylinder(d=2, h=pcbDepth - pcbOffsetFromTop);
        }
        
        translate([7,40-7,0]) {
            cylinder(d=4, h=pcbDepth - pcbOffsetFromTop - pcbThickness);
            cylinder(d=2, h=pcbDepth - pcbOffsetFromTop);
        }
        
        
        translate([44,3,0]) {
            cylinder(d=4, h=pcbDepth - pcbOffsetFromTop - pcbThickness);
            cylinder(d=2, h=pcbDepth - pcbOffsetFromTop);
        }
        
        translate([44,40-3,0]) {
            cylinder(d=4, h=pcbDepth - pcbOffsetFromTop - pcbThickness);
            cylinder(d=2, h=pcbDepth - pcbOffsetFromTop);
        }
    }
    
    //neoPixelPcbPins
    translate([-34.5,-52/2 + 1,baseHeight - pcbDepth + 0.1]) {
        translate([3,12.8,0]) {
            //cylinder(d=3, h=200);
            cylinder(d=4, h=pcbDepth - pcbOffsetFromTop - pcbThickness);
            cylinder(d=1.5, h=pcbDepth - pcbOffsetFromTop);
            
            translate([0,26,0]) {
                //cylinder(d=3, h=200);
                cylinder(d=4, h=pcbDepth - pcbOffsetFromTop - pcbThickness);
                cylinder(d=1.5, h=pcbDepth - pcbOffsetFromTop);
            }
        }
    }
}


module showModels() {
    //%loadCell();
    translate([0,0,-12.75]) {
        %importLoadCellModel();
    }
    
    
    translate([0,0,baseHeight - pcbDepth]) {
        //nfcPcb();
        %nfcPcbRC522();
    }
    
    translate([-34.5,-52/2 +1,baseHeight -5]) {
        %neoPixelPcb();
    }
    
    // 3mm up due to PCB + 2mm layer
    translate([0,0,loadcellHeight + 5 + 5]) {
        //bottle();
    }
}

showModels();

bottleHolder();