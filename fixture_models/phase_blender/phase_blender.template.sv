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
#model_param_map = { 'test1': {'gain': 'Av', 'offset_to_cm': 'v_oc_r'} }
model_param_map = { 'test1': {'gain': 'gain', 'offset': 'offset'} }

}$$

always @($$print_sensitivity_list(sensitivity)) begin
  t0 = `get_time;

$${
iv_map = {}
}$$
$$annotate_modelparam(model_param_map, iv_map)

    real wgt = gain + offset;

    // state variables
    logic nxt_state=1'b0;
    real rise0=-1;
    real fall0=-1;
    real rise1=-1;
    real fall1=-1;

    real ttotr0;
    always @(posedge ph_in[0]) begin
        if (nxt_state != 1'b1) begin
            // update nxt_state
            nxt_state = 1'b1;
            // calculate delay
            if ((rise0 != -1) && (rise1 != -1) && (rise1 >= rise0)) begin
                ttotr0 = wgt*(rise1-rise0) + td + pi_obj.get_rj_mixermb();
            end else begin
                ttotr0 = td + pi_obj.get_rj_mixer1b();
            end
            // schedule output
            ph_out <= #(ttotr0*1s) 1'b1;
        end
        rise0 = $realtime/1s;
    end

    real ttotf0;
    always @(negedge ph_in[0]) begin
        if (nxt_state != 1'b0) begin
            nxt_state = 1'b0;
            if ((fall0 != -1) && (fall1 != -1) && (fall1 >= fall0)) begin
                ttotf0 = wgt*(fall1-fall0) + td + pi_obj.get_rj_mixermb();
            end else begin
                ttotf0 = td + pi_obj.get_rj_mixer1b();
            end
            ph_out <= #(ttotf0*1s) 1'b0;
        end
        fall0 = $realtime/1s;
    end

    real ttotr1;
    always @(posedge ph_in[1]) begin
        if (nxt_state != 1'b1) begin
            // update nxt_state
            nxt_state = 1'b1;
            // calculate delay
            if ((rise0 != -1) && (rise1 != -1) && (rise0 >= rise1)) begin
                ttotr1 = (1.0-wgt)*(rise0-rise1) + td + pi_obj.get_rj_mixermb();
            end else begin
                ttotr1 = td + pi_obj.get_rj_mixer1b();
            end
            // schedule output
            ph_out <= #(ttotr1*1s) 1'b1;
        end
        rise1 = $realtime/1s;
    end

    real ttotf1;
    always @(negedge ph_in[1]) begin
        if (nxt_state != 1'b0) begin
            nxt_state = 1'b0;
            if ((fall0 != -1) && (fall1 != -1) && (fall0 >= fall1)) begin
                ttotf1 = (1.0-wgt)*(fall0-fall1) + td + pi_obj.get_rj_mixermb();
            end else begin
                ttotf1 = td + pi_obj.get_rj_mixer1b();
            end
            ph_out <= #(ttotf1*1s) 1'b0;
        end
        fall1 = $realtime/1s;
    end
endmodule
