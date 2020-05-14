`ifndef __VOLTAGE_NET_SV__
`define __VOLTAGE_NET_SV__

	// reference for user-defined nettypes: 
	// https://community.cadence.com/cadence_technology_forums/f/functional-verification/36442/problem-with-user-define-net-types-resolution-functions
	
	// struct for storing voltages and resistances
	
	typedef struct {
		real V;
		real R;
	} voltage_struct ;
	
	// resolution function
	
	function automatic voltage_struct voltage_res(input voltage_struct drivers[]);
		real num;
		real den;
		
		num = 0.0;
		den = 0.0;
	
		foreach (drivers[j]) begin
			num = num + drivers[j].V/drivers[j].R;
			den = den + 1.0/drivers[j].R;
		end
	
	  	voltage_res = '{num/den, 1.0/den};
	endfunction
	
	// nettype declaration
	
	nettype voltage_struct voltage with voltage_res;

`endif // `ifndef __VOLTAGE_NET_SV__
