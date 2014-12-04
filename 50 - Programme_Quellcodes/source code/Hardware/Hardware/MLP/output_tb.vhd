
-- VHDL Test Bench Created from source file output.vhd -- Fri Sep 26 23:12:11 2014

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

library work; use work.all;
use work.mlp_pkg.all; 
use work.float_types.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT output
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		mlp_done : IN std_logic;
		DataIn : IN  float_vector(N_O -1 downto 0); 
		output_new : OUT std_logic;
		DataOut : OUT std_logic_vector(7 downto 0);
		output_done : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic;
	SIGNAL rst :  std_logic;
	SIGNAL mlp_done :  std_logic;
	SIGNAL DataIn :  float_vector(N_O -1 downto 0);
	SIGNAL output_new : std_logic;
	SIGNAL DataOut :  std_logic_vector(7 downto 0);
	SIGNAL output_done :  std_logic;
	
		-- Clock period definitions
	constant SPI_CLK_HALF_PERIOD :time := 10 ns;--for 25 MHz   50Mhz
    constant SYS_CLK_HALF_PERIOD :time := 5 ns; --for 50 MHz   100Mhz

BEGIN

-- Please check and add your generic clause manually
	uut: output PORT MAP(
		clk => clk,
		rst => rst,
		mlp_done => mlp_done,
		output_new => output_new,
		DataIn => DataIn,
		DataOut => DataOut,
		output_done => output_done
	); 
	
	
	--CLK
	process
	begin
		clk <= '0';
		wait for  SYS_CLK_HALF_PERIOD;
		clk <= '1';
		wait for  SYS_CLK_HALF_PERIOD;
	end process; 
	
	
master_process : process 
	begin
		rst <= '1';
		wait for 100 ns;
		rst <= '0'; 
		wait for 100 ns;
		mlp_done <= '1';
		DataIn(0) <= x"40400000";
		--DataIn(1) <= x"3f800000";
		
				
	wait ;
	end process;
		
 										
END;
