`default_nettype none

module pd_aux import const_pack::*; #(
    parameter integer Ncntr = 16-$clog2(Nti),           // counter bit width in aux PD that determines its BW 
    parameter integer Nc_invalid = (Ncntr-5)            // wait for 2**(Nc-1) cycles to be settled
) (
    input wire logic clk,                               // parallel data clock
    input wire logic enable,                            // enable this auxiliary pd (active Hi)
    input wire logic signed [Nadc-1:0] din[Nti-1:0],    // data inputs to PD
    input wire logic signed [Nadc-1:0] pd_offset_ext,   // external value for pd_offset (valid when enable == Lo)
    output wire logic signed [Nadc-1:0] pd_offset       // main pd offset
);

    localparam integer Nfr = 1;     // bit width of fraction part in pd_offset_fp
    localparam integer dy0 = 1;     // step size of dy for computing threshold

    // check that parameter values are consistent
	//synopsys translate_off
    initial begin 
        assert (Ncntr > Nc_invalid) else $error( "%m: Ncntr(%d) must be larger than Nc_invalid(%d) !!!", Ncntr, Nc_invalid);
    end
	//synopsys translate_on

    // signal declaration
    logic startup;                              // to ignore the first comparison after enabled
    logic pd_dir;                               // pd offset direction; Hi: increment, Lo: decrement
    logic [Ncntr-1:0] cntr;                     // counter for resetting accumulator for refresh
    logic signed [Nadc+Nfr-1:0] pd_offset_fp;   // main pd offset in FP

    logic [Nadc-1:0] d_min, d_min_prev;
    logic [Nadc-1:0] _d_min;
    logic [Nadc-1:0] abs_din[Nti];
    logic [Nadc-1:0] threshold;

    logic [Nadc+Ncntr+$clog2(2*Nti)-1:0] no_err, no_err_prev;
    logic [$clog2(2*Nti)-1:0] inc;  // increment per clock
    logic [Nadc-1:0] dy;

    assign pd_offset = pd_offset_fp[Nadc+Nfr-1 -: Nadc];    // take int part
    assign threshold = d_min_prev+dy;

    // absolute value of din
    genvar k;
    generate 
        for (k=0;k<Nti;k++) begin 
            assign abs_din[k] = (din[k][Nadc-1])? ~din[k] + 1 : din[k];
        end
    endgenerate

    // find # of errors 
    always @(*) begin 
        inc = 0;
        for (int i=0;i<Nti;i++) begin
            if (abs_din[i] < threshold) begin
                inc += 1;
            end
        end
    end

    // find min
    always @(*) begin 
        _d_min = d_min;
        for (int i=0;i<Nti;i++) begin 
            if (abs_din[i] < _d_min) begin
                _d_min = abs_din[i];
            end
        end
    end

    // reference counter
    always @(posedge clk or negedge enable) begin
        if (!enable) begin
            cntr <= 0;
        end else begin
            cntr <= cntr + 1;
        end
    end

    // update min(din) and count # of error
    always @(posedge clk or negedge enable) begin
        if (!enable) begin
            no_err <= '1;  
            d_min <= 2**Nadc -1;
        end else if (cntr==0) begin
            no_err <= 0;
            d_min <= 2**Nadc -1;
        end else if (cntr >= {(Nc_invalid){1'b1}}) begin // update minimum data value
            no_err <= no_err + inc;
            d_min <= _d_min;
        end
    end

    // update pd_offset
    always @(posedge clk or negedge enable) begin
        if (!enable) begin
            pd_offset_fp <= pd_offset_ext << Nfr;
            pd_dir <= 1'b1;
            no_err_prev <= 0; 
            startup <= 1'b1;
            d_min_prev <= 2**Nadc - 1;
            dy <= dy0;
        end else if (cntr=='1) begin            // update pd_offset
            if (startup) begin
                startup <= 0;
                no_err_prev <= no_err;
    			d_min_prev <= d_min;
            end else begin
                if (no_err > no_err_prev) begin // error was increased, change direction
                    dy <= dy0;
                    pd_offset_fp <= pd_offset_fp + ( pd_dir ? -1 : +1 ); 
                    pd_dir <= ~pd_dir;
    	  			d_min_prev <= d_min;
                    no_err_prev <= no_err;
                end else begin                  // error was decreased, keep the direction
                    if (no_err == 0) begin      // increase threshold 
                        pd_offset_fp <= pd_offset_fp + ( pd_dir ? +1 : -1 );
                        dy <= dy + dy0;
                        no_err_prev <= '1;
                    end else begin
                        pd_offset_fp <= pd_offset_fp + ( pd_dir ? +2 : -2 );
                        no_err_prev <= no_err;
                    end
                end
            end
        end
    end

endmodule

`default_nettype wire
