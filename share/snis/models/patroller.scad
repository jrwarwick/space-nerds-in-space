$fn = 12; //$preview ? 8 : 12;

// Skews the child geometry.
// xy: Angle towards X along Y axis.
// xz: Angle towards X along Z axis.
// yx: Angle towards Y along X axis.
// yz: Angle towards Y along Z axis.
// zx: Angle towards Z along X axis.
// zy: Angle towards Z along Y axis.
module skew(xy = 0, xz = 0, yx = 0, yz = 0, zx = 0, zy = 0) {
	matrix = [
		[ 1, tan(xy), tan(xz), 0 ],
		[ tan(yx), 1, tan(yz), 0 ],
		[ tan(zx), tan(zy), 1, 0 ],
		[ 0, 0, 0, 1 ]
	];
	multmatrix(matrix)
	children();
}

// Define the main body of the starship
module main_body() {
    hull() {
        translate([0, 0, 0]) cylinder(h=22, r1=5, r2=5);
        translate([0, 0, 22]) sphere(r=5);
    }
    //anterior ring
    translate([0, 0, -1.25])
    difference(){
        cylinder(h=3, r1=5.75, r2=5.5); 
        cylinder(h=3, r1=4.5, r2=4.25);
    }
    
}

// Define the wings of the starship
module wings() {
    translate([-10, 0, 10]) cube([20, 2, 1]);
    translate([-10, 0, 15]) cube([20, 2, 1]);
}

// Define the engines of the starship
module engines() {
    $fn=6;
    translate([-5, -3.75, 0]) cylinder(h=10, r=2.5);
    translate([5, -3.75, 0]) cylinder(h=10, r=2.5);
        translate([5, -3.75, 0]) cylinder(h=10, r=2.5);
}

// Define the thruster at the back of the starship
//TODO: triple it and shorten it
module thruster() {
    translate([0, 0, -3.75]) cylinder(h=3.75, r1=3.25, r2=2);
}

// Define the nacelles at the ends of the wings
//translate([8,8,8]) {
module scoop() {
    difference() {
        difference() {
            cylinder(h=7, r=2.4);
            cylinder(h=7, r=1.85);
        }
        translate([-1.5,-3.75,5])
        rotate([30,0,30])
        cube(size=6.75);
    }
}
module nacelles() {
    translate([-10, 0, 10]) cylinder(h=10, r=2);
    translate([10, 0, 10]) cylinder(h=10, r=2);
    //translate([-10, 0, 15]) cylinder(h=10, r=1);
    translate([-8.75, .5, 2.25]) cylinder(h=10, r=1);
    //translate([10, 0, 15]) cylinder(h=10, r=1);
    translate([8.75, .5, 2.25]) cylinder(h=10, r=1);
    translate([10,0,16]) scoop();
    translate([-10,0,16]) mirror([1,0,0])scoop();
}


// Define the cockpit/bridge extrusion as a trapezoid
module cockpit() {
    skew(zy=-45)
    translate([-1, 4, 16]) {
        linear_extrude(height=6) {
            polygon(points=[[-2, 0], [4, 0], [2, 2], [0, 2]]);
        }
    };
    skew(zy=28)
    translate([-1, 4, 6]) {
        linear_extrude(height=4) {
            polygon(points=[[-2.25, 0], [4.25, 0], [2.25, 2], [-.25, 2]]);
        }
    }

}

module hatch() {
    translate([0,4.25,4.25])
    rotate([0,90,90])cylinder(h=1.5, r1=1.85, r2=1.5); 
}

// Assemble the starship
module starship() {
    main_body();
    hatch();
    wings();
    engines();
    thruster();
    nacelles();
    cockpit();
}

// Render the starship
starship();
