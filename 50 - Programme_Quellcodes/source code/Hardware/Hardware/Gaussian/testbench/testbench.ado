setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "C:/Users/Yisong/Documents/new/gaussian/testbench/testbench.adf"]} { 
	design create testbench "C:/Users/Yisong/Documents/new/gaussian"
  set newDesign 1
}
design open "C:/Users/Yisong/Documents/new/gaussian/testbench"
cd "C:/Users/Yisong/Documents/new/gaussian"
designverincludedir -clear
designverlibrarysim -PL -clear
designverlibrarysim -L -clear
designverlibrarysim -PL pmi_work
designverlibrarysim ovi_machxo2
designverdefinemacro -clear
if {$newDesign == 0} { 
  removefile -Y -D *
}
addfile "C:/Users/Yisong/Documents/new/gaussian/conv_3x3_pkg.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/std_fifo.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/std_fifo_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/rc_counter.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/window_3x3.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/conv_3x3.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/efb_spi.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/spi.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/reset.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/main.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/conv_3x3_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/main_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/gaussian/spi2_tb.vhd"
vlib "C:/Users/Yisong/Documents/new/gaussian/testbench/work"
set worklib work
adel -all
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/conv_3x3_pkg.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/std_fifo.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/std_fifo_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/rc_counter.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/window_3x3.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/conv_3x3.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/efb_spi.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/spi.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/reset.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/main.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/conv_3x3_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/main_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/gaussian/spi2_tb.vhd"
entity testbench
vsim +access +r testbench   -PL pmi_work -L ovi_machxo2
add wave *
run 1000ns
