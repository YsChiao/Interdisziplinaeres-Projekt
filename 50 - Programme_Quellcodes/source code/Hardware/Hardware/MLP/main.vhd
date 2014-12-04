library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library machxo2; 
use machxo2.components.all;
library work; 
use work.all;
use work.ann_types.all;
use work.sram_dp_types.all;
use work.float_types.all;
use work.float_constants.all;
use work.mlp_pkg.all;


LIBRARY STD;
USE std.textio.all;


entity main is 
	port(	SCLK : in std_logic;
			MOSI : in std_logic;
			MISO : out std_logic;
			CE1  : in std_logic;
			GSRn : in std_logic; 
			
--            readin : out std_logic_vector( 7 downto 0);
--			--writeout : out std_logic_vector( 7 downto 0);
			new_data : inout std_logic;
--			data_done : inout std_logic;
			weight_done   : out std_logic;
			clock : inout std_logic;
--			ramDataIn : inout std_logic_vector(31 downto 0);
--			sram_input_A : inout std_logic_vector(31 downto 0);
--			sram_output_B : inout std_logic_vector(31 downto 0);
			mlp_outputs : inout float_vector(N_O - 1 downto 0);
			mlp_done : inout std_logic;
--			
			output_new : out std_logic;
			output_done : out std_logic; 
--			
--			data : out std_logic_vector(31 downto 0);
			
			SDA  : in std_logic; 	  	-- signal for resert
		    GPIO17 : in std_logic;     -- signal for run	
			GPIO18 : in std_logic      -- signal for checker, 1 for inputs and 0 for weights and bias

		);
end main;

architecture rtl of main is 
--------------------------------------------------------



--=================bin to hex conversion function===================
	function to_hstring (value : STD_ULOGIC_VECTOR) return STRING is
    constant result_length : NATURAL := (value'length+3)/4;
    variable pad           : STD_ULOGIC_VECTOR(1 to result_length*4 - value'length);
    variable padded_value  : STD_ULOGIC_VECTOR(1 to result_length*4);
    variable result        : STRING(1 to result_length);
    variable quad          : STD_ULOGIC_VECTOR(1 to 4);
  begin
    if value (value'left) = 'Z' then
      pad := (others => 'Z');
    else
      pad := (others => '0');
    end if;
    padded_value := pad & value;
    for i in 1 to result_length loop
      quad := To_X01Z(padded_value(4*i-3 to 4*i));
      case quad is
        when x"0"   => result(i) := '0';
        when x"1"   => result(i) := '1';
        when x"2"   => result(i) := '2';
        when x"3"   => result(i) := '3';
        when x"4"   => result(i) := '4';
        when x"5"   => result(i) := '5';
        when x"6"   => result(i) := '6';
        when x"7"   => result(i) := '7';
        when x"8"   => result(i) := '8';
        when x"9"   => result(i) := '9';
        when x"A"   => result(i) := 'A';
        when x"B"   => result(i) := 'B';
        when x"C"   => result(i) := 'C';
        when x"D"   => result(i) := 'D';
        when x"E"   => result(i) := 'E';
        when x"F"   => result(i) := 'F';
        when "ZZZZ" => result(i) := 'Z';
        when others => result(i) := 'X';
      end case;
    end loop;
    return result;
  end function to_hstring;
  
 -------------------------------------------------

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
	--outputs : out sram_data;
	
	checker : in std_logic;
	
	inputNumber : in integer;
	weightNumber : in integer;
	weight_done : out std_logic;
	
	sram_addr : out sram_address;
	sram_input : out sram_data;
	sram_output : in sram_data;
	sram_mode :  out std_logic;
	sram_ready : out std_logic
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
		wrA  : in std_logic;
		wrB  : in std_logic;
		readyA : in std_logic;
		readyB : in std_logic
	);
end component;


component pr is
	port (
	rst: in std_logic;
	clk: in std_logic;
	mlp_run : in std_logic;
	weight_done : in std_logic;
	mlp_mode : inout ann_mode;
	mlp_ready : in std_logic); 
	
end component;


component mlp
	port (
	rst : in std_logic;
	clk : in std_logic;
	mode : in ann_mode;	

	outputs : out float_vector(N_O -1 downto 0);
	weight_done : in std_logic;
	ready : out std_logic;
	done  : out std_logic;
	
	float_alu_a : out float;
	float_alu_b : out float;
	float_alu_c : in  float;
	float_alu_mode : inout float_alu_mode;
	float_alu_ready : in std_logic;
	
	sram_addr : out sram_address;
	sram_input : out sram_data;
	sram_output : in sram_data;
	sram_mode : out std_logic;
	sram_ready : out std_logic	
	
	);
end component;

component float_alu is
	port ( 
	rst  : in std_logic;
	clk  : in std_logic;
	a, b : in float;
	c    : out float;
	mode : in float_alu_mode;
	ready : out std_logic
	);
end component float_alu;

component output is 
	port(	clk : in std_logic;
			rst : in std_logic;
			mlp_done : in std_logic;
			DataIn : in  float_vector(N_O -1 downto 0);
			
			output_new : OUT std_logic;
			DataOut  : out std_logic_vector(7 downto 0);
			output_done : out std_logic
		);
end component;


-------------------------------------------------
signal GSRnX : std_logic;

signal tx : std_logic_vector(7 downto 0);
signal rx : std_logic_vector(7 downto 0);
signal rst : std_logic;	
--signal clock : std_logic;
signal readin : std_logic_vector(7 downto 0);
signal writeout : std_logic_vector(7 downto 0);
signal data : std_logic_vector(31 downto 0);
signal counter : integer;

signal clk_sig: std_logic;


SIGNAL write_data :  std_logic_vector(7 downto 0);
SIGNAL write_req :  std_logic;
SIGNAL read_data :  std_logic_vector(7 downto 0);
--SIGNAL new_data :  std_logic;
SIGNAL spi_clk :  std_logic;
SIGNAL spi_miso :  std_logic;
SIGNAL spi_mosi :  std_logic;
SIGNAL spi_cs :  std_logic;


signal data_done : std_logic;
signal counterOut : integer;
signal ramDataIn : std_logic_vector(31 downto 0);
signal ramDataOut : std_logic_vector(31 downto 0); 

-- mlp run signal
signal mlp_run_sig : std_logic;


--loadweight
--signal weight_done : std_logic;	
signal checker : std_logic;

-- sram portA
signal weight_done_sig : std_logic;
signal sram_address_A : sram_address := (others=>'0');
signal sram_input_A : sram_data := (others=>'0');
signal sram_output_A : sram_data := (others=>'0');
signal sram_mode_A : std_logic;
signal sram_ready_A : std_logic;

-- sram portB
signal sram_address_B : sram_address := (others=>'0');
signal sram_input_B : sram_data := (others=>'0');
signal sram_output_B : sram_data := (others=>'0');
signal sram_mode_B : std_logic;
signal sram_ready_B : std_logic;


-- alu
SIGNAL float_alu_ready : STD_LOGIC := '0';
SIGNAL float_alu_a, float_alu_b, float_alu_c : float := float_zero;
SIGNAL float_alu_mode : float_alu_mode := idle;

-- mlp
signal mlp_inputs : float_vector(N_I - 1 downto 0) := (others => float_zero);
--signal mlp_outputs : float_vector(N_O - 1 downto 0) := (others => float_zero);
signal mlp_ready : std_logic := '0';
--signal mlp_done : std_logic;
signal mlp_mode : ann_mode := idle;	

--pr
signal pr_outputs : integer;
signal pr_ready : std_logic;

--output 
--signal output_new : std_logic;
signal output_new_sig : std_logic;
--signal output_done : std_logic;

-- attach a pullup to the GSRn signal
attribute pullmode  : string;
attribute pullmode of GSRnX   : signal is "UP";   -- else floats 
	
	
	
	
type states is ( read, get, get2, idle );
signal state : states := read;
signal I : integer;
-----------------------------------------------------------------------
begin
	
    MISO <= spi_miso;
	spi_clk <= SCLK;
    spi_mosi <= MOSI;
    spi_cs   <= CE1;
	clock <= clk_sig;
	weight_done <= weight_done_sig;	
	output_new <= output_new_sig;
	mlp_run_sig <= GPIO17; 
	checker <= GPIO18;
	
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
	clk => clock,
	sda => SDA,	
	rst => rst	
    );
	--------------------------------------------- 
		
	spi0 : spi2 
	port map(	clk=> clock,
				write_data => write_data,
				write_req => write_req,			
				read_data => read_data,
				new_data  => new_data,
				spi_clk   => spi_clk,
				spi_miso  => spi_miso,
				spi_mosi  => spi_mosi,
				spi_cs    => spi_cs
			);	

	
	-- alu
	float_alu0 : float_alu
	port map ( rst => rst,
			   clk => clock,
	           a => float_alu_a,
			   b => float_alu_b,
 	           c => float_alu_c,
	           mode => float_alu_mode,
	           ready => float_alu_ready
			  );	
			
			
			
	receiver0 :  receiver 
	port map (clock => clock,
			  reset => rst,
			  new_data => new_data,
			  data_done => data_done,
			  count4x => counter,
			  DataIn => read_data,
			  DataOut => ramDataIn
			  );
			  
    
	
	
	sram_dp0 : sram_dp
	port map( 
		resetA => rst,
        resetB => rst,	
		clockA => clock,
		clockB => clock,
		addrA  => sram_address_A,
		addrB  => sram_address_B,
		inputA => sram_input_A,
		inputB => sram_input_B,
		outputA => sram_output_A,
		outputB => sram_output_B,
		wrA  => sram_mode_A,
		wrB  => sram_mode_B,
		readyA => sram_ready_A,
		readyB => sram_ready_B
	); 
	


			  
	loadWeight0 : loadWeight		  
	port map (rst => rst,
			  clk => clock,
	          new_data => data_done,
	          inputs => ramDataIn, 
			  
			  checker => checker,
			  --outputs => ramDataOut,
	       	  inputNumber => N_I,
			  weightNumber => N_H,
			  
			  weight_done => weight_done_sig,
			  sram_addr  => sram_address_A,
			  sram_input => sram_input_A,
			  sram_output => sram_output_A,
			  sram_mode => sram_mode_A,
			  sram_ready => sram_ready_A
			  );
			  
	
			  
			  
			  
	mlp0:  mlp
	port map ( rst => rst,
	           clk => clock,
			   mode => mlp_mode,
	
			   outputs => mlp_outputs,
			   weight_done => weight_done_sig,

			   ready => mlp_ready,
			   done  => mlp_done,
	
			   float_alu_a => float_alu_a,
			   float_alu_b => float_alu_b,
			   float_alu_c => float_alu_c,
	           float_alu_mode => float_alu_mode,
	           float_alu_ready => float_alu_ready,
	
	           sram_addr => sram_address_B,
	           sram_input => sram_input_B,
	           sram_output => sram_output_B,
	           sram_mode =>  sram_mode_B,
	           sram_ready => sram_ready_B);
			   
			   
	pr0: pr
	port map ( rst => rst,
			   clk => clock,
	           mlp_run => mlp_run_sig,
			   weight_done => weight_done_sig,
			   mlp_mode => mlp_mode,
			   mlp_ready => mlp_ready);	
			   
			
			   
    output0:  output
	port map (	clk => new_data,
				rst => rst,
				mlp_done => mlp_done,
				DataIn => mlp_outputs,
			
				output_new => output_new_sig,
				DataOut  =>	 writeout,
				output_done => output_done
		); 
		
	process(clock)
	begin
		if output_new_sig = '1' then
			write_req <= '1';
			--readin  <= read_data;
			write_data <= writeout;
		end if;
	end process;

			   
			   
	
	

			  
--	process(clock, rst)
--	variable my_line :line;
--	begin
--		if (rst = '1') then
--			state <= read;
--			I <= 0;	
--			sram_ready_B <= '1';
--		elsif rising_edge(clock) then
--			if (weight_done_sig = '1' and sram_ready_B = '1') then
--			case state is 
--				when read => 
--					sram_mode_B <= '0';
--					sram_address_B <= std_logic_vector(to_unsigned(I,12));
--					I <= I + 1;
--					state <= get;
----					
----			   	when get =>
----					report "The value of 'I' is " & integer'image(I-1);
----					if (sram_output_B = "00000000") then
----						state <= read;
----					else
----					   	state <= get2;
----					end if;
--				
--				when get => 
--					   if I > N_I + N_H-1 then
--						   state <= idle;
--					   else
--						   write(my_line, string'("sram_addr = "));
--				    	   write(my_line, to_hstring(to_stdulogicvector(sram_address_B)));
--					       writeline(output, my_line);
--						   
--					   	   write(my_line, string'("sram_data = "));
--					       write(my_line, to_hstring(to_stdulogicvector(sram_output_B)));
--					       writeline(output, my_line);
--						   
--					       data <= sram_output_B;
--					       state <= read;
--					   end if;
--
--				 
--				when idle =>
--					state <= idle;
--					sram_ready_B <= '0';
--				 
--				WHEN others =>
--					state <= read;
--			    END CASE; 
--	      end if;	
--		end if;
--	end process;
--	


end architecture rtl;
	
   
	                     
	
	

