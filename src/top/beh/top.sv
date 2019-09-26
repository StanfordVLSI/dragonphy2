module top;

tb tb_i();

initial begin
    #(2500ns);
    assert (tb_i.number >= 1000) else
        $error("Not enough successful bits.");
    $finish;
end

endmodule
