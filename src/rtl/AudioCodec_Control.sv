module AudioCodec_Control
	(input logic		i_CLK, i_NRESET,
	input logic			i_ENABLE,

	output logic		o_XCK,				//	Master Clock
	output logic		io_BitSCLK,			//	BCLK

	output logic		o_DAC_Data,			//	DACDAT
	output logic		io_DAC_LRCK,		//	DACLRCK

	output logic		o_SCL,				//	I2C Clock Wire
	output logic		io_SDA,				//	I2C Data Wire

	output logic		o_MUTE);

	logic		s_I2S_Enabler;
	logic		s_I2C_Enabler;
	logic[15:0]	s_ClockSelect_Counter;
	logic		s_WS;


	always_ff	@(posedge i_CLK, negedge i_NRESET)
	begin
		if (~i_NRESET)		s_ClockSelect_Counter = 4'd0;
		else if (i_ENABLE)	s_ClockSelect_Counter = s_ClockSelect_Counter + 4'd1;
	end

	assign s_WS = (s_ClockSelect_Counter[3]) ?	1'b1 : 1'b0;

	//	If CLK = 50 MHz then
	//	s_ClockSelect_Counter[11]	= 390625 Hz (I2C High-speed (400 KHz))
	//	s_ClockSelect_Counter[13]	= 97656 Hz (I2C Low-speed (100 KHz))
	//	s_ClockSelect_Counter[14]	= 48828 Hz (I2C audio frequency 44.1 KHz)
	
	assign o_XCK = s_ClockSelect_Counter[14];			//	???????????
	assign io_BitSCLK = s_ClockSelect_Counter[14];	//	I2S bit stream clock == 48828 Hz (44.1 KHz)


	assign s_I2S_Enabler = 1'b1;

	I2S_Master_Transmitter		I2S_Data_Loader
		(i_CLK, i_NRESET,
		s_I2S_Enabler,
		s_WS,
		o_DAC_Data);

	assign io_DAC_LRCK = s_WS;


	assign s_I2C_Enabler = 1'b1;

	I2C_Loader	I2C_ConfigurationLoader
		(i_CLK, i_NRESET,
		s_I2C_Enabler,
		o_SCL, io_SDA);


	assign o_MUTE = 1'b1;

endmodule


module I2C_Interface_Clocker
	(input logic	i_CLK, i_NRESET,
	input logic		i_ENABLE,
	output logic	o_I2C_Enable);

	logic[8:0]						s_ClocksNum;

	always_ff	@(posedge i_CLK, negedge i_NRESET)
	begin
		if (~i_NRESET)		s_ClocksNum <= 9'd0;
		else if (i_ENABLE)
		begin
			if (s_ClocksNum == 9'd279)	s_ClocksNum <= 9'd279;
			else						s_ClocksNum <= s_ClocksNum + 9'd1;
		end
	end

	assign o_I2C_Enable = (s_ClocksNum == 9'd279) ?	1'b0 : 1'b1;

endmodule

module I2C_Loader
	#(parameter	DataWidth		= 8,
				TableDataWidth	= 8,
				AddressWidth	= 5)
	(input logic		i_CLK, i_NRESET,
	input logic			i_ENABLE,

	//	I2C Outputs
	output logic					o_SCL,
	output logic					o_SDA);

	logic							s_CLK;
	logic							s_Start, s_Stop;
	logic[(AddressWidth - 1):0]		s_TableAddress;
	logic[(DataWidth - 1):0]		s_TableData;
	logic[4:0]						s_DataPortion;
	logic							s_I2C_Enable;
	logic							s_AddrInc;


	always_ff	@(posedge i_CLK, negedge i_NRESET)
	begin
		if (~i_NRESET)
		begin
			s_DataPortion <= 5'd0;
		end
		else if (i_ENABLE)
		begin
			if (s_DataPortion == 5'd30)	s_DataPortion <= 5'd0;
			else						s_DataPortion <= s_DataPortion + 5'd1;
		end
	end

	assign s_AddrInc =	((s_DataPortion == 6'd10) |
									(s_DataPortion == 6'd19) |
									(s_DataPortion == 6'd28)) ?	1'b1 : 1'b0;

	always_ff	@(posedge s_AddrInc, negedge i_NRESET)
	begin
		if (~i_NRESET)		s_TableAddress <= 4'd0;
		else if (i_ENABLE)	s_TableAddress <= s_TableAddress + 4'd1;
	end

	I2C_Interface_Clocker	I2C_Enabler
		(i_CLK, i_NRESET,
		i_ENABLE,
		s_I2C_Enable);

	AudioCodec_Table ConfigurationalTable
		(s_TableAddress, s_TableData);


	assign s_Start = (s_DataPortion == 6'd0) ?	1'b0 : 1'b1;
	assign s_Stop = (s_DataPortion == 6'd29) ?	1'b1 : 1'b0;

	I2C_Master I2C_Master_Instance
		(i_CLK, i_NRESET,
		s_I2C_Enable,
		s_Start, s_Stop,
		7'b0011010, 1'b0,
		s_TableData,
		o_SCL, o_SDA);

endmodule


module AudioCodec_Table
	#(parameter	AddressWidth	= 5,
				DataWidth		= 8)
	(input logic[(AddressWidth - 1):0]	i_Address,
	output logic[(DataWidth - 1):0]		o_Data);


	always_comb
	begin
		case (i_Address)
		5'd1:		o_Data = 8'h1E;				//	Audiocodec register address
		5'd2:		o_Data = 8'b00000000;		//	Software reset

		5'd4:	o_Data = 8'h04;				//	Audiocodec register address
		5'd5:		o_Data = 8'b01111111;		//	+6 dB	Left Channel DAC Volume

		5'd7:		o_Data = 8'h06;				//	Audiocodec register address
		5'd8:		o_Data = 8'b01111111;		//	+6 dB	Right Channel DAC Volume

		5'd10:		o_Data = 8'h08;				//	Audiocodec register address
		5'd11:		o_Data = 8'b00010000;		//	Sidetone disable, DAC selected, Bypass disabled, etc

		5'd13:	o_Data = 8'h0A;				//	Audiocodec register address
		5'd14:		o_Data = 8'b00000100;		//	No MUTE, 44.1 kHz

		5'd16:		o_Data = 8'h0C;				//	Audiocodec register address
		5'd17:	o_Data = 8'b00000111;		//	Power-down ADC, Microphone, LineIn

		5'd19:		o_Data = 8'h0E;				//	Audiocodec register address
		5'd20:	o_Data = 8'b00000010;		//	Normal mope operation, Slave Mode, Data-word length = 16 bits, I2S Interface mode

		5'd22:		o_Data = 8'h10;				//	Audiocodec register address
		5'd23:		o_Data = 8'b0x100000;		//(1010 or 1000)//	Core clock, Core CLK = MCLK, BCLK = (MCLK / 4), 256 fs based clock, normal mode (not USB) 

		5'd25:		o_Data = 8'h12;				//	Audiocodec register address
		5'd26:		o_Data = 8'b00000001;		//	Activate digital core

		default:	o_Data = 8'hFF;
		endcase
	end

endmodule

