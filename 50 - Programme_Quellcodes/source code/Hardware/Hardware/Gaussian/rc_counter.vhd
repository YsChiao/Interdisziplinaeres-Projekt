library ieee;
use ieee.std_logic_1164.all;

entity rc_counter is
	generic (
	num_cols : integer:=128;
	num_rows : integer:=128
	);
	
	port(
	clk : in std_logic;
	rst : in std_logic;
	en  : in std_logic;
	col : out integer;
	row : out integer
	);
	
end rc_counter;	


architecture rtl of rc_counter is

begin
	process(rst,clk,en)
	
	variable col_var: integer:=0;
	variable row_var: integer:=0;  
	begin
		if rst = '1' then
			col_var := -1;
			col <= 0;
			row_var := 0;
			row <= 0;
		elsif rising_edge(clk) then
			if en = '0' then
				col_var := col_var +1;
				if col_var = num_cols then
					row_var := row_var +1;
					col_var := 0;
					if row_var = num_rows then
						row_var := 0;
					end if;
				end if;
				col <= col_var;
				row <= row_var;
			end if;
		end if;
	end process;
	
	
end rtl;
	
	
