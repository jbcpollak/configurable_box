include <boxes.scad>

// What to generate
generate = 3; // [1:Base, 2:Lid, 3:Both]

// Internal width of box
width_inner = 60;

// Internal bength of box
length_inner = 60;

// Internal height of bottom of box
base_height_internal = 120;

// Internal height of the top/lid of the box
lid_height_internal = 72;

// Height of the lip to generate
overlap_height = 12;

// Thickness of the outer wall
wall_thickness = 2.4;

// How curved to make the corners
radius = 6; // [1:10]

// Tolerance between lid and lip
tolerance = 0.25;

// Ratio of lip to regular wall thickness
lip_thickness_ratio = 0.5;

height_inner = base_height_internal + lid_height_internal;

lip_thickness = wall_thickness * lip_thickness_ratio;

width_outer = width_inner + wall_thickness*2;
length_outer = length_inner + wall_thickness*2;
height_outer = height_inner + wall_thickness*2;

module lip(tol = 0) {
    difference() {
        // The outside shell
        roundedCube(
            [width_inner+lip_thickness+tol*2,length_inner+lip_thickness+tol*2,overlap_height*2],
            radius,
            center=true
        );
        // The inside cavity
        roundedCube(
            [width_inner-tol,length_inner-tol,overlap_height*2-wall_thickness/2],
            radius,
            center=true
        );
        // Slice off the top
        translate(v=[0,0,overlap_height+tol]) 
            cube([width_outer+1, length_outer+1,overlap_height], center=true);
        // Slice off the bottom
        translate(v=[0,0,-overlap_height-tol]) 
            cube([width_outer+1, length_outer+1,overlap_height], center=true);
    } 
}

module openBox(height) {
    other_height = height_outer-height;
    cut_height = height_outer/2-other_height/2;
     
    difference() {
        // The outside shell
        roundedCube([width_outer,length_outer,height_outer],radius,center=true);
        // The inside cavity
        roundedCube([width_inner,length_inner,height_inner],radius,center=true);
        // Cut the top off
        translate(v=[0,0,cut_height]) cube([width_outer+1,length_outer+1,other_height],center=true);
        }
}

module base() {
    base_height_outer = base_height_internal + wall_thickness;
    
    union() {
        translate(v=[0,0,height_outer/2]) 
            openBox(base_height_outer);
        // The -0.01 is designed to ensure the lip intersects with the
        // box so they generate a complete 2-manifold object.
        translate(v=[0,0,base_height_outer + overlap_height/2 - .01]) lip();
    }
}

module lid() {
    lid_height_outer = lid_height_internal + wall_thickness;

    difference() {
        translate(v=[0,0,height_outer/2]) 
            openBox(lid_height_outer);
        translate(v=[0,0,lid_height_outer - overlap_height/2]) lip(tolerance);
    }
}


offset = (generate == 3) ? (width_outer/2)+5 : 0;

if ((generate % 2) == 1) {
    translate(v=[offset,0,0]) base();
}

if (generate >= 2) {
    translate(v=[-offset,0,0]) lid();
}
