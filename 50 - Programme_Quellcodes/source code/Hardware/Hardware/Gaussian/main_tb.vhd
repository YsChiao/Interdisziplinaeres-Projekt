
-- VHDL Test Bench Created from source file main.vhd -- Mon Sep 08 19:18:00 2014

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

ENTITY testbench IS
END testbench;

library std;
USE std.textio.all;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT main
	PORT(
		SCLK : IN std_logic;
		MOSI : IN std_logic;
		CE1 : IN std_logic;
		GSRn : IN std_logic;
		MISO : OUT std_logic;
		SDA  : IN std_logic;
		
        readin : out std_logic_vector( 7 downto 0);
	    writeout : out std_logic_vector( 7 downto 0); 
		new_data : inout std_logic;
		dv     : out std_logic;
		
		clock : inout std_logic
		);
	END COMPONENT;

	SIGNAL SCLK :  std_logic;
	SIGNAL MOSI :  std_logic;
	SIGNAL MISO :  std_logic;
	SIGNAL CE1 :  std_logic;
	SIGNAL GSRn :  std_logic;
	SIGNAL SDA :  std_logic; 
	
	signal readin :  std_logic_vector(7 downto 0);
	signal writeout : std_logic_vector(7 downto 0);
	signal clock : std_logic;
	signal new_data : std_logic; 
	signal dv : std_logic;
	
	
		-- Clock period definitions
	constant SPI_CLK_HALF_PERIOD :time := 10 ns;--for 50Mhz
    constant SYS_CLK_HALF_PERIOD :time := 5 ns; --for 100Mhz
		
    signal DataIn  : std_logic_vector(7 downto 0);													 
	

		-- procedure_spi_write-----------------------
	procedure spi_wr_rd_8b(signal data : in std_logic_vector(7 downto 0);
	    signal clk : in std_logic;
		signal scsn : out std_logic;
		signal sclk : out std_logic;
		signal si   : out std_logic) is
						
		begin
			scsn <= '1';
			wait for SPI_CLK_HALF_PERIOD;
			scsn <= '0';
			
			for i in 0 to 7 loop	   -- send data
				sclk <= '0';
				si <= data(7-i); 
				wait for SPI_CLK_HALF_PERIOD;
				sclk <= '1';
				wait for SPI_CLK_HALF_PERIOD;
			end loop;
			
			sclk <= '0';
			wait for SPI_CLK_HALF_PERIOD;
			scsn <= '1';
	end spi_wr_rd_8b;

BEGIN

-- Please check and add your generic clause manually
	uut: main PORT MAP(
		SCLK => SCLK,
		MOSI => MOSI,
		MISO => MISO,
		CE1 => CE1,
		GSRn => GSRn,
		SDA => SDA,
		clock => clock,
		readin => readin,
		writeout => writeout, 
		new_data => new_data,
		dv  => dv
		
		
		
	); 
	
	
read_from_file: process
variable indata_line: line;
variable indata: integer;
file input_data_file: text open read_mode is "C:\Users\Yisong\Documents\Matlab\convolution\muenchen_640x360.bin";	   
begin 
	wait until falling_edge(CE1);
		readline(input_data_file, indata_line);
		read(indata_line,indata);
		DataIn <= conv_std_logic_vector(indata,8);
		if endfile(input_data_file) then
			report "end of file -- looping back to start of file";
			file_close(input_data_file);
			file_open(input_data_file,"C:\Users\Yisong\Documents\Matlab\convolution\muenchen_640x360.bin");
			wait;
	    end if;
end process; 

write_to_file: process
variable outdata_line: line;
variable outdata: integer:=0;
file output_data_file: text open write_mode  is "C:\Users\Yisong\Documents\Matlab\convolution\muenchen_640x360_vhdl.bin";	 
begin 
	wait until falling_edge(CE1); 
		outdata := conv_integer(unsigned(writeout));
		if DV = '1' then  
			report "write to file ";
			write(outdata_line,outdata);
			writeline(output_data_file,outdata_line);
		end if;
end process;




master_process : process 

	begin
		CE1 <= '1';
		SDA <= '1';
		GSRn <= '0';
		
		wait until rising_edge(clock);
		SDA <= '0';
		GSRn <= '1';
		wait until rising_edge(clock);
		
		for i in 1 to 231050 loop	   	  -- ---44582652 ns for 640x360 8bit 
			spi_wr_rd_8b(DataIn,clock, CE1, SCLK, MOSI);
			report "The value of 'i' is " & integer'image(i);	
		end loop;
		

	
	
		
		
		wait ;
	end process;




END;
