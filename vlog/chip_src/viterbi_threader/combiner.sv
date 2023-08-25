module combiner #(
    parameter integer num_of_channels = 40,
    parameter integer num_of_viterbis = 4,
    parameter integer sym_width = 3,
    parameter integer csym_width = 3

) (
    input logic clk,
    input logic rst_n,

    output logic signed [sym_width-1:0] corr_syms [num_of_channels-1:0],
    output logic corr_syms_push_n,

    input logic signed [csym_width-1:0] syms [num_of_channels-1:0],
    input logic [num_of_viterbis-1:0] tag,
    input logic syms_drdy,
    output logic syms_pop_n,

    input logic signed [csym_width-1:0] corrections [num_of_viterbis-1:0][num_of_channels-1:0],
    input logic [num_of_viterbis-1:0] corr_drdy,
    output logic [num_of_viterbis-1:0] corr_pop_n

);


    logic global_done;
    logic [num_of_viterbis-1:0] and_vec;

    logic signed [csym_width-1:0] gated_corr [num_of_viterbis-1:0][num_of_channels-1:0];
    logic signed [csym_width-1:0] summed_corr [num_of_channels-1:0];
    logic signed [sym_width:0] ext_corr_syms [num_of_channels-1:0];
    logic signed [sym_width-1:0] corr_syms_d [num_of_channels-1:0];

    genvar gi, gj;

    generate
        for(gi = 0; gi < num_of_viterbis; gi += 1) begin
            assign gated_corr[gi] = (!and_vec[gi]) ? '{default: 0} : corrections[gi];
        end
    endgenerate

    always_comb begin
        for(int ii = 0; ii < num_of_channels; ii += 1) begin
            summed_corr[ii] = 0;
            for(int jj = 0; jj < num_of_viterbis; jj += 1) begin
                summed_corr[ii] |= gated_corr[jj][ii];
            end

            ext_corr_syms[ii] = syms[ii] + summed_corr[ii];
            corr_syms_d[ii] = (ext_corr_syms[ii] > 3) ? 3 : (ext_corr_syms[ii] < -3) ? -3 : ext_corr_syms[ii];
        end
    end

    assign and_vec = (tag & ~corr_drdy);
    assign global_done = !((tag == and_vec) && !syms_drdy);
    assign corr_pop_n = global_done ? (1 << num_of_viterbis) -1 : ~and_vec;
    assign syms_pop_n = global_done;

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            corr_syms <= '{default:0};
            corr_syms_push_n <= 1;
        end else begin
            corr_syms <= corr_syms_d;
            corr_syms_push_n <= global_done;
        end
    end


endmodule // combiner