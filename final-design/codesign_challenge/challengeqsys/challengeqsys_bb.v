
module challengeqsys (
	altpll_0_areset_conduit_export,
	altpll_0_locked_conduit_export,
	altpll_0_phasedone_conduit_export,
	clk_clk,
	pio_0_external_connection_export,
	pio_1_external_connection_export,
	pio_2_external_connection_export,
	reset_reset_n);	

	input		altpll_0_areset_conduit_export;
	output		altpll_0_locked_conduit_export;
	output		altpll_0_phasedone_conduit_export;
	input		clk_clk;
	output	[31:0]	pio_0_external_connection_export;
	output	[31:0]	pio_1_external_connection_export;
	output	[31:0]	pio_2_external_connection_export;
	input		reset_reset_n;
endmodule
