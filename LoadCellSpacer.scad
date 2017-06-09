$fn=90;
difference() {
    union() {
        cube([27, 12.75, 7]);
    }
    union() {
        
        //  bolt holes
        translate([5.0, (12.75/2), -0.01]) {
            cylinder(d=6.5, h=61);
        }

        translate([20.0, (12.75/2),-0.01]) {
            cylinder(d=6.5, h=61);
        }
        
    }
}