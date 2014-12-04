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