
-- VHDL Test Bench Created from source file fp_mul.vhd -- Thu Jun 19 22:50:54 2014

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

	COMPONENT fp_mul
	PORT(
		FP_A : IN std_logic_vector(31 downto 0);
		FP_B : IN std_logic_vector(31 downto 0);
		clk : IN std_logic;
		ce : IN std_logic;          
		FP_Z : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	SIGNAL FP_A :  std_logic_vector(31 downto 0);
	SIGNAL FP_B :  std_logic_vector(31 downto 0);
	SIGNAL clk :  std_logic;
	SIGNAL ce :  std_logic;
	SIGNAL FP_Z :  std_logic_vector(31 downto 0);  
	signal clk_period : time := 40 ns;

BEGIN

-- Please check and add your generic clause manually
	uut: fp_mul PORT MAP(
		FP_A => FP_A,
		FP_B => FP_B,
		clk => clk,
		ce => ce,
		FP_Z => FP_Z
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
begin 
	wait for 20 ns; 	--100 
	ce <= '1';
	
	wait until rising_edge(clk);
	FP_A <= x"3f8ccccd";  --Hex 1.1
	FP_B <= x"400ccccd";  --Hex 2.2


	wait;
end process;
END;

