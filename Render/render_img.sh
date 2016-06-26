target='figure5'
for i in 2438
	 #$(seq 411 1 419)
do    
    sed "s/fff/$i/g" figure5/${target}.vmd > render.vmd
    i_text=$(printf "%04d" $i)
    image=${target}_${i_text}.tga
    /Applications/VMD\ 1.9.1.app/Contents/MacOS/startup.command -dispdev text < render_img.tcl
    /Applications/VMD\ 1.9.1.app/Contents/vmd/tachyon_MACOSXX86 -res 2400 1800 render.dat -o ${image}
    # /Applications/VMD\ 1.9.1.app/Contents/vmd/tachyon_MACOSXX86 -res 1200 1200 -aasamples 16 -skylight_samples 32 render.dat -format JPEG -o test${i}.jpg
    mogrify -format jpg ${image}
    rm -f ${image}
done
