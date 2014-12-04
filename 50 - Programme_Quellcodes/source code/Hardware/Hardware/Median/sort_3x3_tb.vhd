
-- VHDL Test Bench Created from source file sort_3x3.vhd -- Wed Jun 18 12:13:06 2014

--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Lattice recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "source->import"
-- menu in the ispLEVER Project Navigator to import the testbench.
-- Then edit the user defined section below, adding code to generate the 
-- stimulus for your design.
-- 3) VHDL simulations will produce errors if there are Lattice FPGA library 
-- elements in your design that require the instantiation of GSR, PUR, and
-- TSALL and they are not present in the testbench. For more information see
-- the How To section of online help.  
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; 

library work;
--use work.conv_3x3_pkg.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

COMPONENT sort_3x3
	generic (
	DATA_WIDTH: integer:=8
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
END COMPONENT;

signal DATA_WIDTH : integer:= 8;
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

signal clk : std_logic;
signal rst : std_logic;

signal clk_period : time := 10 ns;

BEGIN

-- Please check and add your generic clause manually
	uut: sort_3x3 PORT MAP(
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


---- *** Test Bench - User Defined Section ***
--   tb : PROCESS
--   BEGIN
--      wait; -- will wait forever
--   END PROCESS;
---- *** End Test Bench - User Defined Section *** 
clk_process : process
begin
	clk <= '0'; wait for clk_period;
	clk <= '1'; wait for clk_period;
end process;


Master:process
variable counter : unsigned (7 downto 0) := (others => '0');
begin 
	
    wait for 20 ns; 	--100
	rst   <= '1'; 
		
	wait until rising_edge(clk);   --140
	rst  <= '0';
	
	wait until rising_edge(clk);
	w11 <= x"09";
	w12 <= x"08";
	w13 <= x"07";
	w21 <= x"06";
	w22 <= x"05";
	w23 <= x"04";
	w31 <= x"03";
	w32 <= x"02";
	w33 <= x"01";
	DVw <= '1';

	
	
	wait;
end process;

END;
