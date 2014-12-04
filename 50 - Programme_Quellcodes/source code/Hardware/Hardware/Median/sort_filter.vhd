library ieee;
use ieee.std_logic_1164.all;


entity sort_filter is
	generic (
	DATA_WIDTH: integer:=8;
	order: integer:=5;
	num_cols: integer:=128;
	num_rows: integer:=128
	);
	port (
	clk : in std_logic;
	rst : in std_logic;
	DataIn : in std_logic_vector(DATA_WIDTH-1 downto 0);
	DataOut : out std_logic_vector(DATA_WIDTH -1 downto 0);
	DV : out std_logic
	);
end sort_filter;

architecture rtl of sort_filter is 

component sort_3x3 
	generic (
	DATA_WIDTH : integer := 8
	);
	port(
	clk : in std_logic;
	rst : in std_logic;
	w11 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	w12 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	w13 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	w21 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	w22 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	w23 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	w31 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	w32 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	w33 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	DVw : in std_logic;
    DVs : out std_logic;
	s1 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s2 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s3 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s4 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s5 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s6 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s7 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s8 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s9 : out std_logic_vector(DATA_WIDTH -1 downto 0)
	); 
end component sort_3x3;
	
signal w11: std_logic_vector((DATA_WIDTH -1) downto 0);
signal w12: std_logic_vector((DATA_WIDTH -1) downto 0);	
signal w13: std_logic_vector((DATA_WIDTH -1) downto 0);	
signal w21: std_logic_vector((DATA_WIDTH -1) downto 0);	
signal w22: std_logic_vector((DATA_WIDTH -1) downto 0);	
signal w23: std_logic_vector((DATA_WIDTH -1) downto 0);	
signal w31: std_logic_vector((DATA_WIDTH -1) downto 0);
signal w32: std_logic_vector((DATA_WIDTH -1) downto 0);
signal w33: std_logic_vector((DATA_WIDTH -1) downto 0);
signal DVw: std_logic;
signal DVs: std_logic;
signal s1: std_logic_vector((DATA_WIDTH -1) downto 0);
signal s2: std_logic_vector((DATA_WIDTH -1) downto 0);
signal s3: std_logic_vector((DATA_WIDTH -1) downto 0);
signal s4: std_logic_vector((DATA_WIDTH -1) downto 0);
signal s5: std_logic_vector((DATA_WIDTH -1) downto 0);
signal s6: std_logic_vector((DATA_WIDTH -1) downto 0);
signal s7: std_logic_vector((DATA_WIDTH -1) downto 0);
signal s8: std_logic_vector((DATA_WIDTH -1) downto 0);
signal s9: std_logic_vector((DATA_WIDTH -1) downto 0); 


COMPONENT window_3x3
	generic (
	DATA_WIDTH : integer := 8
	);
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		datain: IN std_logic_vector(7 downto 0);          
		w11 : OUT std_logic_vector(7 downto 0);
		w12 : OUT std_logic_vector(7 downto 0);
		w13 : OUT std_logic_vector(7 downto 0);
		w21 : OUT std_logic_vector(7 downto 0);
		w22 : OUT std_logic_vector(7 downto 0);
		w23 : OUT std_logic_vector(7 downto 0);
		w31 : OUT std_logic_vector(7 downto 0);
		w32 : OUT std_logic_vector(7 downto 0);
		w33 : OUT std_logic_vector(7 downto 0);
		DV : OUT std_logic
		);
END COMPONENT window_3x3;

component rc_counter
	generic (
	num_cols: integer:=128;
	num_rows: integer:=128
	);
	port (
	clk : in std_logic;
	rst : in std_logic;
	en : in std_logic;
    col : out integer;
	row : out integer
	);
end component rc_counter; 

signal col  : integer:=0;
signal row  : integer:=0;
signal col_c: integer:=0; -- corrected positions
signal row_c: integer:=0;
signal rt1: integer:=0;
signal rt2: integer:=0;
signal rt3: integer:=0;
signal rt4: integer:=0;
signal rt5: integer:=0;
signal rt6: integer:=0;
signal rt7: integer:=0;
signal rt8: integer:=0;
signal rt9: integer:=0;
signal rt10: integer:=0;
signal rt11: integer:=0;
signal rt12: integer:=0;
signal rt13: integer:=0;
signal rt14: integer:=0;
signal rt15: integer:=0;
signal rt16: integer:=0;
signal flag: std_logic:='0'; 


begin
	sort_3x3_0: sort_3x3
	generic map (
	DATA_WIDTH => 8
	)
	port map (
	clk => clk,
	rst => rst,
	w11 => w11,
	w12 => w12,
	w13 => w13,
	w21 => w21,
	w22 => w22,
	w23 => w23,
	w31 => w31,
	w32 => w32,
	w33 => w33,
	DVw => DVw,
	DVs => DVs,
	s1 => s1,
	s2 => s2,
	s3 => s3,
	s4 => s4,
	s5 => s5,
	s6 => s6,
	s7 => s7,
	s8 => s8,
	s9 => s9
	);
	
	window_3x3_0: window_3x3
	generic map(
	DATA_WIDTH => 8
	)
	port map (
	clk => clk,				
	rst => rst,
	datain => DataIn,
	w11 => w11,
	w12 => w12,
	w13 => w13,
	w21 => w21,
	w22 => w22,
	w23 => w23,
	w31 => w31,
	w32 => w32,
	w33 => w33,
	DV => DVw
	);
	
	rc_counter0: rc_counter
	generic map (
	num_cols => 640,
	num_rows => 360
	)
	port map (
	clk => clk,
	rst => rst,
	en  => rst,
	col => col,
	row => row
	);
	
	
	sort_filter_0 : process(clk,rst)
	begin
		if rst = '1' then
			col_c <= 0;
			rt1 <= 0;
			rt2 <= 0;
			rt3 <= 0;
			rt4 <= 0;
			rt5 <= 0;
			rt6 <= 0;
			rt7 <= 0;
			rt8 <= 0;
			rt9 <= 0;
			rt10 <= 0;
			rt11 <= 0;
			rt12 <= 0;
			rt13 <= 0;
			rt14 <= 0;
			rt15 <= 0;
			rt16 <= 0;
			row_c <= 0;
			DataOut <= (others=>'0');
			DV <= '0';
			flag <= '0';
		elsif rising_edge(clk) then
			-- counter correction
			col_c <= ((col-16) mod 640);
			rt1 <= ((row-1) mod 640);
			rt2 <= rt1;
			rt3 <= rt2;
			rt4 <= rt3;
			rt5 <= rt4;
			rt6 <= rt5;
			rt7 <= rt6;
			rt8 <= rt7;
			rt9 <= rt8;
			rt10 <= rt9;
			rt11 <= rt10;
			rt12 <= rt11;
			rt13 <= rt12;
			rt14 <= rt13;
			rt15 <= rt14;
			rt16 <= rt15;
			row_c <= rt16; 
		if (col_c = num_cols-1) or (row_c = num_rows-1) or (col_c = num_cols-2) or (row_c = 0) then
			DataOut <= (others=>'0');
		else
			if order = 1 then
				DataOut <= s1;
			elsif order = 2 then
				DataOut <= s2;
			elsif order = 3 then
				DataOut <= s3;
			elsif order = 4 then
				DataOut <= s4;
			elsif order = 5 then
				DataOut <= s5;
			elsif order = 6 then
				DataOut <= s6;
			elsif order = 7 then
				DataOut <= s7;
			elsif order = 8 then
				DataOut <= s8;
			elsif order = 9 then
				DataOut <= s9;
			end if;
		end if;	
		if col >= 16 and row >= 1 then
			DV <= '1';
			flag <= '1';
		elsif flag = '1' then  
			DV <= '1';
		else
			DV <= '0';
		end if;
	end if;
end process; 

end rtl;
		
			



