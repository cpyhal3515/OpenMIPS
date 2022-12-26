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


pc_reg pc_reg_inst0 (
    .clk(clk),
    .rst(rst),

    .pc(pc),
    .ce(ce)
);


if_id if_id_inst0 (
    .clk(clk),
    .rst(rst),

    .if_pc(pc),
    .if_inst(rom_data_i),

    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);


id id_inst0 (
    .rst(rst),
    
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),



    .reg1_data_i(reg1_data_i),
    .reg2_data_i(reg2_data_i),
    
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),

    .reg1_o(id_reg1_o),
    .reg1_addr_o(reg1_addr_o),
    .reg1_read_o(reg1_read_o),

    .reg2_o(id_reg2_o),
    .reg2_addr_o(reg2_addr_o),
    .reg2_read_o(reg2_read_o)
);


id_ex id_ex_inst0 (
    .clk(clk),
    .rst(rst),

    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),


    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i)
);


ex ex_inst0 (
    .rst(rst),

    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),

    .wdata_o(ex_wdata_o),
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o)
    );


ex_mem ex_mem_inst0 (
    .clk(clk),
    .rst(rst),

    .ex_wdata(ex_wdata_o),
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),

    .mem_wdata(mem_wdata_i),
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i)
    );


mem mem_inst0 (
    .rst(rst),

    .wdata_i(mem_wdata_i),
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),


    .wdata_o(mem_wdata_o),
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o)
);


mem_wb mem_wb_inst0 (
    .clk(clk),
    .rst(rst),

    .mem_wdata(mem_wdata_o),
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),


    .wb_wdata(wb_wdata_i),
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i)
);


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