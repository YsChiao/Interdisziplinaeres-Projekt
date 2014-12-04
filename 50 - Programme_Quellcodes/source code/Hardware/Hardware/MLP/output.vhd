library ieee; 
use ieee.std_logic_1164.all;	
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work; 
use work.all;
use work.mlp_pkg.all; 
use work.float_types.all; 

LIBRARY STD;
USE std.textio.all;
 

entity output is 
	port(	clk : in std_logic;
			rst : in std_logic;
			mlp_done : in std_logic;
			DataIn : in  float_vector(N_O -1 downto 0);
			
			output_new : OUT std_logic;
			DataOut  : out std_logic_vector(7 downto 0);
			output_done : out std_logic
			
		);
end output;

architecture rtl of output is 

signal k : integer;
signal dat_reg : std_logic_vector(31 downto 0);


type states is (load, output1, output2, output3, output4, idle);
signal state : states;

begin

	fsm_mlp : process(clk, rst) is
	begin 
		if (rst = '1') then
            output_done <= '0';
			output_new <= '0';
            DataOut <= (others => '0');
			k <= 0;
			state <= load;
		elsif rising_edge(clk) then
			if (mlp_done ='1') then 
				case state is 
				when load =>
					output_new <= '0';
					if (k = N_O) then						
						output_done <= '1';
						state <= idle;
					else
						dat_reg <= DataIn(k);
						state <= output1;
					end if;
				
				when output1 => 
					output_new <= '1';
					DataOut <= dat_reg(31 downto 24);
					state <= output2;
					report "output1";
		
				when output2 => 
					DataOut <= dat_reg(23 downto 16);
					state <= output3;
					report "output2";
					
				when output3 => 
					DataOut <= dat_reg(15 downto 8);
					state <= output4;
					report "output3";
					
				when output4 => 
					DataOut <= dat_reg(7 downto 0);
					k <= k + 1;
					state <= load;
					report "output4";
					report "The value of 'k' is " & integer'image(k);
					
				when idle =>
					state <= idle;
					
					
				when others =>
					state <= load;
				end case;
			end if; 
		end if;
	end process;
 
 end rtl;