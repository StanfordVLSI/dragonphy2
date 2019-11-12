`default_nettype none

module sim_status;

	parameter real dt = 1e-6;
	parameter units = "us";

	always begin 
		#(dt*1s);
		
		if (units == "fs") begin
			$display("Sim progress: %0.3f [fs]", $realtime/1fs);
		end else if (units == "ps") begin
			$display("Sim progress: %0.3f [ps]", $realtime/1ps);
		end else if (units == "ns") begin
			$display("Sim progress: %0.3f [ns]", $realtime/1ns);
		end else if (units == "us") begin
			$display("Sim progress: %0.3f [us]", $realtime/1us);
		end else if (units == "ms") begin
			$display("Sim progress: %0.3f [ms]", $realtime/1ms);
		end else if (units == "s") begin
			$display("Sim progress: %0.3f [s]", $realtime/1s);
		end else begin
			$error("Invalid time units for sim_status: %s", units);
		end
	end

endmodule

`default_nettype wire
