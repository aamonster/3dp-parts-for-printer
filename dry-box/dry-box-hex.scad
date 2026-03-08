// Parameters

// central insert
inner_diameter = 8.5;
inner_wall = 1.2;
insert_diameter = inner_diameter + inner_wall*2;
bottom_height = 1;


// central
insert_gap = 0.2;
outer_wall = 6;
outer_diameter = insert_diameter + insert_gap*2 + outer_wall*2;
inner_height = 8;
hole_diameter = 3;
min_wall = 0.4; // from sticks to center hole


// outer parts
rhombus_side = 12; // side length of rhombus
prism_height = 8;
corner_radius = 1.0;
hole_offset = 3; // distance from edge to hole axis


module center_insert() {
    inner_radius = inner_diameter / 2;
    insert_radius = insert_diameter/2;
    outer_radius = outer_diameter / 2;
    
    difference() {
        // Outer
        union() {
            translate([0, 0, inner_height/2+bottom_height])
                cylinder(h = inner_height, r = insert_radius, center = true, $fn = 50);

            translate([0, 0, bottom_height/2])
                cylinder(h = bottom_height, r = outer_radius, center = true, $fn = 50);
        }
        
        // Inner hollow part
        translate([0, 0, (inner_height + bottom_height)/2])
            cylinder(h = inner_height + bottom_height + 2, r = inner_radius, center = true, $fn = 50);

    }
}


module center_part() {
    // Calculated values
    inner_radius = insert_diameter / 2 + insert_gap;
    outer_radius = outer_diameter / 2;
    hole_radius = hole_diameter / 2;

    // Main pipe with 6 side holes at 60° angles
    translate([0, 0, inner_height/2])
    difference() {
        // Outer cylinder
        cylinder(h = inner_height, r = outer_radius, center = true, $fn = 50);
        
        // Inner hollow part
        translate([0, 0, 0])
            cylinder(h = inner_height + 2, r = inner_radius, center = true, $fn = 50);

        // 6 side holes at 60° angles
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
                translate([outer_radius + inner_radius + min_wall, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(h = outer_diameter, 
                                 r = hole_radius, 
                                 center = true, 
                                 $fn = 30);
        }
    }
}

module rhombic_prism(size, height, angle=60) {
    // Rhombic prism with given side length, height, and acute angle (60 degrees)
    // For 60°, the rhombus is actually composed of two equilateral triangles
    
    // Calculate rhombus diagonals
    d1 = size * 2 * sin(angle/2); // short diagonal = size
    d2 = size * 2 * cos(angle/2); // long diagonal = size * sqrt(3)
    
    linear_extrude(height = height, center = true)
        polygon(points = [
            [0, d2/2],   // top
            [d1/2, 0],    // right
            [0, -d2/2],  // bottom
            [-d1/2, 0]   // left
        ]);
}

module rounded_rhombic_prism(size, height, radius, angle=60) {
    minkowski(1) {
        rhombic_prism(size-radius*2, height-radius*2, angle=60);
        sphere(r = radius, $fn=16);
    }
}

// Функция для создания отверстия по начальной точке и направлению
module direction_hole(start, direction, radius, offset=0.0) {
    // from start by direction vector, shifted by offset more
    
    // Вычисляем длину отверстия (достаточно, чтобы выйти за пределы модели)
    hole_length = norm(direction);
    
    // Единичный вектор направления
    unit_dir = direction / norm(direction);

    real_start = start + unit_dir*offset;
    
    // Находим углы поворота для цилиндра
    // Сначала поворот вокруг Y, затем вокруг Z
    theta = acos(unit_dir.z); // угол от оси Z
    phi = atan2(unit_dir.y, unit_dir.x); // угол в плоскости XY
    
    translate(real_start)
        rotate([0, 0, phi]) // Корректировка азимута
            rotate([0, theta, 0]) // Поворачиваем от Z к направлению
                cylinder(h = hole_length, r = radius, center = false, $fn = 40);
}

module inner_center_part() {
    
}

module far_part() {
    $fn = 30;
    
    // Calculate rhombus diagonals
    d1 = rhombus_side * 2 * sin(60/2); // short diagonal
    d2 = rhombus_side * 2 * cos(60/2); // long diagonal
    
    // Позиции вершин ромба (в 2D, потом добавим Z)
    // Вершины: [0, d2/2] - верх, [d1/2, 0] - право, [0, -d2/2] - низ, [-d1/2, 0] - лево
    acute_corner_pos = [d1/2, 0, 0]; // 60° угол (правый)
    obtuse_corner_pos = [-d1/2, 0, 0]; // 120° угол (левый)

    // Main model with 4 holes
    translate([0, 0, prism_height/2])
    {
    difference() {
        // Rhombic prism with rounded edges
//        translate([0,0,3])
        rounded_rhombic_prism(rhombus_side, prism_height, corner_radius, 60);

        start = acute_corner_pos + [-hole_offset/sin(60), 0, -prism_height/2+hole_offset];

        // Hole #1: вдоль короткой диагонали от острого угла (60°) к центру
        dir1 = [-d1, 0, 0]; // вектор к центру
        color("red")
        direction_hole(start, dir1, hole_diameter/2, offset=hole_diameter);
        
        // Hole #2: вдоль стороны от тупого угла (120°) - направление к верхней вершине
        dir2 = [-d1/2, -d2/2, 0]; // вектор к верхней вершине (противоположной)
        color("green")
        direction_hole(start, dir2, hole_diameter/2, offset=hole_diameter);
        
        // Hole #3: вдоль другой стороны от тупого угла (120°) - направление к нижней вершине
        dir3 = [-d1/2, d2/2, 0]; // вектор к нижней вершине (противоположной)
        color("blue")
        direction_hole(start, dir3, hole_diameter/2, offset=hole_diameter);
        
        // Hole #4: вертикальное отверстие в тупом угле (120°)
        dir4 = [0, 0, prism_height]; // вектор вверх
        color("magenta")
        direction_hole(start, dir4, hole_diameter/2, offset=0);
    }
}
}

// Assembly
center_part();

translate([0, 35, 0])
    center_insert();

// Place 6 rhombic prisms around the center at 60° angles
for (i = [0:5]) {
    angle = i * 60;
    distance = 20; // distance from center
    
    translate([distance * cos(angle), distance * sin(angle), 0])
        rotate([0, 0, angle])
            far_part();
}
