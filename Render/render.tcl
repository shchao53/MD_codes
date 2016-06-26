source render.vmd

color Display Background "white"
display cuedensity 0.1
display shadows on
display ambientocclusion on
display aoambient 0.8
display aodirect 1.0 
scale by 0.9
translate by -0.18 0.5 0
# display resize 1200 800

set all [atomselect top all]
# set nFrames [molinfo top get numframes]
set step 1

for {set f 80} {$f <= 120} {set f [expr $f+$step]} {
    # progressbar $f [expr $nFrames/$step]
    animate goto $f
    puts "rendering frame: $f"
    set f_text [format "%04d" $f]
    render Tachyon render.dat '/Applications/VMD\ 1.9.1.app/Contents/vmd/tachyon_MACOSXX86' -res 3240 2040 render.dat -format TARGA -o pull_ens_10nm_f20_1559_${f_text}.tga
}
    
exit    
