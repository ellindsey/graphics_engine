
# Efinity Interface Designer SDC
# Version: 2023.1.150
# Date: 2025-03-19 11:51

# Copyright (C) 2017 - 2023 Efinix Inc. All rights reserved.

# Device: T20F256
# Project: graphics_engine
# Timing Model: C4 (final)

# External clock input
#################
#create_clock -period 40 -name clk [get_ports clk]

# PLL Constraints
#################
create_clock -waveform {1.9868 5.9603} -period 7.9470 CLK125M
create_clock -period 19.8675 CLK50M
create_clock -period 39.7351 CLK25M
create_clock -period 5.0000 CLK200M
create_clock -period 10.0000 CLK100M
create_clock -period 651.4286 CLK1M535

# GPIO Constraints
####################
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[0]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[0]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[1]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[1]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[2]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[2]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[3]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[3]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[4]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[4]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[5]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[5]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[6]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[6]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[7]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[7]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[8]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[8]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[9]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[9]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[10]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[10]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[11]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[11]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[12]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[12]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[13]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[13]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[14]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[14]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {ADDR[15]}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {ADDR[15]}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {nCS}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {nCS}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {nRE}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {nRE}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {nWE}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {nWE}]
# set_output_delay -clock CLK1M535 -max <MAX CALCULATION> [get_ports {LRCLK}]
# set_output_delay -clock CLK1M535 -min <MIN CALCULATION> [get_ports {LRCLK}]
# set_output_delay -clock CLK1M535 -max <MAX CALCULATION> [get_ports {MCLK}]
# set_output_delay -clock CLK1M535 -min <MIN CALCULATION> [get_ports {MCLK}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {nINT}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {nINT}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {nREADY}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {nREADY}]
# set_output_delay -clock CLK1M535 -max <MAX CALCULATION> [get_ports {SCLK}]
# set_output_delay -clock CLK1M535 -min <MIN CALCULATION> [get_ports {SCLK}]
# set_output_delay -clock CLK1M535 -max <MAX CALCULATION> [get_ports {SDATA}]
# set_output_delay -clock CLK1M535 -min <MIN CALCULATION> [get_ports {SDATA}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA0_IN}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA0_IN}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA0_OUT}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA0_OUT}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA0_OE}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA0_OE}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA1_IN}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA1_IN}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA1_OUT}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA1_OUT}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA1_OE}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA1_OE}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA2_IN}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA2_IN}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA2_OUT}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA2_OUT}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA2_OE}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA2_OE}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA3_IN}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA3_IN}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA3_OUT}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA3_OUT}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA3_OE}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA3_OE}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA4_IN}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA4_IN}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA4_OUT}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA4_OUT}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA4_OE}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA4_OE}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA5_IN}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA5_IN}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA5_OUT}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA5_OUT}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA5_OE}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA5_OE}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA6_IN}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA6_IN}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA6_OUT}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA6_OUT}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA6_OE}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA6_OE}]
# set_input_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA7_IN}]
# set_input_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA7_IN}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA7_OUT}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA7_OUT}]
# set_output_delay -clock CLK100M -max <MAX CALCULATION> [get_ports {DATA7_OE}]
# set_output_delay -clock CLK100M -min <MIN CALCULATION> [get_ports {DATA7_OE}]

# LVDS Tx Constraints
####################
set_output_delay -clock CLK50M -max -4.030 [get_ports {HDMI0_DATA[4] HDMI0_DATA[3] HDMI0_DATA[2] HDMI0_DATA[1] HDMI0_DATA[0]}]
set_output_delay -clock CLK50M -min -2.135 [get_ports {HDMI0_DATA[4] HDMI0_DATA[3] HDMI0_DATA[2] HDMI0_DATA[1] HDMI0_DATA[0]}]
set_output_delay -clock CLK50M -max -4.030 [get_ports {HDMI1_DATA[4] HDMI1_DATA[3] HDMI1_DATA[2] HDMI1_DATA[1] HDMI1_DATA[0]}]
set_output_delay -clock CLK50M -min -2.135 [get_ports {HDMI1_DATA[4] HDMI1_DATA[3] HDMI1_DATA[2] HDMI1_DATA[1] HDMI1_DATA[0]}]
set_output_delay -clock CLK50M -max -4.030 [get_ports {HDMI2_DATA[4] HDMI2_DATA[3] HDMI2_DATA[2] HDMI2_DATA[1] HDMI2_DATA[0]}]
set_output_delay -clock CLK50M -min -2.135 [get_ports {HDMI2_DATA[4] HDMI2_DATA[3] HDMI2_DATA[2] HDMI2_DATA[1] HDMI2_DATA[0]}]
set_output_delay -clock CLK50M -max -4.030 [get_ports {HDMICLK_DATA[4] HDMICLK_DATA[3] HDMICLK_DATA[2] HDMICLK_DATA[1] HDMICLK_DATA[0]}]
set_output_delay -clock CLK50M -min -2.135 [get_ports {HDMICLK_DATA[4] HDMICLK_DATA[3] HDMICLK_DATA[2] HDMICLK_DATA[1] HDMICLK_DATA[0]}]
