`define WAIT(x) #((1.0*x)/freq*1s)

`ifndef SRAM_IN_TXT
    `define SRAM_IN_TXT "sram_in.txt"
`endif

`ifndef SRAM_OUT_TXT
    `define SRAM_OUT_TXT "sram_out.txt"
`endif

module test;

    import const_pack::*;

    localparam real freq = 10e9;
    localparam integer N_mem_tiles = 4;
    localparam integer Nwrite = (2**(N_mem_addr+$clog2(N_mem_tiles)))*4;    // write more data than SRAM can hold
                                                       // to make sure we capture just the beginning
    localparam integer Nread = (2**(N_mem_addr+$clog2(N_mem_tiles)));
    // local signals

    logic signed [Nadc-1:0] in [Nti+Nti_rep-1:0];
    logic signed [Nadc-1:0] out [Nti+Nti_rep-1:0];

    logic rstb;
    logic clk;
    logic start;
    logic [N_mem_addr+$clog2(N_mem_tiles)-1:0] addr;

    // instantiate the memory

    oneshot_multimemory oneshot_memory_i #(.N_mem_tiles(4)) (
        .clk(clk),
        .rstb(rstb),
        .in_data(in),
        .in_start_write(start),
        .in_addr(addr),
        .out_data(out)
    );

    // instantiate the recorders

    logic in_record, out_record;

    sram_recorder #(
        .filename(`SRAM_IN_TXT)
    ) sram_in_recorder (
        .in(in),
        .clk(clk),
        .en(in_record)
    );

    sram_recorder #(
        .filename(`SRAM_OUT_TXT)
    ) sram_out_recorder (
        .in(out),
        .clk(clk),
        .en(out_record)
    );

    // generate the clock

    always begin
        clk = 1'b0;
        `WAIT(0.5);
        clk = 1'b1;
        `WAIT(0.5);
    end

    // generate the reset

    initial begin
        rstb = 1'b0;
        `WAIT(1.0);
        rstb = 1'b1;
    end

    // generate the stimulus

    initial begin
        // Uncomment to record key signals
        // $dumpfile("out.vcd");
        // $dumpvars(2, test);

        // initialize and wait for a bit

        in_record = 1'b0;
        out_record = 1'b0;

        start = 1'b0;
        addr = 'd0;

        for(int i=0; i<Nti+Nti_rep; i=i+1) begin
            in[i] = $signed($random%(2**Nadc));
        end

        `WAIT(10.0); 

        // advance to WRITE_IN_PROGRESS

        start = 1'b1;
        `WAIT(1.0);

        // clock data into the memory and the input 

        in_record = 1'b1;

        for (int j=0; j<Nwrite; j=j+1) begin
            for(int i=0; i<Nti+Nti_rep; i=i+1) begin
                in[i] = $signed($random%(2**Nadc));
            end
            `WAIT(1.0);
        end

        in_record = 1'b0;

        // wait a bit so that we're definitely in the WRITE_DONE state

        `WAIT(10.0);

        // go to the WAIT_FOR_WRITE state

        start = 1'b0;
        `WAIT(1.0);

        // clock in the first memory address

        addr = 0;
        `WAIT(1.0);

        // read out the memory contents

        out_record = 1'b1;

        for (int j=1; j<Nread; j=j+1) begin
            addr = j;
            `WAIT(1.0);
        end

        `WAIT(1.0);

        $finish;
    end

endmodule
