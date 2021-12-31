/*[ Cycloidal Gearbox Behavioral Characteristics ]*/

// Input Parameters
// Gear Ratio: (m:1)
m = 15;

// Angular Resolution (degrees):
delta_theta = 1; //Degrees
$fn = 360/delta_theta;


/*[ Cycloidal Gearbox Physical Characteristics ]*/
// Ring Gear Radius
R = 90;

// Roller radius
Rr = 6.5;

// Eccentricity (E <= Rr/2)
E = 1.5;
// Check eccentricity
assert(E < Rr/2, "Eccentricity must be less than half the roller radius");

// Inner Rollers:
M = 6;

// Inner Roller Radius:
Rir = 8;
// Inner roller hole radius:
Rihr = E + Rir;

// Inner Roller placement:
Rip = 45;


// Input shaft diameter:
input_shaft_diameter = 4;

// Output shaft diameter:
output_shaft_diameter = 4;

// Eccentric cam diameter:
cam_radius = 10;
// Check cam size
assert(cam_radius > max(input_shaft_diameter, output_shaft_diameter)/2 + E, "Cam radius must be big enough to accomodate the input and output shafts with the eccentricity.");

// Gear thickness:
gear_thickness = 6;

//Spacer Thickness:
spacer_thickness = 3;

/*[ Derived Parameters & Parameter checks ]*/

// Number of Rollers
N = m;


function epitrochoid(major, minor, ecc, n, d_theta) = 
[for (theta = [0 : d_theta : 360])
    [major*cos(theta) - minor*cos(theta+atan2(sin((1-n)*theta), major/(ecc * n)-cos((1-n)*theta)))- ecc*cos(n*theta),
     major*sin(theta) - minor*sin(theta+atan2(sin((1-n)*theta), major/(ecc * n)-cos((1-n)*theta)))- ecc*sin(n*theta)]
];


module gear(major, minor, ecc, n, r_hole_inner, r_hole_inner_spacing, thickness, phase_angle, d_theta, color="lime", alpha=1.0) {
    rotate([0, 0, phase_angle])
    translate([ecc, 0, 0]){
        color(color, alpha)
        linear_extrude(height=thickness, center=true)
        difference() {    
            polygon(epitrochoid(major, minor, ecc, n, d_theta));
            circle(cam_radius);
            //Inner Roller holes
            for ( i = [0 : 360/M : 360]) {
                rotate([0, 0, i + 180/M])
                translate([r_hole_inner_spacing, 0, 0])
                circle(r_hole_inner);
            }
        };
        if ($preview) {
                color("cyan", .3)
                polygon([[0, cam_radius/10],
                         [0, -cam_radius/10],
                         [major + minor + ecc, -cam_radius/10],
                         [major + minor + ecc, cam_radius/10]]);
        }
    }
}



// Show important circles
if ($preview) {
    //color("yellow", .3) circle(r=R);
    for (i = [0 : 360/m : 360]) {
        rotate([0, 0, i])
        translate([R, 0, 0])
        color("green", .3)
        linear_extrude(height = 2*gear_thickness + spacer_thickness, center=true)
        circle(r=Rr);
    }
    translate([0, 0, gear_thickness/2 + spacer_thickness/2]) gear(R, Rr, E, N, Rihr, Rip, gear_thickness, 0, delta_theta, color="lime");
    translate([0, 0, -(gear_thickness/2 + spacer_thickness/2)]) gear(R, Rr, E, N, Rihr, Rip, gear_thickness, 180, delta_theta, color="red");
}