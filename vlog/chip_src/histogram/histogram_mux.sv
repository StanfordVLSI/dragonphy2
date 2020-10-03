`default_nettype none

module histogram_mux #(
    parameter integer Nti=16,
    parameter integer Nti_rep=2,
    parameter integer Nadc=8
) (
    input wire logic clk,
    input wire logic [1:0] source,
    input wire logic [4:0] index,
    input wire logic signed [(Nadc-1):0] adc_data [(Nti+Nti_rep-1):0],
    input wire logic signed [(Nadc-1):0] ffe_data [(Nti+Nti_rep-1):0],
    input wire logic [(Nadc-1):0] bist_data,
    output wire logic [(Nadc-1):0] out
);

    // register source / index

    logic [1:0] source_reg;
    logic [4:0] index_reg;

    always @(posedge clk) begin
        source_reg <= source;
        index_reg <= index;
    end

    // register data inputs

    logic [(Nadc-1):0] adc_data_reg [(Nti+Nti_rep-1):0];
    logic [(Nadc-1):0] ffe_data_reg [(Nti+Nti_rep-1):0];
    logic [(Nadc-1):0] bist_data_reg;

    genvar k;
    generate
        for (k=0; k<(Nti+Nti_rep); k=k+1) begin
            always @(posedge clk) begin
                adc_data_reg[k] <= adc_data[k];
                ffe_data_reg[k] <= ffe_data[k];
            end
        end
    endgenerate

    always @(posedge clk) begin
        bist_data_reg <= bist_data;
    end

    // select entry from adc_data and ffe_data

    logic [(Nadc-1):0] adc_data_sel;
    logic [(Nadc-1):0] ffe_data_sel;

    always @(posedge clk) begin
        if (index_reg < (Nti+Nti_rep)) begin
            adc_data_sel <= adc_data_reg[index_reg];
            ffe_data_sel <= ffe_data_reg[index_reg];
        end else begin
            adc_data_sel <= 0;
            ffe_data_sel <= 0;
        end
    end

    // select output

    logic [(Nadc-1):0] out_reg;

    always @(posedge clk) begin
        case (source_reg)
            2'b00:   out_reg <= adc_data_sel;   // ADC
            2'b01:   out_reg <= ffe_data_sel;   // FFE
            2'b10:   out_reg <= 0;              // unused
            2'b11:   out_reg <= bist_data_reg;  // BIST
            default: out_reg <= 'x;
        endcase
    end

    // assign output

    assign out = out_reg;

endmodule

`default_nettype wire