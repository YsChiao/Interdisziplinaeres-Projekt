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
USE work.mlp_components.all; 
USE work.mlp_pkg.all;

entity mlp_all is 
	PORT   (
	        rst : in std_logic;
			clk : in std_logic;
			
			inputs : IN float_vector(N_I-1 downto 0);
			outputs : OUT float_vector(N_O-1 downto 0);	
			
			ann_mode : in ann_mode;
			ready : out std_logic;
			done  : out std_logic
			);	
end mlp_all ;


architecture rtl of mlp_all is 

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
	
	-- mlp
    mlp0 : mlp
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
	

			
			