//---------------------------- id_ex.v ----------------------------//
// Perform calculations according to instructions
// first calculate results and then select which one as output
`include "../Include/define.v"
module ex (

    input rst,
    input [`ALUOpBus] aluop_i,
    input [`ALUSelBus] alusel_i,
    input [`RegisterBus] reg1_i,
    input [`RegisterBus] reg2_i,
    input [`RegisterAddressBus] wd_i,
    input wreg_i,

    output reg [`RegisterBus] wdata_o,
    output [`RegisterAddressBus] wd_o,
    output wreg_o


);

    assign wreg_o = wreg_i;
    assign wd_o = wd_i;

    reg [`RegisterBus] logic_calu;

    always@(*) begin
        if(rst == `ResetEnable)
            logic_calu = `ZeroWord;
        else
            case (aluop_i)
                `EXE_OR_OP: logic_calu = reg1_i | reg2_i;
                default: logic_calu = `ZeroWord;
            endcase
    end

    always@(*) begin
        if(rst == `ResetEnable)
            wdata_o = `ZeroWord;
        else
            case (alusel_i)
                `EXE_RES_LOGIC: wdata_o = logic_calu;
                default: wdata_o = `ZeroWord;
            endcase
    end

    
endmodule