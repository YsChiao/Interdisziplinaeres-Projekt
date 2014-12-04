
-- VHDL Test Bench Created from source file spi2.vhd -- Sat Aug 30 10:42:01 2014

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

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	component spi2
	port(	clk : in std_logic;
 	
			write_data : in std_logic_vector(7 downto 0);
			write_req : in std_logic; 
			read_data : out std_logic_vector(7 downto 0);
			new_data : inout std_logic; 
			spi_clk  : inout std_logic;
			spi_miso : inout std_logic;
			spi_mosi : inout std_logic;
			spi_cs : in std_logic
		);
	end component;


	SIGNAL write_data :  std_logic_vector(7 downto 0);
	SIGNAL write_req :  std_logic;
	SIGNAL read_data :  std_logic_vector(7 downto 0);
	SIGNAL new_data :  std_logic;
	SIGNAL spi_clk :  std_logic;
	SIGNAL spi_miso :  std_logic;
	SIGNAL spi_mosi :  std_logic;
	SIGNAL spi_cs :  std_logic;
	
	signal DataIn  : std_logic_vector(7 downto 0);
	
	
--	 Clock period definitions
--	constant CLK_period : time := 10 ns; 
	constant SPI_CLK_HALF_PERIOD :time := 10 ns;--for 25 MHz   50Mhz
    constant SYS_CLK_HALF_PERIOD :time := 5 ns; --for 50 MHz   100Mhz 
		
	signal clk : std_logic;
	
	
		-- procedure_spi_write-----------------------
	procedure spi_wr_rd_8b(signal data : in std_logic_vector(7 downto 0);
	    signal clk : in std_logic;
		signal scsn : out std_logic;
		signal sclk : out std_logic;
		signal si   : out std_logic) is
						
		begin
			scsn <= '1';
			wait for 200ns;
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
	uut : spi2 
	port map(	clk=> clk,
 	
				write_data => write_data,
				write_req => write_req,
								
				read_data => read_data,
				new_data => new_data,
				spi_clk  =>spi_clk,
				spi_miso =>spi_miso,
				spi_mosi =>spi_mosi,
				spi_cs => spi_cs
			);	



	-- clk
	process
		begin
		clk <= '0';
		wait for  SYS_CLK_HALF_PERIOD;
		clk <= '1';
		wait for  SYS_CLK_HALF_PERIOD;
	end process;
	
	
	read_from_file: process
	variable indata_line: line;
	variable indata: integer;
	file input_data_file: text open read_mode is "C:\Users\Yisong\Documents\Matlab\median filter\image1_640x360_noise.bin";
	begin 
	wait until falling_edge(spi_cs);
		readline(input_data_file, indata_line);
		read(indata_line,indata);
		DataIn <= conv_std_logic_vector(indata,8);
		if endfile(input_data_file) then
			report "end of file -- looping back to start of file";
			file_close(input_data_file);
			file_open(input_data_file,"C:\Users\Yisong\Documents\Matlab\median filter\image1_640x360_noise.bin");
			wait;
	    end if;
end process;  
	
	
	master_process : process 

	begin
		spi_cs <= '1';
		wait until rising_edge(clk);
		
		for i in 1 to 231058 loop	   	  -- 165890 us for 640x360 8bit 
			spi_wr_rd_8b(DataIn, clk, spi_cs, spi_clk, spi_mosi);
			report "The value of 'i' is " & integer'image(i);	
		end loop;
		


	
	
		
		
		wait ;
	end process;


END;
