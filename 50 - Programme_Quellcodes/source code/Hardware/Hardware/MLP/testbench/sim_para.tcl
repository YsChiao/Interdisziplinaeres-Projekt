lappend auto_path "C:/lscc/diamond/3.1_x64/data/script"
package require simulation_generation
set ::bali::simulation::Para(PROJECT) {testbench}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/Yisong/Documents/new/mlp}
set ::bali::simulation::Para(FILELIST) {"C:/Users/Yisong/Documents/new/mlp/mlp_pkg.vhd" "C:/Users/Yisong/Documents/new/mlp/output.vhd" "C:/Users/Yisong/Documents/new/mlp/pr.vhd" "C:/Users/Yisong/Documents/new/mlp/test.vhd" "C:/Users/Yisong/Documents/new/mlp/loadWeight.vhd" "C:/Users/Yisong/Documents/new/mlp/ram_dp_true.vhd" "C:/Users/Yisong/Documents/new/mlp/sram_dp_true.vhd" "C:/Users/Yisong/Documents/new/mlp/receiver.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_exp.vhd" "C:/Users/Yisong/Documents/new/mlp/a_s.vhd" "C:/Users/Yisong/Documents/new/mlp/div_nr_wsticky.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_div.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_mul.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_leading_zeros_and_shift.vhd" "C:/Users/Yisong/Documents/new/mlp/right_shifter.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_add.vhd" "C:/Users/Yisong/Documents/new/mlp/fp.vhd" "C:/Users/Yisong/Documents/new/mlp/efb_spi.vhd" "C:/Users/Yisong/Documents/new/mlp/spi.vhd" "C:/Users/Yisong/Documents/new/mlp/reset.vhd" "C:/Users/Yisong/Documents/new/mlp/main.vhd" "C:/Users/Yisong/Documents/new/mlp/output_tb.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_add_tb.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_div_tb.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_exp_clk_tb.vhd" "C:/Users/Yisong/Documents/new/mlp/spi2_tb.vhd" "C:/Users/Yisong/Documents/new/mlp/main_tb.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_exp_tb.vhd" "C:/Users/Yisong/Documents/new/mlp/fp_mul_tb.vhd" "C:/Users/Yisong/Documents/new/mlp/receiver_tb.vhd" "C:/Users/Yisong/Documents/new/mlp/sram_dp_tb.vhd" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_machxo2}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {testbench}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VHDL}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(POJO2LIBREFRESH)    {}
set ::bali::simulation::Para(POJO2MODELSIMLIB)   {}
::bali::simulation::ActiveHDL_Run
