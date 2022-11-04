library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity vga_sync_generator is
    port(
        clrn    :   in      std_logic;
        clk     :   in      std_logic;
        blank_n :   out     std_logic;
        hori_cnt:   out     integer range 0 to 1023;
        vert_cnt:   out     integer range 0 to 1023;
        HS      :   out     std_logic;
        VS      :   out     std_logic
    );
end entity;

--VGA Timing
--Horizontal :
--                ______________                 _____________
--               |              |               |
--_______________|  VIDEO       |_______________|  VIDEO (next line)

--___________   _____________________   ______________________
--           |_|                     |_|
--            B <-C-><----D----><-E->
--           <------------A--------->
--The Unit used below are pixels;  
--  B->Sync_cycle                   :H_sync_cycle
--  C->Back_porch                   :hori_back
--  D->Visable Area
--  E->Front porch                  :hori_front
--  A->horizontal line total length :hori_line
--Vertical :
--               ______________                 _____________
--              |              |               |          
--______________|  VIDEO       |_______________|  VIDEO (next frame)
--
--__________   _____________________   ______________________
--          |_|                     |_|
--           P <-Q-><----R----><-S->
--          <-----------O---------->
--The Unit used below are horizontal lines;  
--  P->Sync_cycle                   :V_sync_cycle
--  Q->Back_porch                   :vert_back
--  R->Visable Area
--  S->Front porch                  :vert_front
--  O->vertical line total length :vert_line

architecture rtl of vga_sync_generator is
    --parameters
    constant hori_line          :   integer range 0 to 1023     := 800;
    constant hori_back          :   integer range 0 to 1023     := 144;
    constant hori_front         :   integer range 0 to 1023     := 16;
    constant vert_line          :   integer range 0 to 1023     := 525;
    constant vert_back          :   integer range 0 to 1023     := 34;
    constant vert_front         :   integer range 0 to 1023     := 11;
    constant H_sync_cycle       :   integer range 0 to 1023     := 96;
    constant V_sync_cycle       :   integer range 0 to 1023     := 2;

    signal  h_cnt               :   integer range 0 to 1023     := 0;
    signal  v_cnt               :   integer range 0 to 1023     := 0;
    signal  cHD,cVD,cDEN        :   std_logic                   := '0';
    signal  hori_valid          :   std_logic                   := '0';
    signal  vert_valid          :   std_logic                   := '0';
begin
    timing: process(clk, clrn)
    begin
        if clrn = '0' then
            h_cnt <= 0;
            v_cnt <= 0;
        elsif rising_edge(clk) then
            if h_cnt < hori_line-1 then
                h_cnt <= h_cnt + 1;
            else
                h_cnt <= 0;
                if v_cnt < vert_line-1 then
                    v_cnt <= v_cnt + 1;
                else
                    v_cnt <= 0;
                end if;
            end if;
        end if;
    end process;
    
    cHD <= '0' when h_cnt < H_sync_cycle else '1';
    cVD <= '0' when v_cnt < V_sync_cycle else '1';

    hori_valid <= '1' when (h_cnt<(hori_line-hori_front)) and (h_cnt>=hori_back) else '0';
    vert_valid <= '1' when (v_cnt<(vert_line-vert_front)) and (v_cnt>=vert_back) else '0';

    cDEN <= hori_valid and vert_valid;

    hori_cnt <= h_cnt - hori_back;
    vert_cnt <= v_cnt - vert_back;

    output: process(clk, clrn)
    begin
        if clrn = '0' then
            HS <= '0';
            VS <= '0';
            blank_n <= '0';
        elsif rising_edge(clk) then
            HS <= cHD;
            VS <= cVD;
            blank_n <= cDEN;
        end if;
    end process;

end rtl;