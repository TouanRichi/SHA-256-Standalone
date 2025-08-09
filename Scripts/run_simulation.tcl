# run_simulation.tcl - Vivado simulation script for SHA-256
# Compatible with Vivado 2020.1

# Set project variables
set project_name "SHA256_Standalone"
set top_module "SHA256_Top"
set tb_module "SHA256_tb"

# Create project directory
set project_dir "./vivado_project"
file mkdir $project_dir

# Create new project
create_project $project_name $project_dir -part xc7a35tcpg236-1 -force

# Add source files
add_files -fileset sources_1 [glob ./Source/*.v]
set_property top $top_module [get_filesets sources_1]

# Add testbench files  
add_files -fileset sim_1 ./Testbench/SHA256_tb.v
set_property top $tb_module [get_filesets sim_1]

# Add constraints
add_files -fileset constrs_1 ./Constraints/SHA256.xdc

# Set simulation properties
set_property -name {xsim.simulate.runtime} -value {50us} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Launch synthesis (optional)
# launch_runs synth_1 -jobs 4
# wait_on_run synth_1

# Launch simulation
launch_simulation

# Add waves to waveform viewer
add_wave {{/SHA256_tb/uut/clk}}
add_wave {{/SHA256_tb/uut/reset}}  
add_wave {{/SHA256_tb/uut/start_in}}
add_wave {{/SHA256_tb/uut/sha256_done}}
add_wave {{/SHA256_tb/uut/sha256_result}}
add_wave {{/SHA256_tb/uut/w0_sha256}}
add_wave {{/SHA256_tb/uut/w15_sha256}}

# Configure waveform display
configure_wave -namecolwidth 250
configure_wave -valuecolwidth 100  
configure_wave -signalwidth 1

# Run simulation
run all

# Save waveform
save_wave_config SHA256_waveform.wcfg

puts "SHA-256 simulation completed successfully!"
puts "Check waveform for detailed analysis."