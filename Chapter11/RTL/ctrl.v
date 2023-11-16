//---------------------------- ctrl.v ----------------------------//
// 完成 CTRL 控制模块
`include "../Include/define.v"
module ctrl (
    input rst,
    input stallreq_from_id,
    input stallreg_from_ex,

    input [31:0] excepttype_i,
    input [`RegisterBus] cp0_epc_i,

    output reg [5:0] stall,

    output reg [`RegisterBus] new_pc,
    output reg flush
);
    // 这里 stall 对应的 Stop 是 1'b1，从低位到高位分别对应
    // PC、IF/ID、ID/EX、EX/MEM、MEM/WB
    always @(*) begin
        if(rst == `ResetEnable) begin
            stall = 6'b000000;
            flush = 1'b0;
            new_pc = `ZeroWord;
        end
        else if(excepttype_i != `ZeroWord) begin
            flush = 1'b1;
            stall = 6'b000000;
            case (excepttype_i)
                32'h00000001: new_pc = 32'h00000020;
                32'h00000008: new_pc = 32'h00000040;
                32'h0000000a: new_pc = 32'h00000040;
                32'h0000000d: new_pc = 32'h00000040;
                32'h0000000c: new_pc = 32'h00000040;
                32'h0000000e: new_pc = cp0_epc_i;
                default: begin
                    
                end
            endcase
        end
        else begin
            if(stallreq_from_id) begin
                stall = 6'b000111;
                flush = 1'b0;
            end
            else if(stallreg_from_ex) begin
                stall = 6'b001111;
                flush = 1'b0;
            end
            else begin
                stall = 6'b000000;
                flush = 1'b0;
                new_pc = `ZeroWord;
            end
        end
    end





endmodule