library ieee;
use ieee.std_logic_1164.all;

package float_types is 
	subtype float is std_logic_vector(31 downto 0);
	type float_vector is array( natural range<> ) of float;
	type float_alu_mode is (idle, add, sub, mul, div, exp);
end float_types;

library ieee;
use ieee.std_logic_1164.all;
use work.float_types.all;
--use work.float_constants.all;

package float_components is 
	component fp_add  
		generic(
		K: natural:= 32; 
		P: natural:= 24; 
		E: natural:= 8);
		port(
		FP_A : in  std_logic_vector (K-1 downto 0);
        FP_B : in  std_logic_vector (K-1 downto 0);
        add_sub: in std_logic;
        clk : in  std_logic;
        ce  : in  std_logic;
        FP_Z : out  std_logic_vector (K-1 downto 0)
		);	
	end component;
	
	component fp_mul
		generic(
		K: natural:= 32; 
		P: natural:= 24; 
		E: natural:= 8);
		port 
		( FP_A : in  std_logic_vector (K-1 downto 0);
		  FP_B : in  std_logic_vector (K-1 downto 0);
          clk  : in  std_logic;
          ce   : in  std_logic;
          FP_Z : out  std_logic_vector (K-1 downto 0)
		);     
	end component; 
	
	component fp_div
		generic(
		K : natural:= 32;
		P : natural:= 24;
		E : natural:= 8);
		port
		( FP_A: in std_logic_vector (K-1 downto 0);
          FP_B: in std_logic_vector (K-1 downto 0);
          clk: in std_logic;
          ce:  in std_logic;
          FP_Z: out std_logic_vector (K-1 downto 0)
		);
	end component;
	
	component fp_exp is
	    generic ( 
		wE : positive := 8;
        wF : positive := 23 );
		port 
		( fpX : in  std_logic_vector(2+wE+wF downto 0);
          fpR : out std_logic_vector(2+wE+wF downto 0) );
    end component;
	
    component fp_exp_clk
		generic ( 
		wE : positive := 8;
        wF : positive := 23 );
		port 
		( fpX : in  std_logic_vector(2+wE+wF downto 0);
          fpR : out std_logic_vector(2+wE+wF downto 0);
          clk : in  std_logic 
		);
	end component;
	
	component float_alu is
		port ( 
		rst  : in std_logic;
		clk  : in std_logic;
		a, b : in float;
		c    : out float;
		mode : in float_alu_mode;
		ready : out std_logic
		);
	end component float_alu;
	
end package float_components; 

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.float_types.all;

package float_constants is
	 --whole number constants
	CONSTANT float_zero		: float := "00000000000000000000000000000000";
	CONSTANT float_one 		: float := "00111111100000000000000000000000";

	 --other constants
	CONSTANT float_half		: float := "00111111000000000000000000000000";
	CONSTANT float_1_10		: float := "00111101110011001100110011001100";
	CONSTANT float_1_20		: float := "00111101010011001100110011001101";
	CONSTANT float_1_100	: float := "00111100001000111101011100001010";

	CONSTANT float_add_wait : INTEGER := 7;
	CONSTANT float_sub_wait : INTEGER := 7;
	CONSTANT float_div_wait : INTEGER := 10;
	CONSTANT float_mul_wait : INTEGER := 9;
	CONSTANT float_exp_wait : INTEGER := 15;
	CONSTANT float_cmp_wait : INTEGER := 0;
end package float_constants;



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.pkg_fp_exp.all;
use work.float_types.all;
use work.float_components.all;
use work.float_constants.all;


entity float_alu is
	port (
	rst, clk : in std_logic;
	a,b  : in  float;
	c    : out float;
	mode : in  float_alu_mode;
	ready : out std_logic
	);
end entity float_alu;

architecture rtl of float_alu is

--wait counter
signal wait_counter : integer := 0;


--alu signals
signal add_ce, sub_ce, mul_ce, div_ce, exp_ce : std_logic := '0'; 
signal add_enable : std_logic :='0';
signal sub_enable : std_logic :='1';
signal exp_a : std_logic_vector(33 downto 0);
signal exp_c : std_logic_vector(33 downto 0); 
signal exp_c0: std_logic_vector(33 downto 0); 
signal alu_a, alu_b, alu_c, add_c, sub_c, mul_c, div_c : float := float_zero;

type states is (idle, add, sub, mul, div, exp);
signal state : states := idle;

begin
	
	c <= alu_c;

	-- alu stuff
	fp_add0 : fp_add port map (alu_a, alu_b, add_enable, clk, add_ce, add_c);
	fp_sub0 : fp_add port map (alu_a, alu_b, sub_enable, clk, sub_ce, sub_c);
	fp_mul0 : fp_mul port map (alu_a, alu_b, clk, mul_ce, mul_c); 
	fp_div0 : fp_div port map (alu_a, alu_b, clk, div_ce, div_c);
	fp_exp0 : fp_exp port map (exp_a, exp_c0); -- no used
	fp_exp_clk0 : fp_exp_clk port map (exp_a, exp_c, clk);
	
	
	fsm : process(clk, rst) is
	begin 
		if(rst = '1') then
			wait_counter <= 0;
			state <= idle;
			ready <= '0';
		elsif rising_edge(clk) then
			if (wait_counter >0) then
				wait_counter <= wait_counter-1;
			else
				case state is 
				when idle =>
					case mode is 
					when idle => 
						ready <= '1';
						state <= idle;
					when add => 
					    ready <= '0'; 
						add_ce <= '1';
						add_enable <= '1';
						alu_a <= a;
						alu_b <= b;
						wait_counter <= float_add_wait;
						state <= add;
					when sub =>
					    ready <= '0';
					   	sub_ce <= '1'; 
					    sub_enable <='0';
						alu_a <= a;
						alu_b <= b;
						wait_counter <= float_sub_wait;
						state <= sub;
					when mul =>
					    ready <= '0';
					 	mul_ce <= '1'; 
						alu_a <= a;
						alu_b <= b;
						wait_counter <= float_mul_wait;
						state <= mul;
					when div =>
					    ready <= '0';
						div_ce <= '1';
						alu_a <= a;
						alu_b <= b;
						wait_counter <= float_div_wait;
						state <= div;
					when exp =>
					    ready <= '0';
						exp_a <= "01" & a;
						wait_counter <= float_exp_wait;
						state <= exp;
					when others => 
					    state <= idle;
					end case;
				when add =>
				    alu_c <= add_c;
					add_ce <= '0';
					state <= idle;
					ready <= '1';
				when sub => 
				    alu_c <= sub_c;
				 	sub_ce <= '0';
					state <= idle;
					ready <= '1';
				when mul =>
				    alu_c <= mul_c;
					mul_ce <='0';
					state <= idle;
					ready <='1';
				when div => 
				    alu_c <= div_c;
					div_ce <= '0';
					state <= idle;
					ready <='1';  
				when exp => 
				    alu_c <= exp_c(31 downto 0);
				    exp_ce <= '0';
					state <=  idle;
					ready <= '1';
				when others	=>
				    state <= idle;
			    end case;
		    end if;
	    end if;
    end process;
		
					
end architecture rtl;				
					
					
					
					
					
	
      
	



























	