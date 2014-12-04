
-- VHDL Test Bench Created from source file main.vhd -- Tue Jun 24 09:28:43 2014

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
use work.float_types.all;  
use work.sram_types.all;
use work.ann_types.all;	
use work.mlp_pkg.all;
LIBRARY STD;
USE std.textio.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

COMPONENT mlp_all
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		inputs : IN float_vector(N_I-1 downto 0);
		outputs : OUT float_vector(N_O-1 downto 0);	
		ann_mode : in ann_mode;
		ready : out std_logic;
		done  : out std_logic
		);
	END COMPONENT;

	SIGNAL rst :  std_logic;
	SIGNAL clk :  std_logic;
	SIGNAL inputs :  float_vector(2 downto 0);
	SIGNAL outputs : float_vector(0 downto 0);
	signal ann_mode :  ann_mode;
	signal ready : std_logic;
	signal done  : std_logic;
	
	signal clk_period : time := 1 ns;

BEGIN

-- Please check and add your generic clause manually
        uut: mlp_all
        PORT MAP(
		rst => rst,
		clk => clk,
		inputs => inputs,
		outputs => outputs,
		ann_mode => ann_mode,
		ready => ready,
		done  => done
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
	wait for 20 ns; 	--20
	wait until rising_edge(clk);
	rst <= '1';
	
	wait until rising_edge(clk);
	rst <= '0';
	
	wait until rising_edge(clk) and ready = '1' ;
	ann_mode <= idle;	
	inputs(0) <= x"3f800000";  -- 1
	inputs(1) <= x"40000000";  -- 2
	inputs(2) <= x"40400000";  -- 3
--	inputs(3) <= x"40800000";  -- 4
--	inputs(4) <= x"40a00000";  -- 5
 	
	wait until rising_edge(clk) and ready = '1';
	ann_mode <= run; 
	report "end of file -- looping back to start of file";
	
	wait until rising_edge(clk) and ready = '1';
	ann_mode <= idle;
	
	
	
	

	wait;
end process;


END;
