`include "../Include/define.v"
module hilo_reg (
    input clk,
    input rst,
    input we,
    input [`RegisterBus] hi_i,
    input [`RegisterBus] lo_i,

    output reg [`RegisterBus] hi_o,
    output reg [`RegisterBus] lo_o
);

    always @(posedge clk) begin
        if(rst == `ResetEnable) begin
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end
        else
            if(we == `WriteEnable) begin
                hi_o <= hi_i;
                lo_o <= lo_i;
            end
    end

    
endmodule