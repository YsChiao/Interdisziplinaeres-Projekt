library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.float_types.all;
use work.float_constants.all;
use work.sram_dp_types.all;

library std;
use std.textio.all;

entity loadInput is
	
	port (
	rst : in std_logic;
	clk : in std_logic;
	new_data: in std_logic;
	inputs : in sram_data;
    --outputs : out sram_data;
	
	inputNumber : in integer;
	weightNumber : in integer;
	weight_done : out std_logic;
	
	sram_addr : out sram_address;
	sram_input : out sram_data;
	sram_output : in sram_data;
	sram_mode :  out std_logic;
	sram_ready : out std_logic
	
	);
end entity loadInput;

architecture rtl of loadInput is

type states is ( load_init, load_input, load_input_complete, load_idle);
signal state : states := load_init;	

signal addr : integer := 0;
-----------------------------------------

begin
	
		
	fsm_lw : process(clk,rst) is
	begin 
		if (rst = '1') then
			weight_done <= '0';
			state <= load_init;
			sram_ready <= '0';
		elsif rising_edge(clk) then
--			if (sram_mode /= idle)then
--				sram_mode <= idle;
--			elsif (sram_ready = '0') then
--			else
				case state is
					
				when load_init => 
					addr <= 0;
					sram_ready <= '1';
					state <= load_weight;
					report "Load initializaion";
				when load_weight =>
					sram_addr <= std_logic_vector(to_unsigned(addr,12));
					if new_data = '1'  then
						sram_input <= inputs; 
						sram_mode <= '1';
						report "The value of 'load_addr' is " & integer'image(addr);
						state <= load_weight_complete;
						
					else 
						state <= load_weight;  
					end if;
					
				when load_weight_complete =>
				if( addr = (inputNumber + weightNumber -1)) then 
						weight_done <= '1';	
						report "The weight has been loaded done.";
					    state <= load_idle;
				    else
						addr <= addr + 1;
						state <= load_weight;
					end if;	
					
					
				when load_idle =>
					--sram_mode <= idle;
					sram_ready <= '0';
					state <= load_idle;

				when others =>
					state <= load_init;
				end case;
			end if;
		--end if;
	end process;
				



end rtl;