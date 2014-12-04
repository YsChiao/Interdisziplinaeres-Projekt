setenv SIM_WORKING_FOLDER .
set newDesign 0
if {![file exists "C:/Users/Yisong/Documents/new/mlp/testbench/testbench.adf"]} { 
	design create testbench "C:/Users/Yisong/Documents/new/mlp"
  set newDesign 1
}
design open "C:/Users/Yisong/Documents/new/mlp/testbench"
cd "C:/Users/Yisong/Documents/new/mlp"
designverincludedir -clear
designverlibrarysim -PL -clear
designverlibrarysim -L -clear
designverlibrarysim -PL pmi_work
designverlibrarysim ovi_machxo2
designverdefinemacro -clear
if {$newDesign == 0} { 
  removefile -Y -D *
}
addfile "C:/Users/Yisong/Documents/new/mlp/mlp_pkg.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/output.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/pr.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/test.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/loadWeight.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/ram_dp_true.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/sram_dp_true.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/receiver.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_exp.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/a_s.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/div_nr_wsticky.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_div.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_mul.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_leading_zeros_and_shift.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/right_shifter.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_add.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/efb_spi.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/spi.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/reset.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/main.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/output_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_add_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_div_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_exp_clk_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/spi2_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/main_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_exp_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/fp_mul_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/receiver_tb.vhd"
addfile "C:/Users/Yisong/Documents/new/mlp/sram_dp_tb.vhd"
vlib "C:/Users/Yisong/Documents/new/mlp/testbench/work"
set worklib work
adel -all
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/mlp_pkg.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/output.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/pr.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/test.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/loadWeight.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/ram_dp_true.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/sram_dp_true.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/receiver.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_exp.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/a_s.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/div_nr_wsticky.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_div.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_mul.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_leading_zeros_and_shift.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/right_shifter.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_add.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/efb_spi.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/spi.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/reset.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/main.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/output_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_add_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_div_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_exp_clk_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/spi2_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/main_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_exp_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/fp_mul_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/receiver_tb.vhd"
vcom -dbg -work work "C:/Users/Yisong/Documents/new/mlp/sram_dp_tb.vhd"
entity testbench
vsim +access +r testbench   -PL pmi_work -L ovi_machxo2
add wave *
run 1000ns
