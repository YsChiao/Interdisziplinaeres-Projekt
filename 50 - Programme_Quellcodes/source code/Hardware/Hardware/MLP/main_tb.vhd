
-- VHDL Test Bench Created from source file main.vhd -- Fri Aug 29 02:31:28 2014

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
LIBRARY work;
USE work.float_types.all;
USE work.mlp_pkg.all;

library std;
USE std.textio.all;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT main
	PORT(
		SCLK : IN std_logic;
		MOSI : IN std_logic;
		CE1 : IN std_logic;
		GSRn : IN std_logic;
		MISO : OUT std_logic;
		SDA  : IN std_logic;
		GPIO17 : IN std_logic;
		GPIO18 : in std_logic;
		
--        readin : out std_logic_vector( 7 downto 0);
--		--writeout : out std_logic_vector( 7 downto 0);
		new_data : inout std_logic;
--		data_done : inout std_logic;
		weight_done   : out std_logic;
--		ramDataIn : inout std_logic_vector(31 downto 0);
--		
--		sram_input_A : inout std_logic_vector(31 downto 0);
--		sram_output_B : inout std_logic_vector(31 downto 0);
--
		mlp_outputs : inout float_vector(N_O - 1 downto 0);
		mlp_done : inout std_logic; 
--		
		output_new : out std_logic;
		output_done : out std_logic;
--		
--		data : out std_logic_vector(31 downto 0);
		
		clock : inout std_logic
		);	   
	END COMPONENT;

	SIGNAL SCLK :  std_logic;
	SIGNAL MOSI :  std_logic;
	SIGNAL MISO :  std_logic;
	SIGNAL CE1 :  std_logic;
	SIGNAL GSRn :  std_logic;
	SIGNAL SDA :  std_logic;
	SIGNAL GPIO17 : std_logic;
	SIGNAL GPIO18 : std_logic;
	

--	signal readin :  std_logic_vector(7 downto 0);
--	signal writeout : std_logic_vector(7 downto 0);
	signal clock : std_logic;
	signal new_data : std_logic;
    signal weight_done : std_logic;
--	signal data_done : std_logic; 
--	
	signal mlp_outputs :  float_vector(N_O - 1 downto 0);
	signal mlp_done    : std_logic;
--	signal ramDataIn : std_logic_vector(31 downto 0);
--    signal sram_input_A      : std_logic_vector(31 downto 0);
--	signal sram_output_B      : std_logic_vector(31 downto 0);
	
	signal data : std_logic_vector(31 downto 0);
	
	signal output_new : std_logic;
	signal output_done : std_logic;
	
	-- Clock period definitions
	constant SPI_CLK_HALF_PERIOD :time := 64 ns;--for 7.8125MHz
    constant SYS_CLK_HALF_PERIOD :time := 5 ns; --for 50 MHz   100Mhz
	
	
	signal DataIn  : std_logic_vector(7 downto 0);
    --signal DataOut : std_logic_vector(7 downto 0);														 
	
	-- procedure_spi_write-----------------------
	procedure spi_wr_rd_8b(signal data : in std_logic_vector(7 downto 0);
	    signal clk : in std_logic;
		signal scsn : out std_logic;
		signal sclk : out std_logic;
		signal si   : out std_logic) is
						
		begin
			scsn <= '1';
			wait for 200 ns;
			--wait for SPI_CLK_HALF_PERIOD;
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
	
	
	-- procedure_spi_write-----------------------
	procedure spi_wr_rd_32b(signal data : in std_logic_vector(31 downto 0);
	    signal clk : in std_logic;
		signal scsn : out std_logic;
		signal sclk : out std_logic;
		signal si   : out std_logic) is
						
		begin
			scsn <= '1';
			wait for 200 ns;
			--wait for SPI_CLK_HALF_PERIOD;
			scsn <= '0';

			for i in 0 to 31 loop	   -- send data
				sclk <= '0';
				si <= data(31-i);
				wait for SPI_CLK_HALF_PERIOD;
				sclk <= '1';
				wait for SPI_CLK_HALF_PERIOD;
			end loop;
			
			sclk <= '0';
			wait for SPI_CLK_HALF_PERIOD;
			scsn <= '1';
	end spi_wr_rd_32b; 
	
	
-- procedure_spi_data2out----------------------
	procedure spi_data2out(signal data : in std_logic_vector(31 downto 0);
	    signal clk : in std_logic;
		signal scsn : out std_logic;
		signal sclk : out std_logic;
		signal so   : out std_logic) is
						
		begin
			scsn <= '1';
			wait for 200 ns;
			--wait for SPI_CLK_HALF_PERIOD;
			scsn <= '0';

			for i in 0 to 31 loop	   -- send data
				sclk <= '0';
				so <= data(31-i);
				wait for SPI_CLK_HALF_PERIOD;
				sclk <= '1';
				wait for SPI_CLK_HALF_PERIOD;
			end loop;
			
			sclk <= '0';
			wait for SPI_CLK_HALF_PERIOD;
			scsn <= '1';
	end spi_data2out;
	

					
					
										
BEGIN				
	
	
-- Please check and add your generic clause manually
	uut: main PORT MAP(
		SCLK => SCLK,
		MOSI => MOSI,
		MISO => MISO,
		CE1 => CE1,
		GSRn => GSRn,
		SDA => SDA,
		GPIO17 => GPIO17,
		GPIO18 => GPIO18,
		clock => clock,
--	    readin => readin,
--		--writeout => writeout,
		new_data => new_data,
--		data_done => data_done,
--
		mlp_outputs => mlp_outputs,
		mlp_done => mlp_done,
--		
		output_new => output_new,
		output_done => 	output_done,
--		
--		--data => data
--		
--		ramDataIn => ramDataIn,
--		sram_input_A  => sram_input_A,
--		sram_output_B  => sram_output_B,
		weight_done  => weight_done
	); 
	


read_from_file: process
variable indata_line: line;
variable indata: integer;
file input_data_file: text open read_mode is "C:\Users\Yisong\Documents\Matlab\NN\nn.bin";
begin 
	wait until falling_edge(CE1);
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
	    wait for 100 ns;
		CE1 <= '1';
		SDA <= '1';
		GSRn <= '0';
		GPIO17 <= '1';
		GPIO18 <= '1';
		wait until rising_edge(clock);
		SDA <= '0';
		GSRn <= '1';
		
		for m in 1 to 4352 loop	   --4288+16 	  as 16x32x16
			spi_wr_rd_8b(DataIn,clock, CE1, SCLK, MOSI);
			--report "The value of 'n' is " & integer'image(m);	
		end loop;
		GPIO17 <= '0';
		
		for i in 1 to 99 loop
			report "The value of 'i' is " & integer'image(i);	
			GPIO17 <= '0';
			wait for 1000 ns;
			GPIO17 <= '1';
			GPIO18 <= '0';
			for l in 1 to 64 loop	   	  
				spi_wr_rd_8b(DataIn,clock, CE1, SCLK, MOSI);
			end loop;
			wait for 1 ms;
			GPIO17 <= '0';
		end loop;
		
		for m in 1 to 10000 loop	   --4288+16 	  as 16x32x16
			spi_wr_rd_8b(DataIn,clock, CE1, SCLK, MOSI);
			report "The value of 'm' is " & integer'image(m);	
		end loop;
		
	 wait;
end process; 


 										
END;