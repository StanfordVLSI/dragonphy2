//
//--------------------------------------------------------------------------------
//          THIS FILE WAS AUTOMATICALLY GENERATED BY THE GENESIS2 ENGINE        
//  FOR MORE INFORMATION: OFER SHACHAM (CHIP GENESIS INC / STANFORD VLSI GROUP)
//    !! THIS VERSION OF GENESIS2 IS NOT FOR ANY COMMERCIAL USE !!
//     FOR COMMERCIAL LICENSE CONTACT SHACHAM@ALUMNI.STANFORD.EDU
//--------------------------------------------------------------------------------
//
//  
//	-----------------------------------------------
//	|            Genesis Release Info             |
//	|  $Change: 11879 $ --- $Date: 2013/06/11 $   |
//	-----------------------------------------------
//	
//
//  Source file: /sim/zamyers/JusTAG/rtl/primitives/reg_file.svp
//  Source template: reg_file
//
// --------------- Begin Pre-Generation Parameters Status Report ---------------
//
//	From 'generate' statement (priority=5):
// Parameter RegList 	= Data structure of type ARRAY
// Parameter CfgOpcodes 	= Data structure of type HASH
// Parameter BaseAddr 	= 7680
// Parameter CfgBusPtr 	= Data structure of type cfg_ifc
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From Command Line input (priority=4):
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From XML input (priority=3):
//
//		---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
//
//	From Config File input (priority=2):
//
// ---------------- End Pre-Generation Pramameters Status Report ----------------

/* *****************************************************************************
 * File: reg_file.vp
 * 
 * Description:
 * This file is using Genesis2 to make a register file.
 * A register file have a config bus input port, and a config bus output port. 
 * The configuration request values are flopped and then handled:
 * * If cfgIn_op is a no-op, nothing happens.
 * * If cfgIn_op is a bypass op, the  cfgIn_* signals are passed to the 
 *      cfgOut_* ports.
 * * If cfgIn_op is a read/write op, and cfgIn_addr is with in the address
 *      range, then the corresponding register is read/written. The values
 *      are streamed to the cfgOut_* ports, except for cfgOut_op that becomes
 *      a bypass-op.
 *      If cfgIn_addr is not in this reg_file address range, all the  cfgIn_* 
 *      signals are passed to the cfgOut_* ports. Someone else will answer...
 * 
 * Note: All registers in the register file are write-able and readable by the
 *      configuration bus (even though some may only have output ports or only
 *      input ports).
 * 
 * 
 * REQUIRED GENESIS PARAMETERS:
 * ----------------------------
 * * RegList  - List of registers. Each element in the list is a hash that contains
 *    * Name - used for generating the enable and data output/input signals
 *    * Width - register width
 *    * Default - (optional) default value. Can be set later by XML input
 *    * IEO - I indicates this register connected to an input signal
 *            E indicates that the input is qualified by an enable 
 *            O indicates that the output is connected to an output signal
 *            Valid options include: I, IE, O, IO, IEO
 *    * Comment - (optional) description of the register
 *   Example:
 *    my $reg_list = [      
 *        {Name => 'regA', Width => 5, Default => 17, IEO => 'ie', Comment => 'this is a reg'}, 
 *        {Name => 'regB', Width => 10, Default => 27, IEO => 'o'}, 
 *        {Name => 'regC', Width => 15, IEO => 'ieo'},
 *        {Name => 'regD', Width => 13, Default => 4, IEO => 'i'}
 *                   ];
 * 
 * * BaseAddr - Base address for this module 
 * * CfgOpcodes - Interpretation of the opcode. Must contain the following feilds:
 *    * nop - value of cfgIn_op for a no-op (default is 0)
 *    * read - value of cfgIn_op for a read operation (default is 1)
 *    * write - value of cfgIn_op for a write operation (default is 2)
 *    * bypass - value of cfgIn_op for bypassing the control signals (default is 3)
 * * CfgBusPtr - An instance of the reg_file_ifc (used as reference)
 * 
 * Inputs:
 * -------
 * Clk
 * Reset
 * cfgIn - Incomming config request
 * foreach REG in REG_LIST (but depending on the IEO flag):
 *  * <REG.name>_en - enable signal for the register
 *  * <REG.name>_d - data input for the register
 * 
 * Outputs:
 * --------
 * cfgOut - Outgoing reply for config request cfgIn
 * foreach REG in REG_LIST (but depending on the IEO flag):
 *  * <REG.name>_q - data output for the register
 * 
 * 
 * NOTE: registers with input from the design may become resource contention
 *       if both their private enable and their by-address enable signals are raised.
 *       Priority is always given to data from the cfg bus!
 * 
 * ****************************************************************************/

// ACTUAL GENESIS2 PARAMETERIZATIONS
// RegList (_GENESIS2_INHERITANCE_PRIORITY_) = 
//	[ { Default=>0, IEO=>o, Name=>ctl_dcdl_sw_0, Width=>2 },
//	  { Default=>0, IEO=>o, Name=>ctl_dcdl_sw_1, Width=>2 },
//	  { Default=>0, IEO=>o, Name=>ctl_dcdl_sw_2, Width=>2 },
//	  { Default=>0, IEO=>o, Name=>ctl_dcdl_sw_3, Width=>2 }
//	]
//
// BaseAddr (_GENESIS2_INHERITANCE_PRIORITY_) = 0x1e00
//
// CfgOpcodes (_GENESIS2_INHERITANCE_PRIORITY_) = 
//	{ bypass=>3, nop=>0, read=>1, write=>2 }
//
// CfgBusPtr (_GENESIS2_INHERITANCE_PRIORITY_) = 
//	InstancePath:raw_jtag.tc_jtag2rf0_ifc (cfg_ifc_unq1)
//

// Fix for reg files with single registers
// 13:4
// 10
// 480
// 10'h1e0
// =============================================================================
//                  LIST OF REGISTERS IN THIS MODULE:
// =============================================================================
// LEGEND: 
//      BaseAddr 'h1e00
//      IEO:  I for input (register samples design)
//            O for output (register drives design)
//            IE for enabled input (register samples design if enable is high)
//
// REGISTERS
// ctl_dcdl_sw_0 [1:0] IEO=o Offset=0 -- 
// ctl_dcdl_sw_1 [1:0] IEO=o Offset=4 -- 
// ctl_dcdl_sw_2 [1:0] IEO=o Offset=8 -- 
// ctl_dcdl_sw_3 [1:0] IEO=o Offset=12 -- 




// =============================================================================
//                             MODULE:
// =============================================================================
module reg_file_unq31
  (
   // inputs for the config interface
   cfg_ifc_unq1.cfgIn cfgIn, // incoming requests
   cfg_ifc_unq1.cfgOut cfgOut, // outgoing responds


   //outputs
    // outputs for register ctl_dcdl_sw_0
    output wire logic[1:0]       ctl_dcdl_sw_0_q,
                           
    // outputs for register ctl_dcdl_sw_1
    output wire logic[1:0]       ctl_dcdl_sw_1_q,
                           
    // outputs for register ctl_dcdl_sw_2
    output wire logic[1:0]       ctl_dcdl_sw_2_q,
                           
    // outputs for register ctl_dcdl_sw_3
    output wire logic[1:0]       ctl_dcdl_sw_3_q,
                           
   
   // Generic inputs 
    input wire logic			       Clk,
    input wire logic                        Reset
   );


   // floping cfg inputs to produce delayed signals:
   logic [13:0]       cfgIn_addr_del;
   logic [31:0]        cfgIn_data_del;
   logic [1:0]         cfgIn_op_del;
   flop_unq5  cfgIn_floper (.Clk(Clk), .Reset(Reset), 
			      .din({cfgIn.addr, cfgIn.data, cfgIn.op}),
			      .dout({cfgIn_addr_del, cfgIn_data_del, cfgIn_op_del}));



   // internal wiring signals
   logic [3:0]             onehot_en;
   logic                               addr_in_range;
   logic [1:0]    cfgIn_addr_del_int; // internal (shorter) address signal
   logic [3:0]             regs_en;
   logic [31:0]        regs_d[3:0];
   logic [31:0]        regs_q[3:0];

   // make sure that the input address is in range
   assign addr_in_range = ((10'h1e0 == cfgIn_addr_del[13:4]) &&
                     (cfgIn_addr_del[3:2] < 3'd4))? 1'b1: 1'b0;
   
   // Pick the right bits of the address signal (if out of range default to zero)
   assign cfgIn_addr_del_int[1:0] = (addr_in_range)? cfgIn_addr_del[3:2]: 2'b0;
   
   // For config writes, there can be at most onehot enable signal
   always_comb begin
      onehot_en = 1'b0;
      onehot_en[cfgIn_addr_del_int] = (cfgIn_op_del == 2) && (addr_in_range == 1'b1);
   end

   // assign the config output ports
   assign cfgOut.data = (addr_in_range != 1'b1) ? cfgIn_data_del : // if not in range, pass the signal to the next guy
                  (cfgIn_op_del == 1) ? regs_q[cfgIn_addr_del_int] : // if in range and this is a readop... read
                  cfgIn_data_del;
   assign cfgOut.addr = cfgIn_addr_del;
   assign cfgOut.op = (addr_in_range != 1'b1) ? cfgIn_op_del : // if not in range pass the signal to next guy
                  (cfgIn_op_del != 0) ? 2'd3:      // if in range (and not a nop) mark as done (bypass)
                  2'd0;                              // else, it's just a nop.
      

   // Instantiate all the registers:
   // ==============================
   // register #0 --- name:ctl_dcdl_sw_0, type:o, Width:2
   // flop input only on cfg writes
   assign regs_en[0] = onehot_en[0]; 
   // input only from cfg bus
   assign regs_d[0][1:0] = cfgIn_data_del[1:0]; 
   flop_unq1  ctl_dcdl_sw_0_reg
     (.Clk(Clk), .Reset(Reset), .en(regs_en[0]),
      .din(regs_d[0][1:0]), .dout(regs_q[0][1:0]));

   // assign value to the relevant output
   assign ctl_dcdl_sw_0_q[1:0] = regs_q[0][1:0]; 
   // pad the config bus with zeros
   assign regs_q[0][31:2] = '0; 
   
   // register #1 --- name:ctl_dcdl_sw_1, type:o, Width:2
   // flop input only on cfg writes
   assign regs_en[1] = onehot_en[1]; 
   // input only from cfg bus
   assign regs_d[1][1:0] = cfgIn_data_del[1:0]; 
   flop_unq1  ctl_dcdl_sw_1_reg
     (.Clk(Clk), .Reset(Reset), .en(regs_en[1]),
      .din(regs_d[1][1:0]), .dout(regs_q[1][1:0]));

   // assign value to the relevant output
   assign ctl_dcdl_sw_1_q[1:0] = regs_q[1][1:0]; 
   // pad the config bus with zeros
   assign regs_q[1][31:2] = '0; 
   
   // register #2 --- name:ctl_dcdl_sw_2, type:o, Width:2
   // flop input only on cfg writes
   assign regs_en[2] = onehot_en[2]; 
   // input only from cfg bus
   assign regs_d[2][1:0] = cfgIn_data_del[1:0]; 
   flop_unq1  ctl_dcdl_sw_2_reg
     (.Clk(Clk), .Reset(Reset), .en(regs_en[2]),
      .din(regs_d[2][1:0]), .dout(regs_q[2][1:0]));

   // assign value to the relevant output
   assign ctl_dcdl_sw_2_q[1:0] = regs_q[2][1:0]; 
   // pad the config bus with zeros
   assign regs_q[2][31:2] = '0; 
   
   // register #3 --- name:ctl_dcdl_sw_3, type:o, Width:2
   // flop input only on cfg writes
   assign regs_en[3] = onehot_en[3]; 
   // input only from cfg bus
   assign regs_d[3][1:0] = cfgIn_data_del[1:0]; 
   flop_unq1  ctl_dcdl_sw_3_reg
     (.Clk(Clk), .Reset(Reset), .en(regs_en[3]),
      .din(regs_d[3][1:0]), .dout(regs_q[3][1:0]));

   // assign value to the relevant output
   assign ctl_dcdl_sw_3_q[1:0] = regs_q[3][1:0]; 
   // pad the config bus with zeros
   assign regs_q[3][31:2] = '0; 
   
endmodule: reg_file_unq31