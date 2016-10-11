$fn = 150;
bottleDiameter = 100;
wallThickness = 3;
bottlePadding = 2;

//height = 100;
height = 40;

loadcellHeight = 2;// 12.75;
loadcellWidth = 12.75;
loadcellLength = 80;

module neoPixelStrip() {
    cube([11,52,4]);
}

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

module loadCell() {

    
    translate([+(loadcellWidth/2)+1,-38,-loadcellHeight]) {
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
    
    //translate([-30,-(loadcellWidth/2)-1,-2]) {
    translate([+(loadcellWidth/2)+1,-46,-2]) {
            rotate([0,0,90]) {
            // Load Cell cutout to allow for movement.
            // Cut out extra to allow for top 
            // surface of the load cell.
            translate([26,-1,2]) {
                cube([loadcellLength - 20, loadcellWidth+4, loadcellHeight+2]);
            }
            
            //  bolt holes
            translate([6, (12.75/2)+1,loadcellHeight + 0]) {
                cylinder(d=5, h=53);
                translate([0,0,5-loadcellHeight ]) {
                    // High enough to 
                    cylinder(d=10, h=12);
                }
            }

            translate([21, (12.75/2)+1,loadcellHeight + 0]) {
                cylinder(d=5, h=53);
                translate([0,0,5-loadcellHeight ]) {
                    cylinder(d=10, h=12);
                }
            }
        }
    }
}

module bottleHolder() {
h = 30; //22 //height;    
baseHeight = loadcellHeight + 11.9;
    
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
            // Make the PCB slot in from 
            translate([-(60/2)+10,-(40/2),loadcellHeight + 5]) {
                //cube([86+20, 55,3.1]);
                cube([62, 40,7]);
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
            translate([-31,-(54/2) +3,0]) {
                cylinder(d=3, h=baseHeight+0.1);
            }
            translate([-37,-54/2,baseHeight-4]) {
                cube([13,54,4]);
            }
            
        }
    }
    
    // PCB Pins
    translate([-(60/2)+11,-(40/2),loadcellHeight + 5]) {
        translate([7,7,0]) {
            cylinder(d=4, h=1);
            cylinder(d=2, h=3);
        }
        
        translate([7,40-7,0]) {
            cylinder(d=4, h=1);
            cylinder(d=2, h=3);
        }
        
        
        translate([44,3,0]) {
            cylinder(d=4, h=1);
            cylinder(d=2, h=3);
        }
        
        translate([44,40-3,0]) {
            cylinder(d=4, h=1);
            cylinder(d=2, h=3);
        }
    }
}


module showModels() {
    //loadCell();
    
    translate([0,0,loadcellHeight + 5]) {
        //nfcPcb();
       // nfcPcbRC522();
    }
    // 3mm up due to PCB + 2mm layer
    translate([0,0,loadcellHeight + 5 + 5]) {
        //bottle();
    }
    
    translate([-36,-(52/2),10]) {
        //%neoPixelStrip();
    }
}

showModels();

bottleHolder();