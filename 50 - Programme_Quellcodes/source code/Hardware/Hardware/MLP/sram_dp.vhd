LIBRARY ieee;
USE ieee.std_logic_1164.all;
package sram_types is
	subtype sram_address is std_logic_vector(11 downto 0); -- 2^12 = 4096x32bit sram
	subtype sram_data is std_logic_vector(31 downto 0);   --32bit float points
	type sram_mode is ( idle, read, write );
end package sram_types;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library ieee; 
use work.sram_types.all;

entity sram is
	port (
		reset : in std_logic;
		clock : in std_logic;
		addr : in sram_address;
		input : in sram_data;
		output : out sram_data;
		mode  : in sram_mode;
		ready : out std_logic;
	);
end entity sram;


ARCHITECTURE rtl OF sram IS




	TYPE states IS (init, idle, read, write, write_complete);
	SIGNAL state : states := idle;
	SIGNAL sram_we : std_logic := '0';
	SIGNAL sram_input : sram_data := (others => '0');
	SIGNAL sram_output : sram_data := (others => '0');
	signal ClockEn   : std_logic := '0';
	
	signal SRAM_ADDR : std_logic_vector(11 downto 0);
	signal SRAM_DQ_I : std_logic_vector(31 downto 0);
	signal SRAM_DQ_O : std_logic_vector(31 downto 0);	 
	
	
	

	
component ram_dp 
    port (
        WrAddress: in  std_logic_vector(11 downto 0); 
        RdAddress: in  std_logic_vector(11 downto 0); 
        Data: in  std_logic_vector(31 downto 0); 
        WE: in  std_logic; 
        RdClock: in  std_logic; 
        RdClockEn: in  std_logic; 
        Reset: in  std_logic; 
        WrClock: in  std_logic; 
        WrClockEn: in  std_logic; 
        Q: out  std_logic_vector(31 downto 0));
end component;



BEGIN
	outputA <= sram_output_A;
	
	sram_input_A <= inputA;
	
	
	ram_dp0 : ram_dp
    port map(
        WrAddress => SRAM_ADDR,
        RdAddress => SRAM_ADDR,
        Data => SRAM_ADDR,
        WE => SRAM_ADDR,
        RdClock => SRAM_ADDR,
        RdClockEn => SRAM_ADDR,
        Reset => SRAM_ADDR,
        WrClock => SRAM_ADDR,
        WrClockEn => SRAM_ADDR,
        Q => SRAM_ADDR
		);

	 	
	fsmA: PROCESS(clockA, resetA) IS
	BEGIN
		IF (resetA = '1') THEN
			readyA <= '0';
			sram_we_A <= '0';  
			stateA <= init;
			ClockEnA <= '1';
		ELSIF rising_edge(clockA) THEN
			CASE stateA IS
				WHEN init =>
				readyA <= '0';
				sram_we_A <= '0'; 
				stateA <= idle;
				
				WHEN idle =>
				CASE modeA IS
					WHEN idle =>
					    readyA <= '1';
				        sram_we_A <= '0'; 
				        stateA <= idle;
			        WHEN read =>
			            readyA <= '0';
				        sram_we_A <= '0';
						SRAM_ADDR_A <= addrA;
				        stateA <= read;
					WHEN write =>
			            readyA <= '0'; 
				        SRAM_ADDR_A <= addrA;
				        SRAM_DQ_I_A <= sram_input_A;
				        sram_we_A <= '1';
				        stateA <= write;
					WHEN others =>
				        stateA <= idle;
				END CASE;


		        WHEN read =>
			        sram_output_A <= SRAM_DQ_O_A;
					readyA <= '1';
					stateA <= idle;
		
				WHEN write =>
				    sram_we_A <= '0';
					readyA <= '1';
					stateA <= idle;
		
				WHEN others =>
					stateA <= init;
				END CASE;
			END IF;
	END PROCESS; 
	
	
	fsmB: PROCESS(clockB, resetB) IS
	BEGIN
		IF (resetB = '1') THEN
			readyB<= '0';
			sram_we_B <= '0';  
			stateB <= init;
			ClockEnB <= '1';
		ELSIF rising_edge(clockB) THEN
			CASE stateB IS
				WHEN init =>
				readyB <= '0';
				sram_we_B <= '0'; 
				stateB <= idle;
				
				WHEN idle =>
				CASE modeB IS
					WHEN idle =>
					    readyB <= '1';
				        sram_we_B <= '0'; 
				        stateB <= idle;
			        WHEN read =>
			            readyB <= '0';
				        sram_we_B <= '0';
						SRAM_ADDR_B <= addrB;
				        stateB <= read;
					WHEN write =>
			            readyB <= '0'; 
				        SRAM_ADDR_B <= addrB;
				        SRAM_DQ_I_B <= sram_input_B;
				        sram_we_B <= '1';
				        stateB <= write;
					WHEN others =>
				        stateB <= idle;
				END CASE;


		        WHEN read =>
			        sram_output_B <= SRAM_DQ_O_B;
					readyB <= '1';
					stateB <= idle;
		
				WHEN write =>
				    sram_we_B <= '0';
					readyB <= '1';
					stateB <= idle;
		
				WHEN others =>
					stateB <= init;
				END CASE;
			END IF;
	END PROCESS; 

end rtl;

	

