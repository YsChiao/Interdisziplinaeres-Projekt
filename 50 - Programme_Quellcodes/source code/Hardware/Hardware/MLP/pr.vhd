library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.mlp_pkg.all;
use work.float_types.all;
use work.float_constants.all;
use work.sram_dp_types.all;
use work.ann_types.all;	

LIBRARY STD;
USE std.textio.all;


entity pr is
	port (
	rst: in std_logic;
	clk: in std_logic;
	mlp_run : in std_logic;

	weight_done : in std_logic;
	mlp_mode : inout ann_mode;
	mlp_ready : in std_logic);
	
end entity pr;

architecture rtl of pr is

type states is (pr_init, pr_run, pr_idle);
signal state : states := pr_init;

begin 
	
	fsm: process(clk,rst) is
	begin
		if (rst = '1') then
			state <= pr_init;
			mlp_mode <= idle;
		elsif rising_edge(clk) then
			if(mlp_mode /= idle) then
				mlp_mode <= idle;
			elsif(mlp_ready = '0') then
			else
				case state is
					when pr_init =>
						if(weight_done ='1') then
							state <= pr_run ;
						else
							state <= pr_idle;
						end if;
						
					when pr_run =>
						if (mlp_run = '1') then
							mlp_mode <= run;
							state <= pr_idle;
						else
							mlp_mode <= idle;
							state <= pr_idle;
					    end if;
						
					when pr_idle =>
						--if(weight_done ='0') then
							if (mlp_run = '1') then
								mlp_mode <= run;
								state <= pr_idle;
								--state <= pr_run ;
							else
								mlp_mode <= idle;
								state <= pr_idle;
							end if;
						--end if;
	
					when others => 
						state <= pr_init;
					end case;
				end if;
			end if;
		end process;
end architecture rtl;
						
					
					
					
							
				
	







