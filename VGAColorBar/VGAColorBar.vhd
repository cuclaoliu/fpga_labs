library ieee;
use ieee.std_logic_1164.all;

entity VGAColorBar is
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

architecture rtl of VGAColorBar is
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
            VGA_R(7)   <= '0';
            VGA_G(7)   <= '0';
            VGA_B(7)   <= '0';
        elsif rising_edge(vga_clk_p) then
            VGA_HS <= hs;
            VGA_VS <= vs;
            VGA_BLANK_N <= blank_n;
            if hori_cnt < 80*1  then
                VGA_R(7)   <= '0';
                VGA_G(7)   <= '0';
                VGA_B(7)   <= '0';
            elsif hori_cnt < 80*2 then
                VGA_R(7)   <= '0';
                VGA_G(7)   <= '0';
                VGA_B(7)   <= '1';
            elsif hori_cnt < 80*3 then
                VGA_R(7)   <= '0';
                VGA_G(7)   <= '1';
                VGA_B(7)   <= '0';
            elsif hori_cnt < 80*4 then
                VGA_R(7)   <= '0';
                VGA_G(7)   <= '1';
                VGA_B(7)   <= '1';
            elsif hori_cnt < 80*5 then
                VGA_R(7)   <= '1';
                VGA_G(7)   <= '0';
                VGA_B(7)   <= '0';
            elsif hori_cnt < 80*6 then
                VGA_R(7)   <= '1';
                VGA_G(7)   <= '0';
                VGA_B(7)   <= '1';
            else
                VGA_R(7)   <= '1';
                VGA_G(7)   <= '1';
                VGA_B(7)   <= '1';
            end if;
        end if;
    end process;
    
    VGA_R(6 downto 0)   <= (others => '0');
    VGA_G(6 downto 0)   <= (others => '0');
    VGA_B(6 downto 0)   <= (others => '0');
end rtl;
