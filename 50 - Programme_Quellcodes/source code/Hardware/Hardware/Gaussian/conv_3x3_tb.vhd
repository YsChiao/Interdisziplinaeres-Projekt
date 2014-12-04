
-- VHDL Test Bench Created from source file conv_3x3.vhd -- Tue Jun 17 23:37:42 2014

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


-------------------------------------------------------------------
--filename: conv_3x3_tb.vhd
--detial : TestBench for sort_filter 
--	read image data form specified file and write processed data
--	to vhdl_output.bin
--	To use this functionality, use the following method for
--  determining simulation length:
--
--  t_valid = time when output data first becomes valid
--  t_delay = t_valid - 5 ns
--  t_sim_stop = 163835 ns + t_delay + 10 ns
--  this is 165305ns for this entity 128x128
--  this is 2310505ns for this entity 640x360
----------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
LIBRARY STD;
USE std.textio.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT conv_3x3
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		DataIn : IN std_logic_vector(7 downto 0);          
		DataOut : OUT std_logic_vector(16 downto 0);
		DV : OUT std_logic
		);
	END COMPONENT;

	SIGNAL clk :  std_logic;
	SIGNAL rst :  std_logic;
	SIGNAL DataIn :  std_logic_vector(7 downto 0) :=(others=>'0');
	SIGNAL DataOut :  std_logic_vector(16 downto 0);
	SIGNAL DV :  std_logic;	 
	
	signal clk_period : time := 5 ns;

BEGIN

-- Please check and add your generic clause manually
	uut: conv_3x3 PORT MAP(
		clk => clk,
		rst => rst,
		DataIn => DataIn,
		DataOut => DataOut,
		DV => DV
	);

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
file input_data_file: text open read_mode is "C:\Users\Yisong\Documents\Matlab\convolution\muenchen_640x360.bin";
begin 
	wait until rising_edge(clk);
		readline(input_data_file, indata_line);
		read(indata_line,indata);
		DataIn <= conv_std_logic_vector(indata,8);
		if endfile(input_data_file) then
		    report "end of file -- looping back to start of file";
			wait;
	    end if;
end process; 

write_to_file: process
variable outdata_line: line;
variable outdata: integer:=0;
file output_data_file: text open write_mode  is "C:\Users\Yisong\Documents\Matlab\convolution\gaussian_vhdl.bin";	 
begin 
	wait until rising_edge(clk); 
		outdata := conv_integer(unsigned(DataOut));
		if DV = '1' then
			report "write to file ";
			write(outdata_line,outdata);
			writeline(output_data_file,outdata_line);
		end if;
end process;

			



END;
