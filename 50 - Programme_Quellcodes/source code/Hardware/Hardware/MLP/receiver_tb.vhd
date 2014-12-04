
-- VHDL Test Bench Created from source file receiver.vhd -- Wed Sep 24 20:25:53 2014

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

library std;
USE std.textio.all;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT receiver
	PORT(
		clock : IN std_logic;
		reset : IN std_logic;
		new_data : IN std_logic;
		DataIn : IN std_logic_vector(7 downto 0);          
		data_done : OUT std_logic;
		count4x : OUT integer;
		DataOut : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;

	SIGNAL clock :  std_logic;
	SIGNAL reset :  std_logic;
	SIGNAL new_data :  std_logic;
	SIGNAL data_done :  std_logic;
	SIGNAL count4x :  integer;
	SIGNAL DataIn :  std_logic_vector(7 downto 0);
	SIGNAL DataOut :  std_logic_vector(31 downto 0);
	
	-- Clock period definitions
	constant SPI_CLK_HALF_PERIOD :time := 10 ns;--for 25 MHz   50Mhz
    constant SYS_CLK_HALF_PERIOD :time := 5 ns; --for 50 MHz   100Mhz

BEGIN

-- Please check and add your generic clause manually
	uut: receiver PORT MAP(
		clock => clock,
		reset => reset,
		new_data => new_data,
		data_done => data_done,
		count4x => count4x,
		DataIn => DataIn,
		DataOut => DataOut
	);
	
	--CLK
	process
		begin
		clock <= '0';
		wait for  SYS_CLK_HALF_PERIOD;
		clock <= '1';
		wait for  SYS_CLK_HALF_PERIOD;
	end process;

read_from_file: process
variable indata_line: line;
variable indata: integer;
file input_data_file: text open read_mode is "C:\Users\Yisong\Documents\Matlab\NN\nn.bin";
begin 
	wait until falling_edge(new_data);
		readline(input_data_file, indata_line);
		read(indata_line,indata);
		DataIn <= conv_std_logic_vector(indata,8);
		if endfile(input_data_file) then
			report "end of file -- looping back to start of file";
			file_close(input_data_file);
			file_open(input_data_file, "C:\Users\Yisong\Documents\Matlab\NN\nn.bin");
			wait;
	    end if;
end process;


master_process : process 

	begin
		reset <= '1';
		wait for 10 ns;
		reset <= '0'; 
		wait for 10 ns;
		for m in 1 to 100 loop
          	new_data <= '0';
            wait for 10ns;
            new_data <= '1';
			wait for 10ns;
			report "The value of 'n' is " & integer'image(m);	
		end loop;
		
	wait ;
	end process;
		
 										
END;
