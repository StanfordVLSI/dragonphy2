module lowest_energy_flag_locater #(
    parameter integer width = 16,
    parameter integer flag_width=2,
    parameter integer ener_bitwidth=10
)(
    input logic [flag_width-1:0] flags [width-1:0],
    input logic [ener_bitwidth-1:0] flag_ener [width-1:0],

    output logic [flag_width-1:0] best_flag [width-1:0]
);

    logic [$clog2(width)-1:0] best_flag_pos;
    logic [ener_bitwidth-1:0] best_flag_ener;

    integer ii, jj;
/*
    initial begin
        $monitor("%m.best_flag_pos: %d", best_flag_pos);
        $monitor("%m.best_flag_ener: %d", best_flag_ener);
        $monitor("%m.best_flag: %p", best_flag );
        $monitor("%m.ii: %d",ii);
    end*/

    always_comb begin
        best_flag_pos = 0;
        for(jj  = 0; jj  < width; jj += 1) begin
            best_flag[jj] = 0;
        end
        best_flag_ener = 2**(ener_bitwidth) - 1;

        for(ii =0; ii < width; ii += 1) begin
            if(flags[ii] > 0) begin
                if(best_flag_ener > flag_ener[ii]) begin
                    best_flag_pos = ii;
                    best_flag_ener = flag_ener[ii];
                end
            end
        end
        
        best_flag[best_flag_pos] = flags[best_flag_pos];
    end
endmodule : lowest_energy_flag_locater