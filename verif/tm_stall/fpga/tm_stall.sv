`include "signals.sv"

module tm_stall ();
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt;
    (* dont_touch = "true" *) logic signed [((`DT_WIDTH)-1):0] __emu_dt_req;
    
    (* dont_touch = "true" *) logic stall_set;
    assign stall_set = |__emu_dt_req;
endmodule
