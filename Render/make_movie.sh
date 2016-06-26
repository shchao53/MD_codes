#!/bin/bash

name='pull_ens_10nm_f20_1559'
for file in ${name}*.jpg
do
    idx=$(echo $file | cut -d "." -f1 | cut -d "_" -f6)
    idx_int=$(echo $idx | sed 's/^0*//')
    time=$(echo "$idx_int*0.2*80/1000" | bc -l)
    time_text=$(printf "%06.2f" $time)
    # convert -strip -interlace Plane -quality 75% $file temp.jpg
    convert $file -gravity South -pointsize 140 -annotate +1100+150 "$time_text μs" text/$file

    check=$(echo "$idx_int % 100" | bc)
    
    if [ "$check" -eq "0" ]
    then
	echo $file
    fi
done

ffmpeg -r 25 -pattern_type glob -i 'text/*.jpg' -c:v libx264  -pix_fmt yuv420p ${name}.mp4
rm -f text/*.jpg
rm -f temp.jpg
