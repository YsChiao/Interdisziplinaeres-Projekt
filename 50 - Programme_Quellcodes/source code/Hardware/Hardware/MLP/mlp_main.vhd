library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library machxo2; 
use machxo2.components.all;
library work; 
use work.all;
use work.sram_dp_types.all;
use work.float_types.all; 
USE work.float_constants.all;
USE work.mlp_pkg.all;


entity main is 
	port(	SCLK : in std_logic;
			MOSI : in std_logic;
			MISO : out std_logic;
			CE1  : in std_logic;
			GSRn : in std_logic; 
			
            readin : out std_logic_vector( 7 downto 0);
			writeout : out std_logic_vector( 7 downto 0);
			new_data : inout std_logic;
			data_done : inout std_logic;
			weight_done   : out std_logic;
			clock : inout std_logic;
			ramDataIn : inout std_logic_vector(31 downto 0);
			data : out std_logic_vector(31 downto 0);
			
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


component loadWeight is
	
	port (
	rst : in std_logic;
	clk : in std_logic;
	new_data: in std_logic;
	inputs : in sram_data;
	outputs : out sram_data;		
	inputNumber : in integer;
	weightNumber : in integer;
	weight_done : out std_logic;
	
	sram_addr : out sram_address;
	sram_input : out sram_data;
	sram_output : in sram_data;
	sram_mode : inout sram_mode;
	sram_ready : in std_logic
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

component float_alu is
	port ( 
	rst  : in std_logic;
	clk  : in std_logic;
	a, b : in float;
	c    : out float;
	mode : in float_alu_mode;
	ready : out std_logic);
end component float_alu;



component OSCH
    generic(	NOM_FREQ: string := "38.00");
    port(	STDBY : in std_logic;
			OSC  : out std_logic;
			SEDSTDBY : out std_logic
		);
end component;


component receiver is 
	port(	clock : in std_logic;
			reset : in std_logic;
			new_data : in std_logic;
			data_done : out std_logic;
			count4x  : out integer;
			DataIn   : in  std_logic_vector(7 downto 0);
			DataOut  : out std_logic_vector(31 downto 0)
		);
end component;

component sram_dp is
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
		modeA  : in sram_mode;
		modeB  : in sram_mode;
		readyA : out std_logic;
		readyB : out STD_LOGIC
	);
end component;

-------------------------------------------------
signal GSRnX : std_logic;

signal tx : std_logic_vector(7 downto 0);
signal rx : std_logic_vector(7 downto 0);
signal rst : std_logic;	
signal counter : integer;

--signal clock : std_logic;
--signal readin : std_logic_vector(7 downto 0);
--signal writeout : std_logic_vector(7 downto 0);
--signal data : std_logic_vector(31 downto 0);
--signal new_data :  std_logic;


signal clk_sig: std_logic;


SIGNAL write_data :  std_logic_vector(7 downto 0);
SIGNAL write_req :  std_logic;
SIGNAL read_data :  std_logic_vector(7 downto 0);

SIGNAL spi_clk :  std_logic;
SIGNAL spi_miso :  std_logic;
SIGNAL spi_mosi :  std_logic;
SIGNAL spi_cs :  std_logic;


--signal data_done : std_logic;
--signal counterOut : integer;
--signal ramDataIn : std_logic_vector(31 downto 0);

signal ramDataOut : std_logic_vector(31 downto 0); 

-- sram portA
signal weight_done_sig : std_logic;
signal sram_address_A : sram_address := (others=>'0');
signal sram_input_A : sram_data := (others=>'0');
signal sram_output_A : sram_data := (others=>'0');
signal sram_mode_A : sram_mode := idle;
signal sram_ready_A : std_logic := '0';

-- sram portB
signal sram_address_B : sram_address := (others=>'0');
signal sram_input_B : sram_data := (others=>'0');
signal sram_output_B : sram_data := (others=>'0');
signal sram_mode_B : sram_mode := idle;
signal sram_ready_B : std_logic := '0';

-- alu
signal float_alu_ready : std_logic := '0';
signal float_alu_a, float_alu_b, float_alu_c : float := float_zero;
signal float_alu_mode : float_alu_mode := idle;


-- attach a pullup to the GSRn signal
attribute pullmode  : string;
attribute pullmode of GSRnX   : signal is "UP";   -- else floats


begin
	
    MISO <= spi_miso;
	spi_clk <= SCLK;
    spi_mosi <= MOSI;
    spi_cs   <= CE1;
	clock <= clk_sig;
	weight_done <= weight_done_sig;
	
    -- global reset
    IBgsr   : IB  port map ( I=>GSRn, O=>GSRnX );
    GSR_GSR : GSR port map ( GSR=>GSRnX );
	
	-- clock
    OSC0: OSCH
      generic map (NOM_FREQ  => "133.00")
      port map (STDBY => '0', OSC => clk_sig,  SEDSTDBY => open);
	
    reset0 :  reset
	port map( clk => clock,
	          sda => SDA,	
	          rst => rst);
		
	spi0 : spi2 
	port map(	clk=> clock,
				write_data => write_data,
				write_req => write_req,			
				read_data => read_data,
				new_data  => new_data,
				spi_clk   => spi_clk,
				spi_miso  => spi_miso,
				spi_mosi  => spi_mosi,
				spi_cs    => spi_cs);	

	receiver0 : receiver 
	port map ( clock => clock,
			   reset => rst,
			   new_data => new_data,
			   data_done => data_done,
			   count4x => counter,
			   DataIn => read_data,
			   DataOut => ramDataIn);
			  
    

	sram_dp0 : sram_dp
	port map(  resetA => rst,
	           resetB => rst,	
			   clockA => clock,
			   clockB => clock,
			   addrA  => sram_address_A,
			   addrB  => sram_address_B,
			   inputA => sram_input_A,
			   inputB => sram_input_B,
			   outputA => sram_output_A,
			   outputB => sram_output_B,
			   modeA  => sram_mode_A,
			   modeB  => sram_mode_B,
			   readyA => sram_ready_A,
			   readyB => sram_ready_B);
			
	-- alu 
	float_alu0 : float_alu
	port map ( rst => rst,
			   clk => clock,
	           a => float_alu_a,
			   b => float_alu_b,
	           c => float_alu_c,
	           mode => float_alu_mode,
	           ready => float_alu_ready);

			  
	loadWeight0 : loadWeight		  
	port map (rst => rst,
			  clk => clock,
	          new_data => data_done,
	          inputs => ramDataIn,
	          outputs => ramDataOut,
	       	  inputNumber => N_I,
			  weightNumber => N_H,
			  
			  weight_done => weight_done_sig,
			  sram_addr  => sram_address_A,
			  sram_input => sram_input_A,
			  sram_output => sram_output_A,
			  sram_mode => sram_mode_A,
			  sram_ready => sram_ready_A);
			  
	
	
		
	
			  

			
			  
			
		
	


end architecture rtl;
	
   
	                     
	
	

