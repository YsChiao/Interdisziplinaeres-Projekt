library ieee; use ieee.std_logic_1164.all;	
              use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work; use work.all;
 

entity receiver is 
	port(	clock : in std_logic;
			reset : in std_logic;
			new_data : in std_logic;
			data_done : out std_logic;
			count4x  : out integer;
			DataIn   : in  std_logic_vector(7 downto 0);
			DataOut  : out std_logic_vector(31 downto 0)
		);
end receiver;

architecture rtl of receiver is 


signal count : integer;	
signal count4x_sig : integer;
signal done : std_logic;
signal dat_reg : std_logic_vector(31 downto 0);

begin
	data_done <= done;
	count4x <= count4x_sig;
 -- counter			
   process (clock,new_data,reset)
    begin
	    if reset = '1' then
		   count <= 0;
		elsif rising_edge(new_data) then
            count <= count + 1;
			if count = 4 then
				count <= 1;
			end if;
        end if;
   end process;
   
-- count the output number
   process(clock,done,reset)
   begin 
	   if reset = '1' then 
		   count4x_sig <= 0;
	   elsif rising_edge(done) then
		   count4x_sig <= count4x_sig + 1;
	   end if;
  end process;
		   
	

   
  process (clock,reset)
   begin
	   if reset = '1' then
		   dat_reg <= (others => '0');
		   DataOut <= (others => '0');
		   done <= '0';
	   elsif rising_edge(clock) then
		   if(new_data = '1') then
			   if count = 1 then
				   dat_reg(7 downto 0) <= DataIn;
				   DataOut <= dat_reg;
				   done <= '1';
			   end if;
			   if count = 2 then
				   dat_reg(15 downto 8) <= DataIn;
				   done <= '0';
			   end if;
			    if count = 3 then
				   dat_reg(23 downto 16) <= DataIn;
				   done <= '0';
			   end if;
			    if count = 4 then
				   dat_reg(31 downto 24) <= DataIn;
				   done <= '0';
			   end if;
		   else
			   done <= '0';
		   end if;
	   end if;
 end process;
 
 end rtl;