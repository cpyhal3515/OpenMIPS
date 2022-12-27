//---------------------------- openmips.v ----------------------------//
// openmips 的顶层连接文件
`include "../Include/define.v"
module openmips (
    input clk,
    input rst,
    input [`InstDataBus] rom_data_i,

    output [`InstAddressBus] rom_addr_o,
    output rom_ce_o
);
    

//---------------------------- pc_reg.v ----------------------------//
wire [`InstAddressBus] pc;
wire ce;
//---------------------------- if_id.v ----------------------------//
wire [`InstAddressBus] id_pc_i;
wire [`InstDataBus] id_inst_i;
//---------------------------- id.v ----------------------------//
wire [`ALUOpBus] id_aluop_o;
wire [`ALUSelBus] id_alusel_o;

wire [`RegisterAddressBus] id_wd_o;
wire id_wreg_o;

wire [`RegisterBus] id_reg1_o;

wire [`RegisterBus] id_reg2_o;

wire [`RegisterAddressBus] reg1_addr_o, reg2_addr_o;
wire reg1_read_o, reg2_read_o;

wire [`RegisterBus] reg1_data_i, reg2_data_i;


//---------------------------- id_ex.v ----------------------------//
wire [`ALUOpBus] ex_aluop_i;
wire [`ALUSelBus] ex_alusel_i;
wire [`RegisterBus] ex_reg1_i;
wire [`RegisterBus] ex_reg2_i;
wire [`RegisterAddressBus]  ex_wd_i;
wire ex_wreg_i;

//---------------------------- ex.v ----------------------------//
wire [`RegisterBus] ex_wdata_o;
wire [`RegisterAddressBus] ex_wd_o;
wire ex_wreg_o;
//---------------------------- ex_mem.v ----------------------------//
wire [`RegisterBus] mem_wdata_i;
wire [`RegisterAddressBus] mem_wd_i;
wire mem_wreg_i;
//---------------------------- mem.v ----------------------------//
wire [`RegisterBus] mem_wdata_o;
wire [`RegisterAddressBus] mem_wd_o;
wire mem_wreg_o;
//---------------------------- mem_wb.v ----------------------------//
wire [`RegisterBus] wb_wdata_i;
wire [`RegisterAddressBus] wb_wd_i;
wire wb_wreg_i;


// 连上指令寄存器
assign rom_addr_o = pc;
assign rom_ce_o = ce;

// pc_reg 模块的例化
pc_reg pc_reg_inst0 (
    .clk(clk),
    .rst(rst),

    .pc(pc),
    .ce(ce)
);

// IF/ID 模块的例化
if_id if_id_inst0 (
    .clk(clk),
    .rst(rst),

    .if_pc(pc),
    .if_inst(rom_data_i),

    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

// 译码阶段 ID 模块例化
id id_inst0 (
    .rst(rst),
    
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),


    // 来自 regfile 模块的输入
    .reg1_data_i(reg1_data_i),
    .reg2_data_i(reg2_data_i),
    
    // 送到 ID/EX 模块的信息
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),


    // 送到 regfile 模块的信息
    .reg1_addr_o(reg1_addr_o),
    .reg1_read_o(reg1_read_o),

    .reg2_addr_o(reg2_addr_o),
    .reg2_read_o(reg2_read_o)
);

// ID/EX 模块例化
id_ex id_ex_inst0 (
    .clk(clk),
    .rst(rst),
    // 从译码阶段 ID 模块传递过来的信息
    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),

    // 传递到执行阶段 EX 模块的信息
    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i)
);

// EX 模块例化
ex ex_inst0 (
    .rst(rst),
    // 从 ID/EX 模块传递过来的信息
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),
    // 输出到 EX/MEM 模块的信息
    .wdata_o(ex_wdata_o),
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o)
    );

// EX/MEM 模块例化
ex_mem ex_mem_inst0 (
    .clk(clk),
    .rst(rst),

    // 来自执行阶段 EX 模块的信息
    .ex_wdata(ex_wdata_o),
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),

    // 送到访存阶段 MEM 模块的信息
    .mem_wdata(mem_wdata_i),
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i)
    );

// MEM 模块例化
mem mem_inst0 (
    .rst(rst),

    // 来自 EX/MEM 模块的信息
    .wdata_i(mem_wdata_i),
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    // 送到 MEM/WB 模块的信息
    .wdata_o(mem_wdata_o),
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o)
);

// MEM/WB 模块例化
mem_wb mem_wb_inst0 (
    .clk(clk),
    .rst(rst),
    
    // 来自访存阶段 MEM 模块的信息
    .mem_wdata(mem_wdata_o),
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    // 送到回写阶段的信息
    .wb_wdata(wb_wdata_i),
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i)
);

// 通用寄存器 Regfile 模块例化
regfile regfile_inst0 (
    .clk(clk),
    .rst(rst),

    .re1(reg1_read_o),
    .raddr1(reg1_addr_o),
    .re2(reg2_read_o),
    .raddr2(reg2_addr_o),

    .we(wb_wreg_i),
    .waddr(wb_wd_i),
    .wdata(wb_wdata_i),

    .rdata1(reg1_data_i),
    .rdata2(reg2_data_i)
);


endmodule