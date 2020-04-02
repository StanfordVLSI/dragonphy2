// only a stub can be included for this block

module DW_tap (
    tck, trst_n, tms, tdi, so, bypass_sel, sentinel_val, 
    clock_dr, shift_dr, update_dr, tdo, tdo_en, tap_state, extest, samp_load, 
    instructions, sync_capture_en, sync_update_dr,test );

  parameter width = 2;
  parameter id = 0;
  parameter version = 0;
  parameter part = 0;
  parameter man_num = 0;
  parameter sync_mode = 0;
  parameter tst_mode = 1;

  input  tck;
  input  trst_n;
  input  tms;
  input  tdi;
  input  so;
  input  bypass_sel;
  input  [(width - 2):0] sentinel_val;
 
  output  clock_dr;
  output  shift_dr;
  output  update_dr;
  output  tdo;
  output  tdo_en;
  output  [15:0] tap_state;
  output  extest;
  output  samp_load;
  output  [(width - 1):0] instructions;
  output  sync_capture_en;
  output  sync_update_dr;
  
  input   test;
 
 endmodule
