//---------------------------- mem_wb.v ----------------------------//
// Just a register.
`include "../Include/define.v"
module mem_wb (
    input clk,
    input rst,

    input [`RegisterBus] mem_wdata,
    input [`RegisterAddressBus] mem_wd,
    input mem_wreg,

    output reg [`RegisterBus] wb_wdata,
    output reg [`RegisterAddressBus] wb_wd,
    output reg wb_wreg

);



always@(posedge clk) begin
    if(rst == `ResetEnable) begin
        wb_wdata   <= `ZeroWord;
        wb_wd      <= `NOPRegisterAddress;
        wb_wreg    <= `WriteDisable;
    end
    else begin
        wb_wdata <= mem_wdata;
        wb_wd <= mem_wd;      
        wb_wreg <= mem_wreg;       
    end
end

    
endmodule