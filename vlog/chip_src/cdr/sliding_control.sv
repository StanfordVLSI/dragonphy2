module mm_sliding_control #(
    parameter integer slide_width=5,
    parameter integer pdBitwidth=12
) (
    input logic signed [pdBitwidth-1:0] pd_in,

    input logic rstb,
    input logic clk,

    output logic signed [1:0] out

);
    typedef enum {stall, moved_right, moved_left} slide_state_t;

    slide_state_t slide_state;

    logic [slide_width-1:0] slide;
    logic move_direct;

    logic left_end;
    logic right_end;

    assign left_end  = slide[slide_width-1];
    assign right_end = slide[0];
    assign move_direct = (pd_in > 0);
    assign stall_direct = pd_in == 0;

    always_comb begin
        out = stall_direct ? 0 : left_end ? 1 : (right_end ? -1 : 0); 
    end

    always_ff @(posedge clk or negedge rstb) begin 
        if(~rstb) begin
            slide       <= 1'b1 << int'(slide_width/2);
            slide_state <= stall;
        end else begin
            case(slide_state)
                stall : begin
                    slide       <= stall_direct ? slide : move_direct? (slide << 1) : (right_end ? slide : (slide >> 1));
                    slide_state <= stall_direct ? stall : move_direct ? moved_left : moved_right;
                end
                moved_left : begin 
                    slide       <= stall_direct ? slide : move_direct ? (left_end ? slide : (slide << 1)) : (slide >> 1);
                    slide_state <= stall_direct ? stall : move_direct ? moved_left : moved_right;
                end
                moved_right : begin
                    slide       <= stall_direct ? slide : move_direct? (slide << 1) : (right_end ? slide : (slide >> 1));
                    slide_state <= stall_direct ? stall : move_direct  ? moved_left : moved_right;
                end
            endcase // slide_state
        end
    end

endmodule : mm_sliding_control