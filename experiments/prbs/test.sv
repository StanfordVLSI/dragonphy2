`timescale 1s/1fs

module test(
    input wire clk_a,
    input wire rst_a,
    output wire out_a,
    input wire clk_b,
    input wire rst_b,
    output wire [31:0] out_b
);

    logic [31:0] init_vals [32];
    assign init_vals[0]  = 32'h39406d25;//32'h3e055e6a; //32'h7c0abcd5; //32'h7280da4b; //32'h97eccdb4; //  32'hf89238e3; //32'h00000204; //32'h00100043;
    assign init_vals[1]  = 32'h1fa44802;//32'h60707c03; //32'hc0e0f806; //32'h3f489004; //32'h54b556dd; // 32'h1eaa85e8; //32'h02042c58; //32'h0123049a;
    assign init_vals[2]  = 32'h5bda4b69;//32'h03ff554c; //32'h07feaa99; //32'hb7b496d3; //32'hb15e800a; // 32'hbbd0d60d; //32'h00020818; //32'h1060428b;
    assign init_vals[3]  = 32'h25fdb240;//32'h6ff2d6cc; //32'hdfe5ad99; //32'h4bfb6480; //32'he40e36c7; // 32'hc6539d46; //32'h0834b1f4; //32'h25ce814c;
    assign init_vals[4]  = 32'h397bbecb;//32'h3e0aa195; //32'h7c15432a; //32'h72f77d96; //32'h03cbc020; // 32'h56fd8d8d; //32'h02042850; //32'h0103041c;
    assign init_vals[5]  = 32'h4dbfed92;//32'h7037a9fe; //32'he06f53fc; //32'h9b7fdb25; //32'had36edda; // 32'he0cbe08d; //32'h040a50a8; //32'h12264bbf;
    assign init_vals[6]  = 32'h2ccb4df6;//32'h1f02aa60; //32'h3e0554c0; //32'h59969bed; //32'h95e6367a; // 32'hdbdbb600; //32'h0830a1c4; //32'h050e045a;
    assign init_vals[7]  = 32'h126dff6d;//32'h73c8034d; //32'he790069a; //32'h24dbfedb; //32'h76363700; // 32'h2de064f6; //32'h126d4bb9; //32'h4a9e0684;
    assign init_vals[8]  = 32'h562c834d;//32'h31f401f3; //32'h63e803e6; //32'hac59069a; //32'h9dcdd941; // 32'ha42d635b; //32'h00020008; //32'h10204387;
    assign init_vals[9]  = 32'h3726ddbf;//32'h4c0d7d2a; //32'h981afa55; //32'h6e4dbb7f; //32'hfc3bb077; // 32'hf1760536; //32'h00240094; //32'h21429324;
    assign init_vals[10] = 32'h37db2092;//32'h00000555; //32'h00000aaa; //32'h6fb64124; //32'h2f80bc6d; // 32'h666dbbb6; //32'h020c0830; //32'h40820e30;
    assign init_vals[11] = 32'h4b6dbfff;//32'h43f03d4c; //32'h87e07a99; //32'h96db7ffe; //32'h9cedaab7; // 32'he5ed2b00; //32'h24d8977a; //32'h851c4e8f;
    assign init_vals[12] = 32'h3a827964;//32'h300bab55; //32'h601756aa; //32'h7504f2c9; //32'h9ead4d5a; // 32'hfd00e0db; //32'h00200084; //32'h0102142a;
    assign init_vals[13] = 32'h1b4949b6;//32'h7bf4164c; //32'hf7e82c99; //32'h3692936d; //32'h5b80b700; // 32'h10b68d6d; //32'h02440918; //32'h02072878;
    assign init_vals[14] = 32'h5924d249;//32'h1f05559f; //32'h3e0aab3f; //32'hb249a493; //32'hb380a1da; // 32'hb6dbb6db; //32'h20c0871a; //32'h041852ee;
    assign init_vals[15] = 32'h2492db6d;//32'h7bebe9b3; //32'hf7d7d367; //32'h4925b6db; //32'hed5ab701; // 32'hc449d2db; //32'h49912e70; //32'h0b3a8934;
    assign init_vals[16] = 32'h3c214412;//32'h3f8afe65; //32'h7f15fcca; //32'h78428824; //32'h0ab543b6; // 32'h5ce3b800; //32'h02040810; //32'h0003002c;
    assign init_vals[17] = 32'h4ed01b49;//32'h421017ea; //32'h84202fd4; //32'h9da03693; //32'ha8deaada; // 32'hef33b36d; //32'h2448952a; //32'h0016021e;
    assign init_vals[18] = 32'h2fe99200;//32'h07ff5566; //32'h0ffeaacc; //32'h5fd32400; //32'h9e62bcda; // 32'hdd600db6; //32'h08102044; //32'h030a2ce8;
    assign init_vals[19] = 32'h16f692db;//32'h5ded5726; //32'hbbdaae4d; //32'h2ded25b6; //32'h7812ab6d; // 32'h239d2b6d; //32'h912654f0; //32'h16761245;
    assign init_vals[20] = 32'h55afad92;//32'h7f8afccf; //32'hff15f99f; //32'hab5f5b25; //32'h9d5d7ada; // 32'hab563b6d; //32'h2040850a; //32'h00100246;
    assign init_vals[21] = 32'h36ff6db6;//32'h63e8094c; //32'hc7d01298; //32'h6dfedb6d; //32'hf65adada; // 32'hf08de000; //32'h40810a10; //32'h032628d4;
    assign init_vals[22] = 32'h322dff6d;//32'h1ffa80cc; //32'h3ff50199; //32'h645bfedb; //32'h262a16db; // 32'h6d6d6db6; //32'h81061479; //32'h10624b95;
    assign init_vals[23] = 32'h49b6db6d;//32'h60175c00; //32'hc02eb801; //32'h936db6da; //32'h9a5b6db7; // 32'he940f6db; //32'h020c2cea; //32'h2cfc26cc;
    assign init_vals[24] = 32'h3832edff;//32'h70085600; //32'he010ac00; //32'h7065dbff; //32'h9457436c; // 32'hf836edb6; //32'h00000004; //32'h03062c58;
    assign init_vals[25] = 32'h1d9b0092;//32'h5e1dfd95; //32'hbc3bfb2b; //32'h3b360124; //32'h504c7000; // 32'h1e5bedb6; //32'h00040058; //32'h162e1a3d;
    assign init_vals[26] = 32'h5f6dffff;//32'h003ffffe; //32'h007ffffc; //32'hbedbfffe; //32'hbc80bdb7; // 32'hbbb60000; //32'h00000418; //32'h0c38b1e6;
    assign init_vals[27] = 32'h2db64924;//32'h411f57f5; //32'h823eafeb; //32'h5b6c9249; //32'hf1371db7; // 32'hc6b6b6db; //32'h041859d0; //32'h5afe61c1;
    assign init_vals[28] = 32'h2b0949b6;//32'h73f7fcb3; //32'he7eff966; //32'h5612936d; //32'h3bf7a000; // 32'h5600db6d; //32'h00040050; //32'h1022428d;
    assign init_vals[29] = 32'h6d249249;//32'h70eb5606; //32'he1d6ac0d; //32'hda492493; //32'hec800001; // 32'he0dbb6db; //32'h000804a8; //32'h2064859c;
    assign init_vals[30] = 32'h6492db6d;//32'h3ffa8199; //32'h7ff50333; //32'hc925b6da; //32'h4c817b6d; // 32'hdb6db6db; //32'h041851e0; //32'h428f020c;
    assign init_vals[31] = 32'h92492493;//32'hf0eb5353; //32'he1d6a6a7; //32'h24924926; //32'h37edb6d8; // 32'hd2dbffff; //32'h0834b3f0; //32'ha5de810f;

    prbs_generator_syn #(
        .n_prbs(32)
    ) prbs_a (
        .clk(clk_a),
        .rst(rst_a),
        .cke(1'b1),
        .init_val(32'h00000001),
        .eqn(32'h4000_0004),
        .inj_err(1'b0),
        .inv_chicken(2'b00),
        .out(out_a),
        .stall(0),
        .early_load(0),
        .late_load(0),
        .run_twice(0)
    );


    genvar i;
    generate
        for(i=0; i<32; i=i+1) begin
            prbs_generator_syn #(
                .n_prbs(32)
            ) prbs_b (
                .clk(clk_b),
                .rst(rst_b),
                .cke(1'b1),
                .init_val(init_vals[i]),
                .eqn(32'h4000_0004),
                .inj_err(1'b0),
                .inv_chicken(2'b00),
                .out(out_b[i]),
                .stall(0),
                .early_load(0),
                .late_load(0),
                .run_twice(0)
            );
        end
    endgenerate

endmodule
