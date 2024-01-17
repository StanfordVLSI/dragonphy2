module tb();


    logic clk, rstb, trigger;

    logic signed [7:0] in;
    logic [9:0] in_addr;
    logic [10+2-1:0] mem_data_out;

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    int fid_2;
    logic signed [7:0] random_val;

    always_ff @(posedge clk) begin
        if (rstb == 1'b0) begin
            in <= 0;
        end else begin
            if ($urandom_range(0, 50) > 40) begin
                in <= in + $urandom_range(0, 2)-1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rstb == 1'b0) begin
            fid_2 = $fopen("in.txt", "w");
        end else begin
            $fwrite( fid_2,"%0t %d\n", $time, in);
        end
    end

    trig_tracker #(
        .bitwidth(8),
        .counter_bitwidth(10),
        .memory_addr_width(10)
    ) aet_i (
        .clk(clk),
        .rstb(rstb),
        .in(in),
        .trigger(trigger),
        .in_addr(in_addr),
        .mem_data_out(mem_data_out)
    );

    integer fid;
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        rstb = 0;
        trigger = 0;
        in_addr = 0;
        #10 rstb = 1;

        #8 trigger = 1;


        @(aet_i.ctrl_state == aet_i.MEM_FULL);

        fid = $fopen("compressed_data.txt", "w");

        for(int ii=0; ii<1024; ii=ii+1) begin
            in_addr = ii;
            @(posedge clk);
            $fwrite( fid,"%d %d\n", ii, mem_data_out);

        end

        #10 trigger = 0;
        #8 trigger = 1;

        


        $finish;
    end

endmodule : tb