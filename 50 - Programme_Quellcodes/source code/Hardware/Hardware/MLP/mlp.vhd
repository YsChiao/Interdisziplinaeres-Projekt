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
USE work.mlp_pkg.all;

PACKAGE mlp_components is


	component mlp 
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
end component;

END PACKAGE mlp_components;



library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.float_types.all;
use work.float_constants.all;
use work.sram_types.all;
use work.ann_types.all;
use work.mlp_pkg.all; 

LIBRARY STD;
USE std.textio.all;

entity mlp is
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
end entity mlp;

architecture rtl of mlp is 

-- output for each perceptron
signal hidden_outputs : float_vector(MAX_H -1 downto 0 ):=(others => float_zero); 
signal temp_outputs : float_vector(MAX_H -1 downto 0 ):=(others => float_zero);
signal output_outputs : float_vector(N_O -1 downto 0 ):=(others => float_zero);	



-- state machine
type states is (
			init,
			init_weight,
			init_weight_complete,
			run,    -- resets all outputs of hidden layer and output layer to 0
			
			hidden_perceptrons_number_load,
			hidden_perceptrons_number_load_complete,
			
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
			
			hidden_sig_double,			   -- Symmetrical sigmoid
			hidden_sig_double_complete,
			hidden_sig_sub,
			hidden_sig_sub_complete,
			
			next_layer_load,
			
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
			
			output_sig_double,			   -- Symmetrical sigmoid
			output_sig_double_complete,
			output_sig_sub,
			output_sig_sub_complete,
			
			idle
			);

signal state : states := init;

-- temp signals
signal i, h, o, n : integer := 0; -- h = n
signal counter : integer := 0; -- count position

signal numL : integer := 0;	-- number of hidden layers
--signal np : integer := 0;    -- number of perceptrons at each hidden layer

signal f, e : float := float_zero;
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
					numL <= 0; -- number of layers -- changed
					report "Initalization";
				when init_weight =>
				    sram_addr <= std_logic_vector(to_unsigned(addr,12));
					sram_input <= "00111111100000000000000000000000"; -- set all weight and bias to 1
					sram_mode <= write;
					state <= init_weight_complete;
				when init_weight_complete =>
					if (addr = N_H -1 )	then
					    state <= idle;
						report "The value of 'addr' is " & integer'image(addr);
				    else
						report "The value of 'addr' is " & integer'image(addr);
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
					state <= hidden_perceptrons_number_load;

			    ---- first load each layer perceptrons number
				WHEN hidden_perceptrons_number_load =>
				    state <= hidden_perceptrons_number_load_complete;
				WHEN hidden_perceptrons_number_load_complete =>
				    --numP(numL)<= numP(numL); 
				    report "The value of 'numL' is " & integer'image(numL);	
					report "The value of 'np' is " & integer'image(numP(numL));	
					report "The value of 'counter' is " & integer'image(counter);
				    state <= hidden_weighted_bias_load;
				
			    -- first load bias weight into sum
				WHEN hidden_weighted_bias_load => 
				    sram_mode <= read;	
					if (numL = 0) then -- if the first hidden layer
				    	sram_addr <= std_logic_vector(to_unsigned((N_I * numP(numL)+ h), 12));	-- the first layer
					else				
						sram_addr <= std_logic_vector(to_unsigned((counter + numP(numL-1)* numP(numL)+ h), 12));	-- not the first layer
					end if;
				    state <= hidden_weighted_bias_load_complete;
			    WHEN hidden_weighted_bias_load_complete =>
				    hidden_outputs(h) <= sram_output;
				    report "The value of 'h' is " & integer'image(h);
				    i <= 0;
				    state <= hidden_weighted_value_load;

			    -- sum up all weighted input to the hidden layer
			    WHEN hidden_weighted_value_load =>
					counter <= counter + 1;
				    sram_mode <= read;
					if (numL = 0) then -- if the first hidden layer
				    	sram_addr <= std_logic_vector(to_unsigned((i*numP(numL)+h), 12));
					else
						sram_addr <= std_logic_vector(to_unsigned(counter+i*numP(numL)+h , 12));	-- not the first layer -- 需要修改
					end if;
					report "The value of 'i' is " & integer'image(i);
				    state <= hidden_weighted_value_load_complete;
			    WHEN hidden_weighted_value_load_complete =>
				    weight <= sram_output;
				    state <= hidden_weighted_value_mul;
			    WHEN hidden_weighted_value_mul =>
				   -- weighted value = weight * value 
				
					if (numL = 0 ) then
						float_alu_b <= inputs(i);
					else
						float_alu_b <= temp_outputs(i); 
					end if;

					float_alu_a <= weight;
				    float_alu_mode <= mul;
				    state <= hidden_weighted_value_mul_complete;
			    WHEN hidden_weighted_value_mul_complete =>
				    e <= float_alu_c;
				    state <= hidden_weighted_value_add;
			    WHEN hidden_weighted_value_add =>
				    -- sum += weighted value
				    float_alu_a <= hidden_outputs(h);
				    float_alu_b <= e;
				    float_alu_mode <= add;
				    state <= hidden_weighted_value_add_complete;
			    WHEN hidden_weighted_value_add_complete =>
				    hidden_outputs(h) <= float_alu_c;
					if (numL = 0 ) then 
						IF (i = N_I - 1) THEN
							state <= hidden_sig_neg;
				    	ELSE
							i <= i + 1;
					    	state <= hidden_weighted_value_load;
				    	END IF;
					else
						IF (i = numP(numL-1)- 1) THEN
							state <= hidden_sig_neg;  
							report "The value of 'counter' is " & integer'image(counter);
				    	ELSE
							i <= i + 1;
					    	state <= hidden_weighted_value_load;
				    	END IF;
					end if;
						

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
				 	hidden_outputs(h) <= float_alu_c;   -- finish sigmoid funtion f(x)
				 
				 	state <= hidden_sig_double;		    -- Symmetrical sigmoid 2f(x)-1
				 when hidden_sig_double =>
				    float_alu_a <= hidden_outputs(h);
				 	float_alu_b <= hidden_outputs(h);
				    float_alu_mode <= add;
					state <= hidden_sig_double_complete; 
				 when hidden_sig_double_complete =>
				    hidden_outputs(h) <= float_alu_c;
				 	state <= hidden_sig_sub;
				 when hidden_sig_sub =>
				 	float_alu_a <= hidden_outputs(h);
				 	float_alu_b <= float_one;
				    float_alu_mode <= sub;
					state <= hidden_sig_sub_complete;
				 when hidden_sig_sub_complete =>
				    hidden_outputs(h) <= float_alu_c;  -- finish the sysmetrical sigmoid 

					
				 	 if (h = numP(numL)-1 ) then
						 o <= 0;
						 numL <= numL + 1;
						 state <= next_layer_load;
					 else
						 h <= h + 1;
						 state <= hidden_weighted_bias_load;
					 end if;
				 WHEN next_layer_load =>
				 	 if (numL < N_L) then
						 h <= 0;   
						 counter <= counter + numP(numL-1);
						 temp_outputs <=  hidden_outputs;
					     state <= hidden_perceptrons_number_load;  -- go to next layer	
						 report "go to next layer ";
					 else
						 state <= output_weighted_bias_load; 
						 report "go to output layer ";
					 end if;
				     
					
			     -- load bias for output layer
			     WHEN output_weighted_bias_load => 
				    sram_addr <= std_logic_vector(to_unsigned((N_H - N_O + o), 12));   -- changed
				    sram_mode <= read;
				    state <= output_weighted_bias_load_complete;
				 WHEN output_weighted_bias_load_complete =>
				    output_outputs(o) <= sram_output;
				 	report "The value of 'o' is " & integer'image(o);
				    n <= 0;
					state <= output_weighted_value_load;

			     -- sum up all weighted value from hidden layer
			     WHEN output_weighted_value_load =>
				 	counter <= counter + 1;
				    sram_mode <= read;
					sram_addr <= std_logic_vector(to_unsigned((N_H - N_O - numP(numL-1)+ o), 12));   -- changed	 -- 前面一层的神经元数目
				    state <= output_weighted_value_load_complete;
			     WHEN output_weighted_value_load_complete =>
				    weight <= sram_output;
				    state <= output_weighted_value_mul;
			     WHEN output_weighted_value_mul => 
				    report "The value of 'n' is " & integer'image(n);
			 	    -- weighted value = weight * value
				    float_alu_a <= weight;
				    float_alu_b <= hidden_outputs(n);
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
				    IF (n = numP(numL-1)- 1) THEN
						state <= output_sig_neg;
				    ELSE
						n <= n + 1;
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
					output_outputs(o) <= float_alu_c;	-- finish the sigmoid function f(x)
				
					state <= output_sig_double;		    -- Symmetrical sigmoid 2f(x)-1
				 when output_sig_double =>
				    float_alu_a <= output_outputs(o);
				 	float_alu_b <= output_outputs(o);
				    float_alu_mode <= add;
					state <= output_sig_double_complete; 
				 when output_sig_double_complete =>
				    output_outputs(o) <= float_alu_c;
				 	state <= output_sig_sub;
				 when output_sig_sub =>
				 	float_alu_a <= output_outputs(o);
				 	float_alu_b <= float_one;
				    float_alu_mode <= sub;
					state <= output_sig_sub_complete;
				 when output_sig_sub_complete =>
				    output_outputs(o) <= float_alu_c;  -- finish the sysmetrical sigmoid 
				
				
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
	
		
					
					
					
					
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	



	
	