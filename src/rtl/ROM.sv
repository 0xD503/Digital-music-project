module ROM
	#(parameter	AddressWidth		= 16,
				WordWidth			= 16,
				MemorySize			= 256,
				I2C_DeviceAddress	= 8'h77)
	//(input logic						i_CLK, i_RESET,
	(input logic						i_ENABLE,
	input logic[(AddressWidth - 1):0]	i_Address,
	output logic[(WordWidth - 1):0]						o_Data);

	logic[(WordWidth - 1):0]	ROM_Array[MemorySize];


	//initial		$readmemh("Music.dat", ROM_Array);
	initial		$readmemh("/home/d503/Documents/Electronics/Digital design/Quartus/Digital Music/Music.dat", ROM_Array);
	//initial		$readmemh("/home/d503/Documents/Electronics/Digital design/Quartus/Digital Music/8k16bitpcm128kbps.wav", ROM_Array);

	assign o_Data =	i_ENABLE ?	ROM_Array[i_Address] : 16'd0;

endmodule
