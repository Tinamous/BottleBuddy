$fn = 90;
bottleDiameter = 100;
wallThickness = 3;
bottlePadding = 2;

//height = 100;
height = 40;

loadcellHeight = 12.75;
loadcellWidth = 12.75;
loadcellLength = 80;
loadCellOffset = -48;

baseHeight = 2 + 10.9; // 2mm for loadcell scren + 12 mm for. (PCB?)
pcbDepth = 8;

// How thick the PCB is.
pcbThickness = 2;
// Space above the PCB 
// to allow for wire poking through on connector
pcbOffsetFromTop = 1;

pcbBoxWidth = 105;

nfcPcbOffset = 0;

// NeoPixels.
includeNeoPixels = false;

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
    translate([-(60/2)+nfcPcbOffset,-(40/2),0]) {
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
            translate([5.0, (12.75/2), 0]) {
                #cylinder(d=4.8, h=20);
                translate([0,0,5-loadcellHeightOffset ]) {
                    // High enough to 
                    cylinder(d=10, h=102);
                }
            }

            translate([20.0, (12.75/2),0]) {
                #cylinder(d=4.8, h=20);
                translate([0,0,5-loadcellHeightOffset ]) {
                    cylinder(d=10, h=12);
                }
            }
        }
    }
}


module nfcPcbCutout() {
    // PCB
    // Make the PCB slot 
    translate([-(60/2)+nfcPcbOffset,-(40/2), baseHeight - pcbDepth + 0.1]) {
        //cube([86+20, 55,3.1]);
        cube([62, 40, pcbDepth]);
        // TODO: Add holes for PCB when we know where they go!
    }
    
    // PCB Cables, through to the bottom compartment
    /*
    translate([28 + nfcPcbOffset,0,0]) {
        translate([0,-9,0]) {
            cube([2, 5, 8]);
        }
        translate([0,9-5,0]) {
            cube([2, 5, 8]);
        }
    }
    */
    
    translate([28 + nfcPcbOffset,0,0]) {
        translate([-1,-13,0]) {
            cube([3, 26, 8]);
        }
        translate([0,9-5,0]) {
            //#cube([2, 5, 8]);
        }
    }
}

module nfcPcbPins() {
    translate([-(60/2)+(nfcPcbOffset+1),-(40/2), baseHeight - pcbDepth]) {
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
}

module neoPixelStripCutout() {
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

module neoPixelPins() {
neoPixelPcbThickness = 4;
    translate([-34.5,-52/2 + 1,baseHeight - pcbDepth + 0.1]) {
        translate([3,12.8,0]) {
            //cylinder(d=3, h=200);
            cylinder(d=4, h=pcbDepth - pcbOffsetFromTop - neoPixelPcbThickness);
            cylinder(d=1.5, h=pcbDepth - pcbOffsetFromTop);
            
            translate([0,26,0]) {
                //cylinder(d=3, h=200);
                cylinder(d=4, h=pcbDepth - pcbOffsetFromTop - neoPixelPcbThickness);
                cylinder(d=1.5, h=pcbDepth - pcbOffsetFromTop);
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
                #cylinder(d=4, h=6);
            }
        }
    }
}

module addSkirt() {
innerDiameter = bottleDiameter + bottlePadding + wallThickness;
skirtHeight = 30;
overlapOnTop = 16.5;// 30
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


module bottleHolder() {
h = 30; //22 //height;    

    
    difference() {
        union() {
            cylinder(d=bottleDiameter + bottlePadding + wallThickness, h=h);
            
            //hollowBox(h);
            //boxLid(h);
            //wideLid(pcbBoxWidth, 1);
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
            
            if (includeNeoPixels) {
                //neoPixelStripCutout();            
            }
        }
    }
    
   
    // PCB Pins
    nfcPcbPins();
    
    if (includeNeoPixels) {
        //neoPixelPins();
    }
    
    addSkirt();
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
    
    if (includeNeoPixels) {
        translate([-34.5,-52/2 +1,baseHeight -5]) {
            //%neoPixelPcb();
        }
    }
    
    // 3mm up due to PCB + 2mm layer
    translate([0,0,loadcellHeight + 5 + 5]) {
        //bottle();
    }
}

//showModels();

difference() {
    bottleHolder();
    liquidEscapeHole();
}