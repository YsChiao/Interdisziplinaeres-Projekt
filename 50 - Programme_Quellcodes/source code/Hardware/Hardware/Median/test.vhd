library ieee;
use ieee.std_logic_1164.all;


entity test is
	generic (
	DATA_WIDTH: integer:=8
	);
	port (
	clk : in std_logic;
	rst : in std_logic;
	DataIn : in std_logic_vector(DATA_WIDTH-1 downto 0);
	DataOut : out std_logic_vector(DATA_WIDTH -1 downto 0)
	);
end test;

architecture rtl of test is 

begin
process(clk,rst)
	begin
	if rst = '1' then
		DataOut <= (others =>'0');
	elsif rising_edge(clk) then
		DataOut <= DataIn;
	end if;
end process;

end rtl;