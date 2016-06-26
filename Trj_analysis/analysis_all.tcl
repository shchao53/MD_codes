set mutlist [list wt N27C N58C]

foreach mut $mutlist {

    set syspath ../1-system
    set trjpath ../3-analysis
    set inPrefix ${mut}_ions
    set dcdName ${mut}_run_nw
    set outfile_rmsd_all [open "${mut}_rmsd_backbone.txt" w]
    set outfile_sasa_all [open "${mut}_sasa_all.txt" w]
    set outfile_sasa_hpob [open "${mut}_sasa_hpob.txt" w]
    set outfile_sasa_hpli [open "${mut}_sasa_hpli.txt" w]

    set timestep 2
    set dcdFreq 24000
    
    # Get the time change between frames in nanoseconds.
    set dt [expr 1.0e-6*$timestep*$dcdFreq]
    
    # Load the reference system.
    set refid [mol load psf ${syspath}/${mut}.psf pdb ${syspath}/${mut}.pdb]
    set ref_p_noh [atomselect $refid "protein and backbone"]

    # Load the trajectory.
    set trjid [mol load psf ${syspath}/${mut}.psf]
    mol addfile ${trjpath}/${dcdName}.dcd waitfor all
    set trj_p_all [atomselect $trjid "protein"]
    set trj_p_noh [atomselect $trjid "protein and backbone"]
    set trj_p_hpob [atomselect $trjid "protein and hydrophobic"]
    set trj_p_hpli [atomselect $trjid "protein and not hydrophobic"]

    set nFrames [molinfo $trjid get numframes]
    
    puts ${mut}
    for {set f 0} {$f < $nFrames} {incr f} {
	progressbar $f $nFrames
	molinfo $trjid set frame $f
	set t [expr $f*$dt]

        $trj_p_all move [measure fit $trj_p_noh $ref_p_noh]

	# measure overal rmsd
	set rmsd_all [measure rmsd $ref_p_noh $trj_p_noh]
	puts $outfile_rmsd_all "[format %.4f $t] $rmsd_all"

	# measure overall SASA 
	set sasa_all [measure sasa 1.4 $trj_p_all]
	set sasa_hpob [measure sasa 1.4 $trj_p_hpob]
	set sasa_hpli [measure sasa 1.4 $trj_p_hpli]
	puts $outfile_sasa_all "[format %.4f $t] $sasa_all" 
	puts $outfile_sasa_hpob "[format %.4f $t] $sasa_hpob" 
	puts $outfile_sasa_hpli "[format %.4f $t] $sasa_hpli" 
	
    }
    
    mol delete all
    delete_all_sels
    close_all_files
    
}

