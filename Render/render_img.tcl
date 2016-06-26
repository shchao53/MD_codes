source render.vmd

# rotate x by -90
# rotate x by 0.05
color Display Background "white" 
display cuedensity 0.1 
display shadows on
display ambientocclusion on
display aoambient 0.8
display aodirect 1.0
translate by -0.000000 0.50 0.00000
# display resize 400 400
# light 1 off
# light 0 pos {0 1 3}
scale by 1.2

render Tachyon render.dat ""
