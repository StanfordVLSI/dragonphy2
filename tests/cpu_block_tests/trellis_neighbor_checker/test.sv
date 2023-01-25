module test;

    localparam integer seq_length = 3;
    localparam integer width = 16;
    localparam integer depth = 30;
    localparam integer est_err_bitwidth = 9;
    localparam integer num_of_trellis_patterns = 4;
    localparam integer trellis_pattern_depth = 4;
    localparam integer est_channel_bitwidth = 10;
    localparam integer ener_bitwidth = 24;
    localparam integer branch_bitwidth = 2;
    localparam integer shift_bitwidth = 4;

    logic signed [est_channel_bitwidth-1:0] channel [depth-1:0];
    logic [shift_bitwidth-1:0] channel_shift;
    logic signed [branch_bitwidth-1:0] trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0];
    logic signed [est_err_bitwidth-1:0] errstream [2*width-1:0];

    logic [$clog2(2*num_of_trellis_patterns+1)-1:0] flags [width-1:0];


    trellis_neighbor_checker #(
        .est_channel_bitwidth(est_channel_bitwidth), 
        .depth(30),  
        .width(width),  
        .branch_bitwidth(2),
        .shift_bitwidth(shift_bitwidth),
        .trellis_neighbor_checker_depth(2),  
        .num_of_trellis_patterns(num_of_trellis_patterns),  
        .trellis_pattern_depth(4),  
        .seq_length(seq_length),  
        .ener_bitwidth(ener_bitwidth),  
        .est_err_bitwidth(est_err_bitwidth) 
    ) tnc_i (
        .channel(channel),
        .channel_shift(channel_shift),
        .trellis_patterns(trellis_patterns),
        .nrz_mode(0),
        .errstream(errstream),
        .flags(flags)
    );

    initial begin
        read_tnc_inputs_from_file("tnc_inputs.txt", channel, channel_shift, trellis_patterns, errstream);
        #(1ns);
        write_tnc_outputs_to_file("tnc_outputs.txt", flags);
        $finish;
    end

    task read_tnc_inputs_from_file(
        input string filename, 
        output logic signed [est_channel_bitwidth-1:0] channel [depth-1:0],
        output logic [shift_bitwidth-1:0] channel_shift,
        output logic signed [branch_bitwidth-1:0] trellis_patterns [num_of_trellis_patterns-1:0][trellis_pattern_depth-1:0],
        output logic signed [est_err_bitwidth-1:0] errstream [2*width-1:0]
    );
        integer file_id;
        file_id =  $fopen(filename, "r");

        for(int ii = 0; ii < seq_length + trellis_pattern_depth -1; ii = ii + 1) begin
            $fscanf(file_id, "%d", channel[ii]);
        end

        $fscanf(file_id, "%d", channel_shift);

        for(int ii = 0; ii < num_of_trellis_patterns; ii = ii + 1) begin
            for(int jj = 0; jj < trellis_pattern_depth; jj = jj + 1) begin
                $fscanf(file_id, "%d", trellis_patterns[ii][jj]);
            end
        end

        for(int ii = 0; ii < 2*width; ii = ii + 1) begin
            $fscanf(file_id, "%d", errstream[ii]);
        end

        $fclose(file_id);
    endtask

    task write_tnc_outputs_to_file(input string filename, input logic [$clog2(2*num_of_trellis_patterns+1)-1:0] flags [width-1:0]);
        integer file_id;
        file_id = $fopen(filename, "w");
        for(int ii = 0; ii < width; ii = ii + 1) begin
            $fwrite(file_id, "%d\n", flags[ii]);
        end
        $fclose(file_id);
    endtask

endmodule : test
