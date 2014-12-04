
-- VHDL Test Bench Created from source file window_3x3.vhd -- Tue Jun 17 17:08:24 2014

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
USE ieee.std_logic_arith.ALL;
use std.textio.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT window_3x3
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		datain: IN std_logic_vector(7 downto 0);          
		w11 : OUT std_logic_vector(7 downto 0);
		w12 : OUT std_logic_vector(7 downto 0);
		w13 : OUT std_logic_vector(7 downto 0);
		w21 : OUT std_logic_vector(7 downto 0);
		w22 : OUT std_logic_vector(7 downto 0);
		w23 : OUT std_logic_vector(7 downto 0);
		w31 : OUT std_logic_vector(7 downto 0);
		w32 : OUT std_logic_vector(7 downto 0);
		w33 : OUT std_logic_vector(7 downto 0);
		DV : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic;
	SIGNAL rst :  std_logic;
	SIGNAL datain:  std_logic_vector(7 downto 0);
	SIGNAL w11 :  std_logic_vector(7 downto 0);
	SIGNAL w12 :  std_logic_vector(7 downto 0);
	SIGNAL w13 :  std_logic_vector(7 downto 0);
	SIGNAL w21 :  std_logic_vector(7 downto 0);
	SIGNAL w22 :  std_logic_vector(7 downto 0);
	SIGNAL w23 :  std_logic_vector(7 downto 0);
	SIGNAL w31 :  std_logic_vector(7 downto 0);
	SIGNAL w32 :  std_logic_vector(7 downto 0);
	SIGNAL w33 :  std_logic_vector(7 downto 0);
	SIGNAL DV :  std_logic;	  
	
	signal clk_period : time := 5 ns;

BEGIN

-- Please check and add your generic clause manually
	uut: window_3x3 PORT MAP(
		clk => clk,
		rst => rst,
		datain=> datain,
		w11 => w11,
		w12 => w12,
		w13 => w13,
		w21 => w21,
		w22 => w22,
		w23 => w23,
		w31 => w31,
		w32 => w32,
		w33 => w33,
		DV => DV
	);


---- *** Test Bench - User Defined Section ***
--   tb : PROCESS
--   BEGIN
--      wait; -- will wait forever
--   END PROCESS;
---- *** End Test Bench - User Defined Section *** 
--
clk_process : process
begin
	clk <= '0'; wait for clk_period;
	clk <= '1'; wait for clk_period;
end process;

reset_process : process
begin 
	rst <= '1'; wait for 10 ns;
	rst <= '0'; wait;
end process;

read_from_file: process
variable indata_line: line;
variable indata: integer;
file input_data_file: text open read_mode is "lena_128x128.bin";
begin 
	wait until rising_edge(clk);
		readline(input_data_file, indata_line);
		read(indata_line,indata);
		datain <= conv_std_logic_vector(indata,8);
		if endfile(input_data_file) then
		  report "end of file -- looping back to start of file";
		  wait;
	    end if;
end process; 


END;
