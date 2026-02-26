## Filament spool 1 kg:
inner diameter 55.5
outer diameter `55.5+72*2 = 199.5`
width ~64
width of inner part 60.5

bearings with roller
inner diameter 8 (ok for wooden axis I have)
outer 21.8
width 7.2

so we need cylinder d = 55 l = 62 with minor flex walls outside
or just small cylinder (spool-shaped) to adjust distance between bearings
with minor borders (so spool can rotate outside of cylinder)
l>=61 
e.g. profile
x=-5      d=32+thickness
x=0       d=21.8+thickness
x=9       d=21.8+thickness
x=1+18    d=12+thickness (slowly narrow to center for simpler printing, maybe in vase mode)
x=31      d=12+thickness
x=62-1-18 d=12+thickness
x=62-1-8  d=21.8+thickness
x=62      d=21.8+thickness
x=62+5    d=32+thickness

narrow spool axis no good: it's not round because of printer backlash
so it works like "gear in gear" in big spool and tends to stop in 4 directions
Possible fixes: 
- more accurate print (use backlash compensation, but with no backlash take-up since it slower printer down - bumps)
- big axis outline so it will stuck inside spool (unable to print in vase mode) 
- fuzzy skin (with compensation only)
