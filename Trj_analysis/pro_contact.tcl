# Compute PEG-Protein contact map for each frame
# Shu-Han Chao 08/28/13

set findrange 10

# compute the distance of protein residues to a given unit of selection (here is part of PEG)
proc ContactMap {iframe sel1 mapi} {
    global findrange
    global m
    global n
    global m0_resid
    global n0_resid
    $sel1 frame $iframe
    $sel1 update
    
    set unitnum [$sel1 num]
    for {set i 0} {$i < $unitnum} {incr i} {
	set resid [lindex [$sel1 get resid] $i]
	set text2 "protein and within ${findrange} of (segname PEG and name O1 and resid ${resid})"
	set sel2 [atomselect top $text2]
	$sel2 frame $iframe 
	$sel2 update
	set pnum [$sel2 num]
	for {set j 0} {$j < $pnum} {incr j} {
	    set dist [vecdist [lindex [$sel1 get {x y z}] $i] [lindex [$sel2 get {x y z}] $j]]
     
	    set mi [expr [lindex [$sel2 get resid] $j] - $m0_resid]
	    set ni [expr $resid - $n0_resid]
	    if {[lindex $mapi $mi $ni] == $findrange} {
		lset mapi $mi $ni $dist
	    } elseif {$dist < [lindex $mapi $mi $ni]} {
		lset mapi $mi $ni $dist
	    }
	}
    }

    return $mapi
}

# Main code
proc ProteinContact {} {
    
    # the dimention and initial resid of contact map mxn
    global m
    global n
    global m0_resid
    global n0_resid
    global findrange  

    set displayPeriod 20
    set startframe 0 
    set endframe 10
    
    # set Oxygen atoms of PEG as selection1
    set text1 "(segname PEG and name O1) and within ${findrange} of protein" 

#     # Get the time change between frames in picoseconds.                                                                       
#     set dt [expr 1.0e-3*$timestep*$dcdFreq]

    # Load the trajectory.                                                                                                     
    # mol load psf 
#     mol addfile ${dcdname}.dcd type dcd first $startframe last $endframe waitfor all
    set nFrames [molinfo top get numframes]
    puts [format "Reading %i frames." $nFrames]
    set sel1 [atomselect top $text1] 

    # set the contact map matrix
    set n [[atomselect top "segname PEG and name O1"] num]
    set m [[atomselect top "protein and name CA"] num]
    set n0_resid [lindex [[atomselect top "segname PEG and name O1"] get resid] 0]
    set m0_resid [lindex [[atomselect top "protein and name CA"] get resid] 0]    
    set row {}
    for {set i 0} {$i < $n} {incr i} {lappend row $findrange}
    set map {}
    for {set i 0} {$i < $m} {incr i} {lappend map "$row"}
    
    # Process frame by frame
    for {set iframe $startframe} {$iframe < $nFrames} {incr iframe} {
	set outfile [open "~/Han/PhD/WW/ContactMap/S16AY23FP4/data/contactmap_S16AY23FP4_${iframe}.txt" w]

	set mapi [ContactMap $iframe $sel1 $map]
		
	# Update the display.                                                                                              
	if {$iframe % $displayPeriod == 0} {
	    puts "frame: $iframe"
	}
	
#	puts $mapi
	# write to map of iframe to an dat file with 3 decimal precision 
	for {set i 0} {$i < $m} {incr i} {
	    for {set j 0} {$j < $n} {incr j} {
		puts -nonewline $outfile "[expr double(round([lindex $mapi $i $j]*1000))/1000] "
	    }
	    puts $outfile ""
	}	
	close $outfile
    }

    #mol delete top
}



