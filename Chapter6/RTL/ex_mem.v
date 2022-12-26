//---------------------------- ex_mem.v ----------------------------//
// Just a register.
`include "../Include/define.v"
module ex_mem (
    input clk,
    input rst,

    input [`RegisterBus] ex_wdata,
    input [`RegisterAddressBus] ex_wd,
    input ex_wreg,

    input [`RegisterBus] ex_hi,
    input [`RegisterBus] ex_lo,
    input ex_whilo,

    output reg [`RegisterBus] mem_wdata,
    output reg [`RegisterAddressBus] mem_wd,
    output reg mem_wreg,

    output reg [`RegisterBus] mem_hi,
    output reg [`RegisterBus] mem_lo,
    output reg mem_whilo


);



always@(posedge clk) begin
    if(rst == `ResetEnable) begin
        mem_wdata   <= `ZeroWord;
        mem_wd      <= `NOPRegisterAddress;
        mem_wreg    <= `WriteDisable;

        mem_hi  <= `ZeroWord;
        mem_lo  <= `ZeroWord;
        mem_whilo <= `WriteDisable;
    end
    else begin
        mem_wdata   <= ex_wdata;
        mem_wd      <= ex_wd;
        mem_wreg    <= ex_wreg;  

        mem_hi <= ex_hi;
        mem_lo <= ex_lo;
        mem_whilo <= ex_whilo;      

    end
end

    
endmodule