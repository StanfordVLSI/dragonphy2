/********************************************************************
filename: phase_blender.sv
Description: 
multi-bit phase blender.
Assumptions:
Todo:
********************************************************************/


$$#$${
$$#import os
$$#from dave.common.misc import *
$$#def_file = os.path.join(os.environ['DAVE_INST_DIR'], 'dave/mgenero/api_mgenero.py')
$$#api_fullpath = get_abspath(def_file, True, None)
$$#api_dir = get_dirname(api_fullpath)
$$#api_base = os.path.splitext(get_basename(api_fullpath))[0]
$$#
$$#import sys
$$#if not api_fullpath in sys.path:
$$#  import sys
$$#  sys.path.append(api_dir)
$$#from api_mgenero import *
$$#
$$#}$$

module $$(Module.name()) #(
  $$(Module.parameters())
) (
  $$(Module.pins())
);


    timeunit 1fs;
    timeprecision 1fs;

    import model_pack::PIParameter;

    // design parameter class init
    PIParameter pi_obj;
    initial begin
        pi_obj = new();
    end

$$Pin.print_map() $$# map between user pin names and generic ones
$$PWL.declare_optional_analog_pins_in_real()
$$PWL.instantiate_pwl2real_optional_analog_pins(['vss'] if Pin.is_exist('vss') else [])
// Declare parameters
real gain;
real offset;

$${
# sensitivity list of always @ statement
# sensitivity = ['v_icm_r', 'vdd_r', 'wakeup'] + get_sensitivity_list() 
sensitivity = ['wakeup'] + get_sensitivity_list() 

# model parameter mapping for back-annotation
# { testname : { test output : Verilog variable being mapped to } }
model_param_map = { 'test1': {'gain': 'gain', 'offset': 'offset'} }

}$$

$${
iv_map = {}
}$$

always @(*) begin
$$annotate_modelparam(model_param_map, iv_map)
end

real wgt;
real td;
assign wgt = gain;
assign td = offset;

// fixed blender error by sjkim85 (3th May 2020) ------------------------------------------------
real rise_lead;
real rise_lag;
real fall_lead;
real fall_lag;
real rise_diff_in;
real fall_diff_in;
real ttotr;
real ttotf;
real flip;

    assign ph_and = ph_in[0]&ph_in[1];
    assign ph_or = ph_in[0]|ph_in[1];

    always @(posedge ph_in[0]) flip = ph_in[1];
    always @(negedge ph_in[0]) flip = ~ph_in[1];

    always @(posedge ph_or) begin
        rise_lead = $realtime/1s;
    end
    always @(posedge ph_and) begin
        rise_lag = $realtime/1s;
        rise_diff_in = rise_lag - rise_lead;
        ttotr = (flip+(1-2*flip)*wgt)*rise_diff_in + td + pi_obj.get_rj_mixermb() - rise_diff_in;
        ph_out <= #(ttotr*1s) 1'b1;
    end
    always @(negedge ph_and) begin
        fall_lead = $realtime/1s;
    end
    always @(negedge ph_or) begin
        fall_lag = $realtime/1s;
        fall_diff_in = fall_lag - fall_lead;
        ttotf = (flip+(1-2*flip)*wgt)*fall_diff_in + td + pi_obj.get_rj_mixermb() - fall_diff_in;
        ph_out <= #(ttotf*1s) 1'b0;
    end


//---------------------------------------------- ------------------------------------------------

endmodule

