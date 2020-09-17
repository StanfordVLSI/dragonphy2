`ifndef N_ITER
    `define N_ITER 10
`endif

`ifndef SCALE
    `define SCALE 10000
`endif

`ifndef MIN_BIN
    `define MIN_BIN -6
`endif

`ifndef MAX_BIN
    `define MAX_BIN 6
`endif

module test;
    integer j, k, seed;
    real signal;

    integer cdf_bins [(`MAX_BIN)-(`MIN_BIN)+1];

    initial begin
        // initialize
        seed = $urandom;
        for (k=`MIN_BIN; k<=`MAX_BIN; k=k+1) begin
            cdf_bins[k-(`MIN_BIN)] = 0;
        end

        // run experiment
        for (j=0; j<(`N_ITER); j=j+1) begin
            if (j%10000000 == 0) begin
                $display("%0.1f%% done", (100.0*j)/(`N_ITER));
            end
            signal = $dist_normal(seed, 0, `SCALE)/(1.0*(`SCALE));
            for (k=`MIN_BIN; k<=`MAX_BIN; k=k+1) begin
                if (signal < k) begin
                    cdf_bins[k-(`MIN_BIN)] = cdf_bins[k-(`MIN_BIN)] + 1;
                end
            end
        end

        // print results
        for (k=`MIN_BIN; k<=`MAX_BIN; k=k+1) begin
            $display("%0d: meas %0e", k, (1.0*cdf_bins[k-(`MIN_BIN)])/(`N_ITER));
        end

        // finish
        $finish;
    end
endmodule
