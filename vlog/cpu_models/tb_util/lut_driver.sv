module lut_driver #(
	parameter integer num_of_channels=16,
	parameter integer addrwidth=9,
	parameter integer codewidth=8
) (
	input logic clk,
	input logic [codewidth-1:0] code_array [num_of_channels-1:0],
	input logic [addrwidth-1:0] addr_array [num_of_channels-1:0],
	input logic update,

	dcore_debug_intf.instrument ddbg_intf_i
);
	logic next_update;
	logic [codewidth-1:0] next_code_array [num_of_channels-1:0];
	logic [addrwidth-1:0] next_addr_array [num_of_channels-1:0];

	integer ii;
	initial begin
		next_update <= 0;
	end

	always @(*) begin
		for(ii=0; ii < num_of_channels; ii=ii+1) begin
			ddbg_intf_i.update_trigger[ii] <= next_update ? 1'b1 : 1'b0;
			ddbg_intf_i.new_lut_val[ii] <= next_code_array[ii];
			ddbg_intf_i.new_lut_addr[ii] <= next_addr_array[ii];
		end
	end

	integer jj;
	always @(posedge clk) begin
		next_update <= update;

		for(jj=0;jj<num_of_channels; jj=jj+1) begin
			next_code_array[jj] <= code_array[jj];
			next_addr_array[jj] <= addr_array[jj];
		end
	end
endmodule