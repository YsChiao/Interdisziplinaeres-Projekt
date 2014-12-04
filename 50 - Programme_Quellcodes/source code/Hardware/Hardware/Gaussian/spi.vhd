library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity spi2 is
	port ( 
	clk : in std_logic;
 	
	write_data : in std_logic_vector(7 downto 0);
	write_req  : in std_logic; 
								
	read_data : out std_logic_vector(7 downto 0);
	new_data  : inout std_logic;  
	

	spi_clk  : inout std_logic;
	spi_miso : inout std_logic;
	spi_mosi : inout std_logic;
	spi_cs : in std_logic);
end entity;	

architecture rtl of spi2 is

type states is (INIT, IDLE, READ_RXDR, WRITE_TXDR); 
signal state : states:=INIT;


signal wbcyc : std_logic;
signal wbstb : std_logic;
signal wbwe  : std_logic;
signal wbaddr : std_logic_vector(7 downto 0);
signal wbdat_i : std_logic_vector(7 downto 0);
signal wbdat_o : std_logic_vector(7 downto 0);
signal wback : std_logic;



-- register addressess
constant SPICR2 : std_logic_vector(7 downto 0):=x"56";
constant SPISR  : std_logic_vector(7 downto 0):=x"5a";	
constant SPIRXDR : std_logic_vector(7 downto 0):=x"5b";
constant SPITXDR : std_logic_vector(7 downto 0):=x"59";	  



begin
		
	efb0: entity work.efb_spi
		port map(
		wb_clk_i=>clk,		         
		wb_rst_i=>'0',		        
		wb_cyc_i=>wbcyc,		        
		wb_stb_i=>wbstb,		         
		wb_we_i =>wbwe,		         
		wb_adr_i=>wbaddr,	         
		wb_dat_i =>wbdat_i,		         
		wb_dat_o =>wbdat_o,	         
		wb_ack_o =>wback,	        
		spi_clk =>spi_clk,	         
		spi_miso=>spi_miso,		         
		spi_mosi=>spi_mosi,		         
		spi_scsn=>spi_cs); 
		
	
		process(clk)
			variable just_written:std_logic:='0';
			variable write_pending:std_logic:='0';
		begin
			if rising_edge(clk) then
				if write_req = '1' then
					write_pending:= '1';
				end if;
				
				case state is
					---------------------------------------------
					when INIT =>   -- enable slave mode	
						if wback='0' then
							wbstb<='1' ; wbcyc<='1' ; wbwe<='1' ;
							wbaddr<=SPICR2;
							wbdat_i<=x"00";
							state<=INIT;
						else
							wbstb<='0';wbcyc<='0';wbwe<='0';			
							state<=IDLE;			
						end if;
				-----------------------------------------
					when IDLE=> -- wait until new data arrives or write request
						new_data <= '0';
						if wback = '0' then
							wbstb<='1' ; wbcyc<='1' ; wbwe<='0';			
						    wbaddr<=SPISR;
							state<=IDLE;
						else
							wbstb<='0' ; wbcyc<='0' ; wbwe<='0';
							if write_pending='1' and wbdat_o(4)='1' and just_written='0' then	--TRDY									
								state<=WRITE_TXDR;
							elsif wbdat_o(3) ='1' then --RRDY
								state<=READ_RXDR;
							end if;
						end if;
						
				--------------------------		
					when READ_RXDR => --read data from wishbone
						if wback='0' then	
							wbstb<='1' ; wbcyc<='1' ; wbwe<='0';
						    wbaddr<=SPIRXDR;
						else
							wbstb<='0' ; wbcyc<='0' ; wbwe<='0';
							read_data<=wbdat_o;
							new_data<='1';
							just_written:='0';
							state<=IDLE;
						end if;
				--------------------------		
					when WRITE_TXDR => --write data to wishbone
						if wback='0' then	
							wbstb<='1' ; wbcyc<='1' ; wbwe<='1';
						    wbaddr<=SPITXDR;
							wbdat_i<= write_data;
						else
							wbstb<='0' ; wbcyc<='0' ; wbwe<='0';
							just_written:='0';	write_pending:='0';
							state<=IDLE; 
						end if;
				end case;	
			end if;	
		end process; 
			
end rtl;
			






