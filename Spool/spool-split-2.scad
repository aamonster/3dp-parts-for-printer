outer_diameter = 55.5 + 0.7;        // Outer diameter (spool inner diameter + some extra)
avg_diameter = 40;
inner_diameter = 21.8 - 0.5;  // Inner diameter (bearing outer diameter - some extra)
height = 7.2+1.2;
segments = 8;                        // Number of parts circle splitted to

line_width = 0.6;
gap = 2; // in outer part - wide (it will shrink)
gap2 = 0.4; // in inner part – narrow (it will expand)

gap_avg = 0.1; // in medium circle - it will stick
dr = 0.8; // ширина упоров на центральной окружности

emphasis = 0.8; // ширина упора для подшипника/катушки
emphasis_height = 0.6; // выстота упора для подшипника/катушки

$fn=256;

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

module variable_extrude(dz = 0.2) {
    // Нижний участок: emphasis от 1 до 0
    for(z = [0:dz:emphasis_height]) {
        emphasis = emphasis*(1 - z/emphasis_height);
        
        translate([0, 0, z])
        linear_extrude(height=dz)
        section(emphasis_outer = emphasis, emphasis_inner = emphasis);
    }
    
    // Средний участок: emphasis = 0
    translate([0, 0, emphasis_height])
    linear_extrude(height=height-2*emphasis_height)
    section(0);
    
    // Верхний участок: emphasis от 0 до 1
    for(z = [height-emphasis_height-0.001:dz:height]) {
        emphasis = emphasis*(z - (height - emphasis_height))/emphasis_height;
        
        translate([0, 0, z])
        linear_extrude(height=dz)
        section(emphasis_outer=0, emphasis_inner=emphasis);
    }
}

//linear_extrude(height) {
//    section(0);
//}

variable_extrude();