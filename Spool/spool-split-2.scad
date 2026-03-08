// recommended print settings:
// - spiral vase mode
// - line width = 0.6 (if changed - reflect to parameters below)
// - layer height 0.2 (if changed - reflect to layer_height in parameters)

// ---------------- Main call

// part for one bearing; print twice for left and right part of the spool
//short_spool();

// one long spool axis for two bearings
long_spool();

// ---------------- parameters

outer_diameter = 55.5 + 0.7;        // Outer diameter (spool inner diameter + some extra)
avg_diameter = 40;
inner_diameter = 21.8 - 0.5;  // Inner diameter (bearing outer diameter - some extra)
height = 7.2+1.2;
segments = 8;                        // Number of parts circle splitted to

long_height = 64;

line_width = 0.6;
gap = 2; // in outer part - wide (it will shrink)
gap2 = 0.4; // in inner part – narrow (it will expand)

gap_avg = 0.1; // in medium circle - it will stick
dr = 0.8; // ширина упоров на центральной окружности

emphasis = 0.8; // ширина упора для подшипника/катушки
emphasis_height = 0.6; // выстота упора для подшипника/катушки

layer_height = 0.2; // for emphasis interpolation

$fn=256;

// ---------------- functions

// круг с вырезами
module splitted_circle(r, n, n_shift, w) {
    // r - радиус круга
    // n - количество вырезов
    // w - ширина выреза (постоянная по всей длине)
    
    angle_step = 360 / n;
    
    difference() {
        // Основной круг
        circle(r);
        
        // Создаем n вырезов
        for (i = [0:n-1]) {
            rotate([0, 0, (i+n_shift) * angle_step]) {
                // Прямоугольный вырез постоянной ширины от центра до края
                translate([0, -w/2, 0])
                    square([r + 1, w]);  // +1 для гарантированного пересечения с кругом
            }
        }
    }
}

// сечение с заданным отступом
module section(emphasis_outer=0, emphasis_inner=0) {
    difference() {
        union() {
            splitted_circle(r = outer_diameter/2 + emphasis_outer, n = segments, n_shift = 0.0, w = gap);
            splitted_circle(r = avg_diameter/2  + dr, n = segments, n_shift = 0.0, w = gap_avg);
        }
        circle(r = avg_diameter/2);
    }
    difference() {
        circle(r = avg_diameter/2);
        splitted_circle(r = avg_diameter/2, n = segments, n_shift = 0.5, w = gap2 + line_width*2);
    }
    circle(r = inner_diameter/2 - emphasis_inner + line_width); // added line_width to ensure proper inner diameter    
}

module variable_extrude(points, dz = layer_height) {
    // Sort points by z coordinate
    sorted_points = points; // TODO: sort later
    
    // Iterate through all segments between points
    for(i = [0:len(sorted_points)-2]) {
        z1 = sorted_points[i][0];
        z2 = sorted_points[i+1][0];
        
        outer1 = sorted_points[i][1];
        outer2 = sorted_points[i+1][1];
        
        inner1 = sorted_points[i][2];
        inner2 = sorted_points[i+1][2];
        
        // Check if values are constant in this segment
        is_constant = (abs(outer2 - outer1) < 1e-6) && (abs(inner2 - inner1) < 1e-6);
        
        if (is_constant) {
            // For constant segment: single extrusion for entire height
            translate([0, 0, z1])
            linear_extrude(height=z2 - z1)
            section(emphasis_outer = outer1, emphasis_inner = inner1);
        } else {
            // For variable segment: interpolate with dz steps
            steps = ceil((z2 - z1) / dz);
            
            echo (dz, layer_height, steps);
            
            for(j = [0:steps-1]) {
                t = j / steps;
                z = z1 + t * (z2 - z1);
                
                // Linear interpolation of parameters
                current_outer = outer1 + t * (outer2 - outer1);
                current_inner = inner1 + t * (inner2 - inner1);
                
                translate([0, 0, z])
                linear_extrude(height=dz)
                section(emphasis_outer = current_outer, 
                       emphasis_inner = current_inner);
            }
        }
    }
}

module short_spool() {
    points = [
        [0,                          emphasis, emphasis],
        [emphasis_height,            0.0, 0.0],
        [height - emphasis_height,   0.0, 0.0],
        [height,                     0.0, emphasis],
    ];

    variable_extrude(points);
}

module long_spool() {
    points = [
        [0,                          emphasis, emphasis],
        [emphasis_height,            0.0, 0.0],
        [height - emphasis_height,   0.0, 0.0],
        [height,                     0.0, emphasis],
        [long_height - height,       0.0, emphasis],
        [long_height - (height - emphasis_height), 0.0, 0.0],
        [long_height - emphasis_height, 0.0, 0.0],
        [long_height,                0, emphasis]
    ];
    variable_extrude(points);
}
