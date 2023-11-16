//---------------------------- mem.v ----------------------------//
// Just a wire.
`include "../Include/define.v"
module mem (
    input rst,
    input [`RegisterBus] wdata_i,
    input [`RegisterAddressBus] wd_i,
    input wreg_i,


    input [`RegisterBus] hi_i,
    input [`RegisterBus] lo_i,
    input whilo_i,

    output reg [`RegisterBus] wdata_o,
    output reg [`RegisterAddressBus] wd_o,
    output reg wreg_o,

    output reg [`RegisterBus] hi_o,
    output reg [`RegisterBus] lo_o,
    output reg whilo_o

);


always @(*) begin
    if(rst == `ResetEnable) begin
        wdata_o = `ZeroWord;
        wd_o = `NOPRegisterAddress;
        wreg_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
        whilo_o = `WriteDisable;
    end
    else begin
        wdata_o = wdata_i;
        wd_o = wd_i;
        wreg_o = wreg_i;  
        
        hi_o = hi_i;
        lo_o = lo_i;
        whilo_o = whilo_i;

    end 

    
end




    
endmodule