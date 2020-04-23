module comb_deadband #(
    parameter integer inputBitwidth=8,
) (
    input wire logic signed [inputBitwidth-1:0] in,
    input wire logic signed [inputBitwidth-1:0] lower_deadband,
    input wire logic signed [inputBitwidth-1:0] upper_deadband,

    output logic signed [inputBitwidth-1:0] out
);

    logic is_above_deadband;
    logic is_below_deadband; 
    logic not_in_deadband;

    for(gc=0; gc<numChannels; gc=gc+1) begin
        assign is_below_deadband[gc]  = (in < lower_deadband[gc]) ? 1'b1 : 1'b0;
        assign is_above_deadband[gc]  = (in > upper_deadband[gc]) ? 1'b1 : 1'b0; 
        assign not_in_deadband[gc]    = is_above_deadband[gc] || is_below_deadband[gc];
        assign out[gc]                = not_in_deadband[gc] ? in[gc] : 0;
    end


endmodule : comb_deadband