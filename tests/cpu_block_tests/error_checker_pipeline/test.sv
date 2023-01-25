module test;
    localparam integer num_of_test_cycles = 5;
    localparam integer seq_length = 3;
    localparam integer width = 16;
    localparam integer depth = 30;
    localparam integer est_err_bitwidth = 9;
    localparam integer num_of_trellis_patterns = 4;
    localparam integer trellis_pattern_depth = 4;
    localparam integer est_channel_bitwidth = channel_gpack::est_channel_precision;
    localparam integer ener_bitwidth = error_gpack::ener_bitwidth;
    localparam integer branch_bitwidth = 2;
    localparam integer shift_bitwidth = 4;

    logic clk, rstb;

    logic signed [est_channel_bitwidth-1:0] channel [depth-1:0];
    logic [shift_bitwidth-1:0] channel_shift;
    logic signed [branch_bitwidth-1:0] trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0];
  
    logic signed [est_err_bitwidth-1:0] errstream [num_of_test_cycles-1:0][width-1:0];
    logic  [1:0] symstream [num_of_test_cycles-1:0][width-1:0];
  
    logic signed [est_err_bitwidth-1:0] res_error_in [width-1:0];
    logic  [1:0] syms_in [width-1:0];

    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] flags [width-1:0];
    logic signed [est_err_bitwidth-1:0] res_error_out [width-1:0];
    logic [ener_bitwidth-1:0] flag_eners [width-1:0];
    logic  [1:0] syms_out [width-1:0]; 

    error_checker_datapath #(
        .seq_length(seq_length),
        .ener_bitwidth(ener_bitwidth),
        .num_of_trellis_patterns(num_of_trellis_patterns),
        .trellis_pattern_depth(trellis_pattern_depth),
        .sliding_detector_output_pipeline_depth(1)
    ) ecd_i (
        .clk(clk),
        .rstb(rstb),

        .symbols_in(syms_in),
        .res_errors_in(res_error_in),
        
        .sd_flags_ener(flag_eners),
        .res_errors_out(res_error_out),
        .sd_flags(flags),
        .symbols_out(syms_out),

        .channel_est(channel),
        .channel_shift(channel_shift),
        .trellis_patterns(trellis_patterns)
    );

    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] result_flags [num_of_test_cycles-1:0][width-1:0];
    logic signed [est_err_bitwidth-1:0] result_res_error_out [num_of_test_cycles-1:0][width-1:0];
    logic [ener_bitwidth-1:0] result_flag_eners [num_of_test_cycles-1:0][width-1:0];
    logic  [1:0] result_syms_out [num_of_test_cycles-1:0][width-1:0]; 

    initial begin
        rstb = 0;
        clk  = 0;
        #1 rstb = 1;

        read_ep_inputs_from_file("ep_inputs.txt", channel, channel_shift, trellis_patterns, errstream, symstream);

        for(int ii =0; ii < num_of_test_cycles; ii += 1) begin
            result_flags[ii] = flags;
            result_res_error_out[ii] = res_error_out;
            result_flag_eners[ii] = flag_eners;
            result_syms_out[ii] = syms_out;
            syms_in = symstream[ii];
            res_error_in = errstream[ii];

            $display("Inputs:");
            $display("symbols: %p", syms_in);
            $display("rse: %p", res_error_in);

            $display("Outputs:");
            $display("flags: %p", flags);
            $display("symbols: %p", syms_out);


            $write("rse: ");
            test_pack::array_io#(logic signed [error_gpack::est_error_precision-1:0], 2*width)::write_array(ecd_i.sd_flat_errors);
            $write("energy: ");
            test_pack::array_io#(logic [ener_bitwidth-1:0],  width)::write_array(flag_eners);

            #1 clk = 1;
            #1 clk = 0;


        end

        write_ep_outputs_to_file("ep_outputs.txt", result_flags, result_res_error_out, result_flag_eners, result_syms_out);
        $finish;
    end

    task read_ep_inputs_from_file(
        input string filename, 
        output logic signed [est_channel_bitwidth-1:0] channel [depth-1:0],
        output logic [shift_bitwidth-1:0] channel_shift,
        output logic signed [branch_bitwidth-1:0] trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0],
        output logic signed [est_err_bitwidth-1:0] res_error_in [num_of_test_cycles-1:0][width-1:0],
        output logic  [1:0] syms_in [num_of_test_cycles-1:0][width-1:0]
    );
        integer file_id;
        file_id =  $fopen(filename, "r");

        test_pack::array_io#(logic signed [est_channel_bitwidth-1:0], depth)::fread_array(file_id, channel);

        $fscanf(file_id, "%d\n", channel_shift);
        for(int ii = 0; ii < num_of_trellis_patterns; ii=ii+1) begin
            test_pack::array_io#(logic signed [branch_bitwidth-1:0], trellis_pattern_depth)::fread_array(file_id, trellis_patterns[ii]);
        end

        for(int ii = 0; ii < num_of_test_cycles; ii=ii+1) begin
            test_pack::array_io#(logic [1:0], width)::fread_array(file_id, syms_in[ii]);
            test_pack::array_io#(logic signed [est_err_bitwidth-1:0], width)::fread_array(file_id, res_error_in[ii]);
        end
        $fclose(file_id);
    endtask

    task write_ep_outputs_to_file(
        input string filename,
        input logic [$clog2(2*num_of_trellis_patterns+1)-1:0] result_flags [num_of_test_cycles-1:0][width-1:0],
        input logic signed [est_err_bitwidth-1:0] result_res_error_out [num_of_test_cycles-1:0][width-1:0],
        input logic [ener_bitwidth-1:0] result_flag_eners [num_of_test_cycles-1:0][width-1:0],
        input logic  [1:0] result_syms_out [num_of_test_cycles-1:0][width-1:0]
    );
        integer file_id;
        file_id = $fopen(filename, "w");
        for(int ii = 0; ii < num_of_test_cycles; ii = ii + 1) begin
            $fdisplay(file_id, "iteration %d:", ii);
            test_pack::array_io#(logic [$clog2(2*num_of_trellis_patterns+1)-1:0],  width)::fwrite_array(file_id, result_flags[ii]);
            test_pack::array_io#(logic signed [est_err_bitwidth-1:0],  width)::fwrite_array(file_id, result_res_error_out[ii]);
            test_pack::array_io#(logic  [1:0],  width)::fwrite_array(file_id, result_syms_out[ii]);
            test_pack::array_io#(logic [ener_bitwidth-1:0],  width)::fwrite_array(file_id, result_flag_eners[ii]);
        end

        $fclose(file_id);
    endtask



endmodule : test

