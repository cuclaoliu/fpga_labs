library ieee;
use ieee.std_logic_1164.all;

entity MyFirstNios is
port
(

	------------ CLOCK ------------
	CLOCK2_50       	:in    	std_logic;
	CLOCK3_50       	:in    	std_logic;
	CLOCK4_50       	:in    	std_logic;
	CLOCK_50        	:in    	std_logic;

	------------ KEY ------------
	KEY             	:in    	std_logic_vector(3 downto 0);

	------------ SW ------------
	SW              	:in    	std_logic_vector(9 downto 0);

	------------ LED ------------
	LEDR            	:out   	std_logic_vector(9 downto 0);

	------------ Seg7 ------------
	HEX0            	:out   	std_logic_vector(6 downto 0);
	HEX1            	:out   	std_logic_vector(6 downto 0);
	HEX2            	:out   	std_logic_vector(6 downto 0);
	HEX3            	:out   	std_logic_vector(6 downto 0);
	HEX4            	:out   	std_logic_vector(6 downto 0);
	HEX5            	:out   	std_logic_vector(6 downto 0)
);

end entity;

---------------------------------------------------------
--  Structural coding
---------------------------------------------------------

architecture rtl of MyFirstNios is
    component nios_core is
        port (
            clk_clk           : in  std_logic                    := 'X';             -- clk
            reset_reset_n     : in  std_logic                    := 'X';             -- reset_n
            pio_sw_export     : in  std_logic_vector(7 downto 0) := (others => 'X'); -- export
            pio_key_export    : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
            pio_ledr_export   : out std_logic_vector(7 downto 0);                    -- export
            pll_locked_export : out std_logic                                        -- export
        );
    end component nios_core;
begin


    u0 : component nios_core
        port map (
            clk_clk           => CLOCK_50,           --        clk.clk
            reset_reset_n     => '1',     --      reset.reset_n
            pio_sw_export     => SW(7 downto 0),     --     pio_sw.export
            pio_key_export    => KEY(3 downto 0),    --    pio_key.export
            pio_ledr_export   => LEDR(7 downto 0),   --   pio_ledr.export
            pll_locked_export => LEDR(9)  -- pll_locked.export
        );

end rtl;

