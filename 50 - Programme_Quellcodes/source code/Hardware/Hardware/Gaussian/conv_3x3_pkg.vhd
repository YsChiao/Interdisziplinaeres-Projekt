library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package conv_3x3_pkg is
	-- the constants kx defines the kernel to be used in the convolution operation
	-- the kx value may be in the range -128<kx<128
	constant k0 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(1,8));
	constant k1 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(2,8));
	constant k2 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(1,8));
	constant k3 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(2,8));
	constant k4 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(4,8));
	constant k5 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(2,8));
	constant k6 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(1,8));
	constant k7 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(2,8)); 
	constant k8 : std_logic_vector(7 downto 0) := std_logic_vector(to_signed(1,8));
	
	
	
	
	constant DATA_WIDTH : integer := 8;
	constant order      : integer := 1;
	constant num_cols   : integer := 640;
	constant num_rows   : integer := 360; 
	
	
	-- the gaussian kernal [1/16 1/8 1/16; 1/8 1/4 1/8; 1/16 1/8 1/16]
	
	end conv_3x3_pkg;