set mutlist [list wt N27C N58C]

foreach mut $mutlist {

    set syspath ../1-system
    set trjpath ../2-simulation
    set inPrefix ${mut}_ions
    set dcdName ${mut}_run
    set alignSelection "protein and noh"

    ## Get the time change between frames in nanoseconds.
    set timestep 2
    set dcdFreq 24000
    set dt [expr 1.0e-6*$timestep*$dcdFreq]

    ## output files
    set outfile_rmsd_res [open "${mut}_rmsd_res.txt" w]
    set outfile_sasa_res [open "${mut}_sasa_res.txt" w]
    set outfile_dihe_res [open "${mut}_dihe_res.txt" w]
    set outfile_struct_res [open "${mut}_struct_res.txt" w]
        
    ## Load the reference system.
    set refid [mol load psf ${syspath}/${mut}.psf pdb ${syspath}/${mut}.pdb]
    set ref_p_noh [atomselect $refid $alignSelection]

    ## Load the trajectory.
    set trjid [mol load psf ${syspath}/${inPrefix}.psf]
    mol addfile ${trjpath}/${dcdName}.dcd waitfor all
    set trj_p_noh [atomselect $trjid $alignSelection]
    set trj_all [atomselect $trjid all]
    
    ## get residue info
    set mol_ca [atomselect $trjid "alpha"]
    set mol_resid [$mol_ca get resid] 
    set mol_resname [$mol_ca get resname]

    ## write the column names to the file
    puts -nonewline $outfile_rmsd_res "Time "
    puts -nonewline $outfile_sasa_res "Time "
    foreach id $mol_resid name $mol_resname {
    	puts -nonewline $outfile_rmsd_res "$name$id "
    	puts -nonewline $outfile_sasa_res "$name$id "
    }
    puts $outfile_rmsd_res ""
    puts $outfile_sasa_res ""

    set nFrames [molinfo $trjid get numframes]
    puts ${mut}
    for {set f 0} {$f < $nFrames} {incr f} {
	progressbar $f $nFrames
	molinfo $trjid set frame $f
	set protein [atomselect top "protein"]

	## fit the molecule to crystal structure 
	set sel_f [atomselect $trjid $alignSelection]
        $trj_all move [measure fit $sel_f $ref_p_noh]
        
        ## Write the timsetamp column.
	set t [expr $f*$dt]
        puts -nonewline $outfile_rmsd_res "[format %.4f $t] "
	puts -nonewline $outfile_sasa_res "[format %.4f $t] "
	$sel_f delete
	
	## calculate the structure
	vmd_calculate_structure $trjid
	
	foreach resid $mol_resid resname $mol_resname {
	    ## measure residue rmsd
	    set ref_p_resi_noh [atomselect $refid "protein and noh and resid $resid"]
	    set trj_p_resi_noh [atomselect $trjid "protein and noh and resid $resid"]
	    set rmsd_resi [measure rmsd $ref_p_resi_noh $trj_p_resi_noh]
  
	    puts -nonewline $outfile_rmsd_res "$rmsd_resi "
	    $ref_p_resi_noh delete
	    $trj_p_resi_noh delete

	    set trj_p_resi [atomselect $trjid "protein and resid $resid"]
	    ## measure residue sasa
	    set sasa_resi [measure sasa 1.4 $protein -restrict $trj_p_resi]
	    puts -nonewline $outfile_sasa_res "$sasa_resi "

	    ## measure dihedral angles phi psi
	    set psi [lsort -unique [$trj_p_resi get psi]] 
	    set phi [lsort -unique [$trj_p_resi get phi]]
	    puts $outfile_dihe_res "$resid $resname [format %.4f $t] $f $phi $psi"		

	    ## measure secondary structure 
	    set struct [lsort -unique [$trj_p_resi get structure]]
	    puts $outfile_struct_res "$resid $resname [format %.4f $t] $f $struct"		

	    $trj_p_resi delete
	}
	
	puts $outfile_rmsd_res ""
	puts $outfile_sasa_res ""
    }
    
    mol delete all
    delete_all_sels
    close_all_files
    
}

