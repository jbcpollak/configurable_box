include <boxes.scad>

// External width of box
width_outer = 80;

// External bength of box
length_outer = 80;

// External height of bottom of box
base_height = 130;

// External height of the top/lid of the box
lid_height = 70;

// Height of the lip to generate
overlap_height = 15;

// Thickness of the outer wall
wall_thickness = 5;

// How curved to make the corners
radius = 6; // [1:10]

// Tolerance between lid and lip
tolerance = 0.2;

// Ratio of lip to regular wall thickness
lip_thickness_ratio = 0.5;

height_outer = base_height + lid_height;

lip_thickness = wall_thickness * lip_thickness_ratio;

width_inner = width_outer - wall_thickness;
length_inner = length_outer - wall_thickness;
height_inner = height_outer - wall_thickness;

lid_height_i = lid_height - wall_thickness;
lid_width_i = width_outer - wall_thickness;
lid_length_i = length_outer - wall_thickness;

module lip(tol = 0) {
    cut_height = height_outer/2-overlap_height;
    
    difference() {
        // The outside shell
        roundedCube(
            [width_inner+lip_thickness+tol,length_inner+lip_thickness+tol,overlap_height*2],
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
        //myLidAtProperHeightWithWiggle();
        }
}

module base() {
    union() {
        translate(v=[0,0,height_outer/2]) openBox(base_height);
        translate(v=[0,0,base_height + overlap_height/2]) lip();
    }
}

module lid() {
    difference() {
        translate(v=[0,0,height_outer/2]) openBox(lid_height);
        translate(v=[0,0,lid_height - overlap_height/2]) lip(tolerance);
    }
}

module boxAndLid() {
	translate(v=[(width_outer/2)+5,0,0]) base();
	translate(v=[(width_outer/-2)-5,0,0]) lid();
}

// Round box
boxAndLid();
