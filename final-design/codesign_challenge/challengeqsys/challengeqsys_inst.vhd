	component challengeqsys is
		port (
			altpll_0_areset_conduit_export    : in  std_logic                     := 'X'; -- export
			altpll_0_locked_conduit_export    : out std_logic;                            -- export
			altpll_0_phasedone_conduit_export : out std_logic;                            -- export
			clk_clk                           : in  std_logic                     := 'X'; -- clk
			pio_0_external_connection_export  : out std_logic_vector(31 downto 0);        -- export
			pio_1_external_connection_export  : out std_logic_vector(31 downto 0);        -- export
			pio_2_external_connection_export  : out std_logic_vector(31 downto 0);        -- export
			reset_reset_n                     : in  std_logic                     := 'X'  -- reset_n
		);
	end component challengeqsys;

	u0 : component challengeqsys
		port map (
			altpll_0_areset_conduit_export    => CONNECTED_TO_altpll_0_areset_conduit_export,    --    altpll_0_areset_conduit.export
			altpll_0_locked_conduit_export    => CONNECTED_TO_altpll_0_locked_conduit_export,    --    altpll_0_locked_conduit.export
			altpll_0_phasedone_conduit_export => CONNECTED_TO_altpll_0_phasedone_conduit_export, -- altpll_0_phasedone_conduit.export
			clk_clk                           => CONNECTED_TO_clk_clk,                           --                        clk.clk
			pio_0_external_connection_export  => CONNECTED_TO_pio_0_external_connection_export,  --  pio_0_external_connection.export
			pio_1_external_connection_export  => CONNECTED_TO_pio_1_external_connection_export,  --  pio_1_external_connection.export
			pio_2_external_connection_export  => CONNECTED_TO_pio_2_external_connection_export,  --  pio_2_external_connection.export
			reset_reset_n                     => CONNECTED_TO_reset_reset_n                      --                      reset.reset_n
		);

