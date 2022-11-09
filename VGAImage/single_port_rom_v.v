module single_port_rom_v
#(	parameter 		DATA_WIDTH	=	8, 
	parameter		ROM_DEPTH   =  	256,
    parameter		MIF         = 	"",
	parameter		ADDR_WIDTH	=	8)
(
	input [(ADDR_WIDTH-1):0] addr,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q
);

	reg [DATA_WIDTH-1:0] rom[0:ROM_DEPTH-1];

	initial
	begin
		$readmemh(MIF, rom, 0, ROM_DEPTH-1);
	end

	always @ (posedge clk)
	begin
		q <= rom[addr];
	end

endmodule
