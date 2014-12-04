library ieee;
use ieee.std_logic_1164.all;


entity sort_3x3 is
	generic (
	DATA_WIDTH: integer:=8
	);
	port (
	clk : in std_logic;
    rst : in std_logic;
	w11 : in std_logic_vector((DATA_WIDTH -1) downto 0);
	w12 : in std_logic_vector((DATA_WIDTH -1) downto 0);
	w13 : in std_logic_vector((DATA_WIDTH -1) downto 0);
	w21 : in std_logic_vector((DATA_WIDTH -1) downto 0);
	w22 : in std_logic_vector((DATA_WIDTH -1) downto 0);
	w23 : in std_logic_vector((DATA_WIDTH -1) downto 0);
	w31 : in std_logic_vector((DATA_WIDTH -1) downto 0);
	w32 : in std_logic_vector((DATA_WIDTH -1) downto 0);
	w33 : in std_logic_vector((DATA_WIDTH -1) downto 0);
	DVw : in std_logic;
	DVs : out std_logic;
	s1 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
	s3 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s4 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s5 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s6 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s7 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s8 : out std_logic_vector(DATA_WIDTH -1 downto 0);
	s9 : out std_logic_vector(DATA_WIDTH -1 downto 0)
	);
end sort_3x3;  

architecture rtl of sort_3x3 is

-- compare signals											 								 
signal c11_L: std_logic_vector((DATA_WIDTH -1) downto 0); 
signal c11_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c12_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c12_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c13_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c13_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c14_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c14_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c21_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c21_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c22_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c22_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c23_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c23_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c24_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c24_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c31_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c31_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c32_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c32_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c33_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c33_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c34_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c34_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c41_L: std_logic_vector((DATA_WIDTH -1) downto 0); 
signal c41_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c42_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c42_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c43_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c43_H: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c44_L: std_logic_vector((DATA_WIDTH -1) downto 0);
signal c44_H: std_logic_vector((DATA_WIDTH -1) downto 0);		 
signal c4a1_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c4a1_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c4a2_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c4a2_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c4b0_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c4b0_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c4b1_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c4b1_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c4b2_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c4b2_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c51_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c51_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c61_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c61_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c71_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c71_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c81_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c81_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c91_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c91_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c101_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c101_H: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c111_L: std_logic_vector((DATA_WIDTH-1) downto 0);
signal c111_H: std_logic_vector((DATA_WIDTH-1) downto 0);


-- register signals
signal r11: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r21: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r31: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r41: std_logic_vector((DATA_WIDTH-1) downto 0);
signal r42: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r43: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r4a1: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r4a2: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r4a3: std_logic_vector((DATA_WIDTH-1) downto 0);
signal r4a4: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r4a5: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r4b1: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r4b4: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r4b5: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r51: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r52: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r53: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r54: std_logic_vector((DATA_WIDTH-1) downto 0);
signal r55: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r56: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r57: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r61: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r62: std_logic_vector((DATA_WIDTH-1) downto 0);
signal r63: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r64: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r65: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r66: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r67: std_logic_vector((DATA_WIDTH-1) downto 0);
signal r71: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r72: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r73: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r74: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r75: std_logic_vector((DATA_WIDTH-1) downto 0);
signal r76: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r77: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r81: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r82: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r83: std_logic_vector((DATA_WIDTH-1) downto 0);
signal r84: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r85: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r86: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r87: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r91: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r92: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r93: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r94: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r95: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r96: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r97: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r101: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r102: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r103: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r104: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r105: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r106: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r107: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r111: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r112: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r113: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r114: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r115: std_logic_vector((DATA_WIDTH -1) downto 0);
signal r116: std_logic_vector((DATA_WIDTH-1) downto 0);
signal r117: std_logic_vector((DATA_WIDTH -1) downto 0); 

-- signals for DV coordination
signal dddddddddddddDV: std_logic:='0';
signal ddddddddddddDV: std_logic;
signal dddddddddddDV: std_logic;
signal ddddddddddDV: std_logic ;
signal dddddddddDV: std_logic;
signal ddddddddDV: std_logic;
signal dddddddDV: std_logic;
signal ddddddDV: std_logic;
signal dddddDV: std_logic;
signal ddddDV: std_logic;
signal dddDV: std_logic;
signal ddDV: std_logic;
signal dDV: std_logic;


begin 
	process(clk,rst)
	begin
		if (rst = '1') then
			c11_L <= (others=>'0');
            c11_H <= (others=>'0');
            c12_L <= (others=>'0');
            c12_H <= (others=>'0');
			c13_L <= (others=>'0');
			c13_H <= (others=>'0');
			c14_L <= (others=>'0');
			c14_H <= (others=>'0');
			c21_L <= (others=>'0');
			c21_H <= (others=>'0');
			c22_L <= (others=>'0');
			c22_H <= (others=>'0');
			c23_L <= (others=>'0');
			c23_H <= (others=>'0');
			c24_L <= (others=>'0');
			c24_H <= (others=>'0');
			c31_L <= (others=>'0');
			c31_H <= (others=>'0');
			c32_L <= (others=>'0');
			c32_H <= (others=>'0');
			c33_L <= (others=>'0');
			c33_H <= (others=>'0');
			c34_L <= (others=>'0');
			c34_H <= (others=>'0');
			c41_L <= (others=>'0');
			c41_H <= (others=>'0');
			c42_L <= (others=>'0');
			c42_H <= (others=>'0');
			c43_L <= (others=>'0');
			c43_H <= (others=>'0');
			c4a1_L <= (others=>'0');
			c4a1_H <= (others=>'0');
			c4a2_L <= (others=>'0');
			c4a2_H <= (others=>'0');
			c4b0_L <= (others=>'0');
			c4b0_H <= (others=>'0');
			c4b1_L <= (others=>'0');
			c4b1_H <= (others=>'0');
			c4b2_L <= (others=>'0');
			c4b2_H <= (others=>'0');
			c51_L <= (others=>'0');
			c51_H <= (others=>'0');
			c61_L <= (others=>'0');
			c61_H <= (others=>'0');
			c71_L <= (others=>'0');
			c71_H <= (others=>'0');
			c81_L <= (others=>'0');
			c81_H <= (others=>'0');
			c91_L <= (others=>'0');
			c91_H <= (others=>'0');
			c101_L <= (others=>'0');
			c101_H <= (others=>'0');
			c111_L <= (others=>'0');
			c111_H <= (others=>'0');
			r11 <= (others=>'0');
			r21 <= (others=>'0');
			r31 <= (others=>'0');
			r41 <= (others=>'0');
			r42 <= (others=>'0');
			r43 <= (others=>'0');
			r4a1 <= (others=>'0');
			r4a2 <= (others=>'0');
			r4a3 <= (others=>'0');
			r4a4 <= (others=>'0');
			r4a5 <= (others=>'0');
			r4b1 <= (others=>'0');
			r4b4 <= (others=>'0');
			r4b5 <= (others=>'0');
			r51 <= (others=>'0');
			r52 <= (others=>'0');
			r53 <= (others=>'0');
			r54 <= (others=>'0');
			r55 <= (others=>'0');
			r56 <= (others=>'0');
			r57 <= (others=>'0');
			r61 <= (others=>'0');
			r62 <= (others=>'0');
			r63 <= (others=>'0');
			r64 <= (others=>'0');
			r65 <= (others=>'0');
			r66 <= (others=>'0');
			r67 <= (others=>'0');
			r71 <= (others=>'0');
			r72 <= (others=>'0');
			r73 <= (others=>'0');
			r74 <= (others=>'0');
			r75 <= (others=>'0');
			r76 <= (others=>'0');
			r77 <= (others=>'0');
			r81 <= (others=>'0');
			r82 <= (others=>'0');
			r83 <= (others=>'0');
			r84 <= (others=>'0');
			r85 <= (others=>'0');
			r86 <= (others=>'0');
			r87 <= (others=>'0');
			r91 <= (others=>'0');
			r92 <= (others=>'0');
			r93 <= (others=>'0');
			r94 <= (others=>'0');
			r95 <= (others=>'0');
			r96 <= (others=>'0');
			r97 <= (others=>'0');
			r101 <= (others=>'0');
			r102 <= (others=>'0');
			r103 <= (others=>'0');
			r104 <= (others=>'0');
			r105 <= (others=>'0');
			r106 <= (others=>'0');
			r107 <= (others=>'0');
			r111 <= (others=>'0');
			r112 <= (others=>'0');
			r113 <= (others=>'0');
			r114 <= (others=>'0');
			r115 <= (others=>'0');
			r116 <= (others=>'0');
			r117 <= (others=>'0');
			s1 <= (others=>'0');
			s2 <= (others=>'0');
			s3 <= (others=>'0');
			s4 <= (others=>'0');
			s5 <= (others=>'0');
			s6 <= (others=>'0');
			s7 <= (others=>'0');
			s8 <= (others=>'0');
			s9 <= (others=>'0');
			ddddddddddddDV <= '0';
			dddddddddddDV <= '0';
			ddddddddddDV <= '0';
			dddddddddDV <= '0';
			ddddddddDV <= '0';
			dddddddDV <= '0';
			ddddddDV <= '0';
			dddddDV <= '0';
			ddddDV <= '0';
			dddDV <= '0';
			ddDV <= '0';
			dDV <= '0';
			DVs <= '0';
			
		elsif rising_edge(clk) then
			if DVw = '1' then
				-- level 1
				if w11 < w12 then
					c11_L <= w11;
					c11_H <= w12;
				else
					c11_L <= w12;
					c11_H <= w11;
				end if;
				if w13 < w21 then
					c12_L <= w13;
					c12_H <= w21;
				else
					c12_L <= w21;
				    c12_H <= w13;
				end if;
				if w22 < w23 then
				    c13_L <= w22;
				    c13_H <= w23;
				else
				    c13_L <= w23;
				    c13_H <= w22;
				end if;
				if w31 < w32 then
				    c14_L <= w31;
				    c14_H <= w32;
				else
				    c14_L <= w32;
				    c14_H <= w31;
				end if;
				r11 <= w33;	 
				
				-- level 2
				if c11_L < c12_L then
					c21_L <= c11_L;
                    c21_H <= c12_L;
				else
					c21_L <= c12_L;
					c21_H <= c11_L;
				end if;
				if c11_H < c12_H then
					c22_L <= c11_H;
					c22_H <= c12_H;
				else
					c22_L <= c12_H;
					c22_H <= c11_H;
				end if;
				if c13_L < c14_L then
					c23_L <= c13_L;
					c23_H <= c14_L;
				else
					c23_L <= c14_L;c23_H <= c13_L;
				end if;
				if c13_H < c14_H then
					c24_L <= c13_H;
					c24_H <= c14_H;
				else
					c24_L <= c14_H;
					c24_H <= c13_H;

				end if;
				r21 <= r11;
				-- level 3
				if c21_L < c23_L then
					c31_L <= c21_L;
					c31_H <= c23_L;
				else
					c31_L <= c23_L;
					c31_H <= c21_L;
				end if;
				if c21_H < c23_H then
					c32_L <= c21_H;
					c32_H <= c23_H;
				else
					c32_L <= c23_H;
					c32_H <= c21_H;
				end if;
				if c22_L < c24_L then
					c33_L <= c22_L;
					c33_H <= c24_L;
				else
					c33_L <= c24_L;
					c33_H <= c22_L;
				end if;
				if c22_H < c24_H then
					c34_L <= c22_H;
					c34_H <= c24_H;
				else
					c34_L <= c24_H;
					c34_H <= c22_H;
				end if;
				r31 <= r21;
				-- level 4
				r41 <= c31_L;
				if c31_H < c32_L then
					c41_L <= c31_H;
					c41_H <= c32_L;
				else
					c41_L <= c32_L;
					c41_H <= c31_H;
				end if;
				if c32_H < c33_L then
					c42_L <= c32_H;
					c42_H <= c33_L;
				else
					c42_L <= c33_L;
					c42_H <= c32_H;
				end if;
				if c33_H < c34_L then
					c43_L <= c33_H;
					c43_H <= c34_L;
				else
					c43_L <= c34_L;
					c43_H <= c33_H;
				end if;
				r42 <= c34_H;
				r43 <= r31;
				-- level 4a
				r4a1 <= r41;
				if c41_L < c42_H then
					c4a1_L <= c41_L;
					c4a1_H <= c42_H;
				else
					c4a1_L <= c42_H;
					c4a1_H <= c41_L;
				end if;
				if c41_H < c42_L then
					c4a2_L <= c41_H;
					c4a2_H <= c42_L;
				else
					c4a2_L <= c42_L;
					c4a2_H <= c41_H;
				end if;
				r4a2 <= c43_L;
				r4a3 <= c43_H;
				r4a4 <= r42;
				r4a5 <= r43;
				-- level 4b
				r4b1 <= r4a1;
				if c4a1_L < c4a2_L then
					c4b0_L <= c4a1_L;
					c4b0_H <= c4a2_L;
				else
					c4b0_L <= c4a2_L;
					c4b0_H <= c4a1_L;
				end if;
				if c4a2_H < r4a2 then
					c4b1_L <= c4a2_H;
					c4b1_H <= r4a2;
				else
					c4b1_L <= r4a2;
					c4b1_H <= c4a2_H;
				end if;
				if c4a1_H < r4a3 then
					c4b2_L <= c4a1_H;
					c4b2_H <= r4a3;
				else
					c4b2_L <= r4a3;
					c4b2_H <= c4a1_H;
				end if;
				r4b4 <= r4a4;
				r4b5 <= r4a5;
				-- level 5
				if r4b1 < r4b5 then
					c51_L <= r4b1;
					c51_H <= r4b5;
				else
					c51_L <= r4b5;
					c51_H <= r4b1;
				end if;
				r51 <= c4b0_L;
				r52 <= c4b0_H;
				r53 <= c4b1_L;
				r54 <= c4b1_H;
				r55 <= c4b2_L;
				r56 <= c4b2_H;
				r57 <= r4b4;
				-- level 6
				if r51 < c51_H then
					c61_L <= r51;
					c61_H <= c51_H;
				else
					c61_L <= c51_H;
					c61_H <= r51;
				end if;
				r61 <= c51_L; -- L
				r62 <= r52;
				r63 <= r53;
				r64 <= r54;
				r65 <= r55;
				r66 <= r56;
				r67 <= r57;
				-- level 7
				if r62 < c61_H then
					c71_L <= r62;
					c71_H <= c61_H;
				else
					c71_L <= c61_H;
					c71_H <= r62;
				end if;
				r71 <= r61; -- L
				r72 <= c61_L; -- 2L
				r73 <= r63;
				r74 <= r64;
				r75 <= r65;
				r76 <= r66;
				r77 <= r67;
				-- level 8
				if r73 < c71_H then
					c81_L <= r73;
					c81_H <= c71_H;
				else
					c81_L <= c71_H;
					c81_H <= r73;
				end if;
				r81 <= r71; -- L
				r82 <= r72; -- 2L
				r83 <= c71_L; -- 3L
				r84 <= r74;
				r85 <= r75;
				r86 <= r76;
				r87 <= r77;
				-- level 9
				if r84 < c81_H then
					c91_L <= r84;
					c91_H <= c81_H;
				else
					c91_L <= c81_H;
					c91_H <= r84;
				end if;
				r91 <= r81; -- L
				r92 <= r82; -- 2L
				r93 <= r83; -- 3L
				r94 <= c81_L; -- 4L
				r95 <= r85;
				r96 <= r86;
				r97 <= r87;
				-- level 10
				if r95 < c91_H then
					c101_L <= r95;
					c101_H <= c91_H;
				else
					c101_L <= c91_H;
					c101_H <= r95;
				end if;
				r101 <= r91; -- L
				r102 <= r92; -- 2L
				r103 <= r93; -- 3L
				r104 <= r94; -- 4L
				r105 <= c91_L; -- M
				r106 <= r96;
				r107 <= r97;
				-- level 11
				if r106 < c101_H then
					c111_L <= r106;
					c111_H <= c101_H;
				else
					c111_L <= c101_H;
					c111_H <= r106;
				end if;
				r111 <= r101; -- L
				r112 <= r102; -- 2L
				r113 <= r103; -- 3L
				r114 <= r104; -- 4L
				r115 <= r105; -- M
				r116 <= c101_L; -- 4L
				r117 <= r107;
				-- level 12
				if r117 < c111_H then
					s8 <= r117; -- 2H
					s9 <= c111_H; -- H
				else
					s8 <= c111_H; -- 2H
					s9 <= r117; -- H
				end if;
				s1 <= r111; -- L
				s2 <= r112; -- 2L
				s3 <= r113; -- 3L
				s4 <= r114; -- 4L
				s5 <= r115; -- M
				s6 <= r116; -- 4H
				s7 <= c111_L; -- 3H
				ddddddddddddDV <= dddddddddddddDV;
				dddddddddddDV <= ddddddddddddDV;
				ddddddddddDV <= dddddddddddDV;
				dddddddddDV <= ddddddddddDV;
				ddddddddDV <= dddddddddDV;
				dddddddDV <= ddddddddDV;
				ddddddDV <= dddddddDV;
				dddddDV <= ddddddDV;
				ddddDV <= dddddDV;
				dddDV <= ddddDV;
				ddDV <= dddDV;
				dDV <= ddDV;
				DVs <= dDV;
				end if;
				if DVw = '1' then
					dddddddddddddDV <= '1';
				end if;
		end if;
	end process;
end rtl;
		
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				