module PI_local_encoder #(
parameter integer Nbit = 9,
parameter integer Nunit = 32,
parameter integer Nblender = 4
)
(
input  rstb,
input [Nbit-1:0] ctl,
input clk_cdr,
input [Nunit-1:0] arb_out, 
input en_ext_Qperi,
input [$clog2(Nunit)-1:0] ext_Qperi,


// added/modified for glitch free ooperation (12th Nov. 2019)
//output reg [$clog2(Nunit)-2:0] sel_mux0,
//output reg [$clog2(Nunit)-2:0] sel_mux1,
output reg [1:0] sel_mux_1st_even [$clog2(Nunit)-2:0],
output reg [1:0] sel_mux_1st_odd [$clog2(Nunit)-2:0],
output reg [1:0] sel_mux_2nd_even, 
output reg [1:0] sel_mux_2nd_odd,
output reg [2**Nblender-1:0] thm_sel_bld,

output reg [$clog2(Nunit)-1:0] Qperi,
output [$clog2(Nunit)-1:0] max_sel_mux,  
output [Nunit-1:0] en_mixer 
);


logic Qperi_lsb;
logic [$clog2(Nunit)-1:0] int_Qperi;

// external Qperi
assign Qperi = en_ext_Qperi ? ext_Qperi : int_Qperi;

//synopsys translate_off
initial begin
//sel_mux0 <=0;
//sel_mux1 <=0;
thm_sel_bld <=0;
end
//synopsys translate_on

reg [$clog2(Nunit)-2:0] ph_num_even;
reg [$clog2(Nunit)-2:0] ph_num_odd;

always @(posedge clk_cdr or negedge rstb) begin 
	if(!rstb) begin
		//sel_mux0 <=0;
		//sel_mux1 <=0;
		ph_num_even <=0;
		ph_num_odd <=0;
		thm_sel_bld <=0;
	end 
	else begin
      thm_sel_bld <= (ctl[Nbit-1:Nblender]%2 == 0) ? ('1 >> ((~ctl[Nblender-1:0]) & 16'h000F)) : ('1 >> (ctl[Nblender-1:0]+1));
      //sel_mux0 <= (ctl[Nbit-1:Nblender] == max_sel_mux) ? 0 : (ctl[Nbit-1:Nblender]+1) >> 1; 
   	  //sel_mux1 <=  ctl[Nbit-1:Nblender] >> 1 ; 		
      ph_num_even <= (ctl[Nbit-1:Nblender] == max_sel_mux) ? 0 : (ctl[Nbit-1:Nblender]+1) >> 1; 
   	  ph_num_odd <=  ctl[Nbit-1:Nblender] >> 1 ; 		
	
	end
end

// added/modified for glitch free operation (12th Nov. 2019)
genvar k;
generate
	for(k=0;k<4;k++) begin
		always_comb begin
			if(ph_num_even[3:2] == k) sel_mux_1st_even[k] = ph_num_even[1:0];
			else if(ph_num_even == 4*(k+1)) sel_mux_1st_even[k] = 3;
			else sel_mux_1st_even[k] = 0;	
		
			if(ph_num_odd[3:2] == k) sel_mux_1st_odd[k] = ph_num_odd[1:0];
			else if(ph_num_odd == 4*(k+1)) sel_mux_1st_odd[k] = 3;
			else sel_mux_1st_odd[k] = 0;	
		end
	end
endgenerate

assign sel_mux_2nd_even = ph_num_even[3:2];
assign sel_mux_2nd_odd = ph_num_odd[3:2];

always_comb begin  
 for (int i=1; i<Nunit;i++) begin			// thm to bin (it is not a regular thm)
   if (arb_out[i-1]&~arb_out[i]) begin
     int_Qperi = unsigned'(i);
     break;
   end
   else int_Qperi = Nunit-1;
 end
end

assign Qperi_lsb = ~Qperi[0];
assign max_sel_mux = (Qperi-Qperi_lsb);			// maximum code for sel_mux
assign en_mixer = unsigned'(1) << max_sel_mux;	// mixer (1-bit blender) enable code


endmodule
