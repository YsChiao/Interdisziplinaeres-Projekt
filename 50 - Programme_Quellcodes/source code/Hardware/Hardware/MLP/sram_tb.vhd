
-- VHDL Test Bench Created from source file sram.vhd -- Wed Sep 24 23:41:43 2014

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
use work.sram_types.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT sram
	PORT(
		reset : IN std_logic;
		clock : IN std_logic;
		addr : IN std_logic_vector(11 downto 0);
		input : IN std_logic_vector(31 downto 0);
		we   : IN std_logic;          
		output : OUT std_logic_vector(31 downto 0);
		ready : OUT std_logic
		);
	END COMPONENT;

	SIGNAL reset :  std_logic;
	SIGNAL clock :  std_logic;
	SIGNAL addr :  std_logic_vector(11 downto 0);
	SIGNAL input :  std_logic_vector(31 downto 0);
	SIGNAL output :  std_logic_vector(31 downto 0);
	SIGNAL we :  std_logic;
	SIGNAL ready :  std_logic;
    
	constant SYS_CLK_HALF_PERIOD :time := 5 ns; --for 50 MHz   100Mhz
BEGIN

-- Please check and add your generic clause manually
	uut: sram PORT MAP(
		reset => reset,
		clock => clock,
		addr => addr,
		input => input,
		output => output,
		we => we,
		ready => ready
	);
	
	--CLK
	process
		begin
		clock <= '0';
		wait for  SYS_CLK_HALF_PERIOD;
		clock <= '1';
		wait for  SYS_CLK_HALF_PERIOD;
	end process;

master_process : process 

	begin

		reset <= '1';		
		wait until rising_edge(clock);
		reset <= '0';

		
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(1,12));
		input <= std_logic_vector(to_unsigned(1,32));	
		we <= '1';
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(2,12));
		input <= std_logic_vector(to_unsigned(2,32));
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(3,12));
		input <= std_logic_vector(to_unsigned(3,32));
		wait until rising_edge(clock); 
		addr <= std_logic_vector(to_unsigned(4,12));
		input <= std_logic_vector(to_unsigned(4,32));
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(5,12));
		input <= std_logic_vector(to_unsigned(5,32));
		wait until rising_edge(clock);				  
		addr <= std_logic_vector(to_unsigned(6,12));
		input <= std_logic_vector(to_unsigned(6,32));
		wait until rising_edge(clock);			  
		addr <= std_logic_vector(to_unsigned(7,12));
		input <= std_logic_vector(to_unsigned(7,32));
		
		
		 
		
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(2,12));
		we <= '0'; 
		wait until rising_edge(clock); 
		addr <= std_logic_vector(to_unsigned(4,12));
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(1,12));
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(5,12));
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(7,12));
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(3,12));
		wait until rising_edge(clock);
		addr <= std_logic_vector(to_unsigned(6,12));
		wait until rising_edge(clock);							
		
 

		
		
		
		
	
	
	
		
		
		wait ;
	end process;


END;
