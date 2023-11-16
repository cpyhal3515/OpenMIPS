//---------------------------- cp0_reg.v ----------------------------//
`include "../Include/define.v"
module cp0_reg (
    
    input clk,
    input rst,

    input we_i,
    input [4:0] waddr_i,
    input [`RegisterBus] data_i,
    input [5:0] int_i,

    input [4:0] raddr_i,
    
    output reg [`RegisterBus] data_o,
    output reg [`RegisterBus] count_o,
    output reg [`RegisterBus] compare_o,
    output reg [`RegisterBus] status_o,
    output reg [`RegisterBus] cause_o,
    output reg [`RegisterBus] epc_o,
    output reg [`RegisterBus] config_o,
    output reg [`RegisterBus] prid_o,
    output reg  timer_int_o

);

always @(posedge clk) begin
    if(rst == `ResetEnable) begin
        count_o <= `ZeroWord;
        compare_o <= `ZeroWord;
        // CU 字段为 4'b0001，表示协处理器 CP0 存在
        status_o <= {4'b0001, 28'd0};
        cause_o <= `ZeroWord;
        epc_o <= `ZeroWord;
        // BE 字段为 1，表示工作在大端模式 MSB
        config_o <= {16'd0, 1'b1, 15'd0};
        // 制作者 L，对应 0x48（自行定义）
        // 类型 0x1 表示基本类型
        // 版本号 1.0
        prid_o <= {8'd0, 8'h48, 10'd1, 6'b000010};
        timer_int_o <= `InterruptNotAssert;
    end
    else begin
        // 计数器开始进行计数
        count_o <= count_o + 1'b1;

        // cause 的 10-15 bit 保存外部中断声明
        // 把外部中断写在 if(we_i == `WriteEnable)
        // 是因为外部中断不由 we_i 的值是否有效控制
        cause_o[15:10] <= int_i;
        
        // 进行计数结果比较，当计数值到达时触发中断
        if(compare_o != `ZeroWord && compare_o == count_o)
            timer_int_o <= `InterruptAssert;
        
        if(we_i == `WriteEnable) begin
            case (waddr_i)
                `CP0_REG_COUNT:     count_o <= data_i;
                `CP0_REG_COMPARE: begin
                    compare_o <= data_i;
                    timer_int_o <= `InterruptNotAssert;
                end
                `CP0_REG_STATUS:    status_o <= data_i;
                `CP0_REG_CAUSE:  begin
                    // cause 寄存器只有 IP[1:0] IV WP 字段是可写的
                    cause_o[23]    <= data_i[23];
                    cause_o[22]   <= data_i[22];
                    cause_o[9:8]   <= data_i[9:8];
                end   
                `CP0_REG_EPC:       epc_o <= data_i;
                
                default: begin
                end
            endcase
        end

    end

end



always @(*) begin
    if(rst == `ResetEnable)
        data_o = `ZeroWord;
    else begin
        case (raddr_i)
            `CP0_REG_COUNT:     data_o <= count_o;
            `CP0_REG_COMPARE:   data_o <= compare_o;
            `CP0_REG_STATUS:    data_o <= status_o;
            `CP0_REG_CAUSE:     data_o <= cause_o;
            `CP0_REG_EPC:       data_o <= epc_o;
            `CP0_REG_PRId:      data_o <= prid_o;
            `CP0_REG_CONFIG:    data_o <= config_o;
            default: begin
            end
        endcase
    end
end
 
endmodule