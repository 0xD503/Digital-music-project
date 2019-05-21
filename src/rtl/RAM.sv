module RAM
	#(parameter	DataWidth		= 8,
				AddressWidth	= 8,
				BuferSize		= 256)
	(input logic		i_CLK, i_NRESET,
	input logic			i_ENABLE,

	//	Control
	input logic			i_WE,

	input logic[(AddressWidth - 1):0]	i_Address,
	input logic[(DataWidth - 1):0]		i_WriteData,
	output logic[(DataWidth - 1):0]		o_ReadData);

	logic[(DataWidth - 1):0]	s_Data[(BuferSize - 1):0];


	always	@(posedge i_CLK)//, negedge i_NRESET)
	begin
		//if (~i_NRESET)
		//else				
		if (i_ENABLE)
			if (i_WE)	s_Data[i_Address] = i_WriteData;
	end

	assign o_ReadData = s_Data[i_Address];

endmodule
