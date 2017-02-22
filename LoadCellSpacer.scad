$fn=90;
difference() {
    union() {
        cube([27, 12.75, 5]);
    }
    union() {
        
        //  bolt holes
        translate([5.0, (12.75/2), 0]) {
            cylinder(d=5, h=20);
        }

        translate([20.0, (12.75/2),0]) {
            cylinder(d=5, h=20);
        }
        
    }
}