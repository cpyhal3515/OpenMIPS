//---------------------------- ctrl.v ----------------------------//
// 完成 CTRL 控制模块
`include "../Include/define.v"
module ctrl (
    input rst,
    input stallreq_from_id,
    input stallreg_from_ex,
    output reg [5:0] stall
);
    // 这里 stall 对应的 Stop 是 1'b1，从低位到高位分别对应
    // PC、IF/ID、ID/EX、EX/MEM、MEM/WB
    always @(*) begin
        if(rst == `ResetEnable)
            stall = 6'b000000;
        else begin
            if(stallreq_from_id)
                stall = 6'b000111;
            else if(stallreg_from_ex)
                stall = 6'b001111;
            else
                stall = 6'b000000;
        end
    end





endmodule