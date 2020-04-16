`default_nettype none

module oneshot_memory import const_pack::*; #(
        parameter integer N_mem_tiles=4
    ) (
    input wire logic clk,
    input wire logic rstb,
    input wire logic signed [Nadc-1:0] in_bytes [N_mem_width-1:0],

    input wire logic in_start_write,

    input wire logic [N_mem_addr + $clog2(N_mem_tiles)-1:0] in_addr,

    output wire logic signed [Nadc-1:0] out_data [N_mem_width-1:0],
    output wire logic [N_mem_addr + $clog2(N_mem_tiles)-1:0] addr
);

    localparam integer sys_addr = N_mem_addr + $clog2(N_mem_tiles);
    localparam [sys_addr-1:0] max_addr = {sys_addr{1'b1}};

    // SRAM address muxing

    logic WEB;

    logic [sys_addr-1:0] write_addr;

    logic [$clog2(N_mem_tiles)-1:0] tile_mux;
    logic [N_mem_addr-1:0] tile_addr [N_mem_tiles-1:0];

    logic [N_mem_tiles-1:0] tile_select_decoder [N_mem_tiles-1:0];
    logic [N_mem_tiles-1:0] tile_select;

    genvar gk;
    generate
        for(gk=0; gk<N_mem_tiles; gk=gk+1) begin
            tile_select_decoder[gk] = ~(1 << gk);
        end
    endgenerate

    assign tile_addr   = (WEB == 1'b0) ? write_addr[N_mem_addr-1:0] : in_addr[N_mem_addr-1:0];
    assign tile_mux    = (WEB == 1'b0) ? write_addr[sys_addr-1:N_mem_addr] : in_addr[sys_addr-1:N_mem_addr];
    assign tile_select = tile_select_decoder[tile_mux];

    // SRAM data I/O

    logic [(N_mem_width)*Nadc-1:0] concat_data_in;
    //logic [(N_mem_width)*Nadc-1:0] concat_data_out;
    logic [(N_mem_width)*Nadc-1:0] concat_data_out [N_mem_tiles-1:0];

    genvar j;
    generate
        for (j=0; j<(N_mem_width); j=j+1) begin
            assign concat_data_in[(j+1)*Nadc-1:j*Nadc] = in_bytes[j];
            assign out_data[j] = concat_data_out[(j+1)*Nadc-1:j*Nadc][tile_mux];
        end
    endgenerate

    // main state machine

    typedef enum logic [1:0] {WAIT_FOR_WRITE, WRITE_IN_PROGRESS, WRITE_DONE} ctrl_state_t;
    ctrl_state_t ctrl_state;

    always @(posedge clk) begin
        if (rstb == 1'b0) begin
            WEB <= 1'b1;
            write_addr <= 'd0;
            ctrl_state <= WAIT_FOR_WRITE;
        end else begin
            case (ctrl_state)
                WAIT_FOR_WRITE : begin
                    WEB <= (in_start_write == 1'b1) ? 1'b0 : 1'b1;
                    write_addr <= 'd0;
                    ctrl_state <= (in_start_write == 1'b1) ? WRITE_IN_PROGRESS : WAIT_FOR_WRITE;
                end      
                WRITE_IN_PROGRESS : begin
                    WEB <= (write_addr == max_addr) ? 1'b1 : 1'b0;
                    write_addr <= (write_addr == max_addr) ? max_addr : write_addr + 'd1;
                    ctrl_state <= (write_addr == max_addr) ? WRITE_DONE : WRITE_IN_PROGRESS;
                end
                WRITE_DONE : begin
                    WEB <= 1'b1;
                    write_addr <= max_addr;
                    ctrl_state <= (in_start_write == 1'b0) ? WAIT_FOR_WRITE : WRITE_DONE;
                end
                default : begin
                    // same as WAIT_FOR_WRITE
                    WEB <= (in_start_write == 1'b1) ? 1'b0 : 1'b1;
                    write_addr <= 'd0;
                    ctrl_state <= (in_start_write == 1'b1) ? WRITE_IN_PROGRESS : WAIT_FOR_WRITE;
                end  
            endcase
        end
    end

    genvar gi;
    generate
        // instantiate SRAM
        for(gi = 0; gi < N_mem_tiles; gi = gi + 1) begin
            sram #(
                .ADR_BITS(N_mem_addr),
                .DAT_BITS((N_mem_width)*Nadc)
            ) sram_i (
                .CLK(clk),
                .CEB(tile_select[gi]),
                .WEB(tile_select[gi] || WEB),
                .A(tile_addr),
                .D(concat_data_in),
                .Q(concat_data_out[gi])
            );   
        end
    endgenerate


endmodule

`default_nettype wire
