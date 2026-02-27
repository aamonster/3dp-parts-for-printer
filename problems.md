

### Z offset:
- Problem: When Z=0 - Z slider pushed into axis bottom and tilted so X axis and print head tilted.  
Basically it means that Z from 0 to 0.5 is approximately the same
- Measurement: g-code which moves head up then down to some height (z-backlash.gcode), measure actual height by paper pile.
- Solution: Z offset = 0.45.  
Possible better solution: put something inside Z axis bottom as a limiter in belt plane (so slider won't tilt)

### X and Y backlash
Problem: backlash in belt, gears etc

Measurement:
- https://www.thingiverse.com/thing:2040624 - x=0.46, y=0.4

Solution: software compensation by post-processing 3dp-compensate.py
(move lines and arcs with left-to-right movement right by DX, with back-to-forward – forward by DY, insert travel move by DX/DY when changing X or Y direction)

Measurement 2: test-backlash.3mf (print, check for border on half of the item height - it should vanish ) 

Result: DX = 0.35, DY = 0.35

Z axis have backlash too but it is effectively discarded by Z-hop = 0.5. 

### Linear advance/Pressure advance
Totally absent, it's main problem of the printer (blobs at corners, underextrusion after corners; higher acceleration and lower speed improve quality).

Partial workaround: use as huge acceleration (600) and jerk (10) as possible.

WIP: g-code preprocessing to simulate Linear Advance (split lines to short parts with speed change not more than Jerk, calculate E for each part, merge parts with same speed back if possible).

### Big spools
1 kg spool should be on separate holder with bearing axis above printer (see Spool model).

### Hotend
20 Watt, extra light and loose.

Problem: heater inner diameter 5.2 mm, nozzle tube 4.9 mm - bad thermal contact (and on one size, look at filament end after retracting it from printer). Limited print speed, possible jams.

Solution: Thermal conductive grease (not tested yet)

Problem: PTFE tube between extruder and nozzle 0.5-1 mm shorter than it should be. On retract it can go up then filament go under this tube and stick to walls, maybe creating jam.
