`include "../Include/define.v"
module openmips_min_sopc (
    input clk,
    input rst
);

wire [`InstAddressBus] inst_addr;
wire [`InstDataBus] inst_data;
wire inst_ce;

wire data_ram_ce;
wire data_ram_we;
wire [`DataBus] data_ram_data_i;
wire [`DataAddressBus] data_ram_addr;
wire [3:0] data_ram_sel;
wire [`DataBus] data_ram_data_o;


inst_rom inst_rom_inst0(
    .ce(inst_ce),
    .addr(inst_addr),
    .inst(inst_data)
);

data_ram data_ram_inst0(
    .clk(clk),
    .ce(data_ram_ce),
    .we(data_ram_we),
    .data_i(data_ram_data_o),
    .addr(data_ram_addr),
    .sel(data_ram_sel),
    .data_o(data_ram_data_i)




);

wire [5:0] int;
wire timer_int;
assign int = {5'b00000, timer_int};
openmips openmips_inst0(
    .clk(clk),
    .rst(rst),
    .rom_data_i(inst_data),
    .rom_addr_o(inst_addr),
    .rom_ce_o(inst_ce),

    .int_i(int),

    .ram_data_i(data_ram_data_i),
    .ram_addr_o(data_ram_addr),
    .ram_data_o(data_ram_data_o),
    .ram_we_o(data_ram_we),
    .ram_sel_o(data_ram_sel),
    .ram_ce_o(data_ram_ce),

    .timer_int_o(timer_int)
);

    
endmodule