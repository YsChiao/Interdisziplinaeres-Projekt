LIBRARY ieee;
USE ieee.std_logic_1164.all;
package sram_dp_types is
	subtype sram_address is std_logic_vector(11 downto 0); -- 2^12 = 4096x32bit sram
	subtype sram_data is std_logic_vector(31 downto 0);   --32bit float points
	type sram_mode is ( idle, read, write );
end package sram_dp_types;

--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.sram_dp_types.all;
--package sram_dp_components is
--component sram_dp is
--	port (
--		resetA : in std_logic;
--        resetB : in std_logic;		
--		clockA : in std_logic;
--		clockB : in std_logic;
--		addrA : in sram_address;
--		addrB : in sram_address; 
--		inputA : in sram_data;
--		inputB : in sram_data;
--		outputA : out sram_data;
--		outputB : out sram_data;
--		modeA  : in sram_mode;
--		modeB  : in sram_mode;
--		readyA : out std_logic;
--		readyB : out STD_LOGIC
--	);
--end component;
--end package sram_dp_components;
--
--
--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
--library ieee; use work.sram_dp_types.all;
--
--entity sram_dp is
--	port (
--		resetA : in std_logic;
--        resetB : in std_logic;		
--		clockA : in std_logic;
--		clockB : in std_logic;
--		addrA : in sram_address;
--		addrB : in sram_address; 
--		inputA : in sram_data;
--		inputB : in sram_data;
--		outputA : out sram_data;
--		outputB : out sram_data;
--		modeA  : in sram_mode;
--		modeB  : in sram_mode;
--		readyA : out std_logic;
--		readyB : out std_logic
--	);
--end entity sram_dp;
--
--
--ARCHITECTURE rtl OF sram_dp IS
--
--
--
--
--	TYPE statesA IS (init, idle, read, write, write_complete);
--	SIGNAL stateA : statesA := idle;
--	SIGNAL sram_we_A : std_logic := '0';
--	SIGNAL sram_input_A : sram_data := (others => '0');
--	SIGNAL sram_output_A : sram_data := (others => '0');
--	signal ClockEnA   : std_logic := '0';
--	
--	signal SRAM_ADDR_A : std_logic_vector(11 downto 0);
--	signal SRAM_DQ_I_A : std_logic_vector(31 downto 0);
--	signal SRAM_DQ_O_A : std_logic_vector(31 downto 0);	 
--	
--	
--	TYPE statesB IS (init, idle, read, write, write_complete);
--	SIGNAL stateB : statesB := idle;
--	SIGNAL sram_we_B : std_logic := '0';
--	SIGNAL sram_input_B : sram_data := (others => '0');
--	SIGNAL sram_output_B : sram_data := (others => '0');
--	signal ClockEnB   : std_logic := '0';
--	
--	signal SRAM_ADDR_B : std_logic_vector(11 downto 0);
--	signal SRAM_DQ_I_B : std_logic_vector(31 downto 0);
--	signal SRAM_DQ_O_B : std_logic_vector(31 downto 0);
--	
--
--	
--component ram_dp_true 
--    port (
--        DataInA: in  std_logic_vector(31 downto 0); 
--        DataInB: in  std_logic_vector(31 downto 0); 
--        AddressA: in  std_logic_vector(11 downto 0); 
--        AddressB: in  std_logic_vector(11 downto 0); 
--        ClockA: in  std_logic; 
--        ClockB: in  std_logic; 
--        ClockEnA: in  std_logic; 
--        ClockEnB: in  std_logic; 
--        WrA: in  std_logic; 
--        WrB: in  std_logic; 
--        ResetA: in  std_logic; 
--        ResetB: in  std_logic; 
--        QA: out  std_logic_vector(31 downto 0); 
--        QB: out  std_logic_vector(31 downto 0));
--end component;
--
--
--component true_dual_port_ram_single_clock is
--	generic (
--		DATA_WIDTH : natural := 32;
--		ADDR_WIDTH : natural := 12
--	);
--	port (
--	clk : in std_logic;
--	addr_a : in natural range 0 to 2**ADDR_WIDTH - 1;
--	addr_b : in natural range 0 to 2**ADDR_WIDTH - 1;
--	data_a : in std_logic_vector((DATA_WIDTH-1) downto 0);
--	data_b : in std_logic_vector((DATA_WIDTH-1) downto 0);
--	we_a : in std_logic := '1';
--	we_b : in std_logic := '1';
--	q_a : out std_logic_vector((DATA_WIDTH -1) downto 0);
--	q_b : out std_logic_vector((DATA_WIDTH -1) downto 0)
--	);
--end component;
--
--
--BEGIN
--	outputA <= sram_output_A;
--	outputB <= sram_output_B;
--	
--	sram_input_A <= inputA;
--	sram_input_B <= inputB;
--	
--	
--	ram_dq_true0 : ram_dp_true
--    port map(
--   		DataInA => SRAM_DQ_I_A,
--        DataInB => SRAM_DQ_I_B,
--        AddressA => SRAM_ADDR_A, 
--        AddressB => SRAM_ADDR_B,
--        ClockA => clockA, 
--        ClockB => clockB,
--        ClockEnA => ClockEnA,
--        ClockEnB => ClockEnB, 
--        WrA => sram_we_A,
--        WrB => sram_we_B, 
--        ResetA => resetA,
--        ResetB => resetB,
--        QA => SRAM_DQ_O_A,
--        QB => SRAM_DQ_O_B
--	 );
--	 	
--	fsmA: PROCESS(clockA, resetA) IS
--	BEGIN
--		IF (resetA = '1') THEN
--			readyA <= '0';
--			sram_we_A <= '0';  
--			stateA <= init;
--			ClockEnA <= '1';
--		ELSIF rising_edge(clockA) THEN
--			CASE stateA IS
--				WHEN init =>
--				readyA <= '0';
--				sram_we_A <= '0'; 
--				stateA <= idle;
--				
--				WHEN idle =>
--				CASE modeA IS
--					WHEN idle =>
--					    readyA <= '1';
--				        sram_we_A <= '0'; 
--				        stateA <= idle;
--			        WHEN read =>
--			            readyA <= '0';
--				        sram_we_A <= '0';
--						SRAM_ADDR_A <= addrA;
--				        stateA <= read;
--					WHEN write =>
--			            readyA <= '0'; 
--				        SRAM_ADDR_A <= addrA;
--				        SRAM_DQ_I_A <= sram_input_A;
--				        sram_we_A <= '1';
--				        stateA <= write;
--					WHEN others =>
--				        stateA <= idle;
--				END CASE;
--
--
--		        WHEN read =>
--			        sram_output_A <= SRAM_DQ_O_A;
--					readyA <= '1';
--					stateA <= idle;
--		
--				WHEN write =>
--				    sram_we_A <= '0';
--					readyA <= '1';
--					stateA <= idle;
--		
--				WHEN others =>
--					stateA <= init;
--				END CASE;
--			END IF;
--	END PROCESS; 
--	
--	
--	fsmB: PROCESS(clockB, resetB) IS
--	BEGIN
--		IF (resetB = '1') THEN
--			readyB<= '0';
--			sram_we_B <= '0';  
--			stateB <= init;
--			ClockEnB <= '1';
--		ELSIF rising_edge(clockB) THEN
--			CASE stateB IS
--				WHEN init =>
--				readyB <= '0';
--				sram_we_B <= '0'; 
--				stateB <= idle;
--				
--				WHEN idle =>
--				CASE modeB IS
--					WHEN idle =>
--					    readyB <= '1';
--				        sram_we_B <= '0'; 
--				        stateB <= idle;
--			        WHEN read =>
--			            readyB <= '0';
--				        sram_we_B <= '0';
--						SRAM_ADDR_B <= addrB;
--				        stateB <= read;
--					WHEN write =>
--			            readyB <= '0'; 
--				        SRAM_ADDR_B <= addrB;
--				        SRAM_DQ_I_B <= sram_input_B;
--				        sram_we_B <= '1';
--				        stateB <= write;
--					WHEN others =>
--				        stateB <= idle;
--				END CASE;
--
--
--		        WHEN read =>
--			        sram_output_B <= SRAM_DQ_O_B;
--					readyB <= '1';
--					stateB <= idle;
--		
--				WHEN write =>
--				    sram_we_B <= '0';
--					readyB <= '1';
--					stateB <= idle;
--		
--				WHEN others =>
--					stateB <= init;
--				END CASE;
--			END IF;
--	END PROCESS; 
--
--end rtl; 















LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 
library work;
use work.sram_dp_types.all;

entity sram_dp is
	port (
		resetA : in std_logic;
        resetB : in std_logic;		
		clockA : in std_logic;
		clockB : in std_logic;
		addrA : in sram_address;
		addrB : in sram_address; 
		inputA : in sram_data;
		inputB : in sram_data;
		outputA : out sram_data;
		outputB : out sram_data;
		wrA  : in std_logic;
		wrB  : in std_logic;
		readyA : in std_logic;
		readyB : in std_logic
	);
end entity sram_dp;


ARCHITECTURE rtl OF sram_dp IS


	SIGNAL sram_we_A : std_logic := '0';
	SIGNAL sram_input_A : sram_data := (others => '0');
	SIGNAL sram_output_A : sram_data := (others => '0');
	SIGNAL sram_addr_A : sram_address;
	signal ClockEnA   : std_logic := '0';
		
	
	SIGNAL sram_we_B : std_logic := '0';
	SIGNAL sram_input_B : sram_data := (others => '0');
	SIGNAL sram_output_B : sram_data := (others => '0');
	SIGNAL sram_addr_B : sram_address;
	signal ClockEnB   : std_logic := '0';
	

	

	
component ram_dp_true 
    port (
        DataInA: in  std_logic_vector(31 downto 0); 
        DataInB: in  std_logic_vector(31 downto 0); 
        AddressA: in  std_logic_vector(11 downto 0); 
        AddressB: in  std_logic_vector(11 downto 0); 
        ClockA: in  std_logic; 
        ClockB: in  std_logic; 
        ClockEnA: in  std_logic; 
        ClockEnB: in  std_logic; 
        WrA: in  std_logic; 
        WrB: in  std_logic; 
        ResetA: in  std_logic; 
        ResetB: in  std_logic; 
        QA: out  std_logic_vector(31 downto 0); 
        QB: out  std_logic_vector(31 downto 0));
end component;


BEGIN
	outputA <= sram_output_A;
	outputB <= sram_output_B;
	
	sram_input_A <= inputA;
	sram_input_B <= inputB;
	
	sram_we_A <= wrA;
	sram_we_B <= wrB;
	
	sram_addr_A <= addrA;
	sram_addr_B <= addrB;
	
	ClockEnA  <= readyA;
	ClockEnB  <= readyB;
	
	
	ram_dq_true0 : ram_dp_true
    port map(
   		DataInA => sram_input_A,
        DataInB => sram_input_B,
        AddressA => sram_addr_A, 
        AddressB => sram_addr_B,
        ClockA => clockA, 
        ClockB => clockB,
        ClockEnA => ClockEnA,
        ClockEnB => ClockEnB, 
        WrA => sram_we_A,
        WrB => sram_we_B, 
        ResetA => resetA,
        ResetB => resetB,
        QA => sram_output_A,
        QB => sram_output_B
	 );
	 	
end rtl; 

























