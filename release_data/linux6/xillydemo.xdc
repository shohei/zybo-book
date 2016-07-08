# clk_100 is a misnomer for Zybo, since the clock is 125 MHz. The name
# is taken from Zedboard's reference clock

create_clock -period 8.000 -name gclk [get_ports clk_100]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_100]

# Vivado constraints unrelated clocks. So set false paths.
set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks vga_clk_ins/*]
set_false_path -from [get_clocks vga_clk_ins/*] -to [get_clocks clk_fpga_1]

# The VGA outputs are turned into an analog voltage by virtue of a resistor
# network, so the flip flops driving these must sit in the IOBs to minimize
# timing skew. The RTL code should handle this, but the constraint below
# is there to fail if something goes wrong about this.
set_output_delay 5.500 [get_ports vga*]

# The VGA core's MMCM must be close to the HDMI I/O's pins, because it drives
# the OSERDES' clock directly

set_property LOC MMCME2_ADV_X0Y1 [get_cells xillybus_ins/system_i/vivado_system_i/xillyvga_0/inst/xillyvga_core_ins/vga_clk_ins/vga_mmcm]
set_property LOC PLLE2_ADV_X0Y0 [get_cells audio/plle2_adv_inst]

set_property PACKAGE_PIN L16 [get_ports clk_100]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100]
set_property PACKAGE_PIN M14 [get_ports {GPIO_LED[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LED[0]}]
set_property PACKAGE_PIN M15 [get_ports {GPIO_LED[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LED[1]}]
set_property PACKAGE_PIN G14 [get_ports {GPIO_LED[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LED[2]}]
set_property PACKAGE_PIN D18 [get_ports {GPIO_LED[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {GPIO_LED[3]}]

set_property PACKAGE_PIN M19 [get_ports {vga4_red[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_red[0]}]
set_property PACKAGE_PIN L20 [get_ports {vga4_red[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_red[1]}]
set_property PACKAGE_PIN J20 [get_ports {vga4_red[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_red[2]}]
set_property PACKAGE_PIN G20 [get_ports {vga4_red[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_red[3]}]
set_property PACKAGE_PIN F19 [get_ports {vga4_red[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_red[4]}]
set_property PACKAGE_PIN H18 [get_ports {vga4_green[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_green[0]}]
set_property PACKAGE_PIN N20 [get_ports {vga4_green[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_green[1]}]
set_property PACKAGE_PIN L19 [get_ports {vga4_green[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_green[2]}]
set_property PACKAGE_PIN J19 [get_ports {vga4_green[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_green[3]}]
set_property PACKAGE_PIN H20 [get_ports {vga4_green[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_green[4]}]
set_property PACKAGE_PIN F20 [get_ports {vga4_green[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_green[5]}]
set_property PACKAGE_PIN P20 [get_ports {vga4_blue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_blue[0]}]
set_property PACKAGE_PIN M20 [get_ports {vga4_blue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_blue[1]}]
set_property PACKAGE_PIN K19 [get_ports {vga4_blue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_blue[2]}]
set_property PACKAGE_PIN J18 [get_ports {vga4_blue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_blue[3]}]
set_property PACKAGE_PIN G19 [get_ports {vga4_blue[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga4_blue[4]}]
set_property PACKAGE_PIN P19 [get_ports vga_hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]
set_property PACKAGE_PIN R19 [get_ports vga_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]

# PS_GPIO pins:
# GPIO pin 0 was USB OTG PHY reset on Zedboard, now going from MIO46 directly
# GPIO pins 6-1 were connected to OLED on Zedboard, now unused
# GPIO pins 10-7 were connected to the four LEDS not used by Xillybus.
# GPIO pins 18-15 went to four slide switches (Zedboard has 8, Zybo only 4)
# GPIO pin 23 went to Zedboard's 5th, middle push button. Zybo has only four.

# On-board Slide Switches

set_property PACKAGE_PIN G15 [get_ports {PS_GPIO[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[11]}]
set_property PACKAGE_PIN P15 [get_ports {PS_GPIO[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[12]}]
set_property PACKAGE_PIN W13 [get_ports {PS_GPIO[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[13]}]
set_property PACKAGE_PIN T16 [get_ports {PS_GPIO[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[14]}]

# On-board Pushbuttons
set_property PACKAGE_PIN R18 [get_ports {PS_GPIO[19]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[19]}]
set_property PACKAGE_PIN P16 [get_ports {PS_GPIO[20]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[20]}]
set_property PACKAGE_PIN V16 [get_ports {PS_GPIO[21]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[21]}]
set_property PACKAGE_PIN Y16 [get_ports {PS_GPIO[22]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[22]}]

# The PMODs have been assigned so that software that ran on the Zedboard sees
# the same A-B-C mapping w.r.t. the GPIO number assignments

## Pmod Header JA (XADC)
set_property PACKAGE_PIN N15 [get_ports {PS_GPIO[24]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[24]}]
set_property PACKAGE_PIN L14 [get_ports {PS_GPIO[25]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[25]}]
set_property PACKAGE_PIN K16 [get_ports {PS_GPIO[26]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[26]}]
set_property PACKAGE_PIN K14 [get_ports {PS_GPIO[27]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[27]}]
set_property PACKAGE_PIN N16 [get_ports {PS_GPIO[28]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[28]}]
set_property PACKAGE_PIN L15 [get_ports {PS_GPIO[29]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[29]}]
set_property PACKAGE_PIN J16 [get_ports {PS_GPIO[30]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[30]}]
set_property PACKAGE_PIN J14 [get_ports {PS_GPIO[31]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[31]}]

## Pmod Header JB
#set_property PACKAGE_PIN T20 [get_ports {PS_GPIO[32]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[32]}]
#set_property PACKAGE_PIN U20 [get_ports {PS_GPIO[33]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[33]}]
#set_property PACKAGE_PIN V20 [get_ports {PS_GPIO[34]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[34]}]
#set_property PACKAGE_PIN W20 [get_ports {PS_GPIO[35]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[35]}]
#set_property PACKAGE_PIN Y18 [get_ports {PS_GPIO[36]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[36]}]
#set_property PACKAGE_PIN Y19 [get_ports {PS_GPIO[37]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[37]}]
#set_property PACKAGE_PIN W18 [get_ports {PS_GPIO[38]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[38]}]
#set_property PACKAGE_PIN W19 [get_ports {PS_GPIO[39]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[39]}]

## Pmod Header JC
#set_property PACKAGE_PIN V15 [get_ports {PS_GPIO[40]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[40]}]
#set_property PACKAGE_PIN W15 [get_ports {PS_GPIO[41]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[41]}]
#set_property PACKAGE_PIN T11 [get_ports {PS_GPIO[42]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[42]}]
#set_property PACKAGE_PIN T10 [get_ports {PS_GPIO[43]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[43]}]
#set_property PACKAGE_PIN W14 [get_ports {PS_GPIO[44]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[44]}]
#set_property PACKAGE_PIN Y14 [get_ports {PS_GPIO[45]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[45]}]
#set_property PACKAGE_PIN T12 [get_ports {PS_GPIO[46]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[46]}]
#set_property PACKAGE_PIN U12 [get_ports {PS_GPIO[47]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[47]}]

## Pmod Header JD
#set_property PACKAGE_PIN T14 [get_ports {PS_GPIO[48]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[48]}]
#set_property PACKAGE_PIN T15 [get_ports {PS_GPIO[49]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[49]}]
#set_property PACKAGE_PIN P14 [get_ports {PS_GPIO[50]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[50]}]
#set_property PACKAGE_PIN R14 [get_ports {PS_GPIO[51]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[51]}]
#set_property PACKAGE_PIN U14 [get_ports {PS_GPIO[52]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[52]}]
#set_property PACKAGE_PIN U15 [get_ports {PS_GPIO[53]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[53]}]
#set_property PACKAGE_PIN V17 [get_ports {PS_GPIO[54]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[54]}]
#set_property PACKAGE_PIN V18 [get_ports {PS_GPIO[55]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[55]}]

## Pmod Header JE -- was MIO PMOD on Zedboard, now using leftover GPIOs
set_property PACKAGE_PIN V12 [get_ports {PS_GPIO[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[0]}]
set_property PACKAGE_PIN W16 [get_ports {PS_GPIO[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[1]}]
set_property PACKAGE_PIN J15 [get_ports {PS_GPIO[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[2]}]
set_property PACKAGE_PIN H15 [get_ports {PS_GPIO[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[3]}]
set_property PACKAGE_PIN V13 [get_ports {PS_GPIO[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[4]}]
set_property PACKAGE_PIN U17 [get_ports {PS_GPIO[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[5]}]
set_property PACKAGE_PIN T17 [get_ports {PS_GPIO[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[6]}]
set_property PACKAGE_PIN Y17 [get_ports {PS_GPIO[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[7]}]

# Pin for detecting USB OTG over-current condition
set_property PACKAGE_PIN U13 [get_ports otg_oc]
set_property IOSTANDARD LVCMOS33 [get_ports otg_oc]

# Ethernet PHY's reset and interrupt pin to GPIOs
set_property PACKAGE_PIN F16 [get_ports {PS_GPIO[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[15]}]
set_property PACKAGE_PIN E17 [get_ports {PS_GPIO[16]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[16]}]

# HDMI I2C pins are mapped to GPIO
set_property PACKAGE_PIN G17 [get_ports {PS_GPIO[17]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[17]}]
set_property PACKAGE_PIN G18 [get_ports {PS_GPIO[18]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[18]}]

# These GPIOs don't have any current use, but they must be connected to
# something, or build will fail. So they go to unused pins
set_property PACKAGE_PIN U18 [get_ports {PS_GPIO[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[8]}]
set_property PACKAGE_PIN U19 [get_ports {PS_GPIO[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[9]}]
set_property PACKAGE_PIN R16 [get_ports {PS_GPIO[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[10]}]
set_property PACKAGE_PIN R17 [get_ports {PS_GPIO[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {PS_GPIO[23]}]

# Pins to audio chip
set_property PACKAGE_PIN K18 [get_ports audio_bclk]
set_property IOSTANDARD LVCMOS33 [get_ports audio_bclk]
set_property PACKAGE_PIN T19 [get_ports audio_mclk]
set_property IOSTANDARD LVCMOS33 [get_ports audio_mclk]
set_property PACKAGE_PIN P18 [get_ports audio_mute]
set_property IOSTANDARD LVCMOS33 [get_ports audio_mute]
set_property PACKAGE_PIN M17 [get_ports audio_dac]
set_property IOSTANDARD LVCMOS33 [get_ports audio_dac]
set_property PACKAGE_PIN L17 [get_ports audio_dac_lrclk]
set_property IOSTANDARD LVCMOS33 [get_ports audio_dac_lrclk]
set_property PACKAGE_PIN K17 [get_ports audio_adc]
set_property IOSTANDARD LVCMOS33 [get_ports audio_adc]
set_property PACKAGE_PIN M18 [get_ports audio_adc_lrclk]
set_property IOSTANDARD LVCMOS33 [get_ports audio_adc_lrclk]
set_property PACKAGE_PIN N18 [get_ports smb_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports smb_sclk]
set_property PACKAGE_PIN N17 [get_ports smb_sdata]
set_property IOSTANDARD LVCMOS33 [get_ports smb_sdata]

# HDMI (DVI) outputs
set_property IOSTANDARD TMDS_33 [get_ports hdmi_clk_n]
set_property PACKAGE_PIN H16 [get_ports hdmi_clk_p]
set_property IOSTANDARD TMDS_33 [get_ports hdmi_clk_p]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_n[0]}]
set_property PACKAGE_PIN D19 [get_ports {hdmi_d_p[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_p[0]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_n[1]}]
set_property PACKAGE_PIN C20 [get_ports {hdmi_d_p[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_p[1]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_n[2]}]
set_property PACKAGE_PIN B19 [get_ports {hdmi_d_p[2]}]
set_property IOSTANDARD TMDS_33 [get_ports {hdmi_d_p[2]}]
set_property PACKAGE_PIN F17 [get_ports hdmi_out_en]
set_property IOSTANDARD LVCMOS33 [get_ports hdmi_out_en]


set_property IOSTANDARD LVCMOS33 [get_ports b2]
set_property IOSTANDARD LVCMOS33 [get_ports b1]
set_property IOSTANDARD LVCMOS33 [get_ports {line[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {line[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {line[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports g1]
set_property IOSTANDARD LVCMOS33 [get_ports lat]
set_property IOSTANDARD LVCMOS33 [get_ports g2]
set_property IOSTANDARD LVCMOS33 [get_ports led_clk]
set_property IOSTANDARD LVCMOS33 [get_ports oeb]
set_property IOSTANDARD LVCMOS33 [get_ports r1]
set_property IOSTANDARD LVCMOS33 [get_ports r2]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property PACKAGE_PIN T20 [get_ports led_clk]
set_property PACKAGE_PIN U20 [get_ports lat]
set_property PACKAGE_PIN V20 [get_ports oeb]
set_property PACKAGE_PIN W20 [get_ports {line[0]}]
set_property PACKAGE_PIN Y18 [get_ports {line[1]}]
set_property PACKAGE_PIN Y19 [get_ports {line[2]}]
set_property PACKAGE_PIN W18 [get_ports r1]
set_property PACKAGE_PIN W19 [get_ports r2]
set_property PACKAGE_PIN V15 [get_ports g1]
set_property PACKAGE_PIN W15 [get_ports g2]
set_property PACKAGE_PIN T11 [get_ports b1]
set_property PACKAGE_PIN T10 [get_ports b2]
set_property PACKAGE_PIN M14 [get_ports led]


create_debug_core u_ila_0_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0_0]
set_property port_width 1 [get_debug_ports u_ila_0_0/clk]
connect_debug_port u_ila_0_0/clk [get_nets [list xillybus_ins/system_i/vivado_system_i/processing_system7_0_FCLK_CLK1]]
set_property port_width 32 [get_debug_ports u_ila_0_0/probe0]
connect_debug_port u_ila_0_0/probe0 [get_nets [list {user_w_write_32_data[0]} {user_w_write_32_data[1]} {user_w_write_32_data[2]} {user_w_write_32_data[3]} {user_w_write_32_data[4]} {user_w_write_32_data[5]} {user_w_write_32_data[6]} {user_w_write_32_data[7]} {user_w_write_32_data[8]} {user_w_write_32_data[9]} {user_w_write_32_data[10]} {user_w_write_32_data[11]} {user_w_write_32_data[12]} {user_w_write_32_data[13]} {user_w_write_32_data[14]} {user_w_write_32_data[15]} {user_w_write_32_data[16]} {user_w_write_32_data[17]} {user_w_write_32_data[18]} {user_w_write_32_data[19]} {user_w_write_32_data[20]} {user_w_write_32_data[21]} {user_w_write_32_data[22]} {user_w_write_32_data[23]} {user_w_write_32_data[24]} {user_w_write_32_data[25]} {user_w_write_32_data[26]} {user_w_write_32_data[27]} {user_w_write_32_data[28]} {user_w_write_32_data[29]} {user_w_write_32_data[30]} {user_w_write_32_data[31]}]]
create_debug_port u_ila_0_0 probe
set_property port_width 32 [get_debug_ports u_ila_0_0/probe1]
connect_debug_port u_ila_0_0/probe1 [get_nets [list {user_r_read_32_data[0]} {user_r_read_32_data[1]} {user_r_read_32_data[2]} {user_r_read_32_data[3]} {user_r_read_32_data[4]} {user_r_read_32_data[5]} {user_r_read_32_data[6]} {user_r_read_32_data[7]} {user_r_read_32_data[8]} {user_r_read_32_data[9]} {user_r_read_32_data[10]} {user_r_read_32_data[11]} {user_r_read_32_data[12]} {user_r_read_32_data[13]} {user_r_read_32_data[14]} {user_r_read_32_data[15]} {user_r_read_32_data[16]} {user_r_read_32_data[17]} {user_r_read_32_data[18]} {user_r_read_32_data[19]} {user_r_read_32_data[20]} {user_r_read_32_data[21]} {user_r_read_32_data[22]} {user_r_read_32_data[23]} {user_r_read_32_data[24]} {user_r_read_32_data[25]} {user_r_read_32_data[26]} {user_r_read_32_data[27]} {user_r_read_32_data[28]} {user_r_read_32_data[29]} {user_r_read_32_data[30]} {user_r_read_32_data[31]}]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe2]
connect_debug_port u_ila_0_0/probe2 [get_nets [list user_w_write_32_full]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe3]
connect_debug_port u_ila_0_0/probe3 [get_nets [list user_w_write_32_open]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe4]
connect_debug_port u_ila_0_0/probe4 [get_nets [list user_w_write_32_wren]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe5]
connect_debug_port u_ila_0_0/probe5 [get_nets [list user_r_read_32_empty]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe6]
connect_debug_port u_ila_0_0/probe6 [get_nets [list user_r_read_32_open]]
create_debug_port u_ila_0_0 probe
set_property port_width 1 [get_debug_ports u_ila_0_0/probe7]
connect_debug_port u_ila_0_0/probe7 [get_nets [list user_r_read_32_rden]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets bus_clk]
