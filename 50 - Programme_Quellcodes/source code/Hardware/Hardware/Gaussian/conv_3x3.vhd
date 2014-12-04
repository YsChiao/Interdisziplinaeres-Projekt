library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.conv_3x3_pkg.all;	 
library work;           use work.all; 


entity conv_3x3 is
	port (
	clk : in std_logic;
	rst : in std_logic;
	DataIn : in std_logic_vector(DATA_WIDTH-1 downto 0);
	DataOut: out std_logic_vector((DATA_WIDTH*2) downto 0);
	DV     : out std_logic
	);
end conv_3x3;
	
architecture rtl of conv_3x3 is	

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

component window_3x3
	generic(
	constant DATA_WIDTH : positive := 8
	);
	port (
	clk : in std_logic;
	rst : in std_logic;
	datain : in std_logic_vector(DATA_WIDTH-1 downto 0);
	w11 :  out  std_logic_vector(DATA_WIDTH-1 downto 0);
	w12 :  out  std_logic_vector(DATA_WIDTH-1 downto 0);
	w13 :  out  std_logic_vector(DATA_WIDTH-1 downto 0);
	w21 :  out  std_logic_vector(DATA_WIDTH-1 downto 0);
	w22 :  out  std_logic_vector(DATA_WIDTH-1 downto 0);
	w23 :  out  std_logic_vector(DATA_WIDTH-1 downto 0);
	w31 :  out  std_logic_vector(DATA_WIDTH-1 downto 0);
	w32 :  out  std_logic_vector(DATA_WIDTH-1 downto 0);
	w33 :  out  std_logic_vector(DATA_WIDTH-1 downto 0);
	DV     : out std_logic  
	);
end component window_3x3;

-- 16 bits for 8x8 plus 1 bit for sign
signal m0: signed((DATA_WIDTH*2) downto 0):=(others=>'0');
signal m1: signed((DATA_WIDTH*2) downto 0):=(others=>'0');
signal m2: signed((DATA_WIDTH*2) downto 0):=(others=>'0');
signal m3: signed((DATA_WIDTH*2) downto 0):=(others=>'0');
signal m4: signed((DATA_WIDTH*2) downto 0):=(others=>'0');
signal m5: signed((DATA_WIDTH*2) downto 0):=(others=>'0');
signal m6: signed((DATA_WIDTH*2) downto 0):=(others=>'0') ;
signal m7: signed((DATA_WIDTH*2) downto 0):=(others=>'0');
signal m8: signed((DATA_WIDTH*2) downto 0):=(others=>'0');
signal a10: signed((DATA_WIDTH*2)+1 downto 0):=(others=>'0');
signal a11: signed((DATA_WIDTH*2)+1 downto 0):=(others=>'0');
signal a12: signed((DATA_WIDTH*2)+1 downto 0):=(others=>'0');
signal a13: signed((DATA_WIDTH*2)+1 downto 0):=(others=>'0');
signal a14: signed((DATA_WIDTH*2)+1 downto 0):=(others=>'0');
signal a20: signed((DATA_WIDTH*2)+2 downto 0):=(others=>'0');
signal a21: signed((DATA_WIDTH*2)+2 downto 0):= (others=>'0');
signal a22: signed((DATA_WIDTH*2)+2 downto 0):=(others=>'0');
signal a30: signed((DATA_WIDTH*2)+3 downto 0):=(others=>'0');
signal a31: signed((DATA_WIDTH*2)+3 downto 0):=(others=>'0');
signal a40: signed((DATA_WIDTH*2)+4 downto 0):=(others=>'0');
signal d0: signed((DATA_WIDTH*2) downto 0):=(others=>'0'); 


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


signal col : integer:=0;
signal row : integer:=0;
signal col_c : integer:=0; -- corrected positions
signal row_c : integer:=0; 
signal rt1 : integer:=0;
signal rt2 : integer:=0;
signal rt3 : integer:=0;
signal rt4 : integer:=0;
signal rt5 : integer:=0;
signal rt6 : integer:=0;
signal rt7 : integer:=0;
signal rt8 : integer:=0; 
signal flag : std_logic:='0';

begin 
	window_3x3_0 :window_3x3
	generic map(
	DATA_WIDTH => 8
	)
	port map(
	clk => clk,
	rst => rst,
	datain=> DataIn,
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
	
	rc_counter0 : rc_counter
	generic map(
	num_cols => 640,
	num_rows => 360
	)
	port map(
	clk => clk,
	rst => rst,
	en  => rst,
	col => col,
	row => row
	);
	
	conv_process: process(clk, rst)
	begin 
		if rst = '1' then
			m0 <= (others=>'0');
			m1 <= (others=>'0');
			m2 <= (others=>'0');
			m3 <= (others=>'0');
			m4 <= (others=>'0');
			m5 <= (others=>'0');
			m6 <= (others=>'0');
			m7 <= (others=>'0');
			m8 <= (others=>'0');
			a10 <= (others=>'0');
			a11 <= (others=>'0');
			a12 <= (others=>'0');
			a13 <= (others=>'0');
			a14 <= (others=>'0');
			a20 <= (others=>'0');
			a21 <= (others=>'0');
			a22 <= (others=>'0');
			a30 <= (others=>'0');
			a31 <= (others=>'0');
			a40 <= (others=>'0');
			d0 <= (others=>'0');
			DataOut <= (others=>'0');
			DV <= '0';
			col_c <= 0;
			rt1 <= 0;
			rt2 <= 0;
			rt3 <= 0;
			rt4 <= 0;
			rt5 <= 0;
			rt6 <= 0;
			rt7 <= 0;
			rt8 <= 0;
			row_c <= 0;
			flag <= '0';
		elsif rising_edge(clk) then
			-- counter correction
			col_c <= ((col-8) mod 640);
			rt1 <= ((row-1) mod 640);
			rt2 <= rt1;
			rt3 <= rt2;
			rt4 <= rt3;
			rt5 <= rt4;
			rt6 <= rt5;
			rt7 <= rt6;
			rt8 <= rt7;
			row_c <= rt8;
			-- screen edge detection
			if (col_c = num_cols-1) or (row_c = num_rows-1) or (col_c = num_cols-2) or (row_c = 0) then
				DataOut <= (others=>'0');
			end if;
			if DVw = '1' then
				-- window*kernel multipliers
				-- this could be optimized by using hardware -specified multipliers	
				m0 <= signed('0'&w11)*signed(k0);
                m1 <= signed('0'&w12)*signed(k1);
                m2 <= signed('0'&w13)*signed(k2);
                m3 <= signed('0'&w21)*signed(k3);
                m4 <= signed('0'&w22)*signed(k4);
                m5 <= signed('0'&w23)*signed(k5);
                m6 <= signed('0'&w31)*signed(k6);
                m7 <= signed('0'&w32)*signed(k7);
                m8 <= signed('0'&w33)*signed(k8);
				a10 <= (m0(16)&m0)+m1;
				a11 <= (m2(16)&m2)+m3;
				a12 <= (m4(16)&m4)+m5;
				a13 <= (m6(16)&m6)+m7;
				a14 <= m8(16)&m8;
				a20 <= (a10(17)&a10)+a11;
				a21 <= (a12(17)&a12)+a13;
				a22 <= a14(17)&a14;
				a30 <= (a20(18)&a20)+a21;
				a31 <= a22(18)&a22;
				a40 <= (a30(19)&a30)+a31;
				d0 <= a40(20 downto 4);
				if (col_c = num_cols-1) or (row_c = num_rows-1) or (col_c = num_cols-2) or (row_c = 0) then
					DataOut <= (others=>'0');
				else
					DataOut <= std_logic_vector(d0);
				end if;
			end if;
				
			if col >= 8  and row >=1 then 
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
	


	
	