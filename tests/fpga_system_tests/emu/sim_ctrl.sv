`timescale 1s/1fs

`ifndef GIT_HASH
    `define GIT_HASH 28'h0
`endif

module sim_ctrl(
    output reg rstb=1'b0,
    output reg tdi=1'b0,
    output reg tck=1'b0,
    output reg tms=1'b1,
    output reg trst_n=1'b0,
    input wire tdo
);
    task cycle();
        #(1us);
        tck = 1'b1;
        #(1us);
        tck = 1'b0;
        #(1us);
    endtask

    task do_reset();
        // initialize signals
        tdi = 1'b0;
        tck = 1'b0;
        tms = 1'b1;
        trst_n = 1'b0;
        cycle();

        // de-assert reset
        trst_n = 1'b1;
        cycle();

        // go to the IDLE state
        tms = 1'b1;
        cycle();
        for (integer i=0; i<10; i=i+1) begin
            cycle();
        end
        tms = 1'b0;
        cycle();
    endtask

    task shift_ir (
        input [31:0] inst_in,
        input [31:0] length
    );
        // Move to Select-DR-Scan state
        tms = 1'b1;
        cycle();

        // Move to Select-IR-Scan state
        tms = 1'b1;
        cycle();

        // Move to Capture IR state
        tms = 1'b0;
        cycle();

        // Move to Shift-IR state
        tms = 1'b0;
        cycle();

        // Remain in Shift-IR state and shift in inst_in.
        // Observe the TDO signal to read the x_inst_out
        for (integer i=0; i<(length-1); i=i+1) begin
            tdi = (inst_in >> i) & 1'b1;
            cycle();
        end

        // Shift in the last bit and switch to Exit1-IR state
        tdi = (inst_in >> (length - 1)) & 1'b1;
        tms = 1'b1;
        cycle();

        // Move to Update-IR state
        tms = 1'b1;
        cycle();

        // Move to Run-Test/Idle state
        tms = 1'b0;
        cycle();
        cycle();
    endtask

    task shift_dr (
        input [31:0] data_in,
        input [31:0] length,
        output [31:0] data_out
    );
        // Move to Select-DR-Scan state
        tms = 1'b1;
        cycle();

        // Move to Capture-DR state
        tms = 1'b0;
        cycle();

        // Move to Shift-DR state
        tms = 1'b0;
        cycle();

        // Remain in Shift-DR state and shift in data_in.
        // Observe the TDO signal to read the data_out
        data_out = 0;
        for (integer i=0; i<(length-1); i=i+1) begin
            tdi = (data_in >> i) & 1'b1;
            data_out = data_out | (tdo << i);
            cycle();
        end

        // Shift in the last bit and switch to Exit1-DR state
        tdi = (data_in >> (length - 1)) & 1'b1;
        data_out = data_out | (tdo << (length-1));
        tms = 1'b1;
        cycle();

        // Move to Update-DR state
        tms = 1'b1;
        cycle();

        // Move to Run-Test/Idle state
        tms = 1'b0;
        cycle();
        cycle();
    endtask

    task read_id (output [31:0] id);
        shift_ir(1, 5);
        shift_dr(0, 32, id);
    endtask

    logic [31:0] jtag_id;
    initial begin
        // wait for emulator reset to complete
        $display("Waiting for emulator reset to complete...");
        #(10us);

        // release external reset
        rstb = 1'b1;
        #(10us);

        // release JTAG reset
        do_reset();
        #(10us);

        // read ID
        read_id(jtag_id);
        #(10us);

        // print ID
        $display("JTAG ID: %08h", jtag_id);
        #(10us);

        // check ID
		assert ((jtag_id[31:4] == `GIT_HASH) && (jtag_id[0] == 1'b1));
        #(10us);

        $finish;
    end
endmodule
