library ieee; use ieee.std_logic_1164.all;	use IEEE.STD_LOGIC_UNSIGNED.ALL;
library machxo2; use machxo2.components.all;
library work; use work.all;



entity main is 
	port(	SCLK : in std_logic;
			MOSI : in std_logic;
			MISO : out std_logic;
			CE1  : in std_logic;
			GSRn : in std_logic; 
			
            --readin : out std_logic_vector( 7 downto 0);
			--writeout : out std_logic_vector( 7 downto 0);
			--new_data : inout std_logic;
            --DV    : out std_logic;
			--clock : inout std_logic;
			
			SDA  : in std_logic
		);
end main;

architecture rtl of main is 
---------------------------------------------------------


component reset is 
	port(
	clk : in std_logic;
	sda : in std_logic;
	rst : out std_logic
	);
end component;



component spi2 
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
end component;	



component OSCH
    generic(	NOM_FREQ: string := "38.00");
    port(	STDBY : in std_logic;
			OSC  : out std_logic;
			SEDSTDBY : out std_logic
		);
end component; 

component sort_filter 
	generic (
	DATA_WIDTH: integer:=8;
	order: integer:=1;
	num_cols: integer:=128;
	num_rows: integer:=128
	);
	port (
	clk : in std_logic;
	rst : in std_logic;
	DataIn : in std_logic_vector(DATA_WIDTH-1 downto 0);
	DataOut : out std_logic_vector(DATA_WIDTH -1 downto 0);
	DV : out std_logic
	);
end component sort_filter;

-------------------------------------------------
signal GSRnX : std_logic;

signal tx : std_logic_vector(7 downto 0);
signal rx : std_logic_vector(7 downto 0);
signal dv : std_logic;
signal rst : std_logic;	


signal clk_sig: std_logic;
signal dv_sig: std_logic;


SIGNAL write_data :  std_logic_vector(7 downto 0);
SIGNAL write_req :  std_logic;
SIGNAL read_data :  std_logic_vector(7 downto 0);

signal new_data :  std_logic;
signal clock : std_logic;
signal readin : std_logic_vector(7 downto 0);
signal writeout : std_logic_vector(7 downto 0);

SIGNAL spi_clk :  std_logic;
SIGNAL spi_miso :  std_logic;
SIGNAL spi_mosi :  std_logic;
SIGNAL spi_cs :  std_logic;




-- attach a pullup to the GSRn signal
attribute pullmode  : string;
attribute pullmode of GSRnX   : signal is "UP";   -- else floats


begin
	
    MISO <= spi_miso;
	spi_clk <= SCLK;
    spi_mosi <= MOSI;
    spi_cs   <= CE1;
	clock <= clk_sig;
	DV <= dv_sig;
	
	
    -- global reset
    IBgsr   : IB  port map ( I=>GSRn, O=>GSRnX );
    GSR_GSR : GSR port map ( GSR=>GSRnX );
	
	-----------------------------------------------
	-- clock
    OSC0: OSCH
      generic map (NOM_FREQ  => "38.00")
      port map (STDBY => '0', OSC => clk_sig,  SEDSTDBY => open);
	-----------------------------------------------
	
    reset0 :  reset
	port map(
	clk => clk_sig,
	sda => SDA,	
	rst => rst	
    );
	---------------------------------------------
	
	spi0 : spi2 
	port map(	clk=> clk_sig,
 	
				write_data => write_data,
				write_req => write_req,
								
				read_data => rx,
				new_data  => new_data,
				spi_clk   => spi_clk,
				spi_miso  => spi_miso,
				spi_mosi  => spi_mosi,
				spi_cs    => spi_cs
			);	

	
   sort_filter0 : sort_filter 
   generic map (DATA_WIDTH => 8,
   				order => 5, 
   				num_cols  => 640, 
				num_rows => 360)   
   port map (clk => new_data, 
   			 rst => rst, 
             DataIn => rx, 
			 DataOut => write_data, 
			 DV => dv_sig
			 );	 
			  

	--control signal 
	process(clk_sig,rst)
	begin
	    if (rst = '1') then
			write_req <= '0';
		elsif rising_edge(clk_sig) then
			if (dv_sig = '0') then
				write_req <= '0';
			else
				write_req <= '1';
			end if;
		end if;	
		
		
		readin <= rx;
		writeout <=  write_data;
	end process;
	


end architecture rtl;
	
   
	                     
	
	

