`include "../Include/define.v"
module openmips_min_sopc (
    input clk,
    input rst
);

wire [`InstAddressBus] inst_addr;
wire [`InstDataBus] inst_data;
wire inst_ce;


inst_rom inst_rom_inst0(
    .ce(inst_ce),
    .addr(inst_addr),
    .inst(inst_data)
);

openmips openmips_inst0(
    .clk(clk),
    .rst(rst),
    .rom_data_i(inst_data),
    .rom_addr_o(inst_addr),
    .rom_ce_o(inst_ce)
);

    
endmodule