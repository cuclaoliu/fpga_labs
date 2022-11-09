library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VGAImage is
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
	HEX5            	:out   	std_logic_vector(6 downto 0);

	----------- Video-In -------------
	TD_RESET_N          :   out     std_logic;    
	TD_CLK27            :   in      std_logic;    
	TD_DATA             :   in      std_logic_vector(7 downto 0);
	TD_HS               :   in      std_logic;
	TD_VS               :   in      std_logic;

	------------ VGA -----------------
	VGA_CLK             :   out     std_logic;
	VGA_HS              :   out     std_logic;
	VGA_VS              :   out     std_logic;
	VGA_BLANK_N         :   out     std_logic;    
	VGA_SYNC_N          :   out     std_logic;    
	VGA_R               :   out     std_logic_vector(7 downto 0);
	VGA_G               :   out     std_logic_vector(7 downto 0);
	VGA_B               :   out     std_logic_vector(7 downto 0);

	------------- Audio ---------------
	AUD_ADCDAT          :   in          std_logic;
	AUD_DACDAT          :   out         std_logic;
	AUD_XCK             :   out         std_logic;
	AUD_ADCLRCK         :   inout       std_logic;
	AUD_BCLK            :   inout       std_logic;
	AUD_DACLRCK         :   inout       std_logic;

	-------------- ADC --------------
	ADC_DOUT            :   in      std_logic;
	ADC_CONVST          :   out     std_logic;
	ADC_DIN             :   out     std_logic;
	ADC_SCLK            :   out     std_logic;

	--------------- SDRAM -------------
	DRAM_ADDR               :   out     std_logic_vector(12 downto 0);
	DRAM_BA                 :   out     std_logic_vector(1 downto 0);
	DRAM_CAS_N              :   out     std_logic;
	DRAM_CKE                :   out     std_logic;
	DRAM_CLK                :   out     std_logic;
	DRAM_CS_N               :   out     std_logic;
	DRAM_LDQM               :   out     std_logic;
	DRAM_RAS_N              :   out     std_logic;
	DRAM_UDQM               :   out     std_logic;
	DRAM_WE_N               :   out     std_logic;
	DRAM_DQ                 :   inout   std_logic_vector(15 downto 0);

	-------- I2C for Audio and Video-In -----------
	FPGA_I2C_SCLK       : out       std_logic;
	FPGA_I2C_SDAT       : inout     std_logic
);

end entity;

---------------------------------------------------------
--  Structural coding
---------------------------------------------------------

architecture rtl of VGAImage is
    constant    ROM_ADDR_WIDTH :    integer := 19;
    component vga_pll is
        port (
            refclk   : in  std_logic := '0'; --  refclk.clk
            rst      : in  std_logic := '0'; --   reset.reset
            outclk_0 : out std_logic;        -- outclk0.clk
            outclk_1 : out std_logic;        -- outclk1.clk
            locked   : out std_logic         --  locked.export
        );
    end component vga_pll;
    component vga_sync_generator is
        port(
            clrn    :   in      std_logic;
            clk     :   in      std_logic;
            blank_n :   out     std_logic;
            hori_cnt:   out     integer range 0 to 1023;
            vert_cnt:   out     integer range 0 to 1023;
            HS      :   out     std_logic;
            VS      :   out     std_logic
        );
    end component;
    signal      vga_clk_p   :   std_logic;
    signal      clrn   :   std_logic;
    signal      hs, vs      :   std_logic;
    signal      blank_n     :   std_logic;
    signal      hori_cnt    :   integer range 0 to 1023;
    signal      vert_cnt    :   integer range 0 to 1023;

    component single_port_rom_v is
        generic (
            DATA_WIDTH : natural := 8;
            ROM_DEPTH : natural := 256;
            MIF : string;
            ADDR_WIDTH : natural
        );
        port 
        (
            clk		: in std_logic;
            addr	: in std_logic_vector((ADDR_WIDTH-1) downto 0);
            q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    --component single_port_rom is
    --    generic (
    --        DATA_WIDTH : natural := 8;
    --        ROM_DEPTH : natural := 256;
    --        MIF : string
    --    );
    --    port 
    --    (
    --        clk		: in std_logic;
    --        addr	: in natural range 0 to ROM_DEPTH - 1;
    --        q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
    --    );
    
    end component;
    signal      image_addr  :   integer range 0 to 480*640-1;
    signal      rgb_index   :   std_logic_vector(7 downto 0);
    signal      rgb_raw     :   std_logic_vector(23 downto 0);
begin

    clrn    <=      KEY(0);
    pll_inst : component vga_pll
        port map(
            refclk      =>  CLOCK_50,
            outclk_0    =>  vga_clk_p,
            outclk_1    =>  VGA_CLK,
            locked      =>  LEDR(9)
        );
    
    vga_sync_gen : component vga_sync_generator
        port map (
            clrn           =>   clrn,
            clk            =>   vga_clk_p,
            blank_n        =>   blank_n,
            hori_cnt       =>   hori_cnt,
            vert_cnt       =>   vert_cnt,
            HS             =>   hs,
            VS             =>   vs
        );

    output: process(vga_clk_p, clrn)
    begin
        if clrn = '0' then
            VGA_HS <= '0';
            VGA_VS <= '0';
            VGA_BLANK_N <= '0';
        elsif rising_edge(vga_clk_p) then
            VGA_HS <= hs;
            VGA_VS <= vs;
            VGA_BLANK_N <= blank_n;
        end if;
    end process;
    
    process(vga_clk_p, clrn)
    begin
        if clrn = '0' then
            image_addr <= 0;
        elsif rising_edge(vga_clk_p) then
            if  hs='0' and vs='0' then
                image_addr <= 0;
            elsif blank_n = '1' then
                image_addr <= image_addr + 1;
            end if;
        end if;
    end process;
    
    image_index_inst : component single_port_rom_v
        generic map(
            DATA_WIDTH  =>  8,
            ROM_DEPTH   =>  480*640,
            MIF         =>  "image_index.mif",
            ADDR_WIDTH  =>  ROM_ADDR_WIDTH
        )
        port map(
            clk         =>  vga_clk_p,
            addr        =>  std_logic_vector(to_unsigned(image_addr, ROM_ADDR_WIDTH)),
            q           =>  rgb_index
        );
    --image_index_inst : component single_port_rom
    --    generic map(
    --        DATA_WIDTH  =>  8,
    --        ROM_DEPTH   =>  480*640,
    --        MIF         =>  "image_index.mif"
    --    )
    --    port map(
    --        clk         =>  vga_clk_p,
    --        addr        =>  image_addr,
    --        q           =>  rgb_index
    --    );

    image_map_inst : component single_port_rom_v
        generic map(
            DATA_WIDTH  =>  24,
            ROM_DEPTH   =>  256,
            MIF         =>  "image_map.mif",
            ADDR_WIDTH  =>  8
        )
        port map(
            clk         =>  vga_clk_p,
            addr        =>  rgb_index,
            q           =>  rgb_raw
        );
    --image_map_inst : component single_port_rom
    --    generic map(
    --        DATA_WIDTH  =>  24,
    --        ROM_DEPTH   =>  256,
    --        MIF         =>  "image_map.mif"
    --    )
    --    port map(
    --        clk         =>  vga_clk_p,
    --        addr        =>  to_integer(unsigned(rgb_index)),
    --        q           =>  rgb_raw
    --    );

    VGA_R <= rgb_raw(23 downto 16);
    VGA_G <= rgb_raw(15 downto 8);
    VGA_B <= rgb_raw(7 downto 0);
end rtl;
