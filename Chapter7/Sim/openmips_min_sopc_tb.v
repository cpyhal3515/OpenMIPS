`include "../Include/define.v"

module openmips_min_sopc_tb ();
    reg clk_50;
    reg rst;

    initial begin
        clk_50 = 1'b0;
        forever #10 clk_50 = ~clk_50;
    end

    initial begin
        rst = `ResetEnable;
        #195 rst = `ResetDisable;
        #1000 $stop;
    end

    openmips_min_sopc openmips_min_sopc_inst0(
        .clk(clk_50),
        .rst(rst)
    );
endmodule