library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mlp_pkg is
    
    constant N_I : integer := 16; -- number of perceptrons at input layer
	constant N_H : integer := 1072; -- total number of weights and bias -- changed
	constant N_O : integer := 16; -- number of perceptrons at output layer
	constant N_L : integer := 1;  -- number of hidden layer 
	
	constant MAX_H : integer := 40;	-- max number of perceptrons at each hidden layer
	
	type int_array is array (0 to 1) of integer;
    constant numP : int_array := (32,0);	 -- each number of perceptrons at hidden layer

end mlp_pkg;

