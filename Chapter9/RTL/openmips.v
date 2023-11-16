`include "../Include/define.v"
module openmips (
    input clk,
    input rst,
    input [`InstDataBus] rom_data_i,
    output [`InstAddressBus] rom_addr_o,
    output rom_ce_o,

    // 新增接口，连接数据存储器 RAM
    input  [`RegisterBus] ram_data_i,
    output [`RegisterBus] ram_addr_o,
    output [`RegisterBus] ram_data_o,
    output                ram_we_o,
    output [3:0]          ram_sel_o,
    output                ram_ce_o
);
    

//---------------------------- pc_reg.v ----------------------------//
wire [`InstAddressBus] pc;
wire ce;
wire branch_flag;
wire [`RegisterBus] branch_target_address;
//---------------------------- ctrl.v ----------------------------//
wire stallreq_from_id, stallreg_from_ex;
wire [5:0] stall;
//---------------------------- if_id.v ----------------------------//
wire [`InstAddressBus] id_pc_i;
wire [`InstDataBus] id_inst_i;
//---------------------------- id.v ----------------------------//
wire [`InstDataBus] id_inst_o;
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
wire [`InstDataBus] ex_inst_i;
wire next_inst_in_delayslot;
wire id_is_in_delayslot;
wire [`RegisterBus] id_link_address;
wire ex_is_in_delayslot;
wire [`RegisterBus] ex_link_address;
wire is_in_delayslot;

//---------------------------- ex.v ----------------------------//
wire [`RegisterBus] ex_wdata_o;
wire [`RegisterAddressBus] ex_wd_o;
wire ex_wreg_o;

wire [`RegisterBus] hi_i, lo_i;

wire [`RegisterBus] wb_hi_i, wb_lo_i;
wire wb_whilo_i;

wire [`RegisterBus] mem_hi_i, mem_lo_i;
wire mem_whilo_i;

wire [`RegisterBus] hi_o, lo_o;
wire whilo_o;

wire [`DoubleRegisterBus] div_result_i;
wire div_ready_i;
wire [`RegisterBus] div_opdata1_o, div_opdata2_o;
wire div_start_o, signed_div_o;

wire [`ALUOpBus] ex_aluop_o;
wire [`RegisterBus] ex_mem_addr_o;
wire [`RegisterBus] ex_reg2_o;


//---------------------------- ex_mem.v ----------------------------//
wire [`RegisterBus] mem_wdata_i;
wire [`RegisterAddressBus] mem_wd_i;
wire mem_wreg_i;

wire [`RegisterBus] mem_hi_o, mem_lo_o;
wire mem_whilo_o;

wire [1:0] cnt_i, cnt_o;
wire [`DoubleRegisterBus] hilo_temp_i, hilo_temp_o;

wire [`ALUOpBus] mem_aluop_i;
wire [`RegisterBus] mem_mem_addr_i;
wire [`RegisterBus] mem_reg2_i;
//---------------------------- mem.v ----------------------------//
wire [`RegisterBus] mem_wdata_o;
wire [`RegisterAddressBus] mem_wd_o;
wire mem_wreg_o;

wire LLbit_i;
wire LLbit_we_o, LLbit_value_o;

//---------------------------- mem_wb.v ----------------------------//
wire [`RegisterBus] wb_wdata_i;
wire [`RegisterAddressBus] wb_wd_i;
wire wb_wreg_i;

wire wb_LLbit_we, wb_LLbit_value;


// 连上指令寄存器
assign rom_addr_o = pc;
assign rom_ce_o = ce;

// CTRL 控制模块
ctrl ctrl_inst0(
    .rst(rst),
    .stallreq_from_id(stallreq_from_id),
    .stallreg_from_ex(stallreg_from_ex),
    .stall(stall)
);


// 程序计数器
pc_reg pc_reg_inst0 (
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .branch_flag_i(branch_flag),
    .branch_target_address_i(branch_target_address),
    .pc(pc),
    .ce(ce)
);


if_id if_id_inst0 (
    .clk(clk),
    .rst(rst),

    .if_pc(pc),
    .if_inst(rom_data_i),

    .stall(stall),

    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);


id id_inst0 (
    .rst(rst),
    
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),

    .reg1_data_i(reg1_data_i),
    .reg2_data_i(reg2_data_i),
    
    .mem_wdata_i(mem_wdata_o),
    .mem_wd_i(mem_wd_o),
    .mem_wreg_i(mem_wreg_o),

    .ex_wdata_i(ex_wdata_o),
    .ex_wd_i(ex_wd_o),
    .ex_wreg_i(ex_wreg_o),

    .is_in_delayslot_i(is_in_delayslot),

    .ex_aluop_i(ex_aluop_i),

    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),

    .reg1_o(id_reg1_o),
    .reg1_addr_o(reg1_addr_o),
    .reg1_read_o(reg1_read_o),

    .reg2_o(id_reg2_o),
    .reg2_addr_o(reg2_addr_o),
    .reg2_read_o(reg2_read_o),

    .stallreq(stallreq_from_id),

    .is_in_delayslot_o(id_is_in_delayslot),
    .link_addr_o(id_link_address),
    .next_inst_in_delayslot_o(next_inst_in_delayslot),
    .branch_target_address_o(branch_target_address),
    .branch_flag_o(branch_flag),

    .inst_o(id_inst_o)
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
    .id_inst(id_inst_o),

    .stall(stall),

    .id_is_in_delayslot(id_is_in_delayslot),
    .id_link_address(id_link_address),
    .next_inst_in_delayslot_i(next_inst_in_delayslot),

    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
    .ex_inst(ex_inst_i),

    .ex_is_in_delayslot(ex_is_in_delayslot),
    .ex_link_address(ex_link_address),
    .is_in_delayslot_o(is_in_delayslot)
);


ex ex_inst0 (
    .rst(rst),

    .inst_i(ex_inst_i),

    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),

    .hi_i(hi_i),
    .lo_i(lo_i),

    .wb_whilo_i(wb_whilo_i),
    .wb_hi_i(wb_hi_i),
    .wb_lo_i(wb_lo_i),

    .mem_whilo_i(mem_whilo_i),
    .mem_hi_i(mem_hi_i),
    .mem_lo_i(mem_lo_i),

    .cnt_i(cnt_i),
    .hilo_temp_i(hilo_temp_i),

    .div_result_i(div_result_i),
    .div_ready_i(div_ready_i),

    .is_in_delayslot_i(ex_is_in_delayslot),
    .link_address_i(ex_link_address),


    .wdata_o(ex_wdata_o),
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),

    .whilo_o(whilo_o),
    .hi_o(hi_o),
    .lo_o(lo_o),

    .cnt_o(cnt_o),
    .hilo_temp_o(hilo_temp_o),
    .stallreq(stallreg_from_ex),

    .div_start_o(div_start_o),
    .div_opdata1_o(div_opdata1_o),
    .div_opdata2_o(div_opdata2_o),
    .signed_div_o(signed_div_o),

    .aluop_o(ex_aluop_o),
    .mem_addr_o(ex_mem_addr_o),
    .reg2_o(ex_reg2_o)

    );

div  div_inst0 (
    .clk(clk),
    .rst(rst),
    .annul_i(1'b0),
    .start_i(div_start_o),
    .opdata1_i(div_opdata1_o), // opdata1_temp 是被除数
    .opdata2_i(div_opdata2_o), // opdata2_temp 是除数
    .signed_div_i(signed_div_o),
    .result_o(div_result_i),
    .ready_o(div_ready_i)

);



ex_mem ex_mem_inst0 (
    .clk(clk),
    .rst(rst),

    .ex_wdata(ex_wdata_o),
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),

    .ex_hi(hi_o),
    .ex_lo(lo_o),
    .ex_whilo(whilo_o),

    .ex_aluop(ex_aluop_o),
    .ex_mem_addr(ex_mem_addr_o),
    .ex_reg2(ex_reg2_o),

    .stall(stall),
    .cnt_i(cnt_o),
    .hilo_i(hilo_temp_o),

    .mem_wdata(mem_wdata_i),
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),

    .mem_hi(mem_hi_o),
    .mem_lo(mem_lo_o),
    .mem_whilo(mem_whilo_o),

    .mem_aluop(mem_aluop_i),
    .mem_mem_addr(mem_mem_addr_i),
    .mem_reg2(mem_reg2_i),

    .cnt_o(cnt_i),
    .hilo_o(hilo_temp_i)

    );



mem mem_inst0 (
    .rst(rst),

    .wdata_i(mem_wdata_i),
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .hi_i(mem_hi_o),
    .lo_i(mem_lo_o),
    .whilo_i(mem_whilo_o),

    .aluop_i(mem_aluop_i),
    .mem_addr_i(mem_mem_addr_i),
    .reg2_i(mem_reg2_i),
    // 来自数据存储器的信息
    .mem_data_i(ram_data_i),

    .LLbit_i(LLbit_i),
    .wb_LLbit_we_i(wb_LLbit_we),
    .wb_LLbit_value_i(wb_LLbit_value),


    .wdata_o(mem_wdata_o),
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .hi_o(mem_hi_i),
    .lo_o(mem_lo_i),
    .whilo_o(mem_whilo_i),

    // 送到数据存储器的信息
    .mem_addr_o(ram_addr_o),
    .mem_we_o(ram_we_o),
    .mem_sel_o(ram_sel_o),
    .mem_data_o(ram_data_o),
    .mem_ce_o(ram_ce_o),

    .LLbit_we_o(LLbit_we_o),
    .LLbit_value_o(LLbit_value_o)
);


mem_wb mem_wb_inst0 (
    .clk(clk),
    .rst(rst),

    .mem_wdata(mem_wdata_o),
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_hi(mem_hi_i),
    .mem_lo(mem_lo_i),
    .mem_whilo(mem_whilo_i),

    .mem_LLbit_we(LLbit_we_o),
    .mem_LLbit_value(LLbit_value_o),

    .wb_wdata(wb_wdata_i),
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_hi(wb_hi_i),
    .wb_lo(wb_lo_i),
    .wb_whilo(wb_whilo_i),

    .stall(stall),

    .wb_LLbit_we(wb_LLbit_we),
    .wb_LLbit_value(wb_LLbit_value)
);

LLbit LLbit_inst0(
    .clk(clk),
    .rst(rst),
    .we(wb_LLbit_we),
    .LL_bit_i(wb_LLbit_value),
    .flush(),

    .LL_bit_o(LLbit_i)
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

hilo_reg hilo_reg_inst0(
    .clk(clk),
    .rst(rst),
    .we(wb_whilo_i),
    .hi_i(wb_hi_i),
    .lo_i(wb_lo_i),

    .hi_o(hi_i),
    .lo_o(lo_i)
);


endmodule