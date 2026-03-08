module center_part() {
    // Parameters
    inner_diameter = 8;
    outer_diameter = 16;
    length = 8;
    hole_diameter = 3;
    min_wall = 0.4; // from sticks to center hole

    // Calculated values
    inner_radius = inner_diameter / 2;
    outer_radius = outer_diameter / 2;
    hole_radius = hole_diameter / 2;

    // Main pipe
    
    translate([0, 0, length/2])
    difference() {
        // Outer cylinder
        cylinder(h = length, r = outer_radius, center = true, $fn = 50);
        
        // Inner hollow part
        translate([0, 0, 0])
            cylinder(h = length + 2, r = inner_radius, center = true, $fn = 50);

        // 4 side holes at 90° angles
        for (i = [0:3]) {
            rotate([0, 0, i * 90])
                translate([outer_radius+inner_radius+min_wall, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(h = outer_diameter, 
                                 r = hole_radius, 
                                 center = true, 
                                 $fn = 30);
        }
    }
}

module far_part() {
    // Параметры
    cube_size = 10;
    corner_radius = 1.0;
    hole_diameter = 3;
    hole_offset = 3; // расстояние от края до оси отверстия
    $fn = 30;

    // Быстрый кубик со скруглёнными рёбрами через hull()
    module rounded_cube_fast(size, radius) {
        hull() {
            // 8 сфер в вершинах куба
            for (x = [-1, 1], y = [-1, 1], z = [-1, 1]) {
                translate([x * (size/2 - radius), 
                           y * (size/2 - radius), 
                           z * (size/2 - radius)])
                    sphere(r = radius);
            }
        }
    }

    // Основная модель с отверстиями
    translate([0, 0, cube_size/2])
    mirror([0,0,1])
    difference() {
        // Кубик со скруглёнными рёбрами
        rounded_cube_fast(cube_size-0.001, corner_radius);
        
        // Отверстие вдоль ребра X (слева направо) у вершины (+Y, +Z)
        color("red")
        translate([-cube_size, cube_size/2 - hole_offset, cube_size/2 - hole_offset])
            rotate([0, 90, 0])
                cylinder(h = cube_size, r = hole_diameter/2);
        
        // Отверстие вдоль ребра Y (спереди назад) у вершины (+X, +Z)  
        color("green")
        translate([cube_size/2 - hole_offset, 0, cube_size/2 - hole_offset])
            rotate([90, 0, 0])
                cylinder(h = cube_size, r = hole_diameter/2);
        
        // Отверстие вдоль ребра Z (снизу вверх) у вершины (+X, +Y)
        color("blue")
        translate([cube_size/2 - hole_offset, cube_size/2 - hole_offset, -cube_size])
            cylinder(h = cube_size, r = hole_diameter/2);
                
        // ИСПРАВЛЕННЫЙ вариант:
        // Цилиндр, направленный по вектору (1,1,0) из вершины (+X,+Y,+Z) к центру
        color("magenta")
        translate([cube_size/2 - hole_offset, cube_size/2 - hole_offset, cube_size/2 - hole_offset])
            rotate([0, 0, -45]) // Поворачиваем вокруг Z, чтобы ось Y совпала с биссектрисой XY
                rotate([90, 0, 0]) // Затем поднимаем ось в плоскость XY
                    cylinder(h = cube_size*3, r = hole_diameter/2);
    } 
}

center_part();
translate([15, 0, 0])
    far_part();
translate([-15, 0, 0])
    far_part();
translate([0, 15, 0])
    far_part();
translate([0, -15, 0])
    far_part();
