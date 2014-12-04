library ieee;
use ieee.std_logic_1164.all; 


entity window_3x3 is
	generic(
	DATA_WIDTH : positive :=8
	);
	port(
	clk    : in  std_logic;
	rst    : in  std_logic;
	datain : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
	w11    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
	w12    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
	w13    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
	w21    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
	w22    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
	w23    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
	w31    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
	w32    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
	w33    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    DV     : out std_logic  
	);
	
end window_3x3;	



architecture rtl of window_3x3 is 
-----------------------------------------------------------
 component std_fifo
	Generic (
			constant DATA_WIDTH : positive := 8;
			constant FIFO_DEPTH : positive := 128
	);
	port (
	CLK     : in  STD_LOGIC;                                       -- Clock input
	RST     : in  STD_LOGIC;                                       -- Active high reset
	WriteEn : in  STD_LOGIC;                                       -- Write enable signal
	DataIn  : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);      -- Data input bus
	ReadEn  : in  STD_LOGIC;                                       -- Read enable signal
	DataOut : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);      -- Data output bus
	Empty   : out STD_LOGIC;                                       -- FIFO empty flag
	Full    : out STD_LOGIC;                                        -- FIFO full flag\
	USEDW   : out INTEGER
	);
    end component;
 -----------------------------------------------------------------------------------------

signal a11 : std_logic_vector(DATA_WIDTH -1 downto 0); 
signal a12 : std_logic_vector(DATA_WIDTH -1 downto 0);
signal a13 : std_logic_vector(DATA_WIDTH -1 downto 0);
signal a21 : std_logic_vector(DATA_WIDTH -1 downto 0);
signal a22 : std_logic_vector(DATA_WIDTH -1 downto 0);
signal a23 : std_logic_vector(DATA_WIDTH -1 downto 0);
signal a31 : std_logic_vector(DATA_WIDTH -1 downto 0);
signal a32 : std_logic_vector(DATA_WIDTH -1 downto 0);
signal a33 : std_logic_vector(DATA_WIDTH -1 downto 0);	


---fifo0 signals ----
signal WriteEn0 : std_logic := '1';
signal ReadEn0  : std_logic := '0';
signal Empty0   : std_logic;
signal Full0    : std_logic;	
signal ofifo0   : std_logic_vector(DATA_WIDTH -1 downto 0);	
signal usedw0	: integer;

---fifo1 signals ----
signal WriteEn1 : std_logic :='0';
signal ReadEn1  : std_logic :='0';
signal Empty1   : std_logic;
signal Full1    : std_logic; 
signal ofifo1   : std_logic_vector(DATA_WIDTH -1 downto 0);	
signal usedw1   : integer; 


signal dwrreqb: std_logic:='0';	

-- signals for DV coordination
signal dddddddddDV: std_logic:='0';
signal ddddddddDV: std_logic;
signal dddddddDV: std_logic;
signal ddddddDV: std_logic;
signal dddddDV: std_logic;
signal ddddDV: std_logic;
signal dddDV: std_logic;
signal ddDV: std_logic;
signal dDV: std_logic;


begin 
	fifo0 : std_fifo
	generic map (
	DATA_WIDTH => 8,
	FIFO_DEPTH => 640
	)
	port map(
	CLK => clk,
	RST	=> rst,
	WriteEn	=> WriteEn0,  
	DataIn  => a13,
	ReadEn  => ReadEn0,
	DataOut	=> ofifo0,
	Empty   => Empty0,
	Full    => Full0,
	USEDW   => usedw0
	);
	
	fifo1 : std_fifo
	generic map (
	DATA_WIDTH => 8,
	FIFO_DEPTH => 640
	)
	port map(
	CLK => clk,
	RST	=> rst,
	WriteEn	=> WriteEn1,  
	DataIn  => a23,
	ReadEn  => ReadEn1,
	DataOut	=> ofifo1,
	Empty   => Empty1,
	Full    => Full1,
	USEDW   => usedw1
	); 
	
	process(clk, rst)
	begin
		if (rst='1') then
			a11 <= (others=>'0');
			a12 <= (others=>'0');
			a13 <= (others=>'0');
			a21 <= (others=>'0');
			a22 <= (others=>'0');
			a23 <= (others=>'0');
			a31 <= (others=>'0');
			a32 <= (others=>'0');
			a33 <= (others=>'0');  
			
			w11 <= (others=>'0'); 
			w12 <= (others=>'0');
			w13 <= (others=>'0');
			w21 <= (others=>'0');
			w22 <= (others=>'0');
			w23 <= (others=>'0');
			w31 <= (others=>'0');
			w32 <= (others=>'0');
			w33 <= (others=>'0'); 
			
			WriteEn0 <= '0';
			WriteEn1 <= '0'; 
			
			ddddddddDV <= '0';
            dddddddDV <= '0';
            ddddddDV <= '0';
            dddddDV <= '0';
            ddddDV <= '0';
            dddDV <= '0';
            ddDV <= '0';
            dDV <= '0';
            DV <= '0';
			
			
		elsif rising_edge(clk) then
			a11 <= datain;
			a12 <= a11; 
			a13 <= a12;
			a21 <= ofifo0;
			a22 <= a21;
			a23 <= a22;
			a31 <= ofifo1;
			a32 <= a31;
			a33 <= a32;
			
			w11 <= a11;
			w12 <= a12;
			w13 <= a13;
			w21 <= a21;
			w22 <= a22;
			w23 <= a23;
			w31 <= a31;
			w32 <= a32;
			w33 <= a33;	
			
			WriteEn0 <= '1';
			WriteEn1 <= dwrreqb;
			
			ddddddddDV <= dddddddddDV;
            dddddddDV <= ddddddddDV;
            ddddddDV <= dddddddDV;
            dddddDV <= ddddddDV;
            ddddDV <= dddddDV;  
            dddDV <= ddddDV;
            ddDV <= dddDV;
            dDV <= ddDV;
            DV <= dDV;			
		end if;
end process; 

req: process(clk)
begin 
	if rising_edge(clk) then
		if usedw0 = 635 then
			ReadEn0 <='1';
			dwrreqb <= '1';
		end if;
		if usedw1 = 635  then
			ReadEn1 <='1';
		elsif usedw1 = 636 then
			dddddddddDV <= '1';
		end if;
	end if;
	end process;	
end rtl;


		

			
	
	
	
	








	
	