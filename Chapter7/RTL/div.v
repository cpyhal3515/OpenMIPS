//---------------------------- div.v ----------------------------//
`include "../Include/define.v"
module div (
    input clk,
    input rst,
    input annul_i,
    input start_i,
    
    input [`RegisterBus] opdata1_i, // opdata1_temp 是被除数
    input [`RegisterBus] opdata2_i, // opdata2_temp 是除数
    input signed_div_i,

    output reg [63:0] result_o,
    output reg ready_o

);

reg [1:0] div_state;
reg [31:0] opdata1_temp, opdata2_temp;
reg [31:0] divisor;
// 注意这里 dividend 的长度为 65 bit 而不是 64 bit
reg [64:0] dividend;
wire [32:0] div_temp;
reg [5:0] cnt;


// Question: 为什么要补一个 1'b0?
assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};



always @(*) begin
    if(rst == `ResetEnable) begin
        opdata1_temp <= `ZeroWord;
        opdata2_temp <= `ZeroWord;
    end
    else begin
        // 表示有符号除法
        if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1)
            opdata1_temp <= ~opdata1_i + 1'b1;
        // 表示无符号除法
        else
            opdata1_temp <= opdata1_i;
        // 表示有符号除法
        if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1)
            opdata2_temp <= ~opdata2_i + 1'b1;
        // 表示无符号除法
        else
            opdata2_temp <= opdata2_i;
    end
end


always @(posedge clk) begin
    if(rst == `ResetEnable) begin
        div_state <= `DivFree;
        result_o <= {`ZeroWord, `ZeroWord};
        ready_o <= `DivResultNotReady;
    end
    else
        case (div_state)
            `DivFree: begin
                if(start_i == `DivStop || annul_i == 1'b1) begin
                    div_state <= `DivFree;
                    result_o <= {`ZeroWord, `ZeroWord};
                    ready_o <= `DivResultNotReady;
                end
                else if(opdata2_i == `ZeroWord) begin
                    div_state <= `DivByZero;
                end
                else begin
                    cnt <= 6'd0;
                    div_state <= `DivOn;
                    dividend <= {32'd0, opdata1_temp,1'b0};
                    divisor <= opdata2_temp;
                end

            end
            
            `DivByZero: begin
                div_state <= `DivEnd;
                result_o <= {`ZeroWord, `ZeroWord};
            end

            `DivOn: begin
                if(annul_i == 1'b1) 
                    div_state <= `DivFree;
                else
                    cnt <= cnt + 1'b1;
                    if(cnt != 6'd32) begin
                        if(div_temp[32] == 1'b1) begin
                            dividend <= {dividend[63:0], 1'b0};
                        end
                        else if(div_temp[32] == 1'b0) begin
                            dividend <= {div_temp[31:0], dividend[31:0],1'b1};
                        end
                    end
                    else begin
                        // 低 32 bit 是商
                        if(signed_div_i == 1'b1 && (opdata1_i[31] ^ opdata2_i[31]) == 1'b1)
                            dividend[31:0] <= (~dividend[31:0]) + 1'b1;
                        // 高 32 bit 是余数
                        // 这里判断的是除数与余数之间的符号关系
                        if(signed_div_i == 1'b1 && (opdata1_i[31] ^ dividend[64]) == 1'b1)
                            dividend[64:33] <= (~dividend[64:33]) + 1'b1;
                       cnt <= 6'd0;
                       result_o <= dividend;
                       div_state <= `DivEnd; 
                    end

            end



            `DivEnd: begin
                // 因为 DivFree 状态一开始在 dividend 最后一位填了 0
                // 因此这里 result_o 的结果隔掉了 dividend[32]
                div_state <= `DivFree;
                if(start_i == `DivStop) begin
                    result_o <= {`ZeroWord, `ZeroWord};
                    ready_o <= `DivResultNotReady;
                end
                else begin
                    result_o <= {dividend[64:33], dividend[31:0]};
                    ready_o <= `DivResultReady;
                end
            end

            default: begin
                
            end
        endcase
end

    
endmodule