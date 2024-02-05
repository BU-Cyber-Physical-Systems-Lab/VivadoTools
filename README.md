Vivado Tools
============

A Collection of tools that aim to decouple Vivado versions and hardware designs.

`import.tcl`
--------------
To use this script to automatically create vivado projects the underlying repository has to have the following folder structure:
- `src`: HDL sources (generally verilog / systemverilog files).
- `sim`: Simulation sources (all the testbenches).
- `bd`: The exported block designs.
- `ip repo`: The packed IPs repository.

When to create a new repository with this structure you can user the `init_repo.sh` script.

To execute the script run `vivado -source import.tcl <source folder> <proj name> <board model>`

Export Block designs
-------------------------
To convert block designs to tcl code you have to open vivado and for each block design
you have to:
1. Open the block design 
2. Execute the following commands in the tcl console: 
   `write_bd_tcl -force -ignore_minor_versions -check_ips true -include_layout ./<path to exported block design file>.tcl`
3. **Remember to do this every time you modify the block design!**
