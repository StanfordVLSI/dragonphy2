////////////////////////////////////////////////////////////////////////////////
//
// Empty stub, placeholder for Synopsys-proprietary DW_tap from designware
//
// ABSTRACT:  TAP Controller
//
//  Input Ports:    Size        Description
//  ===========     ====        ===========
//  tck              1 bit      Test clock 
//  trst_n           1 bit      Test reset, active low 
//  tms              1 bit      Test mode select 
//  tdi              1 bit      Test data in 
//  so               1 bit      Serial data from boundary scan 
//                                register and data registers 
//  bypass_sel       1 bit      Selects the bypass register 
//                         
//  sentinel_val    width - 1   User-defined status bits        
//                         
//  Output Ports    Size        Description
//  ============    ====        ===========
//  clock_dr         1 bit      Controls the boundary scan register     
//  shift_dr         1 bit      Controls the boundary scan register
//  update_dr        1 bit      Controls the boundary scan register
//  tdo              1 bit      Test data out
//  tdo_en           1 bit      Enable for tdo output buffer
//  tap_state       16 bit      Current state of the TAP 
//                                finite state machine
//  extest           1 bit      EXTEST decoded instruction
//  samp_load        1 bit      SAMPLE/PRELOAD decoded instruction
//  instructions    width       Instruction register output     
//
			  		
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
