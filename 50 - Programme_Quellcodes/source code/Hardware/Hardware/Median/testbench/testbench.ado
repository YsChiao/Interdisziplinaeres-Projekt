setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "C:/Users/Yisong/Documents/new/median/testbench/testbench.adf"]} { 
	design create testbench "C:/Users/Yisong/Documents/new/median"
  set newDesign 1
}
design open "C:/Users/Yisong/Documents/new/median/testbench"
cd "C:/Users/Yisong/Documents/new/median"
designverincludedir -clear
designverlibrarysim -PL -clear
designverlibrarysim -L -clear
designverlibrarysim -PL pmi_work
designverlibrarysim ovi_machxo2
designverdefinemacro -clear
if {$newDesign == 0} { 
  removefile -Y -D *
}
addfile "C:/Users/Yisong/Documents/new/median/test.vhd"
addfile "C:/Users/Yisong/Documents/new/median/rc_counter.vhd"
addfile "C:/Users/Yisong/Documents/new/median/std_fifo.vhd"
addfile "C:/Users/Yisong/Documents/new/median/window_3x3.vhd"
addfile "C:/Users/Yisong/Documents/new/median/sort_3x3.vhd"
addfile "C:/Users/Yisong/Documents/new/median/sort_filter.vhd"
addfile "C:/Users/Yisong/Documents/new/median/efb_spi.vhd"
addfile "C:/Users/Yisong/Documents/new/median/spi.vhd"
addfile "C:/Users/Yisong/Documents/new/median/reset.vhd"
addfile "C:/Users/Yisong/Documents/new/median/main.vhd"
addfile "C:/Users/Yisong/Documents/new/median/window_3x3_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/median/spi2_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/median/main_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/median/sort_3x3_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/median/sort_filter_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/median/std_fifo_tb.vhd"
vlib "C:/Users/Yisong/Documents/new/median/testbench/work"
set worklib work
adel -all
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/test.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/rc_counter.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/std_fifo.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/window_3x3.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/sort_3x3.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/sort_filter.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/efb_spi.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/spi.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/reset.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/main.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/window_3x3_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/spi2_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/main_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/sort_3x3_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/sort_filter_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/median/std_fifo_tb.vhd"
entity testbench
vsim +access +r testbench   -PL pmi_work -L ovi_machxo2
add wave *
run 1000ns
