//---------------------------- if_id.v ----------------------------//
// Just a register.
`include "../Include/define.v"
module if_id(
    input clk,
    input rst,
    input [`InstAddressBus] if_pc,
    input [`InstDataBus] if_inst,
    output reg [`InstAddressBus] id_pc,
    output reg [`InstDataBus] id_inst
);
    always@(posedge clk) begin
        if(rst == `ResetEnable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end    
    end


    
endmodule