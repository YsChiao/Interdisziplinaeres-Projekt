lappend auto_path "C:/lscc/diamond/3.1_x64/data/script"
package require tbtemplate_generation

set ::bali::Para(MODNAME) output
set ::bali::Para(PACKAGE) {"C:/lscc/diamond/3.1_x64/cae_library/vhdl_packages/vdbs"}
set ::bali::Para(PRIMITIVEFILE) {"C:/lscc/diamond/3.1_x64/cae_library/synthesis/vhdl/machxo2.vhd"}
set ::bali::Para(TFT) {"C:/lscc/diamond/3.1_x64/data/templates/tstbch_f.tft"}
set ::bali::Para(OUTNAME) output_tb
set ::bali::Para(EXT) .vhd
set ::bali::Para(FILELIST) {"C:/Users/Yisong/Documents/new/mlp/a_s.vhd=work" "C:/Users/Yisong/Documents/new/mlp/right_shifter.vhd=work" "C:/Users/Yisong/Documents/new/mlp/fp.vhd=work" "C:/Users/Yisong/Documents/new/mlp/fp_add.vhd=work" "C:/Users/Yisong/Documents/new/mlp/fp_div.vhd=work" "C:/Users/Yisong/Documents/new/mlp/fp_exp.vhd=work" "C:/Users/Yisong/Documents/new/mlp/fp_exp_exp_y1.vhd=work" "C:/Users/Yisong/Documents/new/mlp/fp_leading_zeros_and_shift.vhd=work" "C:/Users/Yisong/Documents/new/mlp/fp_mul.vhd=work" "C:/Users/Yisong/Documents/new/mlp/fp_exp_exp_y2.vhd=work" "C:/Users/Yisong/Documents/new/mlp/spi.vhd=work" "C:/Users/Yisong/Documents/new/mlp/reset.vhd=work" "C:/Users/Yisong/Documents/new/mlp/receiver.vhd=work" "C:/Users/Yisong/Documents/new/mlp/main.vhd=work" "C:/Users/Yisong/Documents/new/mlp/mlp_pkg.vhd=work" "C:/Users/Yisong/Documents/new/mlp/efb_spi.vhd=work" "C:/Users/Yisong/Documents/new/mlp/div_nr_wsticky.vhd=work" "C:/Users/Yisong/Documents/new/mlp/loadWeight.vhd=work" "C:/Users/Yisong/Documents/new/mlp/pr.vhd=work" "C:/Users/Yisong/Documents/new/mlp/sram_dp_true.vhd=work" "C:/Users/Yisong/Documents/new/mlp/ram_dp_true.vhd=work" "C:/Users/Yisong/Documents/new/mlp/test.vhd=work" "C:/Users/Yisong/Documents/new/mlp/output.vhd=work" }
set ::bali::Para(INCLUDEPATH) {}
puts "set parameters done"
::bali::GenerateTbTemplate
