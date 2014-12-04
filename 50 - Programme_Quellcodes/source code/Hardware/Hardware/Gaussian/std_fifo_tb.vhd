
-- VHDL Test Bench Created from source file std_fifo.vhd -- Tue Jun 17 16:24:33 2014

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

    COMPONENT std_fifo
	Generic (
		constant DATA_WIDTH : positive := 8;
		constant FIFO_DEPTH : positive := 128
	);
	PORT(
		CLK : IN std_logic;
		RST : IN std_logic;
		WriteEn : IN std_logic;
		DataIn : IN std_logic_vector(7 downto 0);
		ReadEn : IN std_logic;          
		DataOut : OUT std_logic_vector(7 downto 0);
		Empty : OUT std_logic;
		Full : OUT std_logic;
		USEDW : OUT integer
		);
	END COMPONENT;

	SIGNAL CLK :  std_logic;
	SIGNAL RST :  std_logic;
	SIGNAL WriteEn :  std_logic;
	SIGNAL DataIn :  std_logic_vector(7 downto 0);
	SIGNAL ReadEn :  std_logic;
	SIGNAL DataOut :  std_logic_vector(7 downto 0);
	SIGNAL Empty :  std_logic;
	SIGNAL Full :  std_logic;
	SIGNAL USEDW :  integer; 
	
	-- Clock period definitions
	constant CLK_period : time := 20 ns;

BEGIN

-- Please check and add your generic clause manually
    uut: std_fifo 
		generic map(
		DATA_WIDTH => 8,
		FIFO_DEPTH => 128
	    )
        PORT MAP(
		CLK => CLK,
		RST => RST,
		WriteEn => WriteEn,
		DataIn => DataIn,
		ReadEn => ReadEn,
		DataOut => DataOut,
		Empty => Empty,
		Full => Full,
		USEDW => USEDW
	);


-- Clock process definitions
	CLK_process :process
	begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
	end process;
	
	master_process : process 
	variable counter : unsigned (7 downto 0) := (others => '0');
	
	begin
		wait for 20 ns;
		RST <= '1';
		wait until rising_edge(clk);
		RST <= '0';	
		
		wait until rising_edge(clk);
		WriteEn <= '1'; 
		ReadEn  <= '0';
		
		for i in 1 to 128*128 loop
			counter := counter + 1;
			
			wait until rising_edge(clk); 
			if USEDW = 123 then
				ReadEn <= '1';
			end if;
			DataIn <= std_logic_vector(counter); 
	
		end loop;
		wait;
	end process; 
		
END;
