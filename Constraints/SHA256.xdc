# SHA256.xdc - Timing constraints for SHA-256 on Vivado 2020.1
# Target: Xilinx 7-series FPGAs at 100MHz

# Clock constraint - 100MHz (10ns period)
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# Input/Output delay constraints
set_input_delay -clock clk -min 1.000 [get_ports {reset start_in}]
set_input_delay -clock clk -max 2.000 [get_ports {reset start_in}]

set_input_delay -clock clk -min 1.000 [get_ports {w*_sha256 A_i B_i C_i D_i E_i F_i G_i H_i}]
set_input_delay -clock clk -max 2.000 [get_ports {w*_sha256 A_i B_i C_i D_i E_i F_i G_i H_i}]

set_output_delay -clock clk -min 1.000 [get_ports {sha256_result sha256_done}]
set_output_delay -clock clk -max 2.000 [get_ports {sha256_result sha256_done}]

# Timing exceptions
set_false_path -from [get_ports reset]

# Clock uncertainty
set_clock_uncertainty 0.100 [get_clocks clk]

# Additional timing constraints for critical paths
set_max_delay -from [get_pins -hier *reg*/C] -to [get_pins -hier *reg*/D] 9.500

# Placement constraints (optional - for better timing closure)
# set_property LOC SLICE_X0Y0 [get_cells {SHA256_Top_inst}]

# I/O Standards
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports start_in]
set_property IOSTANDARD LVCMOS33 [get_ports sha256_done]

# Drive strength
set_property DRIVE 12 [get_ports sha256_done]

# Slew rate
set_property SLEW FAST [get_ports sha256_done]