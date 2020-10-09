module orig_impl #(
  parameter integer Nunit=32
) (
  input [Nunit-1:0] arb_out,
  output reg [$clog2(Nunit)-1:0] int_Qperi
);

always_comb begin
 for (int i=1; i<Nunit;i++) begin           // thm to bin (it is not a regular thm)
   if (arb_out[i-1]&~arb_out[i]) begin
     int_Qperi = unsigned'(i);
     break;
   end
   else int_Qperi = Nunit-1;
 end
end

endmodule

module new_impl #(
  parameter integer Nunit=32
) (
  input [Nunit-1:0] arb_out, 
  output [$clog2(Nunit)-1:0] int_Qperi
);

logic [$clog2(Nunit)-1:0] int_Qperi_arr [Nunit];
generate
  for (genvar i=1; i<Nunit; i=i+1) begin
    assign int_Qperi_arr[i-1] = (arb_out[i-1]&~arb_out[i]) ? i : int_Qperi_arr[i];
  end
endgenerate

// handle endpoints
assign int_Qperi_arr[Nunit-1] = Nunit-1;
assign int_Qperi = int_Qperi_arr[0];

endmodule

module tb #(
  parameter integer Nunit=32
) (
  input [Nunit-1:0] arb_out
);

  wire [$clog2(Nunit)-1:0] int_Qperi_orig;
  wire [$clog2(Nunit)-1:0] int_Qperi_new;

  orig_impl #(
    .Nunit(Nunit)
  ) inst_orig(
    .arb_out(arb_out),
    .int_Qperi(int_Qperi_orig)
  );

  new_impl #(
    .Nunit(Nunit)
  ) inst_new (
    .arb_out(arb_out),
    .int_Qperi(int_Qperi_new)
  );

  always @* begin
    assert (int_Qperi_orig == int_Qperi_new);
  end

endmodule
