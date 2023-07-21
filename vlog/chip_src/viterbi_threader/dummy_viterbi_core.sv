module dummy_viterbi_core #(
        parameter integer num_of_channels= 40,
        parameter integer B_WIDTH =8,
        parameter integer B_LEN = 2,
        parameter integer S_LEN = 2,
        parameter integer SH_DEPTH = 18,
        parameter integer est_channel_width=8,
        parameter integer est_chan_depth =30,
        parameter integer H_DEPTH=6
    ) (
        input logic clk,
        input logic rst_n,

        input logic signed [B_WIDTH-1:0] rse_vals [B_LEN-1:0],
        input logic run,
        input logic initialize,
        input logic frame_end,
        input logic [$clog2(num_of_channels)-1:0] frame_position,

        output logic signed [2:0] final_symbols [B_LEN-1:0],
        output logic delayed_run,
        output logic delayed_initialize,
        output logic delayed_frame_end,
        output logic [$clog2(num_of_channels)-1:0] delayed_frame_position

    );

    logic signed [2:0] shift_reg [H_DEPTH-1:0][B_LEN-1:0];

    logic [$clog2(num_of_channels)-1:0] fp_reg [H_DEPTH-1:0];
    logic fe_reg[H_DEPTH-1:0];
    logic run_reg[H_DEPTH-2:0];
    logic init_reg[H_DEPTH-2:0];

    assign final_symbols = shift_reg[H_DEPTH-1];
    assign delayed_run = run_reg[H_DEPTH-2];
    assign delayed_initialize = init_reg[H_DEPTH-2];
    assign delayed_frame_end = fe_reg[H_DEPTH-1];
    assign delayed_frame_position = fp_reg[H_DEPTH-1];


    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            for(int jj = 0; jj < B_LEN; jj++)
                shift_reg[0][jj] <= 1;
            for(int ii = 1; ii < H_DEPTH; ii++)
                for(int jj = 0; jj < B_LEN; jj++)
                    shift_reg[ii][jj] <= 0;

            for(int ii = 0; ii < H_DEPTH; ii++) begin
                fp_reg[ii]   <= 0;
                fe_reg[ii]   <= 1;
                run_reg[ii]  <= 0;
                init_reg[ii] <= 0;
            end
        end else begin
            if (initialize) begin
                for(int jj = 0; jj < B_LEN; jj++)
                    shift_reg[0][jj] <= 1;
                for(int ii = 0; ii < H_DEPTH; ii++)
                    for(int jj = 0; jj < B_LEN; jj++)
                        shift_reg[ii][jj] <= 0;
            end else if (run) begin
                for(int jj = 0; jj < B_LEN; jj++)
                    shift_reg[0][jj] <= shift_reg[0][jj] + 1;
            end


            for (int ii=H_DEPTH-1; ii>0; ii--) begin
                for(int jj = 0; jj < B_LEN; jj++)
                    shift_reg[ii][jj] <= shift_reg[ii-1][jj];
            end
            fp_reg[0]   <= frame_position;
            fe_reg[0]   <= frame_end;
            run_reg[0]  <= run;
            init_reg[0] <= initialize;
            for(int ii=H_DEPTH-1; ii>0; ii--) begin
                fp_reg[ii] <= fp_reg[ii-1];
                fe_reg[ii] <= fe_reg[ii-1];
                if(ii < H_DEPTH-1) begin
                    run_reg[ii] <= run_reg[ii-1];
                    init_reg[ii] <= init_reg[ii-1];
                end
            end
        end
    end

endmodule 