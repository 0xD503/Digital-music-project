`define DataWidth		8
`define AddressWidth	32
`define WordBuferSize	64


module ShiftRegister
	#(parameter	DataWidth		= 16)
	(input logic				i_CLK, i_NRESET,

	//	Control signals
	input logic					i_ENABLE,
	input logic					i_LOAD,

	//	Data signals
	input logic						i_SerialData,
	input logic[(DataWidth - 1):0]	i_ParallelData,

	output logic					o_SerialData,
	output logic[(DataWidth - 1):0]	o_ParallelData);

	logic[(DataWidth - 1):0]		s_ParallelData;


	always	@(posedge i_CLK, negedge i_NRESET)
	begin
		if (~i_NRESET)			s_ParallelData = 8'd0;
		else if (i_ENABLE)
		begin
			if (i_CLK)
			begin
				if (i_LOAD)		s_ParallelData <= i_ParallelData;
				else				s_ParallelData <= {s_ParallelData[((DataWidth - 1) - 1):0], i_SerialData};
			end
		end
	end

	assign o_SerialData		= s_ParallelData[DataWidth - 1];
	assign o_ParallelData	= s_ParallelData;

endmodule





module I2S_Master_Transmitter
	#(parameter	DataWidth		= 16,
					AddressWidth	= 16)
	(input logic		i_SCK, i_NRESET,

	//	Transmitter control signals
	input logic						i_ENABLE,
	input logic						i_ChannelSelect,		//	WS

	//	Master generates signals
	output logic					o_SerialData);			//	SD

	logic		s_NSCK;
	logic		s_SD;
	logic		s_WS, s_WSD, s_WSDD, s_NWSD, s_WSP;
	//logic		s_Enable;

	logic[(AddressWidth - 1):0]	s_LeftAddress, s_RightAddress;
	logic[(DataWidth - 1):0]	s_LeftData, s_RightData, s_ParallelData_in, s_ParallelData_out;


	ROM				DataLeft
		(s_NWSD,
		s_LeftAddress,
		s_LeftData);
	ROM				DataRight
		(s_WSD,
		s_RightAddress,
		s_RightData);
	ShiftRegister	ShiftReg
		(s_NSCK, i_NRESET,
		i_ENABLE, s_WSP,
		1'b0, s_ParallelData_in,
		s_SD, s_ParallelData_out);


	always_ff	@(posedge i_SCK, negedge i_NRESET)
	begin
		if (~i_NRESET)
		begin
			s_WSD <= 1'b0;
			s_WSDD <= 1'b0;
		end
		else if (i_ENABLE)
		begin
			s_WSD	<= s_WS;
			s_WSDD	<= s_WSD;
		end
	end

	//	ROM Read process
	always_ff	@(posedge i_SCK, negedge i_NRESET)
	begin
		if (~i_NRESET)
		begin
			s_LeftAddress <= 0;
			s_RightAddress <= 0;
		end
		else if (i_ENABLE)
		begin
			if (s_WSD)
			begin
				s_LeftAddress <= s_LeftAddress + 8'd1;
				s_RightAddress <= s_RightAddress;
			end
			else
			begin
				s_LeftAddress <= s_LeftAddress;
				s_RightAddress <= s_RightAddress + 8'd1;
			end
		end
	end


	assign s_NSCK		= ~i_SCK;

	assign o_SerialData	= s_SD;

	assign s_WS			= i_ChannelSelect;
	assign s_WSP		= s_WSD ^ s_WSDD;
	assign s_NWSD		= ~s_WSD;

	//assign s_Enable = 1'b1;
	assign s_ParallelData_in = s_WSD ?	s_RightData : s_LeftData;

endmodule






module I2S_Master_Receiver
	#(parameter	DataWidth		= 16,
					AddressWidth	= 8)
	(input logic			i_SCK, i_NRESET,

	//	Receiver control signals
	input logic						i_ENABLE,
	input logic						i_ChannelSelect,

	//	Data
	input logic						i_SerialData);

	logic		s_SD;
	logic		s_WS, s_WSD, s_WSDD, s_NWSD, s_WSP;
	logic		s_WEnableDataLeft, s_WEnableDataRight;

	logic						s_SerialData_out;
	logic[(DataWidth - 1):0]	s_ParallelData_in, s_ParallelData_out;
	logic[(AddressWidth - 1):0]	s_LeftAddress, s_RightAddress;
	logic[(DataWidth - 1):0]	s_Data, /*s_LeftDataWrite, */s_LeftDataRead, /*s_RightDataWrite, */s_RightDataRead;


	ShiftRegister	ShiftReg
		(i_SCK, i_NRESET,
		i_ENABLE, s_WSP,
		s_SD, s_ParallelData_in,
		s_SerialData_out, s_ParallelData_out);

	RAM				DataLeft
		(i_SCK, i_NRESET,
		i_ENABLE, s_WEnableDataLeft,
		s_LeftAddress,
		s_ParallelData_out,
		s_LeftDataRead);
	RAM				DataRight
		(i_SCK, i_NRESET,
		i_ENABLE, s_WEnableDataRight,
		s_RightAddress,
		s_ParallelData_out,
		s_RightDataRead);


	assign s_SD		= i_SerialData;

	assign s_WS		= i_ChannelSelect;
	assign s_WSP	= s_WSD ^ s_WSDD;
	assign s_NWSD	= ~s_WSD;

	assign s_WEnableDataLeft = s_NWSD & s_WSP;
	assign s_WEnableDataRight = s_WSD & s_WSP;

endmodule
