library ieee;
use ieee.std_logic_1164.all;
package ann_types is 
	type ann_mode is (idle, run);
end package ann_types; 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.float_types.all;
use work.float_constants.all;
use work.sram_dp_types.all;
use work.ann_types.all;
use work.mlp_pkg.all; 

LIBRARY STD;
USE std.textio.all;

entity mlp_dp is
	port (
	rst : in std_logic;
	clk : in std_logic;
	mode : in ann_mode;	
	--inputs : in float_vector(N_I -1 downto 0);
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
	sram_mode : inout sram_mode;
	sram_ready : in std_logic	
	);
end entity mlp_dp;

architecture rtl of mlp_dp is 



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
--=================bin to hex conversion function===================

-- output for each perceptron
signal hidden_outputs : float_vector(MAX_H -1 downto 0 ):=(others => float_zero); 
signal temp_outputs : float_vector(MAX_H -1 downto 0 ):=(others => float_zero);
signal output_outputs : float_vector(N_O -1 downto 0 ):=(others => float_zero);	

--debub signal 
signal sram_addr_temp : std_logic_vector( 11 downto 0);

-- state machine
type states is (
			init,
			init_weight,
			init_weight_complete,
			init_weight_complete2,
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
--signal state : states := idle;

-- temp signals
signal i, h, o, n : integer := 0; -- h = n
signal counter : integer := 0; -- count position

signal numL : integer := 0;	-- number of hidden layers

signal f, e : float := float_zero;
signal weight : float := float_zero;
signal addr : integer := 0;
signal wait_counter : integer := 20;

-- input data
signal inputs : float_vector(N_I - 1 downto 0); 

begin
	
	outputs <= output_outputs;
	
	--fsm triggered at rsing edge
	fsm_mlp : process(clk, rst) is
	variable my_line  :  line;
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
			end if;
			if (sram_mode /= idle)then
				sram_mode <= idle;
			end if;
			if (float_alu_ready ='1' and sram_ready = '1') then
				case state is 
					
				when init => 
				    addr <= 0;
					ready <= '0';
					sram_input <= float_zero;
					numL <= 0;                                                        -- number of layers -- changed
					if (weight_done = '1') then
						state <= init_weight;
						report "Initalization";
					else 
						state <= init;
					end if;				
				when init_weight =>	
					sram_addr <= std_logic_vector(to_unsigned(addr,12));
					sram_mode <= read;
					state <= init_weight_complete;
				when init_weight_complete =>
--					if (sram_output = "00000000") then
--						addr <= addr + 1;
--						state <= init_weight;
--					else
						inputs(addr) <= sram_output;
						state <= init_weight_complete2;
--					end if;	
				when init_weight_complete2 =>				
					write(my_line, string'("input_addr = "));
				    write(my_line, integer'image(addr));
					writeline(output, my_line);				
					
				    write(my_line, string'("input data = "));
				    write(my_line, to_hstring(to_stdulogicvector(sram_output)));
					writeline(output, my_line);
					
					if (addr >= N_I  -1 ) then
					    state <= idle;
						report "inputs load done";
				    else
						addr <= addr + 1;
						state <= init_weight;
					end if;

					
				-- normal run operation start  
				when run  => 
				    ready <= '0';
					done  <= '0';
					report "Nerutal Networks Run";														
				    -- initialize perceptrons to have a zero output
					hidden_outputs <= (others => float_zero);
					output_outputs <= (others => float_zero);
					h <= 0;
					state <= hidden_perceptrons_number_load;

			    ---- first load each layer perceptrons number   not use
				WHEN hidden_perceptrons_number_load =>
					state <= hidden_perceptrons_number_load_complete;						   

				WHEN hidden_perceptrons_number_load_complete =>	  --not use	
					state <= hidden_weighted_bias_load;	
				
			    -- first load bias weight into sum
				WHEN hidden_weighted_bias_load => 
					sram_mode <= read;
					if (numL = 0) then -- if the first hidden layer
						sram_addr <= std_logic_vector(to_unsigned((N_I * numP(numL)+ h + N_I), 12));	-- the first layer
					else				
						sram_addr <= std_logic_vector(to_unsigned((counter + numP(numL-1)* numP(numL)+ h + N_I), 12));	-- not the first layer
					end if;
					
				    state <= hidden_weighted_bias_load_complete;
					
			    WHEN hidden_weighted_bias_load_complete =>
					hidden_outputs(h) <= sram_output;
				    i <= 0;
				    state <= hidden_weighted_value_load;
					
					--report "The value of 'counter' is " & integer'image(counter);
					--report "The value of 'h' is " & integer'image(h);
					
					
					write(my_line, string'("bias_addr = "));
				    write(my_line, integer'image(N_I * numP(numL)+ h + N_I ));
					writeline(output, my_line);
					
					write(my_line, string'("bias = "));
				    write(my_line, to_hstring(to_stdulogicvector(sram_output)));
					writeline(output, my_line);
					
					
			    -- sum up all weighted input to the hidden layer
			    WHEN hidden_weighted_value_load =>				
				    sram_mode <= read;
					if (numL = 0) then -- if the first hidden layer
				    	sram_addr <= std_logic_vector(to_unsigned((i*numP(numL)+h + N_I), 12));
						sram_addr_temp <= std_logic_vector(to_unsigned((i*numP(numL)+h + N_I), 12));
				
					else
						sram_addr <= std_logic_vector(to_unsigned(counter+i*numP(numL)+h+N_I , 12));	-- not the first layer -- 需要修改
						sram_addr_temp <= std_logic_vector(to_unsigned(counter+i*numP(numL)+h+N_I, 12));	-- not the first layer -- 需要修改
					end if;
				    state <= hidden_weighted_value_load_complete;
					
			    WHEN hidden_weighted_value_load_complete =>
				
					--report "The value of 'i' is " & integer'image(i);
					--report "The value of 'counter' is " & integer'image(counter);
					--report "The value of 'h' is " & integer'image(h);
					
					write(my_line, string'("weighted_value_sram_addr = "));
				    write(my_line, to_hstring(to_stdulogicvector(sram_addr_temp)));
					writeline(output, my_line);
					
					write(my_line, string'("weight = "));
				    write(my_line, to_hstring(to_stdulogicvector(sram_output)));
					writeline(output, my_line);
								
				    weight <= sram_output;	
				    state <= hidden_weighted_value_mul;
			    WHEN hidden_weighted_value_mul =>
--					--weighted value = weight * value				
--					if (numL = 0 ) then
--						float_alu_b <= inputs(i);
--					else
--						float_alu_b <= temp_outputs(i); 
--					end if;
--					float_alu_a <= weight;
--				    float_alu_mode <= mul;
     			    state <= hidden_weighted_value_mul_complete;
			    WHEN hidden_weighted_value_mul_complete =>
--					e <= float_alu_c;
				    state <= hidden_weighted_value_add;
			    WHEN hidden_weighted_value_add =>
--				    -- sum += weighted value
--				    float_alu_a <= hidden_outputs(h);
--				    float_alu_b <= e;
--				    float_alu_mode <= add;
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
							--report "The value of 'counter' is " & integer'image(counter);
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
--				    float_alu_a <= hidden_outputs(h);
--				    float_alu_mode <= exp;
				    state <= hidden_sig_exp_complete;
			     WHEN hidden_sig_exp_complete =>
--				    hidden_outputs(h) <= float_alu_c;
				    state <= hidden_sig_add;
			     WHEN hidden_sig_add =>
				    -- output = exp(-sum) + 1.0
--				    float_alu_a <= hidden_outputs(h);
--				    float_alu_b <= float_one;
--				    float_alu_mode <= add;
				    state <= hidden_sig_add_complete;
			     WHEN hidden_sig_add_complete =>
--				    hidden_outputs(h) <= float_alu_c;
				    state <= hidden_sig_div;
			     WHEN hidden_sig_div =>
				    -- output = 1.0 / (exp(-sum) + 1.0)
--				    float_alu_a <= float_one;
--				    float_alu_b <= hidden_outputs(h);
--				    float_alu_mode <= div;
				    state <= hidden_sig_div_complete;
			     WHEN hidden_sig_div_complete =>		 	  
--				 	hidden_outputs(h) <= float_alu_c;   -- finish sigmoid funtion f(x)
				 
				 	state <= hidden_sig_double;		    -- Symmetrical sigmoid 2f(x)-1
				 when hidden_sig_double =>
--				    float_alu_a <= hidden_outputs(h);
--				 	float_alu_b <= hidden_outputs(h);
--				    float_alu_mode <= add;
					state <= hidden_sig_double_complete; 
				 when hidden_sig_double_complete =>
--				    hidden_outputs(h) <= float_alu_c;
				 	state <= hidden_sig_sub;
				 when hidden_sig_sub =>
--				 	float_alu_a <= hidden_outputs(h);
--				 	float_alu_b <= float_one;
--				    float_alu_mode <= sub;
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
						 if (numL = 1)  then --as the second layer 
							 counter <= (N_I+1) * numP(numL-1);
						 else 
						 	counter <= (numP(numL)+1) * numP(numL-1) + counter;
						 end if;
						 temp_outputs <=  hidden_outputs;
					     state <= hidden_perceptrons_number_load;  -- go to next layer	
						 report "go to next layer ";
					 else
						 state <= output_weighted_bias_load;
						 counter <= numP(numL-1) * (numP(numL-2)+1) + counter;
						 report "go to output layer ";
					 end if;
				     
					
			     -- load bias for output layer
			     WHEN output_weighted_bias_load =>
				    --report "The value of 'counter' is " & integer'image(counter);
				 	sram_addr <= std_logic_vector(to_unsigned((N_H - N_O + o + N_I), 12));   -- changed
				 	sram_addr_temp <= std_logic_vector(to_unsigned((N_H - N_O + o + N_I), 12));   -- changed 
				    sram_mode <= read;
				    state <= output_weighted_bias_load_complete;
				 WHEN output_weighted_bias_load_complete =>
				 	output_outputs(o) <= sram_output;
				 
				 
				    				 
				    write(my_line, string'("bias_sram_addr = "));
				    write(my_line, to_hstring(to_stdulogicvector(sram_addr_temp)));
					writeline(output, my_line);
					
				    write(my_line, string'("bias = "));
				    write(my_line, to_hstring(to_stdulogicvector(sram_output)));
					writeline(output, my_line);
					
				 	--report "The value of 'o' is " & integer'image(o);
				    n <= 0;
					state <= output_weighted_value_load;

			     -- sum up all weighted value from hidden layer
			     WHEN output_weighted_value_load =>
				 	--counter <= counter + 1;
				    sram_mode <= read;
					sram_addr <= std_logic_vector(to_unsigned(counter+n*N_O+o+N_I, 12));   -- changed	 -- 前面一层的神经元数目
					sram_addr_temp <=   std_logic_vector(to_unsigned(counter+n*N_O+o+N_I, 12));   -- changed	 -- 前面一层的神经元数目
				    state <= output_weighted_value_load_complete;
			     WHEN output_weighted_value_load_complete =>
				 
				 	--report "The value of 'counter' is " & integer'image(counter);
				    write(my_line, string'("weighted_value_sram_addr = "));
				    write(my_line, to_hstring(to_stdulogicvector(sram_addr_temp)));
					writeline(output, my_line);
					
				    write(my_line, string'("weight = "));
				    write(my_line, to_hstring(to_stdulogicvector(sram_output)));
					writeline(output, my_line);
				    
					weight <= sram_output;
				    state <= output_weighted_value_mul;
			     WHEN output_weighted_value_mul => 
				    --report "The value of 'n' is " & integer'image(n);
			 	    -- weighted value = weight * value
--				    float_alu_a <= weight;
--				    float_alu_b <= hidden_outputs(n);
--				    float_alu_mode <= mul;
				    state <= output_weighted_value_mul_complete;
			     WHEN output_weighted_value_mul_complete =>
--				    f <= float_alu_c;
				    state <= output_weighted_value_add;
			     WHEN output_weighted_value_add =>
--				    -- sum += weighted value
--				    float_alu_a <= output_outputs(o);
--				    float_alu_b <= f;
--				    float_alu_mode <= add;
				    state <= output_weighted_value_add_complete;
			     WHEN output_weighted_value_add_complete =>
--				    output_outputs(o) <= float_alu_c;
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
	--			    float_alu_a <= output_outputs(o);
--				    float_alu_mode <= exp;
			   	    state <= output_sig_exp_complete;
			     WHEN output_sig_exp_complete =>
				 --   output_outputs(o) <= float_alu_c;
				    state <= output_sig_add;
			     WHEN output_sig_add =>
	--			    -- output = exp(-sum) + 1.0
--				    float_alu_a <= output_outputs(o);
--				    float_alu_b <= float_one;
--				    float_alu_mode <= add;
				    state <= output_sig_add_complete;
			    WHEN output_sig_add_complete =>
--				    output_outputs(o) <= float_alu_c;  
				    state <= output_sig_div;
			    WHEN output_sig_div =>
				    -- output = 1.0 / (exp(-sum) + 1.0)
--				    float_alu_a <= float_one;
--				    float_alu_b <= output_outputs(o);
--				    float_alu_mode <= div;
				    state <= output_sig_div_complete;
			    WHEN output_sig_div_complete =>
	--				output_outputs(o) <= float_alu_c;	-- finish the sigmoid function f(x)
				
					state <= output_sig_double;		    -- Symmetrical sigmoid 2f(x)-1
				 when output_sig_double =>
		--		    float_alu_a <= output_outputs(o);
--				 	float_alu_b <= output_outputs(o);
--				    float_alu_mode <= add;
					state <= output_sig_double_complete; 
				 when output_sig_double_complete =>
--				    output_outputs(o) <= float_alu_c;
				 	state <= output_sig_sub;
				 when output_sig_sub =>
--				 	float_alu_a <= output_outputs(o);
--				 	float_alu_b <= float_one;
--				    float_alu_mode <= sub;
					state <= output_sig_sub_complete;
				 when output_sig_sub_complete =>
	--			    output_outputs(o) <= float_alu_c;  -- finish the sysmetrical sigmoid 
				
				
			        IF (o = N_O - 1) then
						state <= idle;
						report "mlp done";
						done  <= '1';
					else
						o <= o + 1;
					    state <= output_weighted_bias_load;
					END IF;
 				
				WHEN idle =>
				    ready <= '1';
				    CASE mode IS
						WHEN idle =>
							sram_mode <= idle;
							state <= idle;
							--report "idle state";
				        WHEN run =>
						  	ready <= '0';
						   	state <= run;
							--report "run";
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
	
		
					
					
					
					
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	



	
	