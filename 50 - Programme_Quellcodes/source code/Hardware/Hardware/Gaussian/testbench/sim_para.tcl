lappend auto_path "C:/lscc/diamond/3.1_x64/data/script"
package require simulation_generation
set ::bali::simulation::Para(PROJECT) {testbench}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/Yisong/Documents/new/gaussian}
set ::bali::simulation::Para(FILELIST) {"C:/Users/Yisong/Documents/new/gaussian/conv_3x3_pkg.vhd" "C:/Users/Yisong/Documents/new/gaussian/std_fifo.vhd" "C:/Users/Yisong/Documents/new/gaussian/std_fifo_tb.vhd" "C:/Users/Yisong/Documents/new/gaussian/rc_counter.vhd" "C:/Users/Yisong/Documents/new/gaussian/window_3x3.vhd" "C:/Users/Yisong/Documents/new/gaussian/conv_3x3.vhd" "C:/Users/Yisong/Documents/new/gaussian/efb_spi.vhd" "C:/Users/Yisong/Documents/new/gaussian/spi.vhd" "C:/Users/Yisong/Documents/new/gaussian/reset.vhd" "C:/Users/Yisong/Documents/new/gaussian/main.vhd" "C:/Users/Yisong/Documents/new/gaussian/conv_3x3_tb.vhd" "C:/Users/Yisong/Documents/new/gaussian/main_tb.vhd" "C:/Users/Yisong/Documents/new/gaussian/spi2_tb.vhd" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" "VHDL" }
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
