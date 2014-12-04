
-- VHDL Test Bench Created from source file fp_exp_clk.vhd -- Thu Jun 19 18:55:02 2014

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

COMPONENT fp_exp_clk
 generic ( wE : positive := 6;
           wF : positive := 13 );
	PORT(
		fpX : IN std_logic_vector(33 downto 0);
		clk : IN std_logic;          
		fpR : OUT std_logic_vector(33 downto 0)
		);
	END COMPONENT;

	SIGNAL fpX :  std_logic_vector(33 downto 0);
	SIGNAL fpR :  std_logic_vector(33 downto 0);
	SIGNAL clk :  std_logic;
	
	signal clk_period : time := 20 ns;

BEGIN

-- Please check and add your generic clause manually
uut: fp_exp_clk 
generic map( 
        wE =>8,
        wF =>23 )
PORT MAP(
		fpX => fpX,
		fpR => fpR,
		clk => clk
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
	wait until rising_edge(clk);

	fpX <= "01" & x"400ccccd";
	wait;
end process;
--
END;
