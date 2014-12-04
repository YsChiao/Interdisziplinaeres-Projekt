LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;  
USE work.float_types.all;
USE work.float_components.all;
USE work.float_constants.all;
USE work.sram_types.all;
USE work.sram_components.all;
USE work.ann_types.all;
USE work.ann_components.all;

entity ann_full is 
	GENERIC (
			N_I : INTEGER := 3;	-- number of perceptrons at input layer
			N_H	: INTEGER := 3;	-- number of perceptrons at hidden layer
			N_O : INTEGER := 2	-- number of perceptrons at output layer
		    );
	PORT   (
	        rst : in std_logic;
			clk : in std_logic;
			
			inputs : IN float_vector(N_I-1 downto 0);
			outputs : OUT float_vector(N_O-1 downto 0);	
			
			ann_mode : in ann_mode;
			ready : out std_logic;
			done  : out std_logic
			);	
end ann_full ;

architecture rtl of ann_full is 

-- ann
signal ann_inputs : float_vector(N_I - 1 downto 0) := (others => float_zero);
signal ann_outputs : float_vector(N_O -1 downto 0 ) := (others => float_zero);
signal ann_ready : std_logic := '0';
signal ann_done : std_logic := '0';

-- alu
SIGNAL float_alu_ready : STD_LOGIC := '0';
SIGNAL float_alu_a, float_alu_b, float_alu_c : float := float_zero;
SIGNAL float_alu_mode : float_alu_mode := idle;


-- sram
signal sram_address : sram_address := (others=>'0');
signal sram_input : sram_data := (others=>'0');
signal sram_output : sram_data := (others=>'0');
signal sram_mode : sram_mode := idle;
signal sram_ready : std_logic := '0';

begin
	ann_inputs <= inputs;
	outputs <= ann_outputs;
	ready <= ann_ready;
	done  <= ann_done;

	

	-- alu 
	float_alu0 : float_alu
	port map (
	rst => rst,
	clk => clk,
	a => float_alu_a,
	b => float_alu_b,
	c => float_alu_c,
	mode => float_alu_mode,
	ready => float_alu_ready
	);
	
	--sram
	sram0 : sram
	port map (
		reset => rst,
		clock => clk,
		addr => sram_address,
		input => sram_input,
		output => sram_output,
		mode => sram_mode,
		ready => sram_ready
	);
	
	-- ann
    ann0 : ann
	generic map (
		N_I => 3,
		N_H => 2,
		N_O => 2
	)
	port map (
		rst => rst,
		clk => clk,
		mode => ann_mode,
		
		inputs => ann_inputs,
		outputs => ann_outputs,
		ready => ann_ready,
		done  => ann_done,
		
		float_alu_a => float_alu_a,
		float_alu_b => float_alu_b,
		float_alu_c => float_alu_c,
		float_alu_mode => float_alu_mode,
		float_alu_ready => float_alu_ready,
		
		sram_addr => sram_address,
		sram_input => sram_input,
		sram_output => sram_output,
		sram_mode => sram_mode,
		sram_ready => sram_ready
	);

end rtl;	
	

			
			