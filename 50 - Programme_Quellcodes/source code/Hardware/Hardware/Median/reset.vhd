library ieee; use ieee.std_logic_1164.all;  
library work; use work.all; 


entity reset is 
	port(
	clk : in std_logic;
	sda : in std_logic;
	rst : out std_logic
	);
end reset;

architecture rtl of reset is 

begin 
	process(clk,sda)
	begin
		if (sda = '1') then
			rst <= '1';
		else 
			rst <= '0';
		end if;
	end process;

end architecture rtl;
