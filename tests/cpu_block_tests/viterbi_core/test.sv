module test;

    import viterbi_23_pkg::s_map;
    localparam integer est_channel_width = 8;
    localparam integer est_channel_depth = 30;
    localparam integer est_error_width = 8;

    localparam integer branch_length = 4;
    localparam integer rse_val_length = 32;
    localparam integer number_of_symbolic_states = 2;

    localparam integer dynamic_history_depth = 8;
    localparam integer static_history_depth = 18;

    logic clk, rst_n, update, initialize, run;

    logic signed [est_channel_width-1:0] est_channel [est_channel_depth-1:0];
    logic signed [est_error_width-1:0] rse_vals [branch_length-1:0];
    logic signed [est_error_width-1:0] est_error [rse_val_length-1:0];

    logic signed [1:0] final_symbols [branch_length-1:0];
    logic signed [1:0] viterbi_output [rse_val_length-1:0];

    initial begin
        clk = 0;
        forever begin
            clk = #0.5 ~clk;
        end
    end

    viterbi_core #(
        .B_LEN(branch_length),
        .S_LEN(number_of_symbolic_states),
        .SH_DEPTH(static_history_depth),
        .H_DEPTH(dynamic_history_depth)
    ) vc_i (
        .clk(clk),
        .rst_n(rst_n),
        .run(run),

        .input_est_channel(est_channel),
        .update(update),

        .initialize(initialize),

        .rse_vals(rse_vals),
        .final_symbols(final_symbols)
    );


    initial begin
       // $shm_open("waves.shm");
       // $shm_probe("S");
        $dumpfile("results.vcd");
        $dumpvars;
        run = 0; 
        rst_n = 0;
        update = 0;
        initialize = 0;
        read_vc_inputs_from_file("vc_inputs.txt", est_channel, est_error);

        @(posedge clk);
        rst_n = 0;
        @(posedge clk);

        rst_n = 1;

        @(posedge clk);
        $display("est_channel = %p", vc_i.est_channel);
        update = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        update = 0;
        for(int jj = 0; jj < branch_length; jj += 1) begin
            rse_vals[jj] = est_error[jj];
        end

        @(posedge clk);
        initialize = 1;
        @(posedge clk);
        initialize = 0;

        @(posedge clk);
        run = 1;
        for(int ii = 0; ii < 7; ii += 1) begin
            $display("Iteration %0d", ii);  
            for(int jj = 0; jj < branch_length; jj += 1) begin
                rse_vals[jj] = est_error[branch_length*(ii+1) + jj];
                $display("rse_vals[%0d] = %0d", jj, rse_vals[jj]);

                viterbi_output[branch_length*ii + jj] = final_symbols[jj];

            end
            $display("final_symbols = %p", final_symbols);
            @(posedge clk);
        end
        run = 0;
        @(posedge clk);

        $display("viterbi_output = %p", viterbi_output);

        write_vc_outputs_to_file("vc_outputs.txt", final_symbols);

        $finish;

    end

    task read_vc_inputs_from_file(
        input string filename,
        output logic signed [est_channel_width-1:0] est_channel [est_channel_depth-1:0],
        output logic signed [est_error_width-1:0] est_error [rse_val_length-1:0]
    );
        integer file_id;
        file_id =  $fopen(filename, "r");


        for(int ii = 0; ii < est_channel_depth; ii = ii + 1) begin
            $fscanf(file_id, "%d", est_channel[ii]);
        end



        for(int ii = 0; ii < rse_val_length; ii = ii + 1) begin
            $fscanf(file_id, "%d", est_error[ii]);
        end


        $fclose(file_id);
    endtask

    task write_vc_outputs_to_file(
            input string filename, 
            input logic signed [1:0] state_vals [branch_length-1:0]

    );
        integer file_id;
        file_id = $fopen(filename, "w");

        for(int ii = 0; ii < branch_length; ii = ii + 1) begin
            $fwrite(file_id, "%d\n", state_vals[ii]);
        end

        $fclose(file_id);
    endtask

endmodule : test
