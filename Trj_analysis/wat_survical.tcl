# Compute survival probability of water molecule in a given layer  
# Shu-Han Chao

# compute how much hbonds survive in given time difference 
proc computeS {framefirst framelast text} {
    set sel [atomselect top $text]
    for {set i $framefirst} {$i<=$framelast} {incr i} {
	$sel frame $i
	$sel update
	if {$i==$framefirst} {set survival [$sel list]}
	set lcurr [$sel list]	
	# compute survival list between initial list and current list, remove those molecules moving out
	set survival_tmp {}
	foreach j $survival {
	    if {[lsearch $lcurr $j]>-1} {
		lappend survival_tmp $j
	    }
	}
	set survival $survival_tmp
    }
    
    return double([llength $survival])
}

proc wsurvival {psfname dcdname dcdFreq timestep d} {
    set displayPeriod 1
    set text "water and noh and within $d of protein"

    # Get the time change between frames in picoseconds.                                                                       
    set dt [expr 1.0e-3*$timestep*$dcdFreq]

    # Load the trajectory.                                                                                                     
    mol load psf ${psfname}.psf
    mol addfile ${dcdname}.dcd type dcd first 0 last 99 waitfor all
    set nFrames [molinfo top get numframes]
    puts [format "Reading %i frames." $nFrames]

    set outfile [open "wsur_${dcdname}.dat" w]
    puts $outfile "t S_$dcdname"

    set sel [atomselect top $text]
    # Move forward, computing Chb(t)                                                                                          
    for {set fincr 0} {$fincr <= $nFrames-1} {incr fincr} {
        # Get the time in picoseconds for this increment.                                                                    
        set t [expr $fincr*$dt]
        set S_t 0
	set total_S_t 0
  
        for {set startframe 0} {$startframe < [expr $nFrames-$fincr]} {incr startframe} {
            set lastframe [expr $startframe + $fincr]
	    # compute number of survival molecules
	    set S_ti [computeS $startframe $lastframe $text]
	    # Normalization
	    if {$fincr == 0} {
		lappend S_t0 $S_ti
	    }
	    set S_ti [expr $S_ti/[lindex $S_t0 $startframe]]
	    set total_S_t [expr $total_S_t+$S_ti]
        }

        set S_t [expr $total_S_t/($nFrames-$fincr)]
        # Write to the output file.                                                                                    
        puts $outfile "$t $S_t"

        # Update the display.                                                                                              
	if {$fincr % $displayPeriod == 0} {
            puts "t:$t S_t:$S_t"
        }
    }
    close $outfile
    mol delete top
}
