library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity single_port_rom is
	generic (
		DATA_WIDTH : natural := 8;
		ROM_DEPTH : natural := 256;
		MIF : string
	);
	port 
	(
		clk		: in std_logic;
		addr	: in natural range 0 to ROM_DEPTH - 1;
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end entity;

architecture rtl of single_port_rom is

	subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
	type memory_t is array(ROM_DEPTH-1 downto 0) of word_t;

	impure function init_rom_hex(filename : in string) return memory_t is
		file text_file : text open read_mode is filename;
		variable text_line : line;
		variable ram_content : memory_t;
	begin
	  	for i in 0 to ROM_DEPTH - 1 loop
			readline(text_file, text_line);
			hread(text_line, ram_content(i));
		end loop;
	  	return ram_content;
	end function;
	signal rom : memory_t := init_rom_hex(MIF);

begin

	process(clk)
	begin
		if rising_edge(clk) then
			q <= rom(addr);
		end if;
	end process;

end rtl;
