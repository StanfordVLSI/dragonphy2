
module inv_chain #(parameter Ninv=8) 
(input logic in, output logic out);

logic [Ninv-2:0] inv_out;

inv iinv_dont_touch[Ninv-1:0] (.in({inv_out, in}), .out({out, inv_out})); 

endmodule


