LIBRARY ieee;
USE ieee.std_logic_1164.all;
package sram_types is
	subtype sram_address is std_logic_vector(11 downto 0); -- 2^12 = 4096x32bit sram
	subtype sram_data is std_logic_vector(31 downto 0);   --32bit float points
	type sram_mode is ( idle, read, write );
end package sram_types;


--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--USE work.sram_types.all;
--package sram_components is
--component sram is
--	PORT (
--		reset, clock : IN STD_LOGIC;
--		addr : IN sram_address;
--		input : IN sram_data;
--		output : OUT sram_data;
--		mode : IN sram_mode;
--		ready : OUT STD_LOGIC
--	);
--end component;
--end package sram_components;
--
--
--LIBRARY ieee;
--USE ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
--library ieee; use work.sram_types.all;
--
--ENTITY sram is
--	port (
--	    reset : IN std_logic; 
--	    clock : IN std_logic;
--		addr  : IN sram_address;
--		input : IN sram_data;
--		output : OUT sram_data;
--		mode   : IN sram_mode;
--		ready  : OUT std_logic
--	);
--END ENTITY sram;
--
--ARCHITECTURE rtl OF sram IS
--	TYPE states IS (init, idle, read, write, write_complete);
--	SIGNAL state : states := idle;
--	SIGNAL sram_we : std_logic := '0';
--	SIGNAL sram_input : sram_data := (others => '0');
--	SIGNAL sram_output : sram_data := (others => '0');
--	signal ClockEn   : std_logic := '0';
--	
--	signal SRAM_ADDR : std_logic_vector(11 downto 0);
--	signal SRAM_DQ_I : std_logic_vector(31 downto 0);
--	signal SRAM_DQ_O : std_logic_vector(31 downto 0);
--	
--	COMPONENT ram_dq
--	PORT(
--		Clock   : IN std_logic;
--		ClockEn : IN std_logic;
--		Reset   : IN std_logic;
--		WE      : IN std_logic;
--		Address : IN std_logic_vector(11 downto 0);
--		Data    : IN std_logic_vector(31 downto 0);          
--		Q       : OUT std_logic_vector(31 downto 0)
--		);
--	END COMPONENT;
--	
--	
--BEGIN
--	output <= sram_output;
--	sram_input <= input;
--	
--	ram_dq_0 : ram_dq
--    port map(
--     Clock   => clock,
--     ClockEn => ClockEn,
--     Reset   => reset, 
--     WE      => sram_we,
--     Address => SRAM_ADDR,
--     Data    => SRAM_DQ_I,
--     Q       => SRAM_DQ_O
--	 );
--	
--	
--	
--	fsm: PROCESS(clock, reset) IS
--	BEGIN
--		IF (reset = '1') THEN
--			ready <= '0';
--			sram_we <= '0';  
--			state <= init;
--			ClockEn <= '1';
--		ELSIF rising_edge(clock) THEN
--			CASE state IS
--				WHEN init =>
--				ready <= '0';
--				sram_we <= '0'; 
--				state <= idle;
--				
--				WHEN idle =>
--				CASE mode IS
--					WHEN idle =>
--					    ready <= '1';
--				        sram_we <= '0'; 
--				        state <= idle;
--			        WHEN read =>
--			            ready <= '0';
--				        sram_we <= '0';
--						SRAM_ADDR <= addr;
--				        state <= read;
--					WHEN write =>
--			            ready <= '0'; 
--				        SRAM_ADDR <= addr;
--				        SRAM_DQ_I <= sram_input;
--				        sram_we <= '1';
--				        state <= write;
--					WHEN others =>
--				        state <= idle;
--				END CASE;
--
--
--		        WHEN read =>
--			        sram_output <= SRAM_DQ_O;
--					ready <= '1';
--					state <= idle;
--		
--				WHEN write =>
--				    sram_we <= '0';
--					ready <= '1';
--					state <= idle;
--		
--				WHEN others =>
--					state <= init;
--				END CASE;
--			END IF;
--END PROCESS;  
--
--
--
--
--END ARCHITECTURE rtl;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.sram_types.all;


entity sram is
	port(
		reset : IN std_logic; 
	    clock : IN std_logic;
		addr  : IN sram_address;
		input : IN sram_data;
		output : OUT sram_data;
		we   : IN std_logic;
		ready  : OUT std_logic
	);
end entity sram;

architecture rtl of sram is

	
COMPONENT ram_dq
	PORT(
		Clock   : IN std_logic;
		ClockEn : IN std_logic;
		Reset   : IN std_logic;
		WE      : IN std_logic;
		Address : IN std_logic_vector(11 downto 0);
		Data    : IN std_logic_vector(31 downto 0);          
		Q       : OUT std_logic_vector(31 downto 0)
		);
END COMPONENT;

	SIGNAL sram_we : std_logic := '0';
	SIGNAL sram_input : sram_data := (others => '0');
	SIGNAL sram_output : sram_data := (others => '0');
	signal sram_addr : sram_address;
	signal ClockEn   : std_logic := '1';
	
	
BEGIN
	output <= sram_output;
	sram_input <= input;
	sram_we <= we;
	sram_addr <= addr;
	
	ram_dq_0 : ram_dq
    port map(
     Clock   => clock,
     ClockEn => ClockEn,
     Reset   => reset, 
     WE      => sram_we,
     Address => sram_addr,
     Data    => sram_input,
     Q       => sram_output
	 );
	 





END ARCHITECTURE rtl;



