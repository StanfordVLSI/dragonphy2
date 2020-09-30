`default_nettype none

module freq_divider #(
  parameter integer N=3
) (
    input wire logic cki,           // input clock
    output wire logic cko,          // divided clock
    input wire logic [N-1:0] ndiv,
    input wire logic rstb
);

    // simple ripple carry clock divider
    // ndiv = 0~7
    // division ratio (Fin/Fout) = 2^0(ndiv = 0) ~ 2^7(ndiv = 7)
    // out = 0 when RSTB =0

    logic [2**N-2:0] divclk;
    logic [2**N-2:0] rstn;
    logic divclk_selected;

    assign rstn[0] = rstb & ( (ndiv>0) ? 1'b1 : 1'b0 ); 

    always @(posedge cki or negedge rstn[0]) begin
        if (!rstn[0]) begin
            divclk[0] <= 1'b0;
        end else begin
            divclk[0] <= ~divclk[0];
        end
    end

    genvar k;

    generate
        for (k=1; k<2**N-1; k=k+1) begin: uALS
            assign rstn[k] = rstb & ( (ndiv>k) ? 1'b1 : 1'b0 );

            always @(posedge divclk[k-1] or negedge rstn[k]) begin
                if (!rstn[k]) begin
                    divclk[k] <= 1'b0;
                end else begin
                    divclk[k] <= ~divclk[k];
                end
            end
      end
    endgenerate

    always @(posedge cki) begin
        divclk_selected <= rstn[0] ? divclk[ndiv-1] : 1'b0;
    end

    assign cko = rstn[0] ? divclk_selected : cki;

endmodule

`default_nettype wire
