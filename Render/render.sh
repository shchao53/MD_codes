start=80
end=120
step=1
file='pull_ens_10nm_f20_1559'

sed "s/setstart/$start/g" render_ref.tcl > render.tcl
sed -i.bak "s/setend/$end/g" render.tcl 
sed -i.bak "s/setstep/$step/g" render.tcl 
sed -i.bak "s/setfile/$file/g" render.tcl

cp ${file}/${file}.vmd ./render.vmd
/Applications/VMD\ 1.9.1.app/Contents/MacOS/startup.command -dispdev text < render.tcl

mogrify -format jpg ${file}*.tga
rm -f ${file}*.tga

