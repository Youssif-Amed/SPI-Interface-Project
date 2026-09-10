###################################################################

# Created by write_sdc on Wed Aug 19 03:47:11 2026

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max scmetro_tsmc_cl013g_rvt_ss_1p08v_125c            \
-max_library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c\
                         -min scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c            \
-min_library scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c
set_wire_load_model -name tsmc13_wl30 -library                                 \
scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c
set_max_area 0
set_driving_cell -lib_cell BUFX2M -library                                     \
scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -pin Y [get_ports MOSI]
set_driving_cell -lib_cell BUFX2M -library                                     \
scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -pin Y [get_ports SS_n]
set_load -pin_load 75 [get_ports MISO]
create_clock [get_ports clk]  -period 100  -waveform {0 50}
set_clock_latency 0  [get_clocks clk]
set_clock_uncertainty -setup 0.2  [get_clocks clk]
set_clock_uncertainty -hold 0.1  [get_clocks clk]
set_clock_transition -min -fall 0.05 [get_clocks clk]
set_clock_transition -max -fall 0.05 [get_clocks clk]
set_clock_transition -min -rise 0.05 [get_clocks clk]
set_clock_transition -max -rise 0.05 [get_clocks clk]
set_input_delay -clock clk  20  [get_ports MOSI]
set_input_delay -clock clk  20  [get_ports SS_n]
set_output_delay -clock clk  20  [get_ports MISO]
