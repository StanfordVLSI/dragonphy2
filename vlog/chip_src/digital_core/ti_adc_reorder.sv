/********************************************************************
filename: ti_adc_reorder.sv

Description: 
Reorder 16 ADC slices' outputs (data+sign)

Assumptions:

********************************************************************/

`default_nettype none
module ti_adc_reorder import const_pack::*; (
    input wire logic [Nadc-1:0] in_data [Nti-1:0],   // serial data
    input wire logic [Nti -1:0] in_sign,             // sign of serial data

    input wire logic [Nadc-1:0] in_data_rep [1:0],
    input wire logic [1:0]      in_sign_rep,

    output logic [Nadc-1:0] out_data [Nti-1:0],      // parallel data
    output logic [Nti-1:0]  out_sign,                // parallel data

    output logic [Nadc-1:0] out_data_rep [1:0],      // parallel data
    output logic [1:0]      out_sign_rep             // parallel data
);

genvar k;

generate
    // Main ADC slices
    for (k=0; k<Nti; k=k+1) begin: genblk1
        assign out_data[k] = in_data[(k%4)*4+(k>>2)];
        assign out_sign[k] = in_sign[(k%4)*4+(k>>2)];
    end

    // Replica ADC slices
    for (k = 0; k<2; k=k+1) begin: genblk_rep
        assign out_data_rep[k] = in_data_rep[k];
        assign out_sign_rep[k] = in_sign_rep[k];
    end
endgenerate

endmodule
`default_nettype wire
