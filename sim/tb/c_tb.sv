module c_tb	();
	logic		s_CLK, s_NRESET;
	logic[15:0]	s_Count;


	CountClock	Counter
		(s_CLK, s_NRESET,
		s_Count);


	initial
	begin
		s_CLK = 1'b0;	s_NRESET = 1'b1;
	end

	always
	begin
		#5;	s_CLK = ~s_CLK;
	end

	initial
	begin
		#16;	@(negedge s_CLK);
		s_NRESET = 1'b0;	repeat(2) @(negedge s_CLK);	s_NRESET = 1'b1;
		repeat(15) @(negedge s_CLK);
	end

endmodule
