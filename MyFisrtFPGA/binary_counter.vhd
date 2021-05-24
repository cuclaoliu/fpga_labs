library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_counter is
	port
	(
		clk		  : in std_logic;
		reset	  : in std_logic;
		q		  : out integer range 0 to 2**25-1
	);

end entity;

architecture rtl of binary_counter is
begin
	process (clk)
		variable   cnt		   : integer range 0 to 2**25-1;
	begin
		if (rising_edge(clk)) then

			if reset = '1' then
				cnt := 0;
			else
				cnt := cnt + 1;
			end if;
		end if;
		q <= cnt;
	end process;
end rtl;