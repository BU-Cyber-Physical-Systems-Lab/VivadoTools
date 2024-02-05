# Create Vivado project and import all designs and verilog code.
# Support only for ZCU102 at the moment
puts "Creating vivado project and importing files"
if {$argc != 3 } {
	puts "Usage: vivado -source import.tcl -tclargs <source folder> <proj name> <board model>"
	puts "board models supported: ZCU102"
  puts "This script will import all the verilog code and the block designs found in <source folder>"
	exit
} else {
    set project_name [lindex $argv 1]
		puts "Creating project ${project_name}.vivado"
    # Set the reference directory for source file relative paths (by default the value is script directory path)
    set origin_dir [file normalize [lindex $argv 0]]
    # Use origin directory path location variable, if specified in the tcl shell
    if { [info exists ::origin_dir_loc] } {
        set origin_dir $::origin_dir_loc
    }
    variable script_file
    set script_file "import.tcl"

    # select board specific details
    switch [lindex $argv 2] {
        "ZCU102" {
            set target_part "xczu9eg-ffvb1156-2-e"
            set board_part "xilinx.com:zcu102:part0:3.1"
            set compute_units "60"
            set xil_defaultlib "xil_defaultlib"
        }
        default {
            puts "${[lindex $argv2]} does not match any configured board"
            exit
        }
    }

    # Create project
    create_project ${project_name} $origin_dir/${project_name}.vivado -part ${target_part}

    # Set the directory path for the new project
    set proj_dir [get_property directory [current_project]]

    # Set project properties
    set obj [current_project]
    set_property -name "board_part" -value "${board_part}" -objects $obj
    set_property -name "default_lib" -value "${xil_defaultlib}" -objects $obj
    set_property -name "dsa.num_compute_units" -value "${compute_units}" -objects $obj
    set_property -name "ip_cache_permissions" -value "read write" -objects $obj
    set_property -name "ip_output_repo" -value "$proj_dir/${project_name}.cache/ip" -objects $obj
    set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
    set_property -name "simulator_language" -value "Mixed" -objects $obj

    # Create 'sources_1' fileset (if not found)
    if {[string equal [get_filesets -quiet sources_1] ""]} {
        create_fileset -srcset sources_1
    }

    # Set 'sources_1' fileset object
    set obj [get_filesets sources_1]
    # Import local files from the original project
    set files [glob ${origin_dir}/src/*.{v,sv,vh}]
    set normalized_files [list]
    foreach src_file $files {
        lappend normalized_files [file normalize $src_file]
    }
    set imported_files [import_files -fileset sources_1 $normalized_files]

    # Set IP repository paths
    set obj [get_filesets sources_1]
    set_property "ip_repo_paths" "[file normalize "$origin_dir/ip_repo"]" $obj

    # Rebuild user ip_repo's index before adding any source files
    update_ip_catalog -rebuild

    # Create 'constrs_1' fileset (if not found)
    if {[string equal [get_filesets -quiet constrs_1] ""]} {
        create_fileset -constrset constrs_1
    }
    # Set 'constrs_1' fileset object
    set obj [get_filesets constrs_1]
    set_property -name "target_part" -value "$target_part" -objects $obj

    # Set 'constrs_1' fileset properties
    set obj [get_filesets constrs_1]

    # Create 'sim_1' fileset (if not found)
    if {[string equal [get_filesets -quiet sim_1] ""]} {
        create_fileset -simset sim_1
    }
    # Set 'sim_1' fileset object
    set obj [get_filesets sim_1]
    # Import local files from the original project
    set files [glob ${origin_dir}/sim/*.{v,sv,vh}]
    set normalized_files [list]
    foreach src_file $files {
        lappend normalized_files [file normalize $src_file]
    }
    set imported_files [import_files -fileset sim_1 $normalized_files]

    # Create block designs
    set bd_files [glob ${origin_dir}/bd/*.tcl]
    foreach bd_file $bd_files {
        source ${bd_file}
    }
    # Generate the wrappers
    set design_names [get_bd_designs]
    foreach design_name $design_names {
        make_wrapper -files [get_files $design_name.bd] -top -import
        save_bd_design
    }
    puts "INFO: Project created:$project_name"
    puts "WARN: This initial import has not synthesis or implementation runs, you should reexport the project and the block designs after creating to those to save them"
    puts "INFO: To export your project go to File -> Project -> Write tcl"
    puts "INFO: make sure that copy sources to new project is ticked"
    puts "INFO: to export the block designs you should open each of them and run the following code:"
    puts "INFO: write_bd_tcl -force -ignore_minor_versions -check_ips true -include_layout ./<path to exported block design file>.tcl"
}