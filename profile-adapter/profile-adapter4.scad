// Параметры
wall_width = 8;          // Расстояние от трубы до L-стенки
wall_height = 32.6;      // Не используется
profile_size = 10;       // Внутренний размер трубы
profile_length = 100;    // Не используется
corner_size = 8;         // Не используется
lid_height = 1.6;
hook_width = 1.6;        // Толщина L-стенки
hook_internal = 1.6;     // Толщина стенки трубы
hook_height = 12;         // Высота трубы и стенки
hook_split = 2;          // Сколько срезать в углу, чтобы отделить крепёж X и Y
chamfer = 0.4;  // ширина фаски

tube_inner_diameter = 8;

snap_depth = 0.8;        // насколько выступают внутрь
snap_step = 1.2;    // по вертикали: 1 шаг – рост толщины наплыва от 0, 1 шаг толщина snap_depth, 1 шаг уходим в 0

// Наружный размер трубы
outer_size = profile_size + 2 * hook_internal;  // 12.4 мм

// Модуль трубы (оставляем на месте, как в шаге 1)
module tube() {
    difference() {
        // Внешний куб (от 0 до outer_size)
        cube([outer_size, outer_size, hook_height]);
        // Внутренняя полость (смещена на толщину стенки)
        translate([hook_internal, hook_internal, -1])
            cube([profile_size, profile_size, hook_height + 2]);
    }
}

// Модуль трубы с фаской через hull()
module tube_outer() {
    // 1. Наружная часть трубы
    cube([outer_size, outer_size, hook_height]);
}

module tube_inner() {
    // 2. Внутренняя полость
    // Она будет формироваться в два этапа:
    // - сначала основная часть
    // - потом фаска отдельно, но проще сразу вычесть hull-форму

    union() {
        // Основная внутренняя полость (без фаски)
        translate([hook_internal, hook_internal, -0.01])
            cube([profile_size, profile_size, hook_height+0.02]);

        // Фаска: расширенная книзу часть
        translate([hook_internal, hook_internal, 0])
            hull() {
                // Верх фаски (на уровне chamfer) — базовый размер
                translate([0, 0, chamfer - 0.02])
                    cube([profile_size, profile_size, 0.01]);

                // Низ фаски (на уровне 0) — расширенный
                translate([-chamfer, -chamfer, -0.01])
                    cube([profile_size + 2*chamfer, profile_size + 2*chamfer, 0.01]);
            }
    }
    
}

module l_hook() {
    hook_offset = hook_width + wall_width;
    hook_length = profile_size + hook_internal*2 + wall_width + hook_width;
    
    // Вертикальная часть L (параллельно оси Y)
    // Она начинается от уровня верхней грани трубы
    translate([-hook_offset, -hook_offset, 0])
        cube([hook_width, hook_length, hook_height]);
    
    // Горизонтальная часть L (параллельно оси X)
    // Она начинается от уровня правой грани трубы
    translate([-hook_offset, -hook_offset, 0])
        cube([hook_length, hook_width, hook_height]);
 }
 
module split_hook() {
    hook_offset = hook_width + wall_width;
    hook_length = profile_size + hook_internal*2 + wall_width + hook_width;
    
    // Вертикальная часть L (параллельно оси Y)
    // Она начинается от уровня верхней грани трубы
    translate([-hook_offset, -hook_offset+hook_split, 0])
        cube([hook_width, hook_length-hook_split, hook_height]);
    
    // Горизонтальная часть L (параллельно оси X)
    // Она начинается от уровня правой грани трубы
    translate([-hook_offset+hook_split, -hook_offset, 0])
        cube([hook_length-hook_split, hook_width, hook_height]);
    
    // --- Наплывы вдоль верхнего края ---
    
    // Наплыв на вертикальной части (идёт вдоль всей длины, сверху)
    hull() {
        translate([-wall_width, 
                   -hook_offset + hook_split, 
                   hook_height - snap_step*2])
            cube([snap_depth, hook_length - hook_split, snap_step]);
        translate([-wall_width,
                   -hook_offset + hook_split, 
                   hook_height - snap_step*3])
            cube([0.01, hook_length - hook_split, snap_step*3]);
    }

    // Наплыв на горизонтальной части (идёт вдоль всей длины, сверху)
    hull() {
        translate([-hook_offset + hook_split,
                   -wall_width, 
                   hook_height - snap_step*2])
            cube([hook_length - hook_split, snap_depth, snap_step]);
        translate([-hook_offset + hook_split, 
                   -wall_width,
                   hook_height - snap_step*3])
            cube([hook_length - hook_split, 0.01, snap_step*3]);
    }
    
        
}
 

 // Модуль донышка (соединяет крюк и трубу, не закрывая отверстие)
module bottom_plate() {
    hook_offset = hook_width + wall_width;
    hook_length = profile_size + hook_internal*2 + wall_width + hook_width;
    
    // Область, которую занимает донышко (прямоугольник от края крюка до края трубы)
    plate_x = hook_offset + outer_size;  // ширина пластины по X
    plate_y = hook_offset + outer_size;  // ширина пластины по Y
    
    // Основание пластины
    translate([-hook_offset, -hook_offset, 0])
        cube([plate_x, plate_y, lid_height]);
}

module top_part() {
    difference() {
        union() {
            tube_outer();
            l_hook();
            bottom_plate();        
        }
        tube_inner();
    }
}

module bottom_part() {
    union() {
        difference() {
            tube_outer();
            mirror([0,0,1])
                translate([0,0,-hook_height])
                    tube_inner();
        }
        bottom_plate();        
    }
}

module holder_part() {
    // Горизонтальная цилиндрическая труба, лежащая на основной
    // Внутренний диаметр 8 мм, внешний диаметр = inner_diameter + 2*стенка
    inner_diameter = tube_inner_diameter;
    outer_diameter = inner_diameter + 2 * hook_internal;  // 8 + 2*1.6 = 11.2 мм


    difference() {
        hull() {
            tube_outer();
            // Располагаем трубу горизонтально (вдоль оси X) на верхней грани квадратной трубы
            translate([0, outer_size/2, hook_height+outer_diameter/2])
                rotate([0, 90, 0])
                // Внешний цилиндр
                cylinder(h = outer_size, r = outer_diameter/2, $fn = 30);
        }


        union() {
            tube_inner();
            translate([0, outer_size/2, hook_height+outer_diameter/2])
                rotate([0, 90, 0])
                // Внутреннее отверстие
                translate([0, 0, -1])
                    cylinder(h = outer_size + 2, r = inner_diameter/2, $fn = 30);
        }
    }
    
}

//top_part();
//bottom_part();
holder_part();
