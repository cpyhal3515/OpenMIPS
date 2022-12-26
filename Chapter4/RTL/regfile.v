//---------------------------- regfile.v ----------------------------//
// General-purpose registers, including write and read
`include "../Include/define.v"
module regfile (
    input clk,
    input rst,

    input re1,
    input [`RegisterAddressBus] raddr1,
    input re2,
    input [`RegisterAddressBus] raddr2,

    input we,
    input [`RegisterAddressBus] waddr,
    input [`RegisterBus] wdata,

    output reg [`RegisterBus] rdata1,
    output reg [`RegisterBus] rdata2

);


//------------------------------------------------------------------//
// Define General-purpose registers, 32 numbers x 32 bits
reg [`RegisterBus] InstMemory [0:`RegisterNum-1];

//------------------------------------------------------------------//
// Completes the operation written to the register

// Question: Why write process uses timing logic but read process uses combinatorial logic?
// Answer: The read register is combinatorial logic that ensures when addr1 or addr2 changes
//         the output data also changes immediately for the decoding stage.
always@(posedge clk) begin 
    // Note here General-purpose registers $0 is not used, don't write
    if(rst == `ResetDisable && we == `WriteEnable && waddr != `RegisterNumLog2'h0)
        InstMemory[waddr] = wdata; 
end

//------------------------------------------------------------------//
// Completes the operation read register1
always@(*) begin
    if(rst == `ResetEnable || re1 == `ReadDisable || raddr1 == `RegisterNumLog2'h0)
        rdata1 = `ZeroWord;
    else begin
        if(waddr == raddr1 && we == `WriteEnable)
            rdata1 = wdata;
        else
            rdata1 = InstMemory[raddr1];
    end
end

//------------------------------------------------------------------//
// Completes the operation read register2
always@(*) begin
    if(rst == `ResetEnable || re2 == `ReadDisable || raddr2 == `RegisterNumLog2'h0)
        rdata2 = `ZeroWord;
    else begin
        if(waddr == raddr2 && we == `WriteEnable)
            rdata2 = wdata;
        else
            rdata2 = InstMemory[raddr2];
    end
end

endmodule