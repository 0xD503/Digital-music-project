module AudioCodec_tb	();
	logic	s_CLK, s_NRESET;
	logic	s_EN;
	logic	o_XCK;
	logic	io_BitSCLK;					//	BCLK
	logic	o_DAC_Data,	io_DAC_LRCK;	//	DACDAT, DACLRCK
	logic	o_SCL, io_SDA;				//	I2C Clock Wire, I2C Data Wire
	logic	o_MUTE;


	AudioCodec_Control	DUT
		(s_CLK, s_NRESET,
		s_EN,
		o_XCK, io_BitSCLK,
		o_DAC_Data,	io_DAC_LRCK,
		o_SCL, io_SDA,
		o_MUTE);

	initial
	begin
		s_CLK = 1'b0;	s_NRESET = 1'b1;
		s_EN = 1'b0;
	end

	always
	begin
		#5;	s_CLK = ~s_CLK;
	end


	initial
	begin
		#17;						s_NRESET = 1'b0;
		repeat(2) @(negedge s_CLK);	s_NRESET = 1'b1;
		#20;						s_EN = 1'b1;
		repeat(400) @(negedge s_CLK);	$stop;
	end

endmodule

