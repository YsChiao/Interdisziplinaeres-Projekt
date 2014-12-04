library ieee;
use ieee.std_logic_1164.all;
package ann_types is 
	type ann_mode is (idle, run);
end package ann_types; 

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.float_types.all;
USE work.sram_types.all;
USE work.ann_types.all;

PACKAGE ann_components is


	COMPONENT ann is
		GENERIC (
			N_I : INTEGER := 2;	-- number of perceptrons at input layer
			N_H	: INTEGER := 2;	-- number of perceptrons at hidden layer
			N_O : INTEGER := 1	-- number of perceptrons at output layer
		);
		PORT (
			rst : in std_logic;
			clk : IN std_logic;
			mode : IN ann_mode;
			
			inputs : IN float_vector(N_I-1 downto 0);
			outputs : OUT float_vector(N_O-1 downto 0);
			ready : OUT std_logic;
			done  : out std_logic;

			float_alu_a : OUT float;
			float_alu_b : OUT float;
			float_alu_c : IN float;
			float_alu_mode : INOUT float_alu_mode;
			float_alu_ready : IN STD_LOGIC;

			sram_addr : OUT sram_address;
			sram_input : OUT sram_data;
			sram_output : IN sram_data;
			sram_mode : INOUT sram_mode;
			sram_ready : IN STD_LOGIC

		);
	END COMPONENT ann;
END PACKAGE ann_components;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.float_types.all;
use work.float_constants.all;
use work.sram_types.all;
use work.ann_types.all;

entity ann is
	generic (
	N_I : integer := 2; -- number of perceptrons at input layer
	N_H	: integer := 2; -- number of perceptrons at hidden layer
	N_O : integer := 1  -- number of perceptrons at output layer
	);
	port (
	rst : in std_logic;
	clk : in std_logic;
	mode : in ann_mode;	
	inputs : in float_vector(N_I -1 downto 0);
	outputs : out float_vector(N_O -1 downto 0);
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
	sram_mode : INOUT sram_mode;
	sram_ready : in std_logic
	
	);
end entity ann;

architecture rtl of ann is 

-- output for each perceptron
signal hidden_outputs : float_vector(N_H -1 downto 0 ):=(others => float_zero);
signal output_outputs : float_vector(N_O -1 downto 0 ):=(others => float_zero);

-- state machine
type states is (
			init,
			init_weight,
			init_weight_complete,
			run,    -- resets all outputs of hidden layer and output layer to 0
			hidden_weighted_bias_load,
			hidden_weighted_bias_load_complete,
			hidden_weighted_value_load,
			hidden_weighted_value_load_complete,
			hidden_weighted_value_mul,
			hidden_weighted_value_mul_complete,
			hidden_weighted_value_add,
			hidden_weighted_value_add_complete,
			hidden_sig_neg,
			hidden_sig_exp,
			hidden_sig_exp_complete, 
			hidden_sig_add,
			hidden_sig_add_complete,
			hidden_sig_div,
			hidden_sig_div_complete, 
			output_weighted_bias_load,
			output_weighted_bias_load_complete,
			output_weighted_value_load,
			output_weighted_value_load_complete,
			output_weighted_value_mul,
			output_weighted_value_mul_complete,
			output_weighted_value_add,
			output_weighted_value_add_complete,
			output_sig_neg,
			output_sig_exp,
			output_sig_exp_complete, 
			output_sig_add,
			output_sig_add_complete,
			output_sig_div,
			output_sig_div_complete, 
			idle
			);

signal state : states := init;

-- temp signals
signal i, h, o : integer := 0;
signal f, e, a : float := float_zero;
signal weight : float := float_zero;
signal addr : integer := 0;

begin
	
	outputs <= output_outputs;
	
	--fsm triggered at rsing edge
	fsm : process(clk, rst) is
	begin 
		if (rst = '1') then
			ready <= '0';
			done  <= '0';
			state <= init;
			float_alu_mode <= idle;
			sram_mode <= idle;
		elsif rising_edge(clk) then
			if (float_alu_mode /= idle) then
				float_alu_mode <= idle;
			elsif (sram_mode /= idle)then
				sram_mode <= idle;
			elsif (float_alu_ready ='0' or sram_ready = '0') then
			else
				case state is 
				when init => 
				    addr <= 0;
					ready <= '0';
					state <= init_weight;
				when init_weight => 
				    sram_addr <= std_logic_vector(to_unsigned(addr,12));
					sram_input <= "00111111100000000000000000000000";					
					sram_mode <= write;
					state <= init_weight_complete;
				when init_weight_complete =>
				    if( addr = ((N_I + 1) * N_H + (N_H + 1) * N_O) - 1 ) then 
					    state <= idle;
				    else
						addr <= addr + 1;
						state <= init_weight;
					end if;
					
				-- normal run operation start  
				when run  => 
				    ready <= '0';
					done  <= '0';
				    -- initialize perceptrons to have a zero output
					hidden_outputs <= (others => float_zero);
					output_outputs <= (others => float_zero);
					h <= 0;
					state <= hidden_weighted_bias_load;
				
				-- first load bias weight into sum
				WHEN hidden_weighted_bias_load =>
				    sram_mode <= read;
				    sram_addr <= std_logic_vector(to_unsigned((N_I * N_H + h), 12));
				    state <= hidden_weighted_bias_load_complete;
			    WHEN hidden_weighted_bias_load_complete =>
				    hidden_outputs(h) <= sram_output;
				    i <= 0;
				    state <= hidden_weighted_value_load;

			    -- sum up all weighted input to the hidden layer
			    WHEN hidden_weighted_value_load =>
				    sram_mode <= read;
				    sram_addr <= std_logic_vector(to_unsigned((i * N_H + h), 12));
				    state <= hidden_weighted_value_load_complete;
			    WHEN hidden_weighted_value_load_complete =>
				    weight <= sram_output;
				    state <= hidden_weighted_value_mul;
			    WHEN hidden_weighted_value_mul =>
				    -- weighted value = weight * value
				    float_alu_a <= weight;
				    float_alu_b <= inputs(i);
				    float_alu_mode <= mul;
				    state <= hidden_weighted_value_mul_complete;
			    WHEN hidden_weighted_value_mul_complete =>
				    f <= float_alu_c;
				    state <= hidden_weighted_value_add;
			    WHEN hidden_weighted_value_add =>
				    -- sum += weighted value
				    float_alu_a <= hidden_outputs(h);
				    float_alu_b <= f;
				    float_alu_mode <= add;
				    state <= hidden_weighted_value_add_complete;
			    WHEN hidden_weighted_value_add_complete =>
				    hidden_outputs(h) <= float_alu_c;
				    IF (i = N_I - 1) THEN
						state <= hidden_sig_neg;
				    ELSE
						i <= i + 1;
					    state <= hidden_weighted_value_load;
				    END IF;

			     -- start sigmoid calculation
			     WHEN hidden_sig_neg =>
				    -- sum = -sum
				    hidden_outputs(h)(31) <= not hidden_outputs(h)(31);
				    state <= hidden_sig_exp;
			     WHEN hidden_sig_exp =>
				    -- output = exp(-sum)
				    float_alu_a <= hidden_outputs(h);
				    float_alu_mode <= exp;
				    state <= hidden_sig_exp_complete;
			     WHEN hidden_sig_exp_complete =>
				    hidden_outputs(h) <= float_alu_c;
				    state <= hidden_sig_add;
			     WHEN hidden_sig_add =>
				    -- output = exp(-sum) + 1.0
				    float_alu_a <= hidden_outputs(h);
				    float_alu_b <= float_one;
				    float_alu_mode <= add;
				    state <= hidden_sig_add_complete;
			     WHEN hidden_sig_add_complete =>
				    hidden_outputs(h) <= float_alu_c;
				    state <= hidden_sig_div;
			     WHEN hidden_sig_div =>
				    -- output = 1.0 / (exp(-sum) + 1.0)
				    float_alu_a <= float_one;
				    float_alu_b <= hidden_outputs(h);
				    float_alu_mode <= div;
				    state <= hidden_sig_div_complete;
			     WHEN hidden_sig_div_complete =>
				    hidden_outputs(h) <= float_alu_c;
				    IF (h = N_H - 1) THEN
						o <= 0;
					    state <= output_weighted_bias_load;
				    ELSE
						h <= h + 1;
					    state <= hidden_weighted_bias_load;
				    END IF;
					
					
			     -- load bias for output layer
			     WHEN output_weighted_bias_load =>
				    sram_addr <= std_logic_vector(to_unsigned(((N_I + 1) * N_H + N_O * N_H + o), 12));
				    sram_mode <= read;
				    state <= output_weighted_bias_load_complete;
				 WHEN output_weighted_bias_load_complete =>
				    output_outputs(o) <= sram_output;
				    h <= 0;
					state <= output_weighted_value_load;

			     -- sum up all weighted value from hidden layer
			     WHEN output_weighted_value_load =>
				    sram_mode <= read;
				    sram_addr <= std_logic_vector(to_unsigned(((N_I + 1) * N_H + N_O * h + o), 12));
				    state <= output_weighted_value_load_complete;
			     WHEN output_weighted_value_load_complete =>
				    weight <= sram_output;
				    state <= output_weighted_value_mul;
			     WHEN output_weighted_value_mul =>
			 	    -- weighted value = weight * value
				    float_alu_a <= weight;
				    float_alu_b <= hidden_outputs(h);
				    float_alu_mode <= mul;
				    state <= output_weighted_value_mul_complete;
			     WHEN output_weighted_value_mul_complete =>
				    f <= float_alu_c;
				    state <= output_weighted_value_add;
			     WHEN output_weighted_value_add =>
				    -- sum += weighted value
				    float_alu_a <= output_outputs(o);
				    float_alu_b <= f;
				    float_alu_mode <= add;
				    state <= output_weighted_value_add_complete;
			     WHEN output_weighted_value_add_complete =>
				    output_outputs(o) <= float_alu_c;
				    IF (h = N_H - 1) THEN
						state <= output_sig_neg;
				    ELSE
						h <= h + 1;
                        state <= output_weighted_value_load;
					END IF;

			     -- start sigmoid calculation for output layer
			     WHEN output_sig_neg =>
				    -- sum = -sum
				    output_outputs(o)(31) <= not output_outputs(o)(31);
				    state <= output_sig_exp;
			     WHEN output_sig_exp =>
				    -- output = exp(-sum)
				    float_alu_a <= output_outputs(o);
				    float_alu_mode <= exp;
			   	    state <= output_sig_exp_complete;
			     WHEN output_sig_exp_complete =>
				    output_outputs(o) <= float_alu_c;
				    state <= output_sig_add;
			     WHEN output_sig_add =>
				    -- output = exp(-sum) + 1.0
				    float_alu_a <= output_outputs(o);
				    float_alu_b <= float_one;
				    float_alu_mode <= add;
				    state <= output_sig_add_complete;
			    WHEN output_sig_add_complete =>
				    output_outputs(o) <= float_alu_c;
				    state <= output_sig_div;
			    WHEN output_sig_div =>
				    -- output = 1.0 / (exp(-sum) + 1.0)
				    float_alu_a <= float_one;
				    float_alu_b <= output_outputs(o);
				    float_alu_mode <= div;
				    state <= output_sig_div_complete;
			    WHEN output_sig_div_complete =>
			        output_outputs(o) <= float_alu_c;
			        IF (o = N_O - 1) then
						state <= idle;
						done  <= '1';
					else
						o <= o + 1;
					    state <= output_weighted_bias_load;
					END IF;
 				
				WHEN idle =>
				    ready <= '1';
				    CASE mode IS
						WHEN idle =>
					       state <= idle;
				        WHEN run =>
						   ready <= '0';
						   state <= run;
						WHEN others =>
						   state <= idle;
				    END CASE;
				WHEN others =>
					state <= init;
			    END CASE; 
				
			end if;
		end if;
		
	end process; 
end rtl;
	
		
					
					
					
					
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	



	
	