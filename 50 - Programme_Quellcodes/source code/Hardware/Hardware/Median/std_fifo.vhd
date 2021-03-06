library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity STD_FIFO is
	Generic (
		constant DATA_WIDTH : positive := 8;
		constant FIFO_DEPTH : positive := 128
	);
	Port ( 
		CLK     : in  STD_LOGIC;                                       -- Clock input
		RST     : in  STD_LOGIC;                                       -- Active high reset
		WriteEn : in  STD_LOGIC;                                       -- Write enable signal
		DataIn  : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);     -- Data input bus
		ReadEn  : in  STD_LOGIC;                                       -- Read enable signal
		DataOut : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);     -- Data output bus
		Empty   : out STD_LOGIC;                                       -- FIFO empty flag
		Full    : out STD_LOGIC;                                       -- FIFO full flag 
		USEDW   : out integer                                          -- USED WORDS NUMBER	
	);
end STD_FIFO; 



architecture Behavioral of STD_FIFO is

		signal full_t  : std_logic;
		signal empty_t : std_logic;
		signal usedw_t : integer;

begin

	-- Memory Pointer Process
	fifo_proc : process (CLK)
		type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
		variable Memory : FIFO_Memory;
		
		variable Head : natural range 0 to FIFO_DEPTH - 1;
		variable Tail : natural range 0 to FIFO_DEPTH - 1; 
		
		variable Looped : boolean;
	begin
		if rising_edge(CLK) then
			if RST = '1' then
				Head := 0;
				Tail := 0;
				
				Looped := false;
				
				full_t  <= '0';
				empty_t <= '1';
			else
				if (ReadEn = '1') then
					if ((Looped = true) or (Head /= Tail)) then
						-- Update data output
						DataOut <= Memory(Tail);
						
						-- Update Tail pointer as needed
						if (Tail = FIFO_DEPTH - 1) then
							Tail := 0;
							
							Looped := false;
						else
							Tail := Tail + 1;
						end if;
					end if;
				end if;
				
				if (WriteEn = '1') then
					if ((Looped = false) or (Head /= Tail)) then
						-- Write Data to Memory
						Memory(Head) := DataIn;
						
						-- Increment Head pointer as needed
						if (Head = FIFO_DEPTH - 1) then
							Head := 0;
							
							Looped := true;
						else
							Head := Head + 1;
						end if;
					end if;
				end if;
				
				-- Update Empty and Full flags
				if (Head = Tail) then
					if Looped then
						full_t <= '1';
					else
						empty_t <= '1';
					end if;
				else
					empty_t	<= '0';
					full_t	<= '0';
				end if;
			end if;
		end if;
	end process; 
	
	
	process (CLK, RST)
	begin
		if RST = '1' then
			usedw_t <= 0;
		elsif rising_edge(CLK) then
			if WriteEn= '1' and ReadEn= '0' and full_t= '0' and usedw_t <(FIFO_DEPTH-1) then
				usedw_t <= usedw_t + 1;
			elsif WriteEn= '0' and ReadEn= '1' and empty_t= '0' and usedw_t > 0 then
				usedw_t <= usedw_t - 1;
			else
				usedw_t <= usedw_t;
			end if;
		end if;	
	end process; 
	
	Full <= full_t;
	Empty <= empty_t;
	USEDW <= usedw_t;
		
		
				
		
		
		
end Behavioral;