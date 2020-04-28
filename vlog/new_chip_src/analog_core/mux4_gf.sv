module mux4_gf (
    input en_gf,
    input [1:0] sel,
    input [3:0] in,
    output out
);

//synopsys dc_script_begin
//set_dont_touch {out_b}
//synopsys dc_script_end
    reg  [1:0] sel_retimed;
    wire [1:0] sel_mux;
    wire out_d;

    mux4_fixed imux4_dont_touch (
        .in(in),
        .sel(sel_mux),
        .out(out)
    );

    always @(posedge out_d or negedge en_gf) begin
        if (!en_gf) begin
            sel_retimed <= 2'b00;
        end else begin
            sel_retimed <= sel;
        end
    end

    inv iinv_1(.in(out), .out(out_b));	
    inv iinv_2(.in(out_b), .out(out_d));	

    assign sel_mux = en_gf ? sel_retimed : sel;

endmodule







