module I2C_Loader_tb	();
	logic	s_CLK, s_NRESET, s_EN;
	logic	s_SCL, s_SDA;
	
	int clocksNum;


	I2C_Loader	DUT
		(s_CLK, s_NRESET,
		s_EN,
		s_SCL, s_SDA);


	initial
	begin
		s_CLK = 1'b0;
		s_NRESET = 1'b1;
		s_EN = 1'b0;
	end

	always
	begin
		#5;	s_CLK = ~s_CLK;
	end
	
	always	@(posedge s_CLK, negedge s_NRESET)
	begin
		if (~s_NRESET)	clocksNum = 0;
		else if (s_EN)	clocksNum = clocksNum + 1;
	end

	initial
	begin
		#17;							s_NRESET = 1'b0;
		repeat(2)	@(negedge s_CLK);	s_NRESET = 1'b1;
		@(negedge s_CLK);				s_EN = 1'b1;
		repeat(340)	@(negedge s_CLK);	$stop;
	end

endmodule
