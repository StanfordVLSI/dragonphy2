/********************************************************************
filename: ti_adc_reorder.sv

Description: 
Reorder the outputs of the ADC slices (main and replica)
********************************************************************/

`default_nettype none

module ti_adc_reorder import const_pack::*; (
    input wire logic [(Nadc-1):0] in_data [(Nti-1):0],
    input wire logic [(Nti-1):0] in_sign,

    input wire logic [(Nadc-1):0] in_data_rep [(Nti_rep-1):0],
    input wire logic [(Nti_rep-1):0] in_sign_rep,

    output logic [(Nadc-1):0] out_data [(Nti-1):0],
    output logic [(Nti-1):0] out_sign,

    output logic [(Nadc-1):0] out_data_rep [(Nti_rep-1):0],
    output logic [(Nti_rep-1):0] out_sign_rep
);

genvar k;

generate
    // Main ADC slices
    for (k=0; k<Nti; k=k+1) begin: genblk1
        assign out_data[k] = in_data[(k/Nout)+((k%Nout)*Nout)];
        assign out_sign[k] = in_sign[(k/Nout)+((k%Nout)*Nout)];
    end

    // Replica ADC slices
    for (k = 0; k<Nti_rep; k=k+1) begin: genblk_rep
        assign out_data_rep[k] = in_data_rep[k];
        assign out_sign_rep[k] = in_sign_rep[k];
    end
endgenerate

endmodule
`default_nettype wire
