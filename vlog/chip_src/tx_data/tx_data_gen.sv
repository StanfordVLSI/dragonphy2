`default_nettype none

module tx_data_gen #(
    parameter integer Nprbs=32,
    parameter integer Nti=16
) (
    input wire logic clk,
    input wire logic exec,

    input wire logic rst,
    input wire logic cke,

    // data generation mode
    // RESET = 3'd0;
    // CONSTANT = 3'd1;
    // PULSE = 3'd2;
    // SQUARE = 3'd3;
    // PRBS = 3'd4;
    input wire logic [2:0] data_mode,

    input wire logic [15:0] data_per,
    input wire logic [(Nti-1):0] data_in,

    input wire logic [(Nprbs-1):0] prbs_init [(Nti-1):0],
    input wire logic [(Nprbs-1):0] prbs_eqn,
    input wire logic [(Nti-1):0] prbs_inj_err,
    input wire logic [1:0] prbs_chicken,

    output wire logic [(Nti-1):0] data_out
);
    // TODO: consider using enum here
    localparam logic [2:0]    RESET = 3'd0;
    localparam logic [2:0] CONSTANT = 3'd1;
    localparam logic [2:0]    PULSE = 3'd2;
    localparam logic [2:0]   SQUARE = 3'd3;
    localparam logic [2:0]     PRBS = 3'd4;

    // synchronize the exec signal, which is used
    // to enable loading of the other control signals

    logic exec_m;
    logic exec_d;

    always @(posedge clk) begin
        exec_m <= exec;
        exec_d <= exec_m;
    end

    // register the reset and clock enable

    logic rst_d;
    logic cke_d;

    always @(posedge clk) begin
        if (exec_d) begin
            rst_d <= rst;
            cke_d <= cke;
        end else begin
            rst_d <= rst_d;
            cke_d <= cke_d;
        end
    end

    // register the data generator controls

    logic [2:0] data_mode_d;
    logic [15:0] data_per_d;
    logic [(Nti-1):0] data_in_d;

    always @(posedge clk) begin
        if (exec_d) begin
            data_mode_d <= data_mode;
            data_per_d <= data_per;
            data_in_d <= data_in;
        end else begin
            data_mode_d <= data_mode_d;
            data_per_d <= data_per_d;
            data_in_d <= data_in_d;
        end
    end

    // instantiate the PRBS generators, registering all of
    // the control signals

    logic [(Nprbs-1):0] prbs_init_d [(Nti-1):0];
    logic [(Nprbs-1):0] prbs_eqn_d;
    logic [(Nti-1):0] prbs_inj_err_d;
    logic [1:0] prbs_chicken_d;
    logic [(Nti-1):0] prbs_out;

    always @(posedge clk) begin
        if (exec_d) begin
            prbs_eqn_d <= prbs_eqn;
            prbs_inj_err_d <= prbs_inj_err;
            prbs_chicken_d <= prbs_chicken;
        end else begin
            prbs_eqn_d <= prbs_eqn_d;
            prbs_inj_err_d <= prbs_inj_err_d;
            prbs_chicken_d <= prbs_chicken_d;
        end
    end

    genvar i;
    generate
        for(i=0; i<Nti; i=i+1) begin
            always @(posedge clk) begin
                if (exec_d) begin
                    prbs_init_d[i] <= prbs_init[i];
                end else begin
                    prbs_init_d[i] <= prbs_init_d[i];
                end
            end
            prbs_generator_syn #(
                .n_prbs(Nprbs)
            ) prbs_generator_syn_i (
                .clk(clk),
                .rst(rst_d),
                .cke(cke_d),
                .init_val(prbs_init_d[i]),
                .eqn(prbs_eqn_d),
                .inj_err(prbs_inj_err_d[i]),
                .inv_chicken(prbs_chicken_d),
                .out(prbs_out[i])
            );
        end
    endgenerate

    // implement the data generator

    logic [(Nti-1):0] data_out_reg;
    logic [15:0] counter;

    always @(posedge clk) begin
        if (rst_d) begin
            data_out_reg <= 0;
            counter <= 0;
        end else begin
            if (data_mode_d == RESET) begin
                data_out_reg <= 0;
                counter <= 0;
            end else if (data_mode_d == CONSTANT) begin
                data_out_reg <= data_in_d;
                counter <= 0;
            end else if (data_mode_d == PULSE) begin
                if (counter == data_per_d) begin
                    data_out_reg <= data_in_d;
                    counter <= 0;
                end else begin
                    data_out_reg <= 0;
                    counter <= counter + 1;
                end
            end else if (data_mode_d == SQUARE) begin
                if (counter == data_per_d) begin
                    data_out_reg <= ~data_out_reg;
                    counter <= 0;
                end else begin
                    data_out_reg <= data_out_reg;
                    counter <= counter + 1;
                end
            end else if (data_mode_d == PRBS) begin
                data_out_reg <= prbs_out;
                counter <= 0;
            end else begin
                data_out_reg <= 0;
                counter <= 0;
            end
        end
    end

    // assign the output

    assign data_out = data_out_reg;

endmodule

`default_nettype wire