`include "../Include/define.v"

module LLbit (
    input clk,
    input rst,
    input we,
    input LL_bit_i,
    input flush,

    output reg LL_bit_o
);
    always @(posedge clk) begin
        if (rst == `ResetEnable)
            LL_bit_o <= 1'b0;
        else if (flush == 1'b1)
            LL_bit_o <= 1'b0;
        else if (we == `WriteEnable)    
            LL_bit_o <= LL_bit_i;    
    end
endmodule