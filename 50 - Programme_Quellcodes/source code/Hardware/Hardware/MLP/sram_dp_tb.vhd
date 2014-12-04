
-- VHDL Test Bench Created from source file sram_dp.vhd -- Thu Sep 25 01:06:14 2014

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

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT sram_dp
	PORT(
		resetA : IN std_logic;
		resetB : IN std_logic;
		clockA : IN std_logic;
		clockB : IN std_logic;
		addrA : IN std_logic_vector(11 downto 0);
		addrB : IN std_logic_vector(11 downto 0);
		inputA : IN std_logic_vector(31 downto 0);
		inputB : IN std_logic_vector(31 downto 0);
		wrA : IN std_logic;
		wrB : IN std_logic;          
		outputA : OUT std_logic_vector(31 downto 0);
		outputB : OUT std_logic_vector(31 downto 0);
		readyA : in std_logic;
		readyB : in std_logic
		);
	END COMPONENT;

	SIGNAL resetA :  std_logic;
	SIGNAL resetB :  std_logic;
	SIGNAL addrA :  std_logic_vector(11 downto 0);
	SIGNAL addrB :  std_logic_vector(11 downto 0);
	SIGNAL inputA :  std_logic_vector(31 downto 0);
	SIGNAL inputB :  std_logic_vector(31 downto 0);
	SIGNAL outputA :  std_logic_vector(31 downto 0);
	SIGNAL outputB :  std_logic_vector(31 downto 0);
	SIGNAL wrA :  std_logic;
	SIGNAL wrB :  std_logic;
	SIGNAL readyA : std_logic;
	SIGNAL readyB : std_logic;
	
	signal clock : std_logic;

	constant SYS_CLK_HALF_PERIOD :time := 5 ns; --for 50 MHz   100Mhz
BEGIN

-- Please check and add your generic clause manually
	uut: sram_dp PORT MAP(
		resetA => resetA,
		resetB => resetB,
		clockA => clock,
		clockB => clock,
		addrA => addrA,
		addrB => addrB,
		inputA => inputA,
		inputB => inputB,
		outputA => outputA,
		outputB => outputB,
		wrA => wrA,
		wrB => wrB,
		readyA => readyA,
		readyB => readyB
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

		resetA<= '1'; resetB<= '1'; 		
		wait until rising_edge(clock);
		resetA <= '0'; resetB <= '0';
		readyA <= '1';

		
		wait until rising_edge(clock);
		addrA <= std_logic_vector(to_unsigned(1,12));
		inputA <= std_logic_vector(to_unsigned(1,32));	
		wrA <= '1';
		wait until rising_edge(clock);
		addrA<= std_logic_vector(to_unsigned(2,12));
		inputA <= std_logic_vector(to_unsigned(2,32));
		wait until rising_edge(clock);
		addrA <= std_logic_vector(to_unsigned(3,12));
		inputA <= std_logic_vector(to_unsigned(3,32));
		wait until rising_edge(clock); 
		addrA <= std_logic_vector(to_unsigned(4,12));
		inputA <= std_logic_vector(to_unsigned(4,32));
		wait until rising_edge(clock);
		addrA <= std_logic_vector(to_unsigned(5,12));
		inputA <= std_logic_vector(to_unsigned(5,32));
		wait until rising_edge(clock);				  
		addrA <= std_logic_vector(to_unsigned(6,12));
		inputA <= std_logic_vector(to_unsigned(6,32));
		wait until rising_edge(clock);			  
		addrA <= std_logic_vector(to_unsigned(7,12));
		inputA <= std_logic_vector(to_unsigned(7,32));
		wait until rising_edge(clock);
		wrA <= '0';
		readyA <= '0';
		
		wait until rising_edge(clock);
		readyB <= '1';
		
		
		 
		
		wait until rising_edge(clock);
		addrB <= std_logic_vector(to_unsigned(2,12));
		wrB <= '0'; 
		wait until rising_edge(clock); 
		addrB <= std_logic_vector(to_unsigned(4,12));
		wait until rising_edge(clock);
		addrB <= std_logic_vector(to_unsigned(1,12));
		wait until rising_edge(clock);
		addrB <= std_logic_vector(to_unsigned(5,12));
		wait until rising_edge(clock);
		addrB <= std_logic_vector(to_unsigned(7,12));
		wait until rising_edge(clock);
		addrB <= std_logic_vector(to_unsigned(3,12));
		wait until rising_edge(clock);
		addrB <= std_logic_vector(to_unsigned(6,12));
		wait until rising_edge(clock);
		readyB <= '0';
 

		
		
		
		
	
	
	
		
		
		wait ;
	end process;


END;
