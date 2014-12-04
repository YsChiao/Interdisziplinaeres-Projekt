-- Copyright 2003-2006 J��r��mie Detrey, Florent de Dinechin
--
-- This file is part of FPLibrary
--
-- FPLibrary is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- FPLibrary is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with FPLibrary; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package pkg_fp_exp is

  function mult_latency ( wX, wY : positive;
                          first  : integer;
                          steps  : positive )
    return positive;

  function fp_exp_g ( wF : positive )
    return positive;

  function fp_exp_wy1 ( wF : positive )
    return positive;

  function fp_exp_wy2 ( wF : positive )
    return positive;

  function fp_exp_shift_wx ( wE, wF : positive )
    return positive;

  function fp_exp_shift_latency ( wE, wF : positive )
    return positive;

  function fp_exp_exp_y2_latency ( wF : positive )
    return positive;

  function fp_exp_add_z0_latency ( wF : positive )
    return integer;

  function min ( x, y : integer )
    return integer;

  function max ( x, y : integer )
    return integer;
  
  function log2 ( x : positive )
    return integer;

  function cst_InvLog2 ( w : positive )
    return std_logic_vector;

  function cst_Log2 ( w : positive )
    return std_logic_vector;

  component delay is
    generic ( w : positive;
              n : integer := 1 );
    port ( nX_0 : in  std_logic_vector(w-1 downto 0);
           nX_d : out std_logic_vector(w-1 downto 0);
           clk  : in  std_logic );
  end component;

  component mult_clk is
    generic ( wX    : positive;
              wY    : positive;
              sgnX  : boolean  := false;
              sgnY  : boolean  := false;
              first : integer  := 0;
              steps : positive := 2 );
    port ( nX  : in  std_logic_vector(wX-1 downto 0);
           nY  : in  std_logic_vector(wY-1 downto 0);
           nR  : out std_logic_vector(wX+wY-1 downto 0);
           clk : in  std_logic );
  end component;

  component fp_exp_shift is
    generic ( wE : positive;
              wF : positive );
    port ( fpX : in  std_logic_vector(wE+wF downto 0);
           nX  : out std_logic_vector(wE+wF+fp_exp_g(wF)-1 downto 0);
           ofl : out std_logic;
           ufl : out std_logic );
  end component;

  component fp_exp_shift_clk is
    generic ( wE : positive;
              wF : positive );
    port ( fpX : in  std_logic_vector(wE+wF downto 0);
           nX  : out std_logic_vector(wE+wF+fp_exp_g(wF)-1 downto 0);
           ofl : out std_logic;
           ufl : out std_logic;
           clk : in  std_logic );
  end component;

  component fp_exp_exp_y1 is
    generic ( wF : positive );
    port ( nY1    : in  std_logic_vector(fp_exp_wy1(wF)-1 downto 0);
           nExpY1 : out std_logic_vector(wF+fp_exp_g(wF)-1 downto 0) );
  end component;

  component fp_exp_exp_y2 is
    generic ( wF : positive );
    port ( nY2    : in  std_logic_vector(fp_exp_wy2(wF)-1 downto 0);
           nExpY2 : out std_logic_vector(fp_exp_wy2(wF) downto 0) );
  end component;

  component fp_exp_exp_y2_clk is
    generic ( wF : positive );
    port ( nY2    : in  std_logic_vector(fp_exp_wy2(wF)-1 downto 0);
           nExpY2 : out std_logic_vector(fp_exp_wy2(wF) downto 0);
           clk    : in  std_logic );
  end component;

end package pkg_fp_exp;


package body pkg_fp_exp is

  function mult_latency ( wX, wY : positive;
                          first  : integer;
                          steps  : positive ) return positive is
  begin
    return (log2(min(wX, wY)-1)+1+1 + first + steps-1) / steps;
  end function;

  function fp_exp_g ( wF : positive ) return positive is
  begin
    return 5;
  end function;

  function fp_exp_wy1 ( wF : positive ) return positive is
  begin
    if wF <= 19 then
      return (wF+fp_exp_g(wF)+1)/3;
    else
      return 8;
    end if;
  end function;

  function fp_exp_wy2 ( wF : positive ) return positive is
  begin
    return wF + fp_exp_g(wF) - 2*fp_exp_wy1(wF);
  end function;

  function fp_exp_shift_wx ( wE, wF : positive ) return positive is
  begin
    return min(wF+fp_exp_g(wF), 2**(wE-1)-1);
  end function;

  function fp_exp_shift_latency ( wE, wF : positive ) return positive is
    constant first : integer  := 4;
    constant steps : positive := 8;
  begin
    return (log2(fp_exp_shift_wx(wE, wF)+wE-2)+1 + first-1) / steps + 1;
  end function;

  function fp_exp_exp_y2_latency ( wF : positive ) return positive is
  begin
    if wF <= 19 then
      return 1;
    else
      return 2;
    end if;
  end function;

  function fp_exp_add_z0_latency ( wF : positive ) return integer is
  begin
    if wF <= 19 then
      return 0;
    else
      return 1;
    end if;                    
  end function;

  function min ( x, y : integer ) return integer is
  begin
    if x <= y then
      return x;
    else
      return y;
    end if;
  end function;

  function max ( x, y : integer ) return integer is
  begin
    if x >= y then
      return x;
    else
      return y;
    end if;
  end function;

  function log2 ( x : positive ) return integer is
    variable n : natural := 0;
  begin
    while 2**(n+1) <= x loop
      n := n+1;
    end loop;
    return n;
  end function;

  function cst_InvLog2 ( w : positive ) return std_logic_vector is
    type lut_t is array (4 to 12) of std_logic_vector(12 downto 0);
    constant lut : lut_t := (  4 => "0000000010111",
                               5 => "0000000101110",
                               6 => "0000001011100",
                               7 => "0000010111001",
                               8 => "0000101110001",
                               9 => "0001011100011",
                              10 => "0010111000101",
                              11 => "0101110001011",
                              12 => "1011100010101" );
  begin
    return lut(w)(w downto 0);
  end function;

  function cst_Log2 ( w : positive ) return std_logic_vector is
    type lut_t is array (10 to 40) of std_logic_vector(39 downto 0);
    constant lut : lut_t := ( 10 => "0000000000000000000000000000001011000110",
                              11 => "0000000000000000000000000000010110001100",
                              12 => "0000000000000000000000000000101100010111",
                              13 => "0000000000000000000000000001011000101110",
                              14 => "0000000000000000000000000010110001011101",
                              15 => "0000000000000000000000000101100010111001",
                              16 => "0000000000000000000000001011000101110010",
                              17 => "0000000000000000000000010110001011100100",
                              18 => "0000000000000000000000101100010111001000",
                              19 => "0000000000000000000001011000101110010001",
                              20 => "0000000000000000000010110001011100100001",
                              21 => "0000000000000000000101100010111001000011",
                              22 => "0000000000000000001011000101110010000110",
                              23 => "0000000000000000010110001011100100001100",
                              24 => "0000000000000000101100010111001000011000",
                              25 => "0000000000000001011000101110010000110000",
                              26 => "0000000000000010110001011100100001100000",
                              27 => "0000000000000101100010111001000011000000",
                              28 => "0000000000001011000101110010000101111111",
                              29 => "0000000000010110001011100100001011111111",
                              30 => "0000000000101100010111001000010111111110",
                              31 => "0000000001011000101110010000101111111100",
                              32 => "0000000010110001011100100001011111111000",
                              33 => "0000000101100010111001000010111111110000",
                              34 => "0000001011000101110010000101111111011111",
                              35 => "0000010110001011100100001011111110111111",
                              36 => "0000101100010111001000010111111101111101",
                              37 => "0001011000101110010000101111111011111010",
                              38 => "0010110001011100100001011111110111110100",
                              39 => "0101100010111001000010111111101111101001",
                              40 => "1011000101110010000101111111011111010010" );
  begin
    return lut(w)(w-1 downto 0);
  end function;
  
end pkg_fp_exp;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity delay is
  generic ( w : positive;
            n : integer := 1 );
  port ( nX_0 : in  std_logic_vector(w-1 downto 0);
         nX_d : out std_logic_vector(w-1 downto 0);
         clk  : in  std_logic );
end entity;

architecture arch of delay is
  signal buf : std_logic_vector((n+1)*w-1 downto 0);
begin

  buf(w-1 downto 0) <= nX_0;

  process(clk)
  begin
    if clk'event and clk = '1' then
      buf((n+1)*w-1 downto w) <= buf(n*w-1 downto 0);
    end if;
  end process;

  nX_d <= buf((n+1)*w-1 downto n*w);

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_fp_exp.all;

entity mult_clk is
  generic ( wX    : positive;
            wY    : positive;
            sgnX  : boolean  := false;
            sgnY  : boolean  := false;
            first : integer  := 0;
            steps : positive := 2 );
  port ( nX  : in  std_logic_vector(wX-1 downto 0);
         nY  : in  std_logic_vector(wY-1 downto 0);
         nR  : out std_logic_vector(wX+wY-1 downto 0);
         clk : in  std_logic );
end entity;

architecture arch of mult_clk is
  constant wX0   : positive := max(wX, wY)+1;
  constant wY0   : positive := min(wX, wY);
  constant sgnX0 : boolean  := ((wX >= wY) and sgnX) or ((wX < wY) and sgnY);
  constant sgnY0 : boolean  := ((wX >= wY) and sgnY) or ((wX < wY) and sgnX);
  constant n     : positive := log2(wY0-1)+1;

  signal nX0_0 : std_logic_vector(wX0-1 downto 0);
  signal nY0_0 : std_logic_vector(wY0-1 downto 0);

  signal buf_x : std_logic_vector((n+1)*(2**n) + (2**(n+1)-1)*wX0 - 1 downto 0);
  signal buf_r : std_logic_vector((n+1)*(2**n) + (2**(n+1)-1)*wX0 - 1 downto 0);
  
  signal nR_a0 : std_logic_vector(wX+wY-1 downto 0);
begin

  no_swap : if wX >= wY generate
    nX0_0(wX0-2 downto 0) <= nX;
    nY0_0 <= nY;
  end generate;

  swap : if wX < wY generate
    nX0_0(wX0-2 downto 0) <= nY;
    nY0_0 <= nX;
  end generate;

  no_signed_x0 : if not sgnX0 generate
    nX0_0(wX0-1) <= '0';
  end generate;
  
  signed_x0 : if sgnX0 generate
    nX0_0(wX0-1) <= nX0_0(wX0-2);
  end generate;

  partial_prod : for i in 0 to wY0-1 generate
    no_signed_y0 : if (i < wY0-1) or (not sgnY0) generate
      buf_x(i*(wX0+1)+wX0 downto i*(wX0+1)) <= nX0_0(wX0-1) & nX0_0 when nY0_0(i) = '1' else
                                               "" & (wX0 downto 0 => '0');
    end generate;

    signed_y0 : if (i = wY0-1) and sgnY0 generate
      buf_x(i*(wX0+1)+wX0 downto i*(wX0+1)) <= (wX0 downto 0 => '0') - (nX0_0(wX0-1) & nX0_0) when nY0_0(i) = '1' else
                                               "" & (wX0 downto 0 => '0');
    end generate;
  end generate;

  adder_tree : for k in 1 to n generate
    reg : if ((k+first) mod steps = 0) and (k+first > 0) generate
      process(clk)
      begin
        if clk'event and clk = '1' then
          buf_r((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + (wY0+2**(k-1)-1)/(2**(k-1))*(wX0+2**(k-1)) - 1 downto
                (k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0)
            <= buf_x((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + (wY0+2**(k-1)-1)/(2**(k-1))*(wX0+2**(k-1)) - 1 downto
                     (k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0);
        end if;
      end process;
    end generate;

    row : for i in 0 to (wY0+2**k-1)/(2**k)-1 generate
      adder : if 2*i < (wY0+2**(k-1)-1)/(2**(k-1))-1 generate
        no_reg : if ((k+first) mod steps /= 0) or (k+first = 0) generate
          buf_x(k*(2**n) + (2**(n+1)-2**(n-k+1))*wX0 + i*(wX0+2**k) + wX0+2**k-1 downto
                k*(2**n) + (2**(n+1)-2**(n-k+1))*wX0 + i*(wX0+2**k))
            <= (  (2**(k-1)-1 downto 0 => buf_x((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)) + wX0+2**(k-1)-1))
                & buf_x((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)) + wX0+2**(k-1)-1 downto
                        (k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1))))
            +  (buf_x((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + (2*i+1)*(wX0+2**(k-1)) + wX0+2**(k-1)-1 downto
                      (k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + (2*i+1)*(wX0+2**(k-1))) & (2**(k-1)-1 downto 0 => '0'));
        end generate;

        reg : if ((k+first) mod steps = 0) and (k+first > 0) generate
          buf_x(k*(2**n) + (2**(n+1)-2**(n-k+1))*wX0 + i*(wX0+2**k) + wX0+2**k-1 downto
                k*(2**n) + (2**(n+1)-2**(n-k+1))*wX0 + i*(wX0+2**k))
            <= (  (2**(k-1)-1 downto 0 => buf_r((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)) + wX0+2**(k-1)-1))
                & buf_r((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)) + wX0+2**(k-1)-1 downto
                        (k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1))))
            +  (buf_r((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + (2*i+1)*(wX0+2**(k-1)) + wX0+2**(k-1)-1 downto
                      (k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + (2*i+1)*(wX0+2**(k-1))) & (2**(k-1)-1 downto 0 => '0'));
        end generate;
      end generate;

      pass : if 2*i = (wY0+2**(k-1)-1)/(2**(k-1))-1 generate
        no_reg : if ((k+first) mod steps /= 0) or (k+first = 0) generate
          buf_x(k*(2**n) + (2**(n+1)-2**(n-k+1))*wX0 + i*(wX0+2**k) + wX0+2**k-1 downto
                k*(2**n) + (2**(n+1)-2**(n-k+1))*wX0 + i*(wX0+2**k))
            <= (2**(k-1)-1 downto 0 => buf_x((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)) + wX0+2**(k-1)-1))
            &  buf_x((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)) + wX0+2**(k-1)-1 downto
                     (k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)));
        end generate;

        reg : if ((k+first) mod steps = 0) and (k+first > 0) generate
          buf_x(k*(2**n) + (2**(n+1)-2**(n-k+1))*wX0 + i*(wX0+2**k) + wX0+2**k-1 downto
                k*(2**n) + (2**(n+1)-2**(n-k+1))*wX0 + i*(wX0+2**k))
            <= (2**(k-1)-1 downto 0 => buf_r((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)) + wX0+2**(k-1)-1))
            &  buf_r((k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)) + wX0+2**(k-1)-1 downto
                     (k-1)*(2**n) + (2**(n+1)-2**(n-k+2))*wX0 + 2*i*(wX0+2**(k-1)));
        end generate;
      end generate;
    end generate;
  end generate;

  nR_a0 <= buf_x(n*(2**n) + (2**(n+1)-2)*wX0 + wX+wY-1 downto n*(2**n) + (2**(n+1)-2)*wX0);

  nR <= nR_a0;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_fp_exp.all;

entity fp_exp_shift is
  generic ( wE : positive;
            wF : positive );
  port ( fpX : in  std_logic_vector(wE+wF downto 0);
         nX  : out std_logic_vector(wE+wF+fp_exp_g(wF)-1 downto 0);
         ofl : out std_logic;
         ufl : out std_logic );
end entity;

architecture arch of fp_exp_shift is
  constant g  : positive := fp_exp_g(wF);
  constant wX : integer  := fp_exp_shift_wx(wE, wF);
  constant n  : positive := log2(wX+wE-2)+1;

  signal e0 : std_logic_vector(wE+1 downto 0);
  signal eX : std_logic_vector(wE+1 downto 0);

  signal mXu : std_logic_vector(wF downto 0);
  signal mXs : std_logic_vector(wF+1 downto 0);

  signal buf : std_logic_vector((n+1)*(wF+2**n+1)-1 downto 0);
begin

  e0 <= conv_std_logic_vector(2**(wE-1)-1 - wX, wE+2);
  eX <= ("00" & fpX(wE+wF-1 downto wF)) - e0;

  ufl <= eX(wE+1);
  ofl <= not eX(wE+1) when eX(wE downto 0) > conv_std_logic_vector(wX+wE-2, wE+1) else
         '0';

  mXu <= "1" & fpX(wF-1 downto 0);

  mXs <= (wF+1 downto 0 => '0') - ("0" & mXu) when fpX(wE+wF) = '1' else
         "0" & mXu;

  buf(wF+1 downto 0) <= mXs;

  shift : for i in 0 to n-1 generate
    buf((i+1)*(wF+2**n+1)+wF+2**(i+1) downto (i+1)*(wF+2**n+1)) <=
      (2**i-1 downto 0 => buf(i*(wF+2**n+1)+wF+2**i)) & buf(i*(wF+2**n+1)+wF+2**i downto i*(wF+2**n+1)) when eX(i) = '0' else
      buf(i*(wF+2**n+1)+wF+2**i downto i*(wF+2**n+1)) & (2**i-1 downto 0 => '0');
  end generate;

  no_padding : if wX >= g generate
    nX <= buf(n*(wF+2**n+1)+wF+wE+wX-1 downto n*(wF+2**n+1)+wX-g);
  end generate;

  padding : if wX < g generate
    nX <= buf(n*(wF+2**n+1)+wF+wE+wX-1 downto n*(wF+2**n+1)) & (g-wX-1 downto 0 => '0');
  end generate;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_fp_exp.all;

entity fp_exp_shift_clk is
  generic ( wE : positive;
            wF : positive );
  port ( fpX : in  std_logic_vector(wE+wF downto 0);
         nX  : out std_logic_vector(wE+wF+fp_exp_g(wF)-1 downto 0);
         ofl : out std_logic;
         ufl : out std_logic;
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_shift_clk is
  constant g  : positive := fp_exp_g(wF);
  constant wX : integer  := fp_exp_shift_wx(wE, wF);
  constant n  : positive := log2(wX+wE-2)+1;

  constant first : integer  := 4;
  constant steps : positive := 8;
  constant nr    : integer  := (n+first-1)/steps;

  signal fpX_0 : std_logic_vector(wE+wF downto 0);
  
  constant e0 : std_logic_vector(wE+1 downto 0) := conv_std_logic_vector(2**(wE-1)-1 - wX, wE+2);

  signal eX_0 : std_logic_vector(wE+1 downto 0);
  signal eX_x : std_logic_vector((nr+1)*n-1 downto 0);
  signal eX_r : std_logic_vector((nr+1)*n-1 downto 0);

  signal ofl_0  : std_logic_vector(0 downto 0);
  signal ofl_a0 : std_logic_vector(0 downto 0);
  signal ufl_0  : std_logic_vector(0 downto 0);
  signal ufl_a0 : std_logic_vector(0 downto 0);

  signal mXu_0 : std_logic_vector(wF downto 0);
  signal mXs_0 : std_logic_vector(wF+1 downto 0);

  signal buf_x : std_logic_vector((n+1)*(wF+2**n+1)-1 downto 0);
  signal buf_r : std_logic_vector(nr*(wF+2**n+1)-1 downto 0);

  signal nX_a0 : std_logic_vector(wE+wF+g-1 downto 0);
begin

  fpX_0 <= fpX;

  eX_0 <= ("00" & fpX_0(wE+wF-1 downto wF)) - e0;

  ufl_0(0) <= eX_0(wE+1);
  ofl_0(0) <= not eX_0(wE+1) when eX_0(wE downto 0) > conv_std_logic_vector(wX+wE-2, wE+1) else
              '0';

  mXu_0 <= "1" & fpX_0(wF-1 downto 0);

  mXs_0 <= (wF+1 downto 0 => '0') - ("0" & mXu_0) when fpX_0(wE+wF) = '1' else
           "0" & mXu_0;

  buf_x(wF+1 downto 0) <= mXs_0;

  eX_x(n-1 downto 0) <= eX_0(n-1 downto 0);

  shift : for i in 0 to n-1 generate
    no_reg : if ((i+first) mod steps /= 0) or (i+first <= 0) generate
      buf_x((i+1)*(wF+2**n+1)+wF+2**(i+1) downto (i+1)*(wF+2**n+1)) <=
        (2**i-1 downto 0 => buf_x(i*(wF+2**n+1)+wF+2**i)) & buf_x(i*(wF+2**n+1)+wF+2**i downto i*(wF+2**n+1)) when eX_x(((i+first)/steps)*n+i) = '0' else
        buf_x(i*(wF+2**n+1)+wF+2**i downto i*(wF+2**n+1)) & (2**i-1 downto 0 => '0');
    end generate;

    reg : if ((i+first) mod steps = 0) and (i+first > 0) generate
      process(clk)
      begin
        if clk'event and clk = '1' then
          buf_r((i/steps)*(wF+2**n+1)+wF+2**i downto (i/steps)*(wF+2**n+1)) <= buf_x(i*(wF+2**n+1)+wF+2**i downto i*(wF+2**n+1));
          eX_r((i/steps+1)*n+n-1 downto (i/steps+1)*n+i)                    <= eX_x((i/steps)*n+n-1 downto (i/steps)*n+i);
        end if;
      end process;

      eX_x((i/steps+1)*n+n-1 downto (i/steps+1)*n+i) <= eX_r((i/steps+1)*n+n-1 downto (i/steps+1)*n+i);

      buf_x((i+1)*(wF+2**n+1)+wF+2**(i+1) downto (i+1)*(wF+2**n+1)) <=
        (2**i-1 downto 0 => buf_r((i/steps)*(wF+2**n+1)+wF+2**i)) & buf_r((i/steps)*(wF+2**n+1)+wF+2**i downto (i/steps)*(wF+2**n+1)) when eX_x((i/steps+1)*n+i) = '0' else
        buf_r((i/steps)*(wF+2**n+1)+wF+2**i downto (i/steps)*(wF+2**n+1)) & (2**i-1 downto 0 => '0');
    end generate;
  end generate;

  no_padding : if wX >= g generate
    nX_a0 <= buf_x(n*(wF+2**n+1)+wF+wE+wX-1 downto n*(wF+2**n+1)+wX-g);
  end generate;

  padding : if wX < g generate
    nX_a0 <= buf_x(n*(wF+2**n+1)+wF+wE+wX-1 downto n*(wF+2**n+1)) & (g-wX-1 downto 0 => '0');
  end generate;

  delay_ofl : delay
    generic map ( w => 1,
                  n => nr )
    port map ( nX_0 => ofl_0,
               nX_d => ofl_a0,
               clk  => clk );

  delay_ufl : delay
    generic map ( w => 1,
                  n => nr )
    port map ( nX_0 => ufl_0,
               nX_d => ufl_a0,
               clk  => clk );

  nX  <= nX_a0;
  ofl <= ofl_a0(0);
  ufl <= ufl_a0(0);

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_fp_exp.all;

entity fp_exp is
  generic ( wE : positive := 6;
            wF : positive := 13 );
  port ( fpX : in  std_logic_vector(2+wE+wF downto 0);
         fpR : out std_logic_vector(2+wE+wF downto 0) );
end entity;

architecture arch of fp_exp is
  constant g   : positive := fp_exp_g(wF);
  constant wY1 : positive := fp_exp_wy1(wF);
  constant wY2 : positive := fp_exp_wy2(wF);

  signal nX : std_logic_vector(wE+wF+g-1 downto 0);

  constant cstInvLog2 : std_logic_vector(wE+1 downto 0) := cst_InvLog2(wE+1);

  signal nK0 : std_logic_vector(wE+4+wE downto 0);
  signal nK1 : std_logic_vector(wE+4+wE+1 downto 0);
  signal nK  : std_logic_vector(wE downto 0);

  constant cstLog2 : std_logic_vector(wE-1+wF+g-1 downto 0) := cst_Log2(wE-1+wF+g);

  signal nKLog20 : std_logic_vector(wE+wE-1+wF+g-1 downto 0);
  signal nKLog2  : std_logic_vector(wE+wE-1+wF+g downto 0);
  
  signal nY  : std_logic_vector(wE+wF+g-1 downto 0);
  signal nY1 : std_logic_vector(wY1-1 downto 0);

  signal nEY1 : std_logic_vector(wF+g-1 downto 0);
  signal nEY2 : std_logic_vector(wY2 downto 0);

  signal nZ0 : std_logic_vector(wF+g-wY1+1 downto 0);
  signal nZ1 : std_logic_vector(wF+g+wF+g-wY1+1 downto 0);
  signal nZ2 : std_logic_vector(wF+g-wY1 downto 0);
  signal nZ  : std_logic_vector(wF+g-1 downto 0);

  signal sticky : std_logic;
  signal round  : std_logic;

  signal fR0 : std_logic_vector(wF+1 downto 0);
  signal fR1 : std_logic_vector(wF downto 0);
  signal fR  : std_logic_vector(wF-1 downto 0);

  signal eR : std_logic_vector(wE downto 0);
  
  signal ofl0 : std_logic;
  signal ofl1 : std_logic;
  signal ofl2 : std_logic;
  signal ufl0 : std_logic;
  signal ufl1 : std_logic;
begin

  shift : fp_exp_shift
    generic map ( wE => wE,
                  wF => wF )
    port map ( fpX => fpX(wE+wF downto 0),
               nX  => nX,
               ofl => ofl0,
               ufl => ufl0 );

  nK0 <= nX(wE+wF+g-2 downto wF+g-4) * cstInvLog2;
  nK1 <= ("0" & nK0) - ("0" & cstInvLog2 & (wE+4-2 downto 0 => '0')) when nX(wE+wF+g-1) = '1' else
         "0" & nK0;

  nK <= nK1(wE+4+wE+1 downto 4+wE+1) + ((wE downto 1 => '0') & nK1(4+wE));

  nKLog20 <= nK(wE-1 downto 0) * cstLog2;
  nKLog2  <= ("0" & nKLog20) - ("0" & cstLog2 & (wE-1 downto 0 => '0')) when nK(wE) = '1' else
             "0" & nKLog20;

  nY <= nX - nKLog2(wE+wE-1+wF+g-1 downto wE-1);

  nY1 <= (not nY(wF+g-1)) & nY(wF+g-2 downto wF+g-wY1);

  exp_y1 : fp_exp_exp_y1
    generic map ( wF => wF )
    port map ( nY1    => nY1,
               nExpY1 => nEY1 );

  exp_y2 : fp_exp_exp_y2
    generic map ( wF => wF )
    port map ( nY2    => nY(wF+g-wY1-1 downto wY1),
               nExpY2 => nEY2 );

  nZ0 <= ((wF+g-wY1+1 downto wY2+1 => '0') & nEY2) + ("0" & nY(wF+g-wY1-1 downto 0) & "0");

  nZ1 <= nEY1 * nZ0;
  nZ2 <= nZ1(wF+g+wF+g-wY1+1 downto wF+g+1);

  nZ <= nEY1 + ((wF+g-1 downto wF+g-wY1+1 => '0') & nZ2);

  sticky <= '1' when nZ(g-4 downto 0) /= (g-4 downto 0 => '0') else
            '0';
  fR0 <= nZ(wF+g-2 downto g-2) & (nZ(g-3) or sticky) when nZ(wF+g-1) = '1' else
         nZ(wF+g-3 downto g-3) & sticky;

  round <= fR0(1) and (fR0(2) or fR0(0));
  fR1 <= ("0" & fR0(wF+1 downto 2)) + ((wF+1 downto 3 => '0') & round);

  fR <= fR1(wF-1 downto 0);

  eR <= nK + ("0" & (wE-2 downto 1 => '1') & (nZ(wF+g-1) or fR1(wF)));

  ofl1 <= '1' when eR(wE-1 downto 0) = (wE-1 downto 0 => '0') else
          '1' when eR(wE-1 downto 0) = (wE-1 downto 0 => '1') else
          ofl0 or eR(wE);

  ufl1 <= '1' when fpX(wE+wF+2 downto wE+wF+1) = "00" else
          ufl0;

  ofl2 <= '1' when fpX(wE+wF+2 downto wE+wF+1) = "10" else
          ofl1 and (not ufl1);
  
  fpR(wE+wF+2 downto wE+wF+1) <= "11"                   when fpX(wE+wF+2 downto wE+wF+1) = "11" else
                                 (not fpX(wE+wF)) & "0" when ofl2 = '1'                         else
                                 "01";

  fpR(wE+wF downto 0) <= "00" & (wE-2 downto 0 => '1') & (wF-1 downto 0 => '0') when ufl1 = '1' else
                         "0" & eR(wE-1 downto 0) & fR;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_fp_exp.all;

entity fp_exp_clk is
  generic ( wE : positive := 6;
            wF : positive := 13 );
  port ( fpX : in  std_logic_vector(2+wE+wF downto 0);
         fpR : out std_logic_vector(2+wE+wF downto 0);
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_clk is
  constant g   : positive := fp_exp_g(wF);
  constant wY1 : positive := fp_exp_wy1(wF);
  constant wY2 : positive := fp_exp_wy2(wF);
  
  signal fpX_0  : std_logic_vector(2+wE+wF downto 0);
  signal fpX_e3 : std_logic_vector(2+wE+wF downto 0);

  signal nX_a0 : std_logic_vector(wE+wF+g-1 downto 0);
  signal nX_a1 : std_logic_vector(wE+wF+g-1 downto 0);
  signal nX_c1 : std_logic_vector(wE+wF+g-1 downto 0);

  constant cstInvLog2 : std_logic_vector(wE+1 downto 0) := cst_InvLog2(wE+1);

  signal nK0_b0 : std_logic_vector(wE+4+wE+1 downto 0);
  signal nK_b0  : std_logic_vector(wE downto 0);
  signal nK_b1  : std_logic_vector(wE downto 0);
  signal nK_e3  : std_logic_vector(wE downto 0);

  constant cstLog2 : std_logic_vector(wE-1+wF+g-1 downto 0) := cst_Log2(wE-1+wF+g);

  signal nKLog2_c0 : std_logic_vector(wE+wE-1+wF+g downto 0);
  signal nKLog2_c1 : std_logic_vector(wE+wE-1+wF+g downto 0);
  
  signal nY_c1  : std_logic_vector(wE+wF+g-1 downto 0);
  signal nY_d1  : std_logic_vector(wE+wF+g-1 downto 0);
  signal nY1_c1 : std_logic_vector(wY1-1 downto 0);

  signal nEY1_c1 : std_logic_vector(wF+g-1 downto 0);
  signal nEY1_d2 : std_logic_vector(wF+g-1 downto 0);
  signal nEY1_e1 : std_logic_vector(wF+g-1 downto 0);
  signal nEY2_d0 : std_logic_vector(wY2 downto 0);
  signal nEY2_d1 : std_logic_vector(wY2 downto 0);

  signal nZ0_d1 : std_logic_vector(wF+g-wY1+1 downto 0);
  signal nZ0_d2 : std_logic_vector(wF+g-wY1+1 downto 0);
  signal nZ1_e0 : std_logic_vector(wF+g+wF+g-wY1+1 downto 0);
  signal nZ2_e0 : std_logic_vector(wF+g-wY1 downto 0);
  signal nZ2_e1 : std_logic_vector(wF+g-wY1 downto 0);
  signal nZ_e1  : std_logic_vector(wF+g-1 downto 0);
  signal nZ_e2  : std_logic_vector(wF+g-1 downto 0);
  signal nZ_e3  : std_logic_vector(wF+g-1 downto 0);

  signal sticky_e1 : std_logic;
  signal round_e2  : std_logic;

  signal fR0_e1 : std_logic_vector(wF+1 downto 0);
  signal fR0_e2 : std_logic_vector(wF+1 downto 0);
  signal fR1_e2 : std_logic_vector(wF downto 0);
  signal fR1_e3 : std_logic_vector(wF downto 0);
  signal fR_e3  : std_logic_vector(wF-1 downto 0);

  signal eR_e3 : std_logic_vector(wE downto 0);
  
  signal ofl0_a0 : std_logic;
  signal ofl0_a1 : std_logic;
  signal ofl1_e3 : std_logic;
  signal ofl2_e3 : std_logic;
  signal ufl0_a0 : std_logic;
  signal ufl0_a1 : std_logic;
  signal ufl1_e3 : std_logic;

  signal fpR_e3 : std_logic_vector(2+wE+wF downto 0);
begin

  fpX_0 <= fpX;

-----------------------------------------------------------------------------------------------------------------------

  shift : fp_exp_shift_clk
    generic map ( wE => wE,
                  wF => wF )
    port map ( fpX => fpX_0(wE+wF downto 0),
               nX  => nX_a0,
               ofl => ofl0_a0,
               ufl => ufl0_a0,
               clk => clk );

  process(clk)
  begin
    if clk'event and clk = '1' then
      nX_a1   <= nX_a0;
      ofl0_a1 <= ofl0_a0;
      ufl0_a1 <= ufl0_a0;
    end if;
  end process;

-----------------------------------------------------------------------------------------------------------------------

  mult_k : mult_clk
    generic map ( wX    => wE+4,
                  wY    => wE+2,
                  sgnX  => true,
                  first => 0,
                  steps => 3 )
    port map ( nX  => nX_a1(wE+wF+g-1 downto wF+g-4),
               nY  => cstInvLog2,
               nR  => nK0_b0,
               clk => clk );

  nK_b0 <= nK0_b0(wE+4+wE+1 downto 4+wE+1) + ((wE downto 1 => '0') & nK0_b0(4+wE));

  process(clk)
  begin
    if clk'event and clk = '1' then
      nK_b1 <= nK_b0;
    end if;
  end process;

-----------------------------------------------------------------------------------------------------------------------

  mult_klog2 : mult_clk
    generic map ( wX    => wE+1,
                  wY    => wE-1+wF+g,
                  sgnX  => true,
                  first => -1,
                  steps => 2 )
    port map ( nX  => nK_b1,
               nY  => cstLog2,
               nR  => nKLog2_c0,
               clk => clk );

  process(clk)
  begin
    if clk'event and clk = '1' then
      nKLog2_c1 <= nKLog2_c0;
    end if;
  end process;

  delay_nx : delay
    generic map ( w => wE+wF+g,
                  n => mult_latency(wE+4, wE+2, 0, 3) + mult_latency(wE+1, wE-1+wF+g, -1, 2) )
    port map ( nX_0 => nX_a1,
               nX_d => nX_c1,
               clk  => clk );

-----------------------------------------------------------------------------------------------------------------------
  
  nY_c1 <= nX_c1 - nKLog2_c1(wE+wE-1+wF+g-1 downto wE-1);

  nY1_c1 <= (not nY_c1(wF+g-1)) & nY_c1(wF+g-2 downto wF+g-wY1);

  exp_y1 : fp_exp_exp_y1
    generic map ( wF => wF )
    port map ( nY1    => nY1_c1,
               nExpY1 => nEY1_c1 );

  exp_y2 : fp_exp_exp_y2_clk
    generic map ( wF => wF )
    port map ( nY2    => nY_c1(wF+g-wY1-1 downto wY1),
               nExpY2 => nEY2_d0,       
               clk    => clk );

  process(clk)
  begin
    if clk'event and clk = '1' then
      nEY2_d1 <= nEY2_d0;
    end if;
  end process;

  delay_ny : delay
    generic map ( w => wE+wF+g,
                  n => fp_exp_exp_y2_latency(wF) )
    port map ( nX_0 => nY_c1,
               nX_d => nY_d1,
               clk  => clk );
  
-----------------------------------------------------------------------------------------------------------------------

  nZ0_d1 <= ((wF+g-wY1+1 downto wY2+1 => '0') & nEY2_d1) + ("0" & nY_d1(wF+g-wY1-1 downto 0) & "0");

  delay_ney1_0 : delay
    generic map ( w => wF+g,
                  n => fp_exp_exp_y2_latency(wF) + fp_exp_add_z0_latency(wF) )
    port map ( nX_0 => nEY1_c1,
               nX_d => nEY1_d2,
               clk  => clk );

  delay_nz0 : delay
    generic map ( w => wF+g-wY1+2,
                  n => fp_exp_add_z0_latency(wF) )
    port map ( nX_0 => nZ0_d1,
               nX_d => nZ0_d2,
               clk  => clk );

-----------------------------------------------------------------------------------------------------------------------

  mult_z1 : mult_clk
    generic map ( wX    => wF+g,
                  wY    => wF+g-wY1+2,
                  first => 0,
                  steps => 2 )
    port map ( nX  => nEY1_d2,
               nY  => nZ0_d2,
               nR  => nZ1_e0,
               clk => clk );
  
  nZ2_e0 <= nZ1_e0(wF+g+wF+g-wY1+1 downto wF+g+1);

  process(clk)
  begin
    if clk'event and clk = '1' then
      nZ2_e1 <= nZ2_e0;
    end if;
  end process;

  delay_ney1_1 : delay
    generic map ( w => wF+g,
                  n => mult_latency(wF+g, wF+g-wY1+2, 0, 2) )
    port map ( nX_0 => nEY1_d2,
               nX_d => nEY1_e1,
               clk  => clk );
  
-----------------------------------------------------------------------------------------------------------------------

  nZ_e1 <= nEY1_e1 + ((wF+g-1 downto wF+g-wY1+1 => '0') & nZ2_e1);

  sticky_e1 <= '1' when nZ_e1(g-4 downto 0) /= (g-4 downto 0 => '0') else
               '0';
  fR0_e1 <= nZ_e1(wF+g-2 downto g-2) & (nZ_e1(g-3) or sticky_e1) when nZ_e1(wF+g-1) = '1' else
            nZ_e1(wF+g-3 downto g-3) & sticky_e1;

  process(clk)
  begin
    if clk'event and clk = '1' then
      nZ_e2  <= nZ_e1;
      fR0_e2 <= fR0_e1;
    end if;
  end process;

-----------------------------------------------------------------------------------------------------------------------

  round_e2 <= fR0_e2(1) and (fR0_e2(2) or fR0_e2(0));
  fR1_e2 <= ("0" & fR0_e2(wF+1 downto 2)) + ((wF+1 downto 3 => '0') & round_e2);

  process(clk)
  begin
    if clk'event and clk = '1' then
      nZ_e3  <= nZ_e2;
      fR1_e3 <= fR1_e2;
    end if;
  end process;

  delay_fpx : delay
    generic map ( w => 3+wE+wF,
                  n => (  fp_exp_shift_latency(wE, wF) + mult_latency(wE+4, wE+2, 0, 3) + mult_latency(wE+1, wE-1+wF+g, -1, 2)
                        + fp_exp_exp_y2_latency(wF) + fp_exp_add_z0_latency(wF) + mult_latency(wF+g, wF+g-wY1+2, 0, 2) + 2) )
    port map ( nX_0 => fpX_0,
               nX_d => fpX_e3,
               clk  => clk );

  delay_nk : delay
    generic map ( w => wE+1,
                  n => (  mult_latency(wE+1, wE-1+wF+g, -1, 2) + fp_exp_exp_y2_latency(wF) + fp_exp_add_z0_latency(wF)
                        + mult_latency(wF+g, wF+g-wY1+2, 0, 2) + 2) )
    port map ( nX_0 => nK_b1,
               nX_d => nK_e3,
               clk  => clk );
  
-----------------------------------------------------------------------------------------------------------------------

  fR_e3 <= fR1_e3(wF-1 downto 0);

  eR_e3 <= nK_e3 + ("0" & (wE-2 downto 1 => '1') & (nZ_e3(wF+g-1) or fR1_e3(wF)));

  ofl1_e3 <= '1' when eR_e3(wE-1 downto 0) = (wE-1 downto 0 => '0') else
             '1' when eR_e3(wE-1 downto 0) = (wE-1 downto 0 => '1') else
             ofl0_a1 or eR_e3(wE);

  ufl1_e3 <= '1' when fpX_e3(wE+wF+2 downto wE+wF+1) = "00" else
             ufl0_a1;

  ofl2_e3 <= '1' when fpX_e3(wE+wF+2 downto wE+wF+1) = "10" else
             ofl1_e3 and (not ufl1_e3);
  
  fpR_e3(wE+wF+2 downto wE+wF+1) <= "11"                      when fpX_e3(wE+wF+2 downto wE+wF+1) = "11" else
                                    (not fpX_e3(wE+wF)) & "0" when ofl2_e3 = '1'                         else
                                    "01";

  fpR_e3(wE+wF downto 0) <= "00" & (wE-2 downto 0 => '1') & (wF-1 downto 0 => '0') when ufl1_e3 = '1' else
                            "0" & eR_e3(wE-1 downto 0) & fR_e3;

-----------------------------------------------------------------------------------------------------------------------

  fpR <= fpR_e3;

end architecture;




-- Copyright 2003-2006 J��r��mie Detrey, Florent de Dinechin
--
-- This file is part of FPLibrary
--
-- FPLibrary is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- FPLibrary is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with FPLibrary; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;

package pkg_fp_exp_exp_y1 is

  component fp_exp_exp_y1_6 is
    port ( nY1    : in  std_logic_vector(3 downto 0);
           nExpY1 : out std_logic_vector(6+4 downto 0) );
  end component;

  component fp_exp_exp_y1_7 is
    port ( nY1    : in  std_logic_vector(3 downto 0);
           nExpY1 : out std_logic_vector(7+4 downto 0) );
  end component;

  component fp_exp_exp_y1_8 is
    port ( nY1    : in  std_logic_vector(3 downto 0);
           nExpY1 : out std_logic_vector(8+4 downto 0) );
  end component;

  component fp_exp_exp_y1_9 is
    port ( nY1    : in  std_logic_vector(4 downto 0);
           nExpY1 : out std_logic_vector(9+4 downto 0) );
  end component;

  component fp_exp_exp_y1_10 is
    port ( nY1    : in  std_logic_vector(4 downto 0);
           nExpY1 : out std_logic_vector(10+4 downto 0) );
  end component;

  component fp_exp_exp_y1_11 is
    port ( nY1    : in  std_logic_vector(4 downto 0);
           nExpY1 : out std_logic_vector(11+4 downto 0) );
  end component;

  component fp_exp_exp_y1_12 is
    port ( nY1    : in  std_logic_vector(5 downto 0);
           nExpY1 : out std_logic_vector(12+4 downto 0) );
  end component;

  component fp_exp_exp_y1_13 is
    port ( nY1    : in  std_logic_vector(5 downto 0);
           nExpY1 : out std_logic_vector(13+4 downto 0) );
  end component;

  component fp_exp_exp_y1_14 is
    port ( nY1    : in  std_logic_vector(5 downto 0);
           nExpY1 : out std_logic_vector(14+4 downto 0) );
  end component;

  component fp_exp_exp_y1_15 is
    port ( nY1    : in  std_logic_vector(6 downto 0);
           nExpY1 : out std_logic_vector(15+4 downto 0) );
  end component;

  component fp_exp_exp_y1_16 is
    port ( nY1    : in  std_logic_vector(6 downto 0);
           nExpY1 : out std_logic_vector(16+4 downto 0) );
  end component;

  component fp_exp_exp_y1_17 is
    port ( nY1    : in  std_logic_vector(6 downto 0);
           nExpY1 : out std_logic_vector(17+4 downto 0) );
  end component;

  component fp_exp_exp_y1_18 is
    port ( nY1    : in  std_logic_vector(7 downto 0);
           nExpY1 : out std_logic_vector(18+4 downto 0) );
  end component;

  component fp_exp_exp_y1_19 is
    port ( nY1    : in  std_logic_vector(7 downto 0);
           nExpY1 : out std_logic_vector(19+4 downto 0) );
  end component;

  component fp_exp_exp_y1_20 is
    port ( nY1    : in  std_logic_vector(7 downto 0);
           nExpY1 : out std_logic_vector(20+4 downto 0) );
  end component;

  component fp_exp_exp_y1_21 is
    port ( nY1    : in  std_logic_vector(7 downto 0);
           nExpY1 : out std_logic_vector(21+4 downto 0) );
  end component;

  component fp_exp_exp_y1_22 is
    port ( nY1    : in  std_logic_vector(7 downto 0);
           nExpY1 : out std_logic_vector(22+4 downto 0) );
  end component;

  component fp_exp_exp_y1_23 is
    port ( nY1    : in  std_logic_vector(7 downto 0);
           nExpY1 : out std_logic_vector(23+4 downto 0) );
  end component;

end package;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_6 is
  port ( nY1    : in  std_logic_vector(3 downto 0);
         nExpY1 : out std_logic_vector(6+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_6 is
begin

  with nY1 select
    nExpY1 <= "01001101101" when "0000", -- t[0] = 621
              "01010010101" when "0001", -- t[1] = 661
              "01011000000" when "0010", -- t[2] = 704
              "01011101101" when "0011", -- t[3] = 749
              "01100011101" when "0100", -- t[4] = 797
              "01101010001" when "0101", -- t[5] = 849
              "01110001000" when "0110", -- t[6] = 904
              "01111000010" when "0111", -- t[7] = 962
              "10000000000" when "1000", -- t[8] = 1024
              "10001000010" when "1001", -- t[9] = 1090
              "10010001000" when "1010", -- t[10] = 1160
              "10011010011" when "1011", -- t[11] = 1235
              "10100100011" when "1100", -- t[12] = 1315
              "10101111000" when "1101", -- t[13] = 1400
              "10111010010" when "1110", -- t[14] = 1490
              "11000110010" when "1111", -- t[15] = 1586
              "-----------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_7 is
  port ( nY1    : in  std_logic_vector(3 downto 0);
         nExpY1 : out std_logic_vector(7+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_7 is
begin

  with nY1 select
    nExpY1 <= "010011011010" when "0000", -- t[0] = 1242
              "010100101010" when "0001", -- t[1] = 1322
              "010110000000" when "0010", -- t[2] = 1408
              "010111011010" when "0011", -- t[3] = 1498
              "011000111011" when "0100", -- t[4] = 1595
              "011010100010" when "0101", -- t[5] = 1698
              "011100001111" when "0110", -- t[6] = 1807
              "011110000100" when "0111", -- t[7] = 1924
              "100000000000" when "1000", -- t[8] = 2048
              "100010000100" when "1001", -- t[9] = 2180
              "100100010001" when "1010", -- t[10] = 2321
              "100110100110" when "1011", -- t[11] = 2470
              "101001000110" when "1100", -- t[12] = 2630
              "101011101111" when "1101", -- t[13] = 2799
              "101110100100" when "1110", -- t[14] = 2980
              "110001100100" when "1111", -- t[15] = 3172
              "------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_8 is
  port ( nY1    : in  std_logic_vector(3 downto 0);
         nExpY1 : out std_logic_vector(8+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_8 is
begin

  with nY1 select
    nExpY1 <= "0100110110100" when "0000", -- t[0] = 2484
              "0101001010101" when "0001", -- t[1] = 2645
              "0101011111111" when "0010", -- t[2] = 2815
              "0101110110101" when "0011", -- t[3] = 2997
              "0110001110110" when "0100", -- t[4] = 3190
              "0110101000100" when "0101", -- t[5] = 3396
              "0111000011111" when "0110", -- t[6] = 3615
              "0111100001000" when "0111", -- t[7] = 3848
              "1000000000000" when "1000", -- t[8] = 4096
              "1000100001000" when "1001", -- t[9] = 4360
              "1001000100001" when "1010", -- t[10] = 4641
              "1001101001101" when "1011", -- t[11] = 4941
              "1010010001011" when "1100", -- t[12] = 5259
              "1010111011111" when "1101", -- t[13] = 5599
              "1011101001000" when "1110", -- t[14] = 5960
              "1100011001000" when "1111", -- t[15] = 6344
              "-------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_9 is
  port ( nY1    : in  std_logic_vector(4 downto 0);
         nExpY1 : out std_logic_vector(9+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_9 is
begin

  with nY1 select
    nExpY1 <= "01001101101001" when "00000", -- t[0] = 4969
              "01010000000110" when "00001", -- t[1] = 5126
              "01010010101001" when "00010", -- t[2] = 5289
              "01010101010001" when "00011", -- t[3] = 5457
              "01010111111110" when "00100", -- t[4] = 5630
              "01011010110001" when "00101", -- t[5] = 5809
              "01011101101001" when "00110", -- t[6] = 5993
              "01100000101000" when "00111", -- t[7] = 6184
              "01100011101100" when "01000", -- t[8] = 6380
              "01100110110110" when "01001", -- t[9] = 6582
              "01101010000111" when "01010", -- t[10] = 6791
              "01101101011111" when "01011", -- t[11] = 7007
              "01110000111101" when "01100", -- t[12] = 7229
              "01110100100011" when "01101", -- t[13] = 7459
              "01111000010000" when "01110", -- t[14] = 7696
              "01111100000100" when "01111", -- t[15] = 7940
              "10000000000000" when "10000", -- t[16] = 8192
              "10000100000100" when "10001", -- t[17] = 8452
              "10001000010000" when "10010", -- t[18] = 8720
              "10001100100101" when "10011", -- t[19] = 8997
              "10010001000011" when "10100", -- t[20] = 9283
              "10010101101001" when "10101", -- t[21] = 9577
              "10011010011001" when "10110", -- t[22] = 9881
              "10011111010011" when "10111", -- t[23] = 10195
              "10100100010111" when "11000", -- t[24] = 10519
              "10101001100101" when "11001", -- t[25] = 10853
              "10101110111101" when "11010", -- t[26] = 11197
              "10110100100001" when "11011", -- t[27] = 11553
              "10111010001111" when "11100", -- t[28] = 11919
              "11000000001010" when "11101", -- t[29] = 12298
              "11000110010000" when "11110", -- t[30] = 12688
              "11001100100011" when "11111", -- t[31] = 13091
              "--------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_10 is
  port ( nY1    : in  std_logic_vector(4 downto 0);
         nExpY1 : out std_logic_vector(10+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_10 is
begin

  with nY1 select
    nExpY1 <= "010011011010001" when "00000", -- t[0] = 9937
              "010100000001101" when "00001", -- t[1] = 10253
              "010100101010010" when "00010", -- t[2] = 10578
              "010101010100010" when "00011", -- t[3] = 10914
              "010101111111101" when "00100", -- t[4] = 11261
              "010110101100010" when "00101", -- t[5] = 11618
              "010111011010011" when "00110", -- t[6] = 11987
              "011000001001111" when "00111", -- t[7] = 12367
              "011000111011000" when "01000", -- t[8] = 12760
              "011001101101101" when "01001", -- t[9] = 13165
              "011010100001111" when "01010", -- t[10] = 13583
              "011011010111110" when "01011", -- t[11] = 14014
              "011100001111011" when "01100", -- t[12] = 14459
              "011101001000110" when "01101", -- t[13] = 14918
              "011110000011111" when "01110", -- t[14] = 15391
              "011111000001000" when "01111", -- t[15] = 15880
              "100000000000000" when "10000", -- t[16] = 16384
              "100001000001000" when "10001", -- t[17] = 16904
              "100010000100001" when "10010", -- t[18] = 17441
              "100011001001010" when "10011", -- t[19] = 17994
              "100100010000110" when "10100", -- t[20] = 18566
              "100101011010011" when "10101", -- t[21] = 19155
              "100110100110011" when "10110", -- t[22] = 19763
              "100111110100110" when "10111", -- t[23] = 20390
              "101001000101101" when "11000", -- t[24] = 21037
              "101010011001001" when "11001", -- t[25] = 21705
              "101011101111010" when "11010", -- t[26] = 22394
              "101101001000001" when "11011", -- t[27] = 23105
              "101110100011111" when "11100", -- t[28] = 23839
              "110000000010011" when "11101", -- t[29] = 24595
              "110001100100000" when "11110", -- t[30] = 25376
              "110011001000110" when "11111", -- t[31] = 26182
              "---------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_11 is
  port ( nY1    : in  std_logic_vector(4 downto 0);
         nExpY1 : out std_logic_vector(11+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_11 is
begin

  with nY1 select
    nExpY1 <= "0100110110100011" when "00000", -- t[0] = 19875
              "0101000000011010" when "00001", -- t[1] = 20506
              "0101001010100101" when "00010", -- t[2] = 21157
              "0101010101000100" when "00011", -- t[3] = 21828
              "0101011111111001" when "00100", -- t[4] = 22521
              "0101101011000100" when "00101", -- t[5] = 23236
              "0101110110100110" when "00110", -- t[6] = 23974
              "0110000010011111" when "00111", -- t[7] = 24735
              "0110001110110000" when "01000", -- t[8] = 25520
              "0110011011011010" when "01001", -- t[9] = 26330
              "0110101000011110" when "01010", -- t[10] = 27166
              "0110110101111100" when "01011", -- t[11] = 28028
              "0111000011110110" when "01100", -- t[12] = 28918
              "0111010010001100" when "01101", -- t[13] = 29836
              "0111100000111111" when "01110", -- t[14] = 30783
              "0111110000010000" when "01111", -- t[15] = 31760
              "1000000000000000" when "10000", -- t[16] = 32768
              "1000010000010000" when "10001", -- t[17] = 33808
              "1000100001000001" when "10010", -- t[18] = 34881
              "1000110010010101" when "10011", -- t[19] = 35989
              "1001000100001011" when "10100", -- t[20] = 37131
              "1001010110100110" when "10101", -- t[21] = 38310
              "1001101001100110" when "10110", -- t[22] = 39526
              "1001111101001100" when "10111", -- t[23] = 40780
              "1010010001011011" when "11000", -- t[24] = 42075
              "1010100110010011" when "11001", -- t[25] = 43411
              "1010111011110101" when "11010", -- t[26] = 44789
              "1011010010000010" when "11011", -- t[27] = 46210
              "1011101000111101" when "11100", -- t[28] = 47677
              "1100000000100111" when "11101", -- t[29] = 49191
              "1100011001000000" when "11110", -- t[30] = 50752
              "1100110010001011" when "11111", -- t[31] = 52363
              "----------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_12 is
  port ( nY1    : in  std_logic_vector(5 downto 0);
         nExpY1 : out std_logic_vector(12+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_12 is
begin

  with nY1 select
    nExpY1 <= "01001101101000110" when "000000", -- t[0] = 39750
              "01001110110111000" when "000001", -- t[1] = 40376
              "01010000000110011" when "000010", -- t[2] = 41011
              "01010001010111001" when "000011", -- t[3] = 41657
              "01010010101001001" when "000100", -- t[4] = 42313
              "01010011111100100" when "000101", -- t[5] = 42980
              "01010101010001000" when "000110", -- t[6] = 43656
              "01010110100111000" when "000111", -- t[7] = 44344
              "01010111111110010" when "001000", -- t[8] = 45042
              "01011001010111000" when "001001", -- t[9] = 45752
              "01011010110001000" when "001010", -- t[10] = 46472
              "01011100001100100" when "001011", -- t[11] = 47204
              "01011101101001011" when "001100", -- t[12] = 47947
              "01011111000111110" when "001101", -- t[13] = 48702
              "01100000100111101" when "001110", -- t[14] = 49469
              "01100010001001000" when "001111", -- t[15] = 50248
              "01100011101011111" when "010000", -- t[16] = 51039
              "01100101010000011" when "010001", -- t[17] = 51843
              "01100110110110100" when "010010", -- t[18] = 52660
              "01101000011110001" when "010011", -- t[19] = 53489
              "01101010000111011" when "010100", -- t[20] = 54331
              "01101011110010011" when "010101", -- t[21] = 55187
              "01101101011111000" when "010110", -- t[22] = 56056
              "01101111001101011" when "010111", -- t[23] = 56939
              "01110000111101011" when "011000", -- t[24] = 57835
              "01110010101111010" when "011001", -- t[25] = 58746
              "01110100100010111" when "011010", -- t[26] = 59671
              "01110110011000011" when "011011", -- t[27] = 60611
              "01111000001111101" when "011100", -- t[28] = 61565
              "01111010001000111" when "011101", -- t[29] = 62535
              "01111100000100000" when "011110", -- t[30] = 63520
              "01111110000001000" when "011111", -- t[31] = 64520
              "10000000000000000" when "100000", -- t[32] = 65536
              "10000010000001000" when "100001", -- t[33] = 66568
              "10000100000100000" when "100010", -- t[34] = 67616
              "10000110001001001" when "100011", -- t[35] = 68681
              "10001000010000011" when "100100", -- t[36] = 69763
              "10001010011001101" when "100101", -- t[37] = 70861
              "10001100100101001" when "100110", -- t[38] = 71977
              "10001110110010111" when "100111", -- t[39] = 73111
              "10010001000010110" when "101000", -- t[40] = 74262
              "10010011010100111" when "101001", -- t[41] = 75431
              "10010101101001011" when "101010", -- t[42] = 76619
              "10011000000000010" when "101011", -- t[43] = 77826
              "10011010011001100" when "101100", -- t[44] = 79052
              "10011100110101000" when "101101", -- t[45] = 80296
              "10011111010011001" when "101110", -- t[46] = 81561
              "10100001110011101" when "101111", -- t[47] = 82845
              "10100100010110110" when "110000", -- t[48] = 84150
              "10100110111100011" when "110001", -- t[49] = 85475
              "10101001100100101" when "110010", -- t[50] = 86821
              "10101100001111100" when "110011", -- t[51] = 88188
              "10101110111101001" when "110100", -- t[52] = 89577
              "10110001101101100" when "110101", -- t[53] = 90988
              "10110100100000101" when "110110", -- t[54] = 92421
              "10110111010110100" when "110111", -- t[55] = 93876
              "10111010001111010" when "111000", -- t[56] = 95354
              "10111101001011000" when "111001", -- t[57] = 96856
              "11000000001001101" when "111010", -- t[58] = 98381
              "11000011001011010" when "111011", -- t[59] = 99930
              "11000110010000000" when "111100", -- t[60] = 101504
              "11001001010111111" when "111101", -- t[61] = 103103
              "11001100100010110" when "111110", -- t[62] = 104726
              "11001111110000111" when "111111", -- t[63] = 106375
              "-----------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_13 is
  port ( nY1    : in  std_logic_vector(5 downto 0);
         nExpY1 : out std_logic_vector(13+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_13 is
begin

  with nY1 select
    nExpY1 <= "010011011010001011" when "000000", -- t[0] = 79499
              "010011101101101111" when "000001", -- t[1] = 80751
              "010100000001100111" when "000010", -- t[2] = 82023
              "010100010101110010" when "000011", -- t[3] = 83314
              "010100101010010010" when "000100", -- t[4] = 84626
              "010100111111000111" when "000101", -- t[5] = 85959
              "010101010100010001" when "000110", -- t[6] = 87313
              "010101101001110000" when "000111", -- t[7] = 88688
              "010101111111100100" when "001000", -- t[8] = 90084
              "010110010101101111" when "001001", -- t[9] = 91503
              "010110101100010000" when "001010", -- t[10] = 92944
              "010111000011001000" when "001011", -- t[11] = 94408
              "010111011010010110" when "001100", -- t[12] = 95894
              "010111110001111100" when "001101", -- t[13] = 97404
              "011000001001111010" when "001110", -- t[14] = 98938
              "011000100010010000" when "001111", -- t[15] = 100496
              "011000111010111111" when "010000", -- t[16] = 102079
              "011001010100000110" when "010001", -- t[17] = 103686
              "011001101101100111" when "010010", -- t[18] = 105319
              "011010000111100010" when "010011", -- t[19] = 106978
              "011010100001110111" when "010100", -- t[20] = 108663
              "011010111100100110" when "010101", -- t[21] = 110374
              "011011010111110000" when "010110", -- t[22] = 112112
              "011011110011010101" when "010111", -- t[23] = 113877
              "011100001111010111" when "011000", -- t[24] = 115671
              "011100101011110100" when "011001", -- t[25] = 117492
              "011101001000101110" when "011010", -- t[26] = 119342
              "011101100110000110" when "011011", -- t[27] = 121222
              "011110000011111011" when "011100", -- t[28] = 123131
              "011110100010001110" when "011101", -- t[29] = 125070
              "011111000000111111" when "011110", -- t[30] = 127039
              "011111100000010000" when "011111", -- t[31] = 129040
              "100000000000000000" when "100000", -- t[32] = 131072
              "100000100000010000" when "100001", -- t[33] = 133136
              "100001000001000001" when "100010", -- t[34] = 135233
              "100001100010010010" when "100011", -- t[35] = 137362
              "100010000100000101" when "100100", -- t[36] = 139525
              "100010100110011011" when "100101", -- t[37] = 141723
              "100011001001010010" when "100110", -- t[38] = 143954
              "100011101100101101" when "100111", -- t[39] = 146221
              "100100010000101100" when "101000", -- t[40] = 148524
              "100100110101001111" when "101001", -- t[41] = 150863
              "100101011010010111" when "101010", -- t[42] = 153239
              "100110000000000100" when "101011", -- t[43] = 155652
              "100110100110010111" when "101100", -- t[44] = 158103
              "100111001101010001" when "101101", -- t[45] = 160593
              "100111110100110010" when "101110", -- t[46] = 163122
              "101000011100111011" when "101111", -- t[47] = 165691
              "101001000101101100" when "110000", -- t[48] = 168300
              "101001101111000110" when "110001", -- t[49] = 170950
              "101010011001001010" when "110010", -- t[50] = 173642
              "101011000011111001" when "110011", -- t[51] = 176377
              "101011101111010010" when "110100", -- t[52] = 179154
              "101100011011010111" when "110101", -- t[53] = 181975
              "101101001000001001" when "110110", -- t[54] = 184841
              "101101110101101000" when "110111", -- t[55] = 187752
              "101110100011110101" when "111000", -- t[56] = 190709
              "101111010010110000" when "111001", -- t[57] = 193712
              "110000000010011010" when "111010", -- t[58] = 196762
              "110000110010110101" when "111011", -- t[59] = 199861
              "110001100100000000" when "111100", -- t[60] = 203008
              "110010010101111101" when "111101", -- t[61] = 206205
              "110011001000101100" when "111110", -- t[62] = 209452
              "110011111100001111" when "111111", -- t[63] = 212751
              "------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_14 is
  port ( nY1    : in  std_logic_vector(5 downto 0);
         nExpY1 : out std_logic_vector(14+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_14 is
begin

  with nY1 select
    nExpY1 <= "0100110110100010110" when "000000", -- t[0] = 158998
              "0100111011011011110" when "000001", -- t[1] = 161502
              "0101000000011001110" when "000010", -- t[2] = 164046
              "0101000101011100101" when "000011", -- t[3] = 166629
              "0101001010100100101" when "000100", -- t[4] = 169253
              "0101001111110001110" when "000101", -- t[5] = 171918
              "0101010101000100010" when "000110", -- t[6] = 174626
              "0101011010011100000" when "000111", -- t[7] = 177376
              "0101011111111001001" when "001000", -- t[8] = 180169
              "0101100101011011110" when "001001", -- t[9] = 183006
              "0101101011000100000" when "001010", -- t[10] = 185888
              "0101110000110001111" when "001011", -- t[11] = 188815
              "0101110110100101101" when "001100", -- t[12] = 191789
              "0101111100011111001" when "001101", -- t[13] = 194809
              "0110000010011110101" when "001110", -- t[14] = 197877
              "0110001000100100001" when "001111", -- t[15] = 200993
              "0110001110101111110" when "010000", -- t[16] = 204158
              "0110010101000001101" when "010001", -- t[17] = 207373
              "0110011011011001111" when "010010", -- t[18] = 210639
              "0110100001111000100" when "010011", -- t[19] = 213956
              "0110101000011101101" when "010100", -- t[20] = 217325
              "0110101111001001011" when "010101", -- t[21] = 220747
              "0110110101111100000" when "010110", -- t[22] = 224224
              "0110111100110101011" when "010111", -- t[23] = 227755
              "0111000011110101101" when "011000", -- t[24] = 231341
              "0111001010111101000" when "011001", -- t[25] = 234984
              "0111010010001011101" when "011010", -- t[26] = 238685
              "0111011001100001100" when "011011", -- t[27] = 242444
              "0111100000111110101" when "011100", -- t[28] = 246261
              "0111101000100011100" when "011101", -- t[29] = 250140
              "0111110000001111111" when "011110", -- t[30] = 254079
              "0111111000000100000" when "011111", -- t[31] = 258080
              "1000000000000000000" when "100000", -- t[32] = 262144
              "1000001000000100000" when "100001", -- t[33] = 266272
              "1000010000010000001" when "100010", -- t[34] = 270465
              "1000011000100100101" when "100011", -- t[35] = 274725
              "1000100001000001011" when "100100", -- t[36] = 279051
              "1000101001100110101" when "100101", -- t[37] = 283445
              "1000110010010100101" when "100110", -- t[38] = 287909
              "1000111011001011011" when "100111", -- t[39] = 292443
              "1001000100001011000" when "101000", -- t[40] = 297048
              "1001001101010011110" when "101001", -- t[41] = 301726
              "1001010110100101101" when "101010", -- t[42] = 306477
              "1001100000000001000" when "101011", -- t[43] = 311304
              "1001101001100101110" when "101100", -- t[44] = 316206
              "1001110011010100010" when "101101", -- t[45] = 321186
              "1001111101001100011" when "101110", -- t[46] = 326243
              "1010000111001110101" when "101111", -- t[47] = 331381
              "1010010001011011000" when "110000", -- t[48] = 336600
              "1010011011110001100" when "110001", -- t[49] = 341900
              "1010100110010010100" when "110010", -- t[50] = 347284
              "1010110000111110001" when "110011", -- t[51] = 352753
              "1010111011110100100" when "110100", -- t[52] = 358308
              "1011000110110101111" when "110101", -- t[53] = 363951
              "1011010010000010010" when "110110", -- t[54] = 369682
              "1011011101011010000" when "110111", -- t[55] = 375504
              "1011101000111101001" when "111000", -- t[56] = 381417
              "1011110100101100000" when "111001", -- t[57] = 387424
              "1100000000100110101" when "111010", -- t[58] = 393525
              "1100001100101101010" when "111011", -- t[59] = 399722
              "1100011001000000001" when "111100", -- t[60] = 406017
              "1100100101011111010" when "111101", -- t[61] = 412410
              "1100110010001011001" when "111110", -- t[62] = 418905
              "1100111111000011110" when "111111", -- t[63] = 425502
              "-------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_15 is
  port ( nY1    : in  std_logic_vector(6 downto 0);
         nExpY1 : out std_logic_vector(15+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_15 is
begin

  with nY1 select
    nExpY1 <= "01001101101000101101" when "0000000", -- t[0] = 317997
              "01001110001111101011" when "0000001", -- t[1] = 320491
              "01001110110110111100" when "0000010", -- t[2] = 323004
              "01001111011110100010" when "0000011", -- t[3] = 325538
              "01010000000110011011" when "0000100", -- t[4] = 328091
              "01010000101110101000" when "0000101", -- t[5] = 330664
              "01010001010111001010" when "0000110", -- t[6] = 333258
              "01010010000000000000" when "0000111", -- t[7] = 335872
              "01010010101001001010" when "0001000", -- t[8] = 338506
              "01010011010010101001" when "0001001", -- t[9] = 341161
              "01010011111100011100" when "0001010", -- t[10] = 343836
              "01010100100110100101" when "0001011", -- t[11] = 346533
              "01010101010001000011" when "0001100", -- t[12] = 349251
              "01010101111011110110" when "0001101", -- t[13] = 351990
              "01010110100110111111" when "0001110", -- t[14] = 354751
              "01010111010010011101" when "0001111", -- t[15] = 357533
              "01010111111110010010" when "0010000", -- t[16] = 360338
              "01011000101010011100" when "0010001", -- t[17] = 363164
              "01011001010110111100" when "0010010", -- t[18] = 366012
              "01011010000011110011" when "0010011", -- t[19] = 368883
              "01011010110001000000" when "0010100", -- t[20] = 371776
              "01011011011110100100" when "0010101", -- t[21] = 374692
              "01011100001100011110" when "0010110", -- t[22] = 377630
              "01011100111010110000" when "0010111", -- t[23] = 380592
              "01011101101001011001" when "0011000", -- t[24] = 383577
              "01011110011000011010" when "0011001", -- t[25] = 386586
              "01011111000111110010" when "0011010", -- t[26] = 389618
              "01011111110111100010" when "0011011", -- t[27] = 392674
              "01100000100111101001" when "0011100", -- t[28] = 395753
              "01100001011000001001" when "0011101", -- t[29] = 398857
              "01100010001001000010" when "0011110", -- t[30] = 401986
              "01100010111010010010" when "0011111", -- t[31] = 405138
              "01100011101011111100" when "0100000", -- t[32] = 408316
              "01100100011101111110" when "0100001", -- t[33] = 411518
              "01100101010000011010" when "0100010", -- t[34] = 414746
              "01100110000011001111" when "0100011", -- t[35] = 417999
              "01100110110110011101" when "0100100", -- t[36] = 421277
              "01100111101010000101" when "0100101", -- t[37] = 424581
              "01101000011110000111" when "0100110", -- t[38] = 427911
              "01101001010010100100" when "0100111", -- t[39] = 431268
              "01101010000111011010" when "0101000", -- t[40] = 434650
              "01101010111100101011" when "0101001", -- t[41] = 438059
              "01101011110010010111" when "0101010", -- t[42] = 441495
              "01101100101000011101" when "0101011", -- t[43] = 444957
              "01101101011110111111" when "0101100", -- t[44] = 448447
              "01101110010101111101" when "0101101", -- t[45] = 451965
              "01101111001101010101" when "0101110", -- t[46] = 455509
              "01110000000101001010" when "0101111", -- t[47] = 459082
              "01110000111101011011" when "0110000", -- t[48] = 462683
              "01110001110110000111" when "0110001", -- t[49] = 466311
              "01110010101111010001" when "0110010", -- t[50] = 469969
              "01110011101000110111" when "0110011", -- t[51] = 473655
              "01110100100010111010" when "0110100", -- t[52] = 477370
              "01110101011101011010" when "0110101", -- t[53] = 481114
              "01110110011000010111" when "0110110", -- t[54] = 484887
              "01110111010011110010" when "0110111", -- t[55] = 488690
              "01111000001111101011" when "0111000", -- t[56] = 492523
              "01111001001100000010" when "0111001", -- t[57] = 496386
              "01111010001000110111" when "0111010", -- t[58] = 500279
              "01111011000110001011" when "0111011", -- t[59] = 504203
              "01111100000011111101" when "0111100", -- t[60] = 508157
              "01111101000010001111" when "0111101", -- t[61] = 512143
              "01111110000001000000" when "0111110", -- t[62] = 516160
              "01111111000000010000" when "0111111", -- t[63] = 520208
              "10000000000000000000" when "1000000", -- t[64] = 524288
              "10000001000000010000" when "1000001", -- t[65] = 528400
              "10000010000001000000" when "1000010", -- t[66] = 532544
              "10000011000010010001" when "1000011", -- t[67] = 536721
              "10000100000100000011" when "1000100", -- t[68] = 540931
              "10000101000110010101" when "1000101", -- t[69] = 545173
              "10000110001001001001" when "1000110", -- t[70] = 549449
              "10000111001100011110" when "1000111", -- t[71] = 553758
              "10001000010000010110" when "1001000", -- t[72] = 558102
              "10001001010100101111" when "1001001", -- t[73] = 562479
              "10001010011001101010" when "1001010", -- t[74] = 566890
              "10001011011111001001" when "1001011", -- t[75] = 571337
              "10001100100101001010" when "1001100", -- t[76] = 575818
              "10001101101011101110" when "1001101", -- t[77] = 580334
              "10001110110010110110" when "1001110", -- t[78] = 584886
              "10001111111010100001" when "1001111", -- t[79] = 589473
              "10010001000010110000" when "1010000", -- t[80] = 594096
              "10010010001011100100" when "1010001", -- t[81] = 598756
              "10010011010100111100" when "1010010", -- t[82] = 603452
              "10010100011110111001" when "1010011", -- t[83] = 608185
              "10010101101001011011" when "1010100", -- t[84] = 612955
              "10010110110100100010" when "1010101", -- t[85] = 617762
              "10011000000000001111" when "1010110", -- t[86] = 622607
              "10011001001100100011" when "1010111", -- t[87] = 627491
              "10011010011001011100" when "1011000", -- t[88] = 632412
              "10011011100110111100" when "1011001", -- t[89] = 637372
              "10011100110101000011" when "1011010", -- t[90] = 642371
              "10011110000011110001" when "1011011", -- t[91] = 647409
              "10011111010011000111" when "1011100", -- t[92] = 652487
              "10100000100011000100" when "1011101", -- t[93] = 657604
              "10100001110011101010" when "1011110", -- t[94] = 662762
              "10100011000100111000" when "1011111", -- t[95] = 667960
              "10100100010110101111" when "1100000", -- t[96] = 673199
              "10100101101001001111" when "1100001", -- t[97] = 678479
              "10100110111100011000" when "1100010", -- t[98] = 683800
              "10101000010000001100" when "1100011", -- t[99] = 689164
              "10101001100100101001" when "1100100", -- t[100] = 694569
              "10101010111001110000" when "1100101", -- t[101] = 700016
              "10101100001111100011" when "1100110", -- t[102] = 705507
              "10101101100110000000" when "1100111", -- t[103] = 711040
              "10101110111101001001" when "1101000", -- t[104] = 716617
              "10110000010100111101" when "1101001", -- t[105] = 722237
              "10110001101101011110" when "1101010", -- t[106] = 727902
              "10110011000110101011" when "1101011", -- t[107] = 733611
              "10110100100000100101" when "1101100", -- t[108] = 739365
              "10110101111011001011" when "1101101", -- t[109] = 745163
              "10110111010110100000" when "1101110", -- t[110] = 751008
              "10111000110010100010" when "1101111", -- t[111] = 756898
              "10111010001111010011" when "1110000", -- t[112] = 762835
              "10111011101100110010" when "1110001", -- t[113] = 768818
              "10111101001010111111" when "1110010", -- t[114] = 774847
              "10111110101001111101" when "1110011", -- t[115] = 780925
              "11000000001001101010" when "1110100", -- t[116] = 787050
              "11000001101010000110" when "1110101", -- t[117] = 793222
              "11000011001011010100" when "1110110", -- t[118] = 799444
              "11000100101101010010" when "1110111", -- t[119] = 805714
              "11000110010000000001" when "1111000", -- t[120] = 812033
              "11000111110011100010" when "1111001", -- t[121] = 818402
              "11001001010111110101" when "1111010", -- t[122] = 824821
              "11001010111100111010" when "1111011", -- t[123] = 831290
              "11001100100010110010" when "1111100", -- t[124] = 837810
              "11001110001001011101" when "1111101", -- t[125] = 844381
              "11001111110000111011" when "1111110", -- t[126] = 851003
              "11010001011001001110" when "1111111", -- t[127] = 857678
              "--------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_16 is
  port ( nY1    : in  std_logic_vector(6 downto 0);
         nExpY1 : out std_logic_vector(16+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_16 is
begin

  with nY1 select
    nExpY1 <= "010011011010001011001" when "0000000", -- t[0] = 635993
              "010011100011111010110" when "0000001", -- t[1] = 640982
              "010011101101101111001" when "0000010", -- t[2] = 646009
              "010011110111101000100" when "0000011", -- t[3] = 651076
              "010100000001100110110" when "0000100", -- t[4] = 656182
              "010100001011101010001" when "0000101", -- t[5] = 661329
              "010100010101110010011" when "0000110", -- t[6] = 666515
              "010100011111111111111" when "0000111", -- t[7] = 671743
              "010100101010010010100" when "0001000", -- t[8] = 677012
              "010100110100101010001" when "0001001", -- t[9] = 682321
              "010100111111000111001" when "0001010", -- t[10] = 687673
              "010101001001101001010" when "0001011", -- t[11] = 693066
              "010101010100010000110" when "0001100", -- t[12] = 698502
              "010101011110111101101" when "0001101", -- t[13] = 703981
              "010101101001101111110" when "0001110", -- t[14] = 709502
              "010101110100100111011" when "0001111", -- t[15] = 715067
              "010101111111100100011" when "0010000", -- t[16] = 720675
              "010110001010100110111" when "0010001", -- t[17] = 726327
              "010110010101101111000" when "0010010", -- t[18] = 732024
              "010110100000111100101" when "0010011", -- t[19] = 737765
              "010110101100010000000" when "0010100", -- t[20] = 743552
              "010110110111101000111" when "0010101", -- t[21] = 749383
              "010111000011000111101" when "0010110", -- t[22] = 755261
              "010111001110101100001" when "0010111", -- t[23] = 761185
              "010111011010010110011" when "0011000", -- t[24] = 767155
              "010111100110000110011" when "0011001", -- t[25] = 773171
              "010111110001111100100" when "0011010", -- t[26] = 779236
              "010111111101111000011" when "0011011", -- t[27] = 785347
              "011000001001111010011" when "0011100", -- t[28] = 791507
              "011000010110000010011" when "0011101", -- t[29] = 797715
              "011000100010010000011" when "0011110", -- t[30] = 803971
              "011000101110100100101" when "0011111", -- t[31] = 810277
              "011000111010111111000" when "0100000", -- t[32] = 816632
              "011001000111011111101" when "0100001", -- t[33] = 823037
              "011001010100000110100" when "0100010", -- t[34] = 829492
              "011001100000110011110" when "0100011", -- t[35] = 835998
              "011001101101100111010" when "0100100", -- t[36] = 842554
              "011001111010100001011" when "0100101", -- t[37] = 849163
              "011010000111100001111" when "0100110", -- t[38] = 855823
              "011010010100101000111" when "0100111", -- t[39] = 862535
              "011010100001110110100" when "0101000", -- t[40] = 869300
              "011010101111001010110" when "0101001", -- t[41] = 876118
              "011010111100100101110" when "0101010", -- t[42] = 882990
              "011011001010000111011" when "0101011", -- t[43] = 889915
              "011011010111101111111" when "0101100", -- t[44] = 896895
              "011011100101011111001" when "0101101", -- t[45] = 903929
              "011011110011010101011" when "0101110", -- t[46] = 911019
              "011100000001010010100" when "0101111", -- t[47] = 918164
              "011100001111010110101" when "0110000", -- t[48] = 925365
              "011100011101100001111" when "0110001", -- t[49] = 932623
              "011100101011110100001" when "0110010", -- t[50] = 939937
              "011100111010001101101" when "0110011", -- t[51] = 947309
              "011101001000101110011" when "0110100", -- t[52] = 954739
              "011101010111010110011" when "0110101", -- t[53] = 962227
              "011101100110000101110" when "0110110", -- t[54] = 969774
              "011101110100111100100" when "0110111", -- t[55] = 977380
              "011110000011111010110" when "0111000", -- t[56] = 985046
              "011110010011000000100" when "0111001", -- t[57] = 992772
              "011110100010001101110" when "0111010", -- t[58] = 1000558
              "011110110001100010110" when "0111011", -- t[59] = 1008406
              "011111000000111111011" when "0111100", -- t[60] = 1016315
              "011111010000100011110" when "0111101", -- t[61] = 1024286
              "011111100000001111111" when "0111110", -- t[62] = 1032319
              "011111110000000100000" when "0111111", -- t[63] = 1040416
              "100000000000000000000" when "1000000", -- t[64] = 1048576
              "100000010000000100000" when "1000001", -- t[65] = 1056800
              "100000100000010000001" when "1000010", -- t[66] = 1065089
              "100000110000100100010" when "1000011", -- t[67] = 1073442
              "100001000001000000101" when "1000100", -- t[68] = 1081861
              "100001010001100101011" when "1000101", -- t[69] = 1090347
              "100001100010010010010" when "1000110", -- t[70] = 1098898
              "100001110011000111101" when "1000111", -- t[71] = 1107517
              "100010000100000101011" when "1001000", -- t[72] = 1116203
              "100010010101001011110" when "1001001", -- t[73] = 1124958
              "100010100110011010101" when "1001010", -- t[74] = 1133781
              "100010110111110010001" when "1001011", -- t[75] = 1142673
              "100011001001010010011" when "1001100", -- t[76] = 1151635
              "100011011010111011100" when "1001101", -- t[77] = 1160668
              "100011101100101101011" when "1001110", -- t[78] = 1169771
              "100011111110101000010" when "1001111", -- t[79] = 1178946
              "100100010000101100000" when "1010000", -- t[80] = 1188192
              "100100100010111000111" when "1010001", -- t[81] = 1197511
              "100100110101001111000" when "1010010", -- t[82] = 1206904
              "100101000111101110001" when "1010011", -- t[83] = 1216369
              "100101011010010110110" when "1010100", -- t[84] = 1225910
              "100101101101001000100" when "1010101", -- t[85] = 1235524
              "100110000000000011111" when "1010110", -- t[86] = 1245215
              "100110010011001000101" when "1010111", -- t[87] = 1254981
              "100110100110010111000" when "1011000", -- t[88] = 1264824
              "100110111001101111000" when "1011001", -- t[89] = 1274744
              "100111001101010000110" when "1011010", -- t[90] = 1284742
              "100111100000111100011" when "1011011", -- t[91] = 1294819
              "100111110100110001110" when "1011100", -- t[92] = 1304974
              "101000001000110001001" when "1011101", -- t[93] = 1315209
              "101000011100111010100" when "1011110", -- t[94] = 1325524
              "101000110001001110000" when "1011111", -- t[95] = 1335920
              "101001000101101011110" when "1100000", -- t[96] = 1346398
              "101001011010010011110" when "1100001", -- t[97] = 1356958
              "101001101111000110001" when "1100010", -- t[98] = 1367601
              "101010000100000010111" when "1100011", -- t[99] = 1378327
              "101010011001001010010" when "1100100", -- t[100] = 1389138
              "101010101110011100001" when "1100101", -- t[101] = 1400033
              "101011000011111000101" when "1100110", -- t[102] = 1411013
              "101011011001100000000" when "1100111", -- t[103] = 1422080
              "101011101111010010001" when "1101000", -- t[104] = 1433233
              "101100000101001111010" when "1101001", -- t[105] = 1444474
              "101100011011010111100" when "1101010", -- t[106] = 1455804
              "101100110001101010110" when "1101011", -- t[107] = 1467222
              "101101001000001001001" when "1101100", -- t[108] = 1478729
              "101101011110110010111" when "1101101", -- t[109] = 1490327
              "101101110101101000000" when "1101110", -- t[110] = 1502016
              "101110001100101000100" when "1101111", -- t[111] = 1513796
              "101110100011110100101" when "1110000", -- t[112] = 1525669
              "101110111011001100011" when "1110001", -- t[113] = 1537635
              "101111010010101111111" when "1110010", -- t[114] = 1549695
              "101111101010011111001" when "1110011", -- t[115] = 1561849
              "110000000010011010011" when "1110100", -- t[116] = 1574099
              "110000011010100001101" when "1110101", -- t[117] = 1586445
              "110000110010110100111" when "1110110", -- t[118] = 1598887
              "110001001011010100100" when "1110111", -- t[119] = 1611428
              "110001100100000000010" when "1111000", -- t[120] = 1624066
              "110001111100111000100" when "1111001", -- t[121] = 1636804
              "110010010101111101010" when "1111010", -- t[122] = 1649642
              "110010101111001110100" when "1111011", -- t[123] = 1662580
              "110011001000101100100" when "1111100", -- t[124] = 1675620
              "110011100010010111010" when "1111101", -- t[125] = 1688762
              "110011111100001110111" when "1111110", -- t[126] = 1702007
              "110100010110010011100" when "1111111", -- t[127] = 1715356
              "---------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_17 is
  port ( nY1    : in  std_logic_vector(6 downto 0);
         nExpY1 : out std_logic_vector(17+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_17 is
begin

  with nY1 select
    nExpY1 <= "0100110110100010110011" when "0000000", -- t[0] = 1271987
              "0100111000111110101011" when "0000001", -- t[1] = 1281963
              "0100111011011011110010" when "0000010", -- t[2] = 1292018
              "0100111101111010000111" when "0000011", -- t[3] = 1302151
              "0101000000011001101100" when "0000100", -- t[4] = 1312364
              "0101000010111010100001" when "0000101", -- t[5] = 1322657
              "0101000101011100100111" when "0000110", -- t[6] = 1333031
              "0101000111111111111110" when "0000111", -- t[7] = 1343486
              "0101001010100100100111" when "0001000", -- t[8] = 1354023
              "0101001101001010100011" when "0001001", -- t[9] = 1364643
              "0101001111110001110010" when "0001010", -- t[10] = 1375346
              "0101010010011010010101" when "0001011", -- t[11] = 1386133
              "0101010101000100001100" when "0001100", -- t[12] = 1397004
              "0101010111101111011001" when "0001101", -- t[13] = 1407961
              "0101011010011011111100" when "0001110", -- t[14] = 1419004
              "0101011101001001110101" when "0001111", -- t[15] = 1430133
              "0101011111111001000110" when "0010000", -- t[16] = 1441350
              "0101100010101001101111" when "0010001", -- t[17] = 1452655
              "0101100101011011110000" when "0010010", -- t[18] = 1464048
              "0101101000001111001011" when "0010011", -- t[19] = 1475531
              "0101101011000011111111" when "0010100", -- t[20] = 1487103
              "0101101101111010001111" when "0010101", -- t[21] = 1498767
              "0101110000110001111010" when "0010110", -- t[22] = 1510522
              "0101110011101011000001" when "0010111", -- t[23] = 1522369
              "0101110110100101100101" when "0011000", -- t[24] = 1534309
              "0101111001100001100111" when "0011001", -- t[25] = 1546343
              "0101111100011111000111" when "0011010", -- t[26] = 1558471
              "0101111111011110000110" when "0011011", -- t[27] = 1570694
              "0110000010011110100101" when "0011100", -- t[28] = 1583013
              "0110000101100000100101" when "0011101", -- t[29] = 1595429
              "0110001000100100000110" when "0011110", -- t[30] = 1607942
              "0110001011101001001001" when "0011111", -- t[31] = 1620553
              "0110001110101111110000" when "0100000", -- t[32] = 1633264
              "0110010001110111111001" when "0100001", -- t[33] = 1646073
              "0110010101000001101000" when "0100010", -- t[34] = 1658984
              "0110011000001100111011" when "0100011", -- t[35] = 1671995
              "0110011011011001110101" when "0100100", -- t[36] = 1685109
              "0110011110101000010101" when "0100101", -- t[37] = 1698325
              "0110100001111000011110" when "0100110", -- t[38] = 1711646
              "0110100101001010001110" when "0100111", -- t[39] = 1725070
              "0110101000011101101000" when "0101000", -- t[40] = 1738600
              "0110101011110010101100" when "0101001", -- t[41] = 1752236
              "0110101111001001011011" when "0101010", -- t[42] = 1765979
              "0110110010100001110110" when "0101011", -- t[43] = 1779830
              "0110110101111011111101" when "0101100", -- t[44] = 1793789
              "0110111001010111110010" when "0101101", -- t[45] = 1807858
              "0110111100110101010101" when "0101110", -- t[46] = 1822037
              "0111000000010100101000" when "0101111", -- t[47] = 1836328
              "0111000011110101101010" when "0110000", -- t[48] = 1850730
              "0111000111011000011110" when "0110001", -- t[49] = 1865246
              "0111001010111101000011" when "0110010", -- t[50] = 1879875
              "0111001110100011011011" when "0110011", -- t[51] = 1894619
              "0111010010001011100111" when "0110100", -- t[52] = 1909479
              "0111010101110101100111" when "0110101", -- t[53] = 1924455
              "0111011001100001011101" when "0110110", -- t[54] = 1939549
              "0111011101001111001001" when "0110111", -- t[55] = 1954761
              "0111100000111110101100" when "0111000", -- t[56] = 1970092
              "0111100100110000001000" when "0111001", -- t[57] = 1985544
              "0111101000100011011100" when "0111010", -- t[58] = 2001116
              "0111101100011000101011" when "0111011", -- t[59] = 2016811
              "0111110000001111110101" when "0111100", -- t[60] = 2032629
              "0111110100001000111100" when "0111101", -- t[61] = 2048572
              "0111111000000011111111" when "0111110", -- t[62] = 2064639
              "0111111100000001000000" when "0111111", -- t[63] = 2080832
              "1000000000000000000000" when "1000000", -- t[64] = 2097152
              "1000000100000001000000" when "1000001", -- t[65] = 2113600
              "1000001000000100000001" when "1000010", -- t[66] = 2130177
              "1000001100001001000101" when "1000011", -- t[67] = 2146885
              "1000010000010000001011" when "1000100", -- t[68] = 2163723
              "1000010100011001010101" when "1000101", -- t[69] = 2180693
              "1000011000100100100100" when "1000110", -- t[70] = 2197796
              "1000011100110001111010" when "1000111", -- t[71] = 2215034
              "1000100001000001010111" when "1001000", -- t[72] = 2232407
              "1000100101010010111100" when "1001001", -- t[73] = 2249916
              "1000101001100110101010" when "1001010", -- t[74] = 2267562
              "1000101101111100100011" when "1001011", -- t[75] = 2285347
              "1000110010010100100111" when "1001100", -- t[76] = 2303271
              "1000110110101110111000" when "1001101", -- t[77] = 2321336
              "1000111011001011010110" when "1001110", -- t[78] = 2339542
              "1000111111101010000011" when "1001111", -- t[79] = 2357891
              "1001000100001011000001" when "1010000", -- t[80] = 2376385
              "1001001000101110001111" when "1010001", -- t[81] = 2395023
              "1001001101010011101111" when "1010010", -- t[82] = 2413807
              "1001010001111011100011" when "1010011", -- t[83] = 2432739
              "1001010110100101101011" when "1010100", -- t[84] = 2451819
              "1001011011010010001001" when "1010101", -- t[85] = 2471049
              "1001100000000000111110" when "1010110", -- t[86] = 2490430
              "1001100100110010001010" when "1010111", -- t[87] = 2509962
              "1001101001100101110000" when "1011000", -- t[88] = 2529648
              "1001101110011011110000" when "1011001", -- t[89] = 2549488
              "1001110011010100001100" when "1011010", -- t[90] = 2569484
              "1001111000001111000101" when "1011011", -- t[91] = 2589637
              "1001111101001100011100" when "1011100", -- t[92] = 2609948
              "1010000010001100010010" when "1011101", -- t[93] = 2630418
              "1010000111001110101001" when "1011110", -- t[94] = 2651049
              "1010001100010011100001" when "1011111", -- t[95] = 2671841
              "1010010001011010111100" when "1100000", -- t[96] = 2692796
              "1010010110100100111100" when "1100001", -- t[97] = 2713916
              "1010011011110001100010" when "1100010", -- t[98] = 2735202
              "1010100001000000101110" when "1100011", -- t[99] = 2756654
              "1010100110010010100011" when "1100100", -- t[100] = 2778275
              "1010101011100111000001" when "1100101", -- t[101] = 2800065
              "1010110000111110001010" when "1100110", -- t[102] = 2822026
              "1010110110011000000000" when "1100111", -- t[103] = 2844160
              "1010111011110100100011" when "1101000", -- t[104] = 2866467
              "1011000001010011110101" when "1101001", -- t[105] = 2888949
              "1011000110110101110111" when "1101010", -- t[106] = 2911607
              "1011001100011010101011" when "1101011", -- t[107] = 2934443
              "1011010010000010010010" when "1101100", -- t[108] = 2957458
              "1011010111101100101110" when "1101101", -- t[109] = 2980654
              "1011011101011010000000" when "1101110", -- t[110] = 3004032
              "1011100011001010001000" when "1101111", -- t[111] = 3027592
              "1011101000111101001010" when "1110000", -- t[112] = 3051338
              "1011101110110011000110" when "1110001", -- t[113] = 3075270
              "1011110100101011111110" when "1110010", -- t[114] = 3099390
              "1011111010100111110011" when "1110011", -- t[115] = 3123699
              "1100000000100110100110" when "1110100", -- t[116] = 3148198
              "1100000110101000011010" when "1110101", -- t[117] = 3172890
              "1100001100101101001111" when "1110110", -- t[118] = 3197775
              "1100010010110101000111" when "1110111", -- t[119] = 3222855
              "1100011001000000000101" when "1111000", -- t[120] = 3248133
              "1100011111001110001000" when "1111001", -- t[121] = 3273608
              "1100100101011111010011" when "1111010", -- t[122] = 3299283
              "1100101011110011101000" when "1111011", -- t[123] = 3325160
              "1100110010001011000111" when "1111100", -- t[124] = 3351239
              "1100111000100101110011" when "1111101", -- t[125] = 3377523
              "1100111111000011101110" when "1111110", -- t[126] = 3404014
              "1101000101100100111000" when "1111111", -- t[127] = 3430712
              "----------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_18 is
  port ( nY1    : in  std_logic_vector(7 downto 0);
         nExpY1 : out std_logic_vector(18+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_18 is
begin

  with nY1 select
    nExpY1 <= "01001101101000101100110" when "00000000", -- t[0] = 2543974
              "01001101111100001001011" when "00000001", -- t[1] = 2553931
              "01001110001111101010111" when "00000010", -- t[2] = 2563927
              "01001110100011010001010" when "00000011", -- t[3] = 2573962
              "01001110110110111100100" when "00000100", -- t[4] = 2584036
              "01001111001010101100101" when "00000101", -- t[5] = 2594149
              "01001111011110100001111" when "00000110", -- t[6] = 2604303
              "01001111110010011100000" when "00000111", -- t[7] = 2614496
              "01010000000110011011000" when "00001000", -- t[8] = 2624728
              "01010000011010011111001" when "00001001", -- t[9] = 2635001
              "01010000101110101000010" when "00001010", -- t[10] = 2645314
              "01010001000010110110100" when "00001011", -- t[11] = 2655668
              "01010001010111001001110" when "00001100", -- t[12] = 2666062
              "01010001101011100010001" when "00001101", -- t[13] = 2676497
              "01010001111111111111100" when "00001110", -- t[14] = 2686972
              "01010010010100100010001" when "00001111", -- t[15] = 2697489
              "01010010101001001001110" when "00010000", -- t[16] = 2708046
              "01010010111101110110101" when "00010001", -- t[17] = 2718645
              "01010011010010101000110" when "00010010", -- t[18] = 2729286
              "01010011100111100000000" when "00010011", -- t[19] = 2739968
              "01010011111100011100100" when "00010100", -- t[20] = 2750692
              "01010100010001011110010" when "00010101", -- t[21] = 2761458
              "01010100100110100101010" when "00010110", -- t[22] = 2772266
              "01010100111011110001100" when "00010111", -- t[23] = 2783116
              "01010101010001000011001" when "00011000", -- t[24] = 2794009
              "01010101100110011010000" when "00011001", -- t[25] = 2804944
              "01010101111011110110010" when "00011010", -- t[26] = 2815922
              "01010110010001011000000" when "00011011", -- t[27] = 2826944
              "01010110100110111111000" when "00011100", -- t[28] = 2838008
              "01010110111100101011100" when "00011101", -- t[29] = 2849116
              "01010111010010011101011" when "00011110", -- t[30] = 2860267
              "01010111101000010100110" when "00011111", -- t[31] = 2871462
              "01010111111110010001100" when "00100000", -- t[32] = 2882700
              "01011000010100010011111" when "00100001", -- t[33] = 2893983
              "01011000101010011011101" when "00100010", -- t[34] = 2905309
              "01011001000000101001001" when "00100011", -- t[35] = 2916681
              "01011001010110111100000" when "00100100", -- t[36] = 2928096
              "01011001101101010100100" when "00100101", -- t[37] = 2939556
              "01011010000011110010101" when "00100110", -- t[38] = 2951061
              "01011010011010010110100" when "00100111", -- t[39] = 2962612
              "01011010110000111111111" when "00101000", -- t[40] = 2974207
              "01011011000111101111000" when "00101001", -- t[41] = 2985848
              "01011011011110100011110" when "00101010", -- t[42] = 2997534
              "01011011110101011110010" when "00101011", -- t[43] = 3009266
              "01011100001100011110100" when "00101100", -- t[44] = 3021044
              "01011100100011100100100" when "00101101", -- t[45] = 3032868
              "01011100111010110000010" when "00101110", -- t[46] = 3044738
              "01011101010010000001111" when "00101111", -- t[47] = 3056655
              "01011101101001011001010" when "00110000", -- t[48] = 3068618
              "01011110000000110110101" when "00110001", -- t[49] = 3080629
              "01011110011000011001110" when "00110010", -- t[50] = 3092686
              "01011110110000000010110" when "00110011", -- t[51] = 3104790
              "01011111000111110001110" when "00110100", -- t[52] = 3116942
              "01011111011111100110101" when "00110101", -- t[53] = 3129141
              "01011111110111100001101" when "00110110", -- t[54] = 3141389
              "01100000001111100010100" when "00110111", -- t[55] = 3153684
              "01100000100111101001011" when "00111000", -- t[56] = 3166027
              "01100000111111110110010" when "00111001", -- t[57] = 3178418
              "01100001011000001001010" when "00111010", -- t[58] = 3190858
              "01100001110000100010011" when "00111011", -- t[59] = 3203347
              "01100010001001000001100" when "00111100", -- t[60] = 3215884
              "01100010100001100110111" when "00111101", -- t[61] = 3228471
              "01100010111010010010011" when "00111110", -- t[62] = 3241107
              "01100011010011000100000" when "00111111", -- t[63] = 3253792
              "01100011101011111011111" when "01000000", -- t[64] = 3266527
              "01100100000100111010000" when "01000001", -- t[65] = 3279312
              "01100100011101111110011" when "01000010", -- t[66] = 3292147
              "01100100110111001001000" when "01000011", -- t[67] = 3305032
              "01100101010000011010000" when "01000100", -- t[68] = 3317968
              "01100101101001110001010" when "01000101", -- t[69] = 3330954
              "01100110000011001110111" when "01000110", -- t[70] = 3343991
              "01100110011100110010111" when "01000111", -- t[71] = 3357079
              "01100110110110011101010" when "01001000", -- t[72] = 3370218
              "01100111010000001110001" when "01001001", -- t[73] = 3383409
              "01100111101010000101011" when "01001010", -- t[74] = 3396651
              "01101000000100000011001" when "01001011", -- t[75] = 3409945
              "01101000011110000111011" when "01001100", -- t[76] = 3423291
              "01101000111000010010010" when "01001101", -- t[77] = 3436690
              "01101001010010100011100" when "01001110", -- t[78] = 3450140
              "01101001101100111011100" when "01001111", -- t[79] = 3463644
              "01101010000111011010000" when "01010000", -- t[80] = 3477200
              "01101010100001111111010" when "01010001", -- t[81] = 3490810
              "01101010111100101011000" when "01010010", -- t[82] = 3504472
              "01101011010111011101100" when "01010011", -- t[83] = 3518188
              "01101011110010010110110" when "01010100", -- t[84] = 3531958
              "01101100001101010110110" when "01010101", -- t[85] = 3545782
              "01101100101000011101100" when "01010110", -- t[86] = 3559660
              "01101101000011101011000" when "01010111", -- t[87] = 3573592
              "01101101011110111111010" when "01011000", -- t[88] = 3587578
              "01101101111010011010100" when "01011001", -- t[89] = 3601620
              "01101110010101111100100" when "01011010", -- t[90] = 3615716
              "01101110110001100101100" when "01011011", -- t[91] = 3629868
              "01101111001101010101010" when "01011100", -- t[92] = 3644074
              "01101111101001001100001" when "01011101", -- t[93] = 3658337
              "01110000000101001001111" when "01011110", -- t[94] = 3672655
              "01110000100001001110110" when "01011111", -- t[95] = 3687030
              "01110000111101011010100" when "01100000", -- t[96] = 3701460
              "01110001011001101101011" when "01100001", -- t[97] = 3715947
              "01110001110110000111011" when "01100010", -- t[98] = 3730491
              "01110010010010101000100" when "01100011", -- t[99] = 3745092
              "01110010101111010000110" when "01100100", -- t[100] = 3759750
              "01110011001100000000001" when "01100101", -- t[101] = 3774465
              "01110011101000110110110" when "01100110", -- t[102] = 3789238
              "01110100000101110100101" when "01100111", -- t[103] = 3804069
              "01110100100010111001101" when "01101000", -- t[104] = 3818957
              "01110101000000000110000" when "01101001", -- t[105] = 3833904
              "01110101011101011001110" when "01101010", -- t[106] = 3848910
              "01110101111010110100110" when "01101011", -- t[107] = 3863974
              "01110110011000010111001" when "01101100", -- t[108] = 3879097
              "01110110110110000000111" when "01101101", -- t[109] = 3894279
              "01110111010011110010001" when "01101110", -- t[110] = 3909521
              "01110111110001101010111" when "01101111", -- t[111] = 3924823
              "01111000001111101011000" when "01110000", -- t[112] = 3940184
              "01111000101101110010101" when "01110001", -- t[113] = 3955605
              "01111001001100000001111" when "01110010", -- t[114] = 3971087
              "01111001101010011000110" when "01110011", -- t[115] = 3986630
              "01111010001000110111001" when "01110100", -- t[116] = 4002233
              "01111010100111011101001" when "01110101", -- t[117] = 4017897
              "01111011000110001010111" when "01110110", -- t[118] = 4033623
              "01111011100101000000010" when "01110111", -- t[119] = 4049410
              "01111100000011111101011" when "01111000", -- t[120] = 4065259
              "01111100100011000010010" when "01111001", -- t[121] = 4081170
              "01111101000010001110111" when "01111010", -- t[122] = 4097143
              "01111101100001100011011" when "01111011", -- t[123] = 4113179
              "01111110000000111111101" when "01111100", -- t[124] = 4129277
              "01111110100000100011111" when "01111101", -- t[125] = 4145439
              "01111111000000010000000" when "01111110", -- t[126] = 4161664
              "01111111100000000100000" when "01111111", -- t[127] = 4177952
              "10000000000000000000000" when "10000000", -- t[128] = 4194304
              "10000000100000000100000" when "10000001", -- t[129] = 4210720
              "10000001000000010000000" when "10000010", -- t[130] = 4227200
              "10000001100000100100001" when "10000011", -- t[131] = 4243745
              "10000010000001000000011" when "10000100", -- t[132] = 4260355
              "10000010100001100100101" when "10000101", -- t[133] = 4277029
              "10000011000010010001001" when "10000110", -- t[134] = 4293769
              "10000011100011000101110" when "10000111", -- t[135] = 4310574
              "10000100000100000010110" when "10001000", -- t[136] = 4327446
              "10000100100101000111111" when "10001001", -- t[137] = 4344383
              "10000101000110010101010" when "10001010", -- t[138] = 4361386
              "10000101100111101011000" when "10001011", -- t[139] = 4378456
              "10000110001001001001001" when "10001100", -- t[140] = 4395593
              "10000110101010101111101" when "10001101", -- t[141] = 4412797
              "10000111001100011110100" when "10001110", -- t[142] = 4430068
              "10000111101110010101111" when "10001111", -- t[143] = 4447407
              "10001000010000010101101" when "10010000", -- t[144] = 4464813
              "10001000110010011110000" when "10010001", -- t[145] = 4482288
              "10001001010100101110111" when "10010010", -- t[146] = 4499831
              "10001001110111001000011" when "10010011", -- t[147] = 4517443
              "10001010011001101010100" when "10010100", -- t[148] = 4535124
              "10001010111100010101010" when "10010101", -- t[149] = 4552874
              "10001011011111001000101" when "10010110", -- t[150] = 4570693
              "10001100000010000100111" when "10010111", -- t[151] = 4588583
              "10001100100101001001110" when "10011000", -- t[152] = 4606542
              "10001101001000010111011" when "10011001", -- t[153] = 4624571
              "10001101101011101101111" when "10011010", -- t[154] = 4642671
              "10001110001111001101010" when "10011011", -- t[155] = 4660842
              "10001110110010110101100" when "10011100", -- t[156] = 4679084
              "10001111010110100110110" when "10011101", -- t[157] = 4697398
              "10001111111010100000111" when "10011110", -- t[158] = 4715783
              "10010000011110100100000" when "10011111", -- t[159] = 4734240
              "10010001000010110000001" when "10100000", -- t[160] = 4752769
              "10010001100111000101011" when "10100001", -- t[161] = 4771371
              "10010010001011100011110" when "10100010", -- t[162] = 4790046
              "10010010110000001011001" when "10100011", -- t[163] = 4808793
              "10010011010100111011110" when "10100100", -- t[164] = 4827614
              "10010011111001110101101" when "10100101", -- t[165] = 4846509
              "10010100011110111000110" when "10100110", -- t[166] = 4865478
              "10010101000100000101001" when "10100111", -- t[167] = 4884521
              "10010101101001011010110" when "10101000", -- t[168] = 4903638
              "10010110001110111001110" when "10101001", -- t[169] = 4922830
              "10010110110100100010010" when "10101010", -- t[170] = 4942098
              "10010111011010010100001" when "10101011", -- t[171] = 4961441
              "10011000000000001111011" when "10101100", -- t[172] = 4980859
              "10011000100110010100010" when "10101101", -- t[173] = 5000354
              "10011001001100100010101" when "10101110", -- t[174] = 5019925
              "10011001110010111010100" when "10101111", -- t[175] = 5039572
              "10011010011001011100000" when "10110000", -- t[176] = 5059296
              "10011011000000000111010" when "10110001", -- t[177] = 5079098
              "10011011100110111100001" when "10110010", -- t[178] = 5098977
              "10011100001101111010110" when "10110011", -- t[179] = 5118934
              "10011100110101000011001" when "10110100", -- t[180] = 5138969
              "10011101011100010101010" when "10110101", -- t[181] = 5159082
              "10011110000011110001010" when "10110110", -- t[182] = 5179274
              "10011110101011010111001" when "10110111", -- t[183] = 5199545
              "10011111010011000111000" when "10111000", -- t[184] = 5219896
              "10011111111011000000110" when "10111001", -- t[185] = 5240326
              "10100000100011000100100" when "10111010", -- t[186] = 5260836
              "10100001001011010010010" when "10111011", -- t[187] = 5281426
              "10100001110011101010001" when "10111100", -- t[188] = 5302097
              "10100010011100001100001" when "10111101", -- t[189] = 5322849
              "10100011000100111000010" when "10111110", -- t[190] = 5343682
              "10100011101101101110101" when "10111111", -- t[191] = 5364597
              "10100100010110101111001" when "11000000", -- t[192] = 5385593
              "10100100111111111010000" when "11000001", -- t[193] = 5406672
              "10100101101001001111001" when "11000010", -- t[194] = 5427833
              "10100110010010101110101" when "11000011", -- t[195] = 5449077
              "10100110111100011000100" when "11000100", -- t[196] = 5470404
              "10100111100110001100110" when "11000101", -- t[197] = 5491814
              "10101000010000001011101" when "11000110", -- t[198] = 5513309
              "10101000111010010100111" when "11000111", -- t[199] = 5534887
              "10101001100100101000110" when "11001000", -- t[200] = 5556550
              "10101010001111000111010" when "11001001", -- t[201] = 5578298
              "10101010111001110000011" when "11001010", -- t[202] = 5600131
              "10101011100100100100001" when "11001011", -- t[203] = 5622049
              "10101100001111100010101" when "11001100", -- t[204] = 5644053
              "10101100111010101011111" when "11001101", -- t[205] = 5666143
              "10101101100110000000000" when "11001110", -- t[206] = 5688320
              "10101110010001011110111" when "11001111", -- t[207] = 5710583
              "10101110111101001000110" when "11010000", -- t[208] = 5732934
              "10101111101000111101100" when "11010001", -- t[209] = 5755372
              "10110000010100111101010" when "11010010", -- t[210] = 5777898
              "10110001000001001000000" when "11010011", -- t[211] = 5800512
              "10110001101101011101110" when "11010100", -- t[212] = 5823214
              "10110010011001111110110" when "11010101", -- t[213] = 5846006
              "10110011000110101010110" when "11010110", -- t[214] = 5868886
              "10110011110011100010001" when "11010111", -- t[215] = 5891857
              "10110100100000100100101" when "11011000", -- t[216] = 5914917
              "10110101001101110010011" when "11011001", -- t[217] = 5938067
              "10110101111011001011100" when "11011010", -- t[218] = 5961308
              "10110110101000110000000" when "11011011", -- t[219] = 5984640
              "10110111010110011111111" when "11011100", -- t[220] = 6008063
              "10111000000100011011010" when "11011101", -- t[221] = 6031578
              "10111000110010100010001" when "11011110", -- t[222] = 6055185
              "10111001100000110100100" when "11011111", -- t[223] = 6078884
              "10111010001111010010100" when "11100000", -- t[224] = 6102676
              "10111010111101111100010" when "11100001", -- t[225] = 6126562
              "10111011101100110001100" when "11100010", -- t[226] = 6150540
              "10111100011011110010101" when "11100011", -- t[227] = 6174613
              "10111101001010111111011" when "11100100", -- t[228] = 6198779
              "10111101111010011000001" when "11100101", -- t[229] = 6223041
              "10111110101001111100101" when "11100110", -- t[230] = 6247397
              "10111111011001101101001" when "11100111", -- t[231] = 6271849
              "11000000001001101001100" when "11101000", -- t[232] = 6296396
              "11000000111001110001111" when "11101001", -- t[233] = 6321039
              "11000001101010000110011" when "11101010", -- t[234] = 6345779
              "11000010011010100111000" when "11101011", -- t[235] = 6370616
              "11000011001011010011110" when "11101100", -- t[236] = 6395550
              "11000011111100001100101" when "11101101", -- t[237] = 6420581
              "11000100101101010001111" when "11101110", -- t[238] = 6445711
              "11000101011110100011011" when "11101111", -- t[239] = 6470939
              "11000110010000000001001" when "11110000", -- t[240] = 6496265
              "11000111000001101011011" when "11110001", -- t[241] = 6521691
              "11000111110011100010000" when "11110010", -- t[242] = 6547216
              "11001000100101100101001" when "11110011", -- t[243] = 6572841
              "11001001010111110100110" when "11110100", -- t[244] = 6598566
              "11001010001010010001000" when "11110101", -- t[245] = 6624392
              "11001010111100111010000" when "11110110", -- t[246] = 6650320
              "11001011101111101111100" when "11110111", -- t[247] = 6676348
              "11001100100010110001111" when "11111000", -- t[248] = 6702479
              "11001101010110000000111" when "11111001", -- t[249] = 6728711
              "11001110001001011100111" when "11111010", -- t[250] = 6755047
              "11001110111101000101101" when "11111011", -- t[251] = 6781485
              "11001111110000111011011" when "11111100", -- t[252] = 6808027
              "11010000100100111110001" when "11111101", -- t[253] = 6834673
              "11010001011001001101111" when "11111110", -- t[254] = 6861423
              "11010010001101101010110" when "11111111", -- t[255] = 6888278
              "-----------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_19 is
  port ( nY1    : in  std_logic_vector(7 downto 0);
         nExpY1 : out std_logic_vector(19+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_19 is
begin

  with nY1 select
    nExpY1 <= "010011011010001011001100" when "00000000", -- t[0] = 5087948
              "010011011111000010010110" when "00000001", -- t[1] = 5107862
              "010011100011111010101101" when "00000010", -- t[2] = 5127853
              "010011101000110100010011" when "00000011", -- t[3] = 5147923
              "010011101101101111000111" when "00000100", -- t[4] = 5168071
              "010011110010101011001011" when "00000101", -- t[5] = 5188299
              "010011110111101000011101" when "00000110", -- t[6] = 5208605
              "010011111100100110111111" when "00000111", -- t[7] = 5228991
              "010100000001100110110001" when "00001000", -- t[8] = 5249457
              "010100000110100111110011" when "00001001", -- t[9] = 5270003
              "010100001011101010000101" when "00001010", -- t[10] = 5290629
              "010100010000101101101000" when "00001011", -- t[11] = 5311336
              "010100010101110010011100" when "00001100", -- t[12] = 5332124
              "010100011010111000100001" when "00001101", -- t[13] = 5352993
              "010100011111111111111000" when "00001110", -- t[14] = 5373944
              "010100100101001000100001" when "00001111", -- t[15] = 5394977
              "010100101010010010011100" when "00010000", -- t[16] = 5416092
              "010100101111011101101010" when "00010001", -- t[17] = 5437290
              "010100110100101010001011" when "00010010", -- t[18] = 5458571
              "010100111001111000000000" when "00010011", -- t[19] = 5479936
              "010100111111000111000111" when "00010100", -- t[20] = 5501383
              "010101000100010111100011" when "00010101", -- t[21] = 5522915
              "010101001001101001010011" when "00010110", -- t[22] = 5544531
              "010101001110111100011000" when "00010111", -- t[23] = 5566232
              "010101010100010000110010" when "00011000", -- t[24] = 5588018
              "010101011001100110100001" when "00011001", -- t[25] = 5609889
              "010101011110111101100101" when "00011010", -- t[26] = 5631845
              "010101100100010101111111" when "00011011", -- t[27] = 5653887
              "010101101001101111110000" when "00011100", -- t[28] = 5676016
              "010101101111001010110111" when "00011101", -- t[29] = 5698231
              "010101110100100111010110" when "00011110", -- t[30] = 5720534
              "010101111010000101001011" when "00011111", -- t[31] = 5742923
              "010101111111100100011000" when "00100000", -- t[32] = 5765400
              "010110000101000100111101" when "00100001", -- t[33] = 5787965
              "010110001010100110111011" when "00100010", -- t[34] = 5810619
              "010110010000001010010001" when "00100011", -- t[35] = 5833361
              "010110010101101111000000" when "00100100", -- t[36] = 5856192
              "010110011011010101001001" when "00100101", -- t[37] = 5879113
              "010110100000111100101011" when "00100110", -- t[38] = 5902123
              "010110100110100101100111" when "00100111", -- t[39] = 5925223
              "010110101100001111111110" when "00101000", -- t[40] = 5948414
              "010110110001111011101111" when "00101001", -- t[41] = 5971695
              "010110110111101000111100" when "00101010", -- t[42] = 5995068
              "010110111101010111100100" when "00101011", -- t[43] = 6018532
              "010111000011000111101000" when "00101100", -- t[44] = 6042088
              "010111001000111001001000" when "00101101", -- t[45] = 6065736
              "010111001110101100000100" when "00101110", -- t[46] = 6089476
              "010111010100100000011110" when "00101111", -- t[47] = 6113310
              "010111011010010110010101" when "00110000", -- t[48] = 6137237
              "010111100000001101101001" when "00110001", -- t[49] = 6161257
              "010111100110000110011100" when "00110010", -- t[50] = 6185372
              "010111101100000000101101" when "00110011", -- t[51] = 6209581
              "010111110001111100011100" when "00110100", -- t[52] = 6233884
              "010111110111111001101011" when "00110101", -- t[53] = 6258283
              "010111111101111000011001" when "00110110", -- t[54] = 6282777
              "011000000011111000100111" when "00110111", -- t[55] = 6307367
              "011000001001111010010110" when "00111000", -- t[56] = 6332054
              "011000001111111101100100" when "00111001", -- t[57] = 6356836
              "011000010110000010010100" when "00111010", -- t[58] = 6381716
              "011000011100001000100110" when "00111011", -- t[59] = 6406694
              "011000100010010000011001" when "00111100", -- t[60] = 6431769
              "011000101000011001101110" when "00111101", -- t[61] = 6456942
              "011000101110100100100110" when "00111110", -- t[62] = 6482214
              "011000110100110001000001" when "00111111", -- t[63] = 6507585
              "011000111010111110111110" when "01000000", -- t[64] = 6533054
              "011001000001001110100000" when "01000001", -- t[65] = 6558624
              "011001000111011111100110" when "01000010", -- t[66] = 6584294
              "011001001101110010010000" when "01000011", -- t[67] = 6610064
              "011001010100000110011111" when "01000100", -- t[68] = 6635935
              "011001011010011100010011" when "01000101", -- t[69] = 6661907
              "011001100000110011101101" when "01000110", -- t[70] = 6687981
              "011001100111001100101101" when "01000111", -- t[71] = 6714157
              "011001101101100111010100" when "01001000", -- t[72] = 6740436
              "011001110100000011100001" when "01001001", -- t[73] = 6766817
              "011001111010100001010110" when "01001010", -- t[74] = 6793302
              "011010000001000000110010" when "01001011", -- t[75] = 6819890
              "011010000111100001110110" when "01001100", -- t[76] = 6846582
              "011010001110000100100011" when "01001101", -- t[77] = 6873379
              "011010010100101000111001" when "01001110", -- t[78] = 6900281
              "011010011011001110111000" when "01001111", -- t[79] = 6927288
              "011010100001110110100000" when "01010000", -- t[80] = 6954400
              "011010101000011111110011" when "01010001", -- t[81] = 6981619
              "011010101111001010110000" when "01010010", -- t[82] = 7008944
              "011010110101110111011001" when "01010011", -- t[83] = 7036377
              "011010111100100101101100" when "01010100", -- t[84] = 7063916
              "011011000011010101101100" when "01010101", -- t[85] = 7091564
              "011011001010000111010111" when "01010110", -- t[86] = 7119319
              "011011010000111010101111" when "01010111", -- t[87] = 7147183
              "011011010111101111110101" when "01011000", -- t[88] = 7175157
              "011011011110100110100111" when "01011001", -- t[89] = 7203239
              "011011100101011111001000" when "01011010", -- t[90] = 7231432
              "011011101100011001010111" when "01011011", -- t[91] = 7259735
              "011011110011010101010101" when "01011100", -- t[92] = 7288149
              "011011111010010011000010" when "01011101", -- t[93] = 7316674
              "011100000001010010011111" when "01011110", -- t[94] = 7345311
              "011100001000010011101011" when "01011111", -- t[95] = 7374059
              "011100001111010110101001" when "01100000", -- t[96] = 7402921
              "011100010110011011010111" when "01100001", -- t[97] = 7431895
              "011100011101100001110110" when "01100010", -- t[98] = 7460982
              "011100100100101010001000" when "01100011", -- t[99] = 7490184
              "011100101011110100001100" when "01100100", -- t[100] = 7519500
              "011100110011000000000010" when "01100101", -- t[101] = 7548930
              "011100111010001101101100" when "01100110", -- t[102] = 7578476
              "011101000001011101001001" when "01100111", -- t[103] = 7608137
              "011101001000101110011011" when "01101000", -- t[104] = 7637915
              "011101010000000001100000" when "01101001", -- t[105] = 7667808
              "011101010111010110011011" when "01101010", -- t[106] = 7697819
              "011101011110101101001100" when "01101011", -- t[107] = 7727948
              "011101100110000101110010" when "01101100", -- t[108] = 7758194
              "011101101101100000001111" when "01101101", -- t[109] = 7788559
              "011101110100111100100010" when "01101110", -- t[110] = 7819042
              "011101111100011010101101" when "01101111", -- t[111] = 7849645
              "011110000011111010110000" when "01110000", -- t[112] = 7880368
              "011110001011011100101011" when "01110001", -- t[113] = 7911211
              "011110010011000000011110" when "01110010", -- t[114] = 7942174
              "011110011010100110001011" when "01110011", -- t[115] = 7973259
              "011110100010001101110010" when "01110100", -- t[116] = 8004466
              "011110101001110111010010" when "01110101", -- t[117] = 8035794
              "011110110001100010101101" when "01110110", -- t[118] = 8067245
              "011110111001010000000100" when "01110111", -- t[119] = 8098820
              "011111000000111111010110" when "01111000", -- t[120] = 8130518
              "011111001000110000100100" when "01111001", -- t[121] = 8162340
              "011111010000100011101110" when "01111010", -- t[122] = 8194286
              "011111011000011000110110" when "01111011", -- t[123] = 8226358
              "011111100000001111111011" when "01111100", -- t[124] = 8258555
              "011111101000001000111110" when "01111101", -- t[125] = 8290878
              "011111110000000011111111" when "01111110", -- t[126] = 8323327
              "011111111000000001000000" when "01111111", -- t[127] = 8355904
              "100000000000000000000000" when "10000000", -- t[128] = 8388608
              "100000001000000001000000" when "10000001", -- t[129] = 8421440
              "100000010000000100000001" when "10000010", -- t[130] = 8454401
              "100000011000001001000010" when "10000011", -- t[131] = 8487490
              "100000100000010000000101" when "10000100", -- t[132] = 8520709
              "100000101000011001001010" when "10000101", -- t[133] = 8554058
              "100000110000100100010010" when "10000110", -- t[134] = 8587538
              "100000111000110001011101" when "10000111", -- t[135] = 8621149
              "100001000001000000101011" when "10001000", -- t[136] = 8654891
              "100001001001010001111101" when "10001001", -- t[137] = 8688765
              "100001010001100101010100" when "10001010", -- t[138] = 8722772
              "100001011001111010110000" when "10001011", -- t[139] = 8756912
              "100001100010010010010010" when "10001100", -- t[140] = 8791186
              "100001101010101011111001" when "10001101", -- t[141] = 8825593
              "100001110011000111101000" when "10001110", -- t[142] = 8860136
              "100001111011100101011101" when "10001111", -- t[143] = 8894813
              "100010000100000101011011" when "10010000", -- t[144] = 8929627
              "100010001100100111100000" when "10010001", -- t[145] = 8964576
              "100010010101001011101111" when "10010010", -- t[146] = 8999663
              "100010011101110010000110" when "10010011", -- t[147] = 9034886
              "100010100110011010101000" when "10010100", -- t[148] = 9070248
              "100010101111000101010100" when "10010101", -- t[149] = 9105748
              "100010110111110010001011" when "10010110", -- t[150] = 9141387
              "100011000000100001001101" when "10010111", -- t[151] = 9177165
              "100011001001010010011100" when "10011000", -- t[152] = 9213084
              "100011010010000101110111" when "10011001", -- t[153] = 9249143
              "100011011010111011011111" when "10011010", -- t[154] = 9285343
              "100011100011110011010100" when "10011011", -- t[155] = 9321684
              "100011101100101101011000" when "10011100", -- t[156] = 9358168
              "100011110101101001101011" when "10011101", -- t[157] = 9394795
              "100011111110101000001101" when "10011110", -- t[158] = 9431565
              "100100000111101001000000" when "10011111", -- t[159] = 9468480
              "100100010000101100000010" when "10100000", -- t[160] = 9505538
              "100100011001110001010110" when "10100001", -- t[161] = 9542742
              "100100100010111000111011" when "10100010", -- t[162] = 9580091
              "100100101100000010110010" when "10100011", -- t[163] = 9617586
              "100100110101001110111101" when "10100100", -- t[164] = 9655229
              "100100111110011101011010" when "10100101", -- t[165] = 9693018
              "100101000111101110001100" when "10100110", -- t[166] = 9730956
              "100101010001000001010001" when "10100111", -- t[167] = 9769041
              "100101011010010110101100" when "10101000", -- t[168] = 9807276
              "100101100011101110011101" when "10101001", -- t[169] = 9845661
              "100101101101001000100100" when "10101010", -- t[170] = 9884196
              "100101110110100101000001" when "10101011", -- t[171] = 9922881
              "100110000000000011110110" when "10101100", -- t[172] = 9961718
              "100110001001100101000100" when "10101101", -- t[173] = 10000708
              "100110010011001000101001" when "10101110", -- t[174] = 10039849
              "100110011100101110101000" when "10101111", -- t[175] = 10079144
              "100110100110010111000001" when "10110000", -- t[176] = 10118593
              "100110110000000001110100" when "10110001", -- t[177] = 10158196
              "100110111001101111000010" when "10110010", -- t[178] = 10197954
              "100111000011011110101011" when "10110011", -- t[179] = 10237867
              "100111001101010000110001" when "10110100", -- t[180] = 10277937
              "100111010111000101010100" when "10110101", -- t[181] = 10318164
              "100111100000111100010100" when "10110110", -- t[182] = 10358548
              "100111101010110101110010" when "10110111", -- t[183] = 10399090
              "100111110100110001101111" when "10111000", -- t[184] = 10439791
              "100111111110110000001100" when "10111001", -- t[185] = 10480652
              "101000001000110001001000" when "10111010", -- t[186] = 10521672
              "101000010010110100100100" when "10111011", -- t[187] = 10562852
              "101000011100111010100010" when "10111100", -- t[188] = 10604194
              "101000100111000011000010" when "10111101", -- t[189] = 10645698
              "101000110001001110000100" when "10111110", -- t[190] = 10687364
              "101000111011011011101001" when "10111111", -- t[191] = 10729193
              "101001000101101011110010" when "11000000", -- t[192] = 10771186
              "101001001111111110011111" when "11000001", -- t[193] = 10813343
              "101001011010010011110001" when "11000010", -- t[194] = 10855665
              "101001100100101011101001" when "11000011", -- t[195] = 10898153
              "101001101111000110000111" when "11000100", -- t[196] = 10940807
              "101001111001100011001100" when "11000101", -- t[197] = 10983628
              "101010000100000010111001" when "11000110", -- t[198] = 11026617
              "101010001110100101001110" when "11000111", -- t[199] = 11069774
              "101010011001001010001100" when "11001000", -- t[200] = 11113100
              "101010100011110001110011" when "11001001", -- t[201] = 11156595
              "101010101110011100000101" when "11001010", -- t[202] = 11200261
              "101010111001001001000010" when "11001011", -- t[203] = 11244098
              "101011000011111000101010" when "11001100", -- t[204] = 11288106
              "101011001110101010111110" when "11001101", -- t[205] = 11332286
              "101011011001100000000000" when "11001110", -- t[206] = 11376640
              "101011100100010111101111" when "11001111", -- t[207] = 11421167
              "101011101111010010001100" when "11010000", -- t[208] = 11465868
              "101011111010001111011000" when "11010001", -- t[209] = 11510744
              "101100000101001111010100" when "11010010", -- t[210] = 11555796
              "101100010000010010000000" when "11010011", -- t[211] = 11601024
              "101100011011010111011101" when "11010100", -- t[212] = 11646429
              "101100100110011111101100" when "11010101", -- t[213] = 11692012
              "101100110001101010101101" when "11010110", -- t[214] = 11737773
              "101100111100111000100001" when "11010111", -- t[215] = 11783713
              "101101001000001001001001" when "11011000", -- t[216] = 11829833
              "101101010011011100100110" when "11011001", -- t[217] = 11876134
              "101101011110110010111000" when "11011010", -- t[218] = 11922616
              "101101101010001100000000" when "11011011", -- t[219] = 11969280
              "101101110101100111111110" when "11011100", -- t[220] = 12016126
              "101110000001000110110100" when "11011101", -- t[221] = 12063156
              "101110001100101000100010" when "11011110", -- t[222] = 12110370
              "101110011000001101001000" when "11011111", -- t[223] = 12157768
              "101110100011110100101001" when "11100000", -- t[224] = 12205353
              "101110101111011111000011" when "11100001", -- t[225] = 12253123
              "101110111011001100011000" when "11100010", -- t[226] = 12301080
              "101111000110111100101001" when "11100011", -- t[227] = 12349225
              "101111010010101111110111" when "11100100", -- t[228] = 12397559
              "101111011110100110000010" when "11100101", -- t[229] = 12446082
              "101111101010011111001010" when "11100110", -- t[230] = 12494794
              "101111110110011011010001" when "11100111", -- t[231] = 12543697
              "110000000010011010011000" when "11101000", -- t[232] = 12592792
              "110000001110011100011111" when "11101001", -- t[233] = 12642079
              "110000011010100001100111" when "11101010", -- t[234] = 12691559
              "110000100110101001110000" when "11101011", -- t[235] = 12741232
              "110000110010110100111100" when "11101100", -- t[236] = 12791100
              "110000111111000011001011" when "11101101", -- t[237] = 12841163
              "110001001011010100011110" when "11101110", -- t[238] = 12891422
              "110001010111101000110101" when "11101111", -- t[239] = 12941877
              "110001100100000000010010" when "11110000", -- t[240] = 12992530
              "110001110000011010110110" when "11110001", -- t[241] = 13043382
              "110001111100111000100000" when "11110010", -- t[242] = 13094432
              "110010001001011001010010" when "11110011", -- t[243] = 13145682
              "110010010101111101001101" when "11110100", -- t[244] = 13197133
              "110010100010100100010001" when "11110101", -- t[245] = 13248785
              "110010101111001110011111" when "11110110", -- t[246] = 13300639
              "110010111011111011111000" when "11110111", -- t[247] = 13352696
              "110011001000101100011101" when "11111000", -- t[248] = 13404957
              "110011010101100000001111" when "11111001", -- t[249] = 13457423
              "110011100010010111001110" when "11111010", -- t[250] = 13510094
              "110011101111010001011011" when "11111011", -- t[251] = 13562971
              "110011111100001110110111" when "11111100", -- t[252] = 13616055
              "110100001001001111100011" when "11111101", -- t[253] = 13669347
              "110100010110010011011111" when "11111110", -- t[254] = 13722847
              "110100100011011010101101" when "11111111", -- t[255] = 13776557
              "------------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_20 is
  port ( nY1    : in  std_logic_vector(7 downto 0);
         nExpY1 : out std_logic_vector(20+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_20 is
begin

  with nY1 select
    nExpY1 <= "0100110110100010110011000" when "00000000", -- t[0] = 10175896
              "0100110111110000100101011" when "00000001", -- t[1] = 10215723
              "0100111000111110101011010" when "00000010", -- t[2] = 10255706
              "0100111010001101000100110" when "00000011", -- t[3] = 10295846
              "0100111011011011110001111" when "00000100", -- t[4] = 10336143
              "0100111100101010110010101" when "00000101", -- t[5] = 10376597
              "0100111101111010000111010" when "00000110", -- t[6] = 10417210
              "0100111111001001101111110" when "00000111", -- t[7] = 10457982
              "0101000000011001101100001" when "00001000", -- t[8] = 10498913
              "0101000001101001111100101" when "00001001", -- t[9] = 10540005
              "0101000010111010100001001" when "00001010", -- t[10] = 10581257
              "0101000100001011011001111" when "00001011", -- t[11] = 10622671
              "0101000101011100100110111" when "00001100", -- t[12] = 10664247
              "0101000110101110001000010" when "00001101", -- t[13] = 10705986
              "0101000111111111111110000" when "00001110", -- t[14] = 10747888
              "0101001001010010001000010" when "00001111", -- t[15] = 10789954
              "0101001010100100100111001" when "00010000", -- t[16] = 10832185
              "0101001011110111011010101" when "00010001", -- t[17] = 10874581
              "0101001101001010100010111" when "00010010", -- t[18] = 10917143
              "0101001110011101111111111" when "00010011", -- t[19] = 10959871
              "0101001111110001110001111" when "00010100", -- t[20] = 11002767
              "0101010001000101111000110" when "00010101", -- t[21] = 11045830
              "0101010010011010010100111" when "00010110", -- t[22] = 11089063
              "0101010011101111000110000" when "00010111", -- t[23] = 11132464
              "0101010101000100001100011" when "00011000", -- t[24] = 11176035
              "0101010110011001101000001" when "00011001", -- t[25] = 11219777
              "0101010111101111011001010" when "00011010", -- t[26] = 11263690
              "0101011001000101011111111" when "00011011", -- t[27] = 11307775
              "0101011010011011111100000" when "00011100", -- t[28] = 11352032
              "0101011011110010101101111" when "00011101", -- t[29] = 11396463
              "0101011101001001110101011" when "00011110", -- t[30] = 11441067
              "0101011110100001010010110" when "00011111", -- t[31] = 11485846
              "0101011111111001000110001" when "00100000", -- t[32] = 11530801
              "0101100001010001001111011" when "00100001", -- t[33] = 11575931
              "0101100010101001101110110" when "00100010", -- t[34] = 11621238
              "0101100100000010100100010" when "00100011", -- t[35] = 11666722
              "0101100101011011110000000" when "00100100", -- t[36] = 11712384
              "0101100110110101010010001" when "00100101", -- t[37] = 11758225
              "0101101000001111001010110" when "00100110", -- t[38] = 11804246
              "0101101001101001011001110" when "00100111", -- t[39] = 11850446
              "0101101011000011111111100" when "00101000", -- t[40] = 11896828
              "0101101100011110111011110" when "00101001", -- t[41] = 11943390
              "0101101101111010001111000" when "00101010", -- t[42] = 11990136
              "0101101111010101111001000" when "00101011", -- t[43] = 12037064
              "0101110000110001111001111" when "00101100", -- t[44] = 12084175
              "0101110010001110010001111" when "00101101", -- t[45] = 12131471
              "0101110011101011000001001" when "00101110", -- t[46] = 12178953
              "0101110101001000000111100" when "00101111", -- t[47] = 12226620
              "0101110110100101100101001" when "00110000", -- t[48] = 12274473
              "0101111000000011011010010" when "00110001", -- t[49] = 12322514
              "0101111001100001100110111" when "00110010", -- t[50] = 12370743
              "0101111011000000001011001" when "00110011", -- t[51] = 12419161
              "0101111100011111000111000" when "00110100", -- t[52] = 12467768
              "0101111101111110011010110" when "00110101", -- t[53] = 12516566
              "0101111111011110000110010" when "00110110", -- t[54] = 12565554
              "0110000000111110001001110" when "00110111", -- t[55] = 12614734
              "0110000010011110100101011" when "00111000", -- t[56] = 12664107
              "0110000011111111011001001" when "00111001", -- t[57] = 12713673
              "0110000101100000100101001" when "00111010", -- t[58] = 12763433
              "0110000111000010001001100" when "00111011", -- t[59] = 12813388
              "0110001000100100000110010" when "00111100", -- t[60] = 12863538
              "0110001010000110011011100" when "00111101", -- t[61] = 12913884
              "0110001011101001001001100" when "00111110", -- t[62] = 12964428
              "0110001101001100010000001" when "00111111", -- t[63] = 13015169
              "0110001110101111101111101" when "01000000", -- t[64] = 13066109
              "0110010000010011101000000" when "01000001", -- t[65] = 13117248
              "0110010001110111111001100" when "01000010", -- t[66] = 13168588
              "0110010011011100100100000" when "01000011", -- t[67] = 13220128
              "0110010101000001100111110" when "01000100", -- t[68] = 13271870
              "0110010110100111000100111" when "01000101", -- t[69] = 13323815
              "0110011000001100111011011" when "01000110", -- t[70] = 13375963
              "0110011001110011001011011" when "01000111", -- t[71] = 13428315
              "0110011011011001110101000" when "01001000", -- t[72] = 13480872
              "0110011101000000111000010" when "01001001", -- t[73] = 13533634
              "0110011110101000010101100" when "01001010", -- t[74] = 13586604
              "0110100000010000001100100" when "01001011", -- t[75] = 13639780
              "0110100001111000011101101" when "01001100", -- t[76] = 13693165
              "0110100011100001001000110" when "01001101", -- t[77] = 13746758
              "0110100101001010001110001" when "01001110", -- t[78] = 13800561
              "0110100110110011101101111" when "01001111", -- t[79] = 13854575
              "0110101000011101101000001" when "01010000", -- t[80] = 13908801
              "0110101010000111111100110" when "01010001", -- t[81] = 13963238
              "0110101011110010101100001" when "01010010", -- t[82] = 14017889
              "0110101101011101110110001" when "01010011", -- t[83] = 14072753
              "0110101111001001011011000" when "01010100", -- t[84] = 14127832
              "0110110000110101011010111" when "01010101", -- t[85] = 14183127
              "0110110010100001110101110" when "01010110", -- t[86] = 14238638
              "0110110100001110101011111" when "01010111", -- t[87] = 14294367
              "0110110101111011111101001" when "01011000", -- t[88] = 14350313
              "0110110111101001101001111" when "01011001", -- t[89] = 14406479
              "0110111001010111110010000" when "01011010", -- t[90] = 14462864
              "0110111011000110010101110" when "01011011", -- t[91] = 14519470
              "0110111100110101010101010" when "01011100", -- t[92] = 14576298
              "0110111110100100110000100" when "01011101", -- t[93] = 14633348
              "0111000000010100100111101" when "01011110", -- t[94] = 14690621
              "0111000010000100111010111" when "01011111", -- t[95] = 14748119
              "0111000011110101101010001" when "01100000", -- t[96] = 14805841
              "0111000101100110110101110" when "01100001", -- t[97] = 14863790
              "0111000111011000011101101" when "01100010", -- t[98] = 14921965
              "0111001001001010100010000" when "01100011", -- t[99] = 14980368
              "0111001010111101000010111" when "01100100", -- t[100] = 15038999
              "0111001100110000000000100" when "01100101", -- t[101] = 15097860
              "0111001110100011011011000" when "01100110", -- t[102] = 15156952
              "0111010000010111010010010" when "01100111", -- t[103] = 15216274
              "0111010010001011100110101" when "01101000", -- t[104] = 15275829
              "0111010100000000011000001" when "01101001", -- t[105] = 15335617
              "0111010101110101100110111" when "01101010", -- t[106] = 15395639
              "0111010111101011010011000" when "01101011", -- t[107] = 15455896
              "0111011001100001011100100" when "01101100", -- t[108] = 15516388
              "0111011011011000000011110" when "01101101", -- t[109] = 15577118
              "0111011101001111001000101" when "01101110", -- t[110] = 15638085
              "0111011111000110101011011" when "01101111", -- t[111] = 15699291
              "0111100000111110101100000" when "01110000", -- t[112] = 15760736
              "0111100010110111001010110" when "01110001", -- t[113] = 15822422
              "0111100100110000000111101" when "01110010", -- t[114] = 15884349
              "0111100110101001100010110" when "01110011", -- t[115] = 15946518
              "0111101000100011011100011" when "01110100", -- t[116] = 16008931
              "0111101010011101110100101" when "01110101", -- t[117] = 16071589
              "0111101100011000101011011" when "01110110", -- t[118] = 16134491
              "0111101110010100000001000" when "01110111", -- t[119] = 16197640
              "0111110000001111110101011" when "01111000", -- t[120] = 16261035
              "0111110010001100001000111" when "01111001", -- t[121] = 16324679
              "0111110100001000111011100" when "01111010", -- t[122] = 16388572
              "0111110110000110001101011" when "01111011", -- t[123] = 16452715
              "0111111000000011111110101" when "01111100", -- t[124] = 16517109
              "0111111010000010001111100" when "01111101", -- t[125] = 16581756
              "0111111100000000111111111" when "01111110", -- t[126] = 16646655
              "0111111110000000010000000" when "01111111", -- t[127] = 16711808
              "1000000000000000000000000" when "10000000", -- t[128] = 16777216
              "1000000010000000010000000" when "10000001", -- t[129] = 16842880
              "1000000100000001000000001" when "10000010", -- t[130] = 16908801
              "1000000110000010010000101" when "10000011", -- t[131] = 16974981
              "1000001000000100000001011" when "10000100", -- t[132] = 17041419
              "1000001010000110010010101" when "10000101", -- t[133] = 17108117
              "1000001100001001000100100" when "10000110", -- t[134] = 17175076
              "1000001110001100010111010" when "10000111", -- t[135] = 17242298
              "1000010000010000001010110" when "10001000", -- t[136] = 17309782
              "1000010010010100011111011" when "10001001", -- t[137] = 17377531
              "1000010100011001010101000" when "10001010", -- t[138] = 17445544
              "1000010110011110101100000" when "10001011", -- t[139] = 17513824
              "1000011000100100100100011" when "10001100", -- t[140] = 17582371
              "1000011010101010111110011" when "10001101", -- t[141] = 17651187
              "1000011100110001111010000" when "10001110", -- t[142] = 17720272
              "1000011110111001010111011" when "10001111", -- t[143] = 17789627
              "1000100001000001010110101" when "10010000", -- t[144] = 17859253
              "1000100011001001111000001" when "10010001", -- t[145] = 17929153
              "1000100101010010111011101" when "10010010", -- t[146] = 17999325
              "1000100111011100100001101" when "10010011", -- t[147] = 18069773
              "1000101001100110101010000" when "10010100", -- t[148] = 18140496
              "1000101011110001010101000" when "10010101", -- t[149] = 18211496
              "1000101101111100100010101" when "10010110", -- t[150] = 18282773
              "1000110000001000010011010" when "10010111", -- t[151] = 18354330
              "1000110010010100100110111" when "10011000", -- t[152] = 18426167
              "1000110100100001011101101" when "10011001", -- t[153] = 18498285
              "1000110110101110110111101" when "10011010", -- t[154] = 18570685
              "1000111000111100110101001" when "10011011", -- t[155] = 18643369
              "1000111011001011010110001" when "10011100", -- t[156] = 18716337
              "1000111101011010011010111" when "10011101", -- t[157] = 18789591
              "1000111111101010000011011" when "10011110", -- t[158] = 18863131
              "1001000001111010001111111" when "10011111", -- t[159] = 18936959
              "1001000100001011000000100" when "10100000", -- t[160] = 19011076
              "1001000110011100010101100" when "10100001", -- t[161] = 19085484
              "1001001000101110001110110" when "10100010", -- t[162] = 19160182
              "1001001011000000101100101" when "10100011", -- t[163] = 19235173
              "1001001101010011101111001" when "10100100", -- t[164] = 19310457
              "1001001111100111010110100" when "10100101", -- t[165] = 19386036
              "1001010001111011100010111" when "10100110", -- t[166] = 19461911
              "1001010100010000010100011" when "10100111", -- t[167] = 19538083
              "1001010110100101101011001" when "10101000", -- t[168] = 19614553
              "1001011000111011100111010" when "10101001", -- t[169] = 19691322
              "1001011011010010001001000" when "10101010", -- t[170] = 19768392
              "1001011101101001010000011" when "10101011", -- t[171] = 19845763
              "1001100000000000111101101" when "10101100", -- t[172] = 19923437
              "1001100010011001010000111" when "10101101", -- t[173] = 20001415
              "1001100100110010001010010" when "10101110", -- t[174] = 20079698
              "1001100111001011101010000" when "10101111", -- t[175] = 20158288
              "1001101001100101110000001" when "10110000", -- t[176] = 20237185
              "1001101100000000011101000" when "10110001", -- t[177] = 20316392
              "1001101110011011110000100" when "10110010", -- t[178] = 20395908
              "1001110000110111101010111" when "10110011", -- t[179] = 20475735
              "1001110011010100001100011" when "10110100", -- t[180] = 20555875
              "1001110101110001010101000" when "10110101", -- t[181] = 20636328
              "1001111000001111000101000" when "10110110", -- t[182] = 20717096
              "1001111010101101011100101" when "10110111", -- t[183] = 20798181
              "1001111101001100011011111" when "10111000", -- t[184] = 20879583
              "1001111111101100000010111" when "10111001", -- t[185] = 20961303
              "1010000010001100010001111" when "10111010", -- t[186] = 21043343
              "1010000100101101001001001" when "10111011", -- t[187] = 21125705
              "1010000111001110101000100" when "10111100", -- t[188] = 21208388
              "1010001001110000110000100" when "10111101", -- t[189] = 21291396
              "1010001100010011100001000" when "10111110", -- t[190] = 21374728
              "1010001110110110111010010" when "10111111", -- t[191] = 21458386
              "1010010001011010111100100" when "11000000", -- t[192] = 21542372
              "1010010011111111100111110" when "11000001", -- t[193] = 21626686
              "1010010110100100111100011" when "11000010", -- t[194] = 21711331
              "1010011001001010111010010" when "11000011", -- t[195] = 21796306
              "1010011011110001100001111" when "11000100", -- t[196] = 21881615
              "1010011110011000110011001" when "11000101", -- t[197] = 21967257
              "1010100001000000101110010" when "11000110", -- t[198] = 22053234
              "1010100011101001010011100" when "11000111", -- t[199] = 22139548
              "1010100110010010100011000" when "11001000", -- t[200] = 22226200
              "1010101000111100011100111" when "11001001", -- t[201] = 22313191
              "1010101011100111000001010" when "11001010", -- t[202] = 22400522
              "1010101110010010010000011" when "11001011", -- t[203] = 22488195
              "1010110000111110001010100" when "11001100", -- t[204] = 22576212
              "1010110011101010101111101" when "11001101", -- t[205] = 22664573
              "1010110110010111111111111" when "11001110", -- t[206] = 22753279
              "1010111001000101111011101" when "11001111", -- t[207] = 22842333
              "1010111011110100100010111" when "11010000", -- t[208] = 22931735
              "1010111110100011110110000" when "11010001", -- t[209] = 23021488
              "1011000001010011110100111" when "11010010", -- t[210] = 23111591
              "1011000100000100011111111" when "11010011", -- t[211] = 23202047
              "1011000110110101110111010" when "11010100", -- t[212] = 23292858
              "1011001001100111111010111" when "11010101", -- t[213] = 23384023
              "1011001100011010101011010" when "11010110", -- t[214] = 23475546
              "1011001111001110001000010" when "11010111", -- t[215] = 23567426
              "1011010010000010010010011" when "11011000", -- t[216] = 23659667
              "1011010100110111001001100" when "11011001", -- t[217] = 23752268
              "1011010111101100101110000" when "11011010", -- t[218] = 23845232
              "1011011010100010111111111" when "11011011", -- t[219] = 23938559
              "1011011101011001111111100" when "11011100", -- t[220] = 24032252
              "1011100000010001101101000" when "11011101", -- t[221] = 24126312
              "1011100011001010001000100" when "11011110", -- t[222] = 24220740
              "1011100110000011010010001" when "11011111", -- t[223] = 24315537
              "1011101000111101001010001" when "11100000", -- t[224] = 24410705
              "1011101011110111110000110" when "11100001", -- t[225] = 24506246
              "1011101110110011000110001" when "11100010", -- t[226] = 24602161
              "1011110001101111001010011" when "11100011", -- t[227] = 24698451
              "1011110100101011111101110" when "11100100", -- t[228] = 24795118
              "1011110111101001100000011" when "11100101", -- t[229] = 24892163
              "1011111010100111110010100" when "11100110", -- t[230] = 24989588
              "1011111101100110110100011" when "11100111", -- t[231] = 25087395
              "1100000000100110100110000" when "11101000", -- t[232] = 25185584
              "1100000011100111000111110" when "11101001", -- t[233] = 25284158
              "1100000110101000011001101" when "11101010", -- t[234] = 25383117
              "1100001001101010011100000" when "11101011", -- t[235] = 25482464
              "1100001100101101001110111" when "11101100", -- t[236] = 25582199
              "1100001111110000110010101" when "11101101", -- t[237] = 25682325
              "1100010010110101000111011" when "11101110", -- t[238] = 25782843
              "1100010101111010001101010" when "11101111", -- t[239] = 25883754
              "1100011001000000000100100" when "11110000", -- t[240] = 25985060
              "1100011100000110101101011" when "11110001", -- t[241] = 26086763
              "1100011111001110001000000" when "11110010", -- t[242] = 26188864
              "1100100010010110010100100" when "11110011", -- t[243] = 26291364
              "1100100101011111010011010" when "11110100", -- t[244] = 26394266
              "1100101000101001000100010" when "11110101", -- t[245] = 26497570
              "1100101011110011100111110" when "11110110", -- t[246] = 26601278
              "1100101110111110111110001" when "11110111", -- t[247] = 26705393
              "1100110010001011000111011" when "11111000", -- t[248] = 26809915
              "1100110101011000000011110" when "11111001", -- t[249] = 26914846
              "1100111000100101110011100" when "11111010", -- t[250] = 27020188
              "1100111011110100010110110" when "11111011", -- t[251] = 27125942
              "1100111111000011101101110" when "11111100", -- t[252] = 27232110
              "1101000010010011111000101" when "11111101", -- t[253] = 27338693
              "1101000101100100110111110" when "11111110", -- t[254] = 27445694
              "1101001000110110101011001" when "11111111", -- t[255] = 27553113
              "-------------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_21 is
  port ( nY1    : in  std_logic_vector(7 downto 0);
         nExpY1 : out std_logic_vector(21+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_21 is
begin

  with nY1 select
    nExpY1 <= "01001101101000101100110000" when "00000000", -- t[0] = 20351792
              "01001101111100001001010110" when "00000001", -- t[1] = 20431446
              "01001110001111101010110101" when "00000010", -- t[2] = 20511413
              "01001110100011010001001100" when "00000011", -- t[3] = 20591692
              "01001110110110111100011110" when "00000100", -- t[4] = 20672286
              "01001111001010101100101011" when "00000101", -- t[5] = 20753195
              "01001111011110100001110101" when "00000110", -- t[6] = 20834421
              "01001111110010011011111100" when "00000111", -- t[7] = 20915964
              "01010000000110011011000011" when "00001000", -- t[8] = 20997827
              "01010000011010011111001010" when "00001001", -- t[9] = 21080010
              "01010000101110101000010011" when "00001010", -- t[10] = 21162515
              "01010001000010110110011111" when "00001011", -- t[11] = 21245343
              "01010001010111001001101111" when "00001100", -- t[12] = 21328495
              "01010001101011100010000100" when "00001101", -- t[13] = 21411972
              "01010001111111111111100000" when "00001110", -- t[14] = 21495776
              "01010010010100100010000100" when "00001111", -- t[15] = 21579908
              "01010010101001001001110010" when "00010000", -- t[16] = 21664370
              "01010010111101110110101010" when "00010001", -- t[17] = 21749162
              "01010011010010101000101101" when "00010010", -- t[18] = 21834285
              "01010011100111011111111110" when "00010011", -- t[19] = 21919742
              "01010011111100011100011110" when "00010100", -- t[20] = 22005534
              "01010100010001011110001101" when "00010101", -- t[21] = 22091661
              "01010100100110100101001101" when "00010110", -- t[22] = 22178125
              "01010100111011110001100000" when "00010111", -- t[23] = 22264928
              "01010101010001000011000110" when "00011000", -- t[24] = 22352070
              "01010101100110011010000010" when "00011001", -- t[25] = 22439554
              "01010101111011110110010100" when "00011010", -- t[26] = 22527380
              "01010110010001010111111110" when "00011011", -- t[27] = 22615550
              "01010110100110111111000000" when "00011100", -- t[28] = 22704064
              "01010110111100101011011110" when "00011101", -- t[29] = 22792926
              "01010111010010011101010111" when "00011110", -- t[30] = 22882135
              "01010111101000010100101101" when "00011111", -- t[31] = 22971693
              "01010111111110010001100001" when "00100000", -- t[32] = 23061601
              "01011000010100010011110110" when "00100001", -- t[33] = 23151862
              "01011000101010011011101100" when "00100010", -- t[34] = 23242476
              "01011001000000101001000100" when "00100011", -- t[35] = 23333444
              "01011001010110111100000001" when "00100100", -- t[36] = 23424769
              "01011001101101010100100011" when "00100101", -- t[37] = 23516451
              "01011010000011110010101011" when "00100110", -- t[38] = 23608491
              "01011010011010010110011101" when "00100111", -- t[39] = 23700893
              "01011010110000111111110111" when "00101000", -- t[40] = 23793655
              "01011011000111101110111101" when "00101001", -- t[41] = 23886781
              "01011011011110100011101111" when "00101010", -- t[42] = 23980271
              "01011011110101011110001111" when "00101011", -- t[43] = 24074127
              "01011100001100011110011111" when "00101100", -- t[44] = 24168351
              "01011100100011100100011111" when "00101101", -- t[45] = 24262943
              "01011100111010110000010001" when "00101110", -- t[46] = 24357905
              "01011101010010000001111000" when "00101111", -- t[47] = 24453240
              "01011101101001011001010011" when "00110000", -- t[48] = 24548947
              "01011110000000110110100101" when "00110001", -- t[49] = 24645029
              "01011110011000011001101111" when "00110010", -- t[50] = 24741487
              "01011110110000000010110010" when "00110011", -- t[51] = 24838322
              "01011111000111110001110001" when "00110100", -- t[52] = 24935537
              "01011111011111100110101011" when "00110101", -- t[53] = 25033131
              "01011111110111100001100100" when "00110110", -- t[54] = 25131108
              "01100000001111100010011101" when "00110111", -- t[55] = 25229469
              "01100000100111101001010110" when "00111000", -- t[56] = 25328214
              "01100000111111110110010010" when "00111001", -- t[57] = 25427346
              "01100001011000001001010010" when "00111010", -- t[58] = 25526866
              "01100001110000100010010111" when "00111011", -- t[59] = 25626775
              "01100010001001000001100011" when "00111100", -- t[60] = 25727075
              "01100010100001100110111000" when "00111101", -- t[61] = 25827768
              "01100010111010010010010111" when "00111110", -- t[62] = 25928855
              "01100011010011000100000010" when "00111111", -- t[63] = 26030338
              "01100011101011111011111010" when "01000000", -- t[64] = 26132218
              "01100100000100111010000001" when "01000001", -- t[65] = 26234497
              "01100100011101111110010111" when "01000010", -- t[66] = 26337175
              "01100100110111001001000000" when "01000011", -- t[67] = 26440256
              "01100101010000011001111100" when "01000100", -- t[68] = 26543740
              "01100101101001110001001110" when "01000101", -- t[69] = 26647630
              "01100110000011001110110110" when "01000110", -- t[70] = 26751926
              "01100110011100110010110110" when "01000111", -- t[71] = 26856630
              "01100110110110011101010000" when "01001000", -- t[72] = 26961744
              "01100111010000001110000101" when "01001001", -- t[73] = 27067269
              "01100111101010000101010111" when "01001010", -- t[74] = 27173207
              "01101000000100000011001000" when "01001011", -- t[75] = 27279560
              "01101000011110000111011001" when "01001100", -- t[76] = 27386329
              "01101000111000010010001100" when "01001101", -- t[77] = 27493516
              "01101001010010100011100011" when "01001110", -- t[78] = 27601123
              "01101001101100111011011111" when "01001111", -- t[79] = 27709151
              "01101010000111011010000001" when "01010000", -- t[80] = 27817601
              "01101010100001111111001100" when "01010001", -- t[81] = 27926476
              "01101010111100101011000001" when "01010010", -- t[82] = 28035777
              "01101011010111011101100010" when "01010011", -- t[83] = 28145506
              "01101011110010010110110001" when "01010100", -- t[84] = 28255665
              "01101100001101010110101110" when "01010101", -- t[85] = 28366254
              "01101100101000011101011101" when "01010110", -- t[86] = 28477277
              "01101101000011101010111101" when "01010111", -- t[87] = 28588733
              "01101101011110111111010011" when "01011000", -- t[88] = 28700627
              "01101101111010011010011110" when "01011001", -- t[89] = 28812958
              "01101110010101111100100000" when "01011010", -- t[90] = 28925728
              "01101110110001100101011101" when "01011011", -- t[91] = 29038941
              "01101111001101010101010100" when "01011100", -- t[92] = 29152596
              "01101111101001001100001000" when "01011101", -- t[93] = 29266696
              "01110000000101001001111010" when "01011110", -- t[94] = 29381242
              "01110000100001001110101101" when "01011111", -- t[95] = 29496237
              "01110000111101011010100010" when "01100000", -- t[96] = 29611682
              "01110001011001101101011011" when "01100001", -- t[97] = 29727579
              "01110001110110000111011010" when "01100010", -- t[98] = 29843930
              "01110010010010101000011111" when "01100011", -- t[99] = 29960735
              "01110010101111010000101110" when "01100100", -- t[100] = 30077998
              "01110011001100000000001000" when "01100101", -- t[101] = 30195720
              "01110011101000110110101111" when "01100110", -- t[102] = 30313903
              "01110100000101110100100100" when "01100111", -- t[103] = 30432548
              "01110100100010111001101010" when "01101000", -- t[104] = 30551658
              "01110101000000000110000010" when "01101001", -- t[105] = 30671234
              "01110101011101011001101110" when "01101010", -- t[106] = 30791278
              "01110101111010110100101111" when "01101011", -- t[107] = 30911791
              "01110110011000010111001001" when "01101100", -- t[108] = 31032777
              "01110110110110000000111011" when "01101101", -- t[109] = 31154235
              "01110111010011110010001010" when "01101110", -- t[110] = 31276170
              "01110111110001101010110101" when "01101111", -- t[111] = 31398581
              "01111000001111101011000000" when "01110000", -- t[112] = 31521472
              "01111000101101110010101011" when "01110001", -- t[113] = 31644843
              "01111001001100000001111010" when "01110010", -- t[114] = 31768698
              "01111001101010011000101101" when "01110011", -- t[115] = 31893037
              "01111010001000110111000111" when "01110100", -- t[116] = 32017863
              "01111010100111011101001001" when "01110101", -- t[117] = 32143177
              "01111011000110001010110110" when "01110110", -- t[118] = 32268982
              "01111011100101000000001111" when "01110111", -- t[119] = 32395279
              "01111100000011111101010111" when "01111000", -- t[120] = 32522071
              "01111100100011000010001110" when "01111001", -- t[121] = 32649358
              "01111101000010001110111000" when "01111010", -- t[122] = 32777144
              "01111101100001100011010111" when "01111011", -- t[123] = 32905431
              "01111110000000111111101011" when "01111100", -- t[124] = 33034219
              "01111110100000100011110111" when "01111101", -- t[125] = 33163511
              "01111111000000001111111101" when "01111110", -- t[126] = 33293309
              "01111111100000000100000000" when "01111111", -- t[127] = 33423616
              "10000000000000000000000000" when "10000000", -- t[128] = 33554432
              "10000000100000000100000000" when "10000001", -- t[129] = 33685760
              "10000001000000010000000011" when "10000010", -- t[130] = 33817603
              "10000001100000100100001001" when "10000011", -- t[131] = 33949961
              "10000010000001000000010101" when "10000100", -- t[132] = 34082837
              "10000010100001100100101010" when "10000101", -- t[133] = 34216234
              "10000011000010010001001000" when "10000110", -- t[134] = 34350152
              "10000011100011000101110011" when "10000111", -- t[135] = 34484595
              "10000100000100000010101100" when "10001000", -- t[136] = 34619564
              "10000100100101000111110101" when "10001001", -- t[137] = 34755061
              "10000101000110010101010001" when "10001010", -- t[138] = 34891089
              "10000101100111101011000000" when "10001011", -- t[139] = 35027648
              "10000110001001001001000111" when "10001100", -- t[140] = 35164743
              "10000110101010101111100110" when "10001101", -- t[141] = 35302374
              "10000111001100011110011111" when "10001110", -- t[142] = 35440543
              "10000111101110010101110110" when "10001111", -- t[143] = 35579254
              "10001000010000010101101011" when "10010000", -- t[144] = 35718507
              "10001000110010011110000001" when "10010001", -- t[145] = 35858305
              "10001001010100101110111011" when "10010010", -- t[146] = 35998651
              "10001001110111001000011001" when "10010011", -- t[147] = 36139545
              "10001010011001101010100000" when "10010100", -- t[148] = 36280992
              "10001010111100010101001111" when "10010101", -- t[149] = 36422991
              "10001011011111001000101011" when "10010110", -- t[150] = 36565547
              "10001100000010000100110100" when "10010111", -- t[151] = 36708660
              "10001100100101001001101110" when "10011000", -- t[152] = 36852334
              "10001101001000010111011010" when "10011001", -- t[153] = 36996570
              "10001101101011101101111010" when "10011010", -- t[154] = 37141370
              "10001110001111001101010010" when "10011011", -- t[155] = 37286738
              "10001110110010110101100010" when "10011100", -- t[156] = 37432674
              "10001111010110100110101101" when "10011101", -- t[157] = 37579181
              "10001111111010100000110110" when "10011110", -- t[158] = 37726262
              "10010000011110100011111110" when "10011111", -- t[159] = 37873918
              "10010001000010110000001001" when "10100000", -- t[160] = 38022153
              "10010001100111000101010111" when "10100001", -- t[161] = 38170967
              "10010010001011100011101100" when "10100010", -- t[162] = 38320364
              "10010010110000001011001010" when "10100011", -- t[163] = 38470346
              "10010011010100111011110010" when "10100100", -- t[164] = 38620914
              "10010011111001110101101000" when "10100101", -- t[165] = 38772072
              "10010100011110111000101110" when "10100110", -- t[166] = 38923822
              "10010101000100000101000110" when "10100111", -- t[167] = 39076166
              "10010101101001011010110001" when "10101000", -- t[168] = 39229105
              "10010110001110111001110100" when "10101001", -- t[169] = 39382644
              "10010110110100100010001111" when "10101010", -- t[170] = 39536783
              "10010111011010010100000110" when "10101011", -- t[171] = 39691526
              "10011000000000001111011010" when "10101100", -- t[172] = 39846874
              "10011000100110010100001110" when "10101101", -- t[173] = 40002830
              "10011001001100100010100101" when "10101110", -- t[174] = 40159397
              "10011001110010111010100000" when "10101111", -- t[175] = 40316576
              "10011010011001011100000011" when "10110000", -- t[176] = 40474371
              "10011011000000000111001111" when "10110001", -- t[177] = 40632783
              "10011011100110111100000111" when "10110010", -- t[178] = 40791815
              "10011100001101111010101110" when "10110011", -- t[179] = 40951470
              "10011100110101000011000101" when "10110100", -- t[180] = 41111749
              "10011101011100010101010000" when "10110101", -- t[181] = 41272656
              "10011110000011110001010001" when "10110110", -- t[182] = 41434193
              "10011110101011010111001010" when "10110111", -- t[183] = 41596362
              "10011111010011000110111101" when "10111000", -- t[184] = 41759165
              "10011111111011000000101110" when "10111001", -- t[185] = 41922606
              "10100000100011000100011111" when "10111010", -- t[186] = 42086687
              "10100001001011010010010001" when "10111011", -- t[187] = 42251409
              "10100001110011101010001000" when "10111100", -- t[188] = 42416776
              "10100010011100001100000111" when "10111101", -- t[189] = 42582791
              "10100011000100111000001111" when "10111110", -- t[190] = 42749455
              "10100011101101101110100100" when "10111111", -- t[191] = 42916772
              "10100100010110101111001000" when "11000000", -- t[192] = 43084744
              "10100100111111111001111100" when "11000001", -- t[193] = 43253372
              "10100101101001001111000101" when "11000010", -- t[194] = 43422661
              "10100110010010101110100101" when "11000011", -- t[195] = 43592613
              "10100110111100011000011110" when "11000100", -- t[196] = 43763230
              "10100111100110001100110010" when "11000101", -- t[197] = 43934514
              "10101000010000001011100101" when "11000110", -- t[198] = 44106469
              "10101000111010010100111001" when "11000111", -- t[199] = 44279097
              "10101001100100101000110000" when "11001000", -- t[200] = 44452400
              "10101010001111000111001110" when "11001001", -- t[201] = 44626382
              "10101010111001110000010101" when "11001010", -- t[202] = 44801045
              "10101011100100100100000111" when "11001011", -- t[203] = 44976391
              "10101100001111100010101000" when "11001100", -- t[204] = 45152424
              "10101100111010101011111001" when "11001101", -- t[205] = 45329145
              "10101101100101111111111110" when "11001110", -- t[206] = 45506558
              "10101110010001011110111010" when "11001111", -- t[207] = 45684666
              "10101110111101001000101111" when "11010000", -- t[208] = 45863471
              "10101111101000111101011111" when "11010001", -- t[209] = 46042975
              "10110000010100111101001110" when "11010010", -- t[210] = 46223182
              "10110001000001000111111111" when "11010011", -- t[211] = 46404095
              "10110001101101011101110011" when "11010100", -- t[212] = 46585715
              "10110010011001111110101111" when "11010101", -- t[213] = 46768047
              "10110011000110101010110100" when "11010110", -- t[214] = 46951092
              "10110011110011100010000101" when "11010111", -- t[215] = 47134853
              "10110100100000100100100110" when "11011000", -- t[216] = 47319334
              "10110101001101110010011000" when "11011001", -- t[217] = 47504536
              "10110101111011001011100000" when "11011010", -- t[218] = 47690464
              "10110110101000101111111111" when "11011011", -- t[219] = 47877119
              "10110111010110011111111001" when "11011100", -- t[220] = 48064505
              "10111000000100011011010000" when "11011101", -- t[221] = 48252624
              "10111000110010100010000111" when "11011110", -- t[222] = 48441479
              "10111001100000110100100010" when "11011111", -- t[223] = 48631074
              "10111010001111010010100010" when "11100000", -- t[224] = 48821410
              "10111010111101111100001100" when "11100001", -- t[225] = 49012492
              "10111011101100110001100010" when "11100010", -- t[226] = 49204322
              "10111100011011110010100110" when "11100011", -- t[227] = 49396902
              "10111101001010111111011100" when "11100100", -- t[228] = 49590236
              "10111101111010011000000111" when "11100101", -- t[229] = 49784327
              "10111110101001111100101001" when "11100110", -- t[230] = 49979177
              "10111111011001101101000110" when "11100111", -- t[231] = 50174790
              "11000000001001101001100000" when "11101000", -- t[232] = 50371168
              "11000000111001110001111100" when "11101001", -- t[233] = 50568316
              "11000001101010000110011010" when "11101010", -- t[234] = 50766234
              "11000010011010100111000000" when "11101011", -- t[235] = 50964928
              "11000011001011010011101111" when "11101100", -- t[236] = 51164399
              "11000011111100001100101011" when "11101101", -- t[237] = 51364651
              "11000100101101010001110110" when "11101110", -- t[238] = 51565686
              "11000101011110100011010101" when "11101111", -- t[239] = 51767509
              "11000110010000000001001001" when "11110000", -- t[240] = 51970121
              "11000111000001101011010110" when "11110001", -- t[241] = 52173526
              "11000111110011100010000000" when "11110010", -- t[242] = 52377728
              "11001000100101100101001000" when "11110011", -- t[243] = 52582728
              "11001001010111110100110011" when "11110100", -- t[244] = 52788531
              "11001010001010010001000100" when "11110101", -- t[245] = 52995140
              "11001010111100111001111101" when "11110110", -- t[246] = 53202557
              "11001011101111101111100010" when "11110111", -- t[247] = 53410786
              "11001100100010110001110110" when "11111000", -- t[248] = 53619830
              "11001101010110000000111100" when "11111001", -- t[249] = 53829692
              "11001110001001011100110111" when "11111010", -- t[250] = 54040375
              "11001110111101000101101011" when "11111011", -- t[251] = 54251883
              "11001111110000111011011011" when "11111100", -- t[252] = 54464219
              "11010000100100111110001010" when "11111101", -- t[253] = 54677386
              "11010001011001001101111011" when "11111110", -- t[254] = 54891387
              "11010010001101101010110010" when "11111111", -- t[255] = 55106226
              "--------------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_22 is
  port ( nY1    : in  std_logic_vector(7 downto 0);
         nExpY1 : out std_logic_vector(22+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_22 is
begin

  with nY1 select
    nExpY1 <= "010011011010001011001100000" when "00000000", -- t[0] = 40703584
              "010011011111000010010101101" when "00000001", -- t[1] = 40862893
              "010011100011111010101101010" when "00000010", -- t[2] = 41022826
              "010011101000110100010011001" when "00000011", -- t[3] = 41183385
              "010011101101101111000111100" when "00000100", -- t[4] = 41344572
              "010011110010101011001010110" when "00000101", -- t[5] = 41506390
              "010011110111101000011101001" when "00000110", -- t[6] = 41668841
              "010011111100100110111111000" when "00000111", -- t[7] = 41831928
              "010100000001100110110000110" when "00001000", -- t[8] = 41995654
              "010100000110100111110010100" when "00001001", -- t[9] = 42160020
              "010100001011101010000100110" when "00001010", -- t[10] = 42325030
              "010100010000101101100111101" when "00001011", -- t[11] = 42490685
              "010100010101110010011011101" when "00001100", -- t[12] = 42656989
              "010100011010111000100001000" when "00001101", -- t[13] = 42823944
              "010100011111111111111000000" when "00001110", -- t[14] = 42991552
              "010100100101001000100001000" when "00001111", -- t[15] = 43159816
              "010100101010010010011100011" when "00010000", -- t[16] = 43328739
              "010100101111011101101010011" when "00010001", -- t[17] = 43498323
              "010100110100101010001011011" when "00010010", -- t[18] = 43668571
              "010100111001110111111111101" when "00010011", -- t[19] = 43839485
              "010100111111000111000111100" when "00010100", -- t[20] = 44011068
              "010101000100010111100011010" when "00010101", -- t[21] = 44183322
              "010101001001101001010011011" when "00010110", -- t[22] = 44356251
              "010101001110111100011000000" when "00010111", -- t[23] = 44529856
              "010101010100010000110001101" when "00011000", -- t[24] = 44704141
              "010101011001100110100000100" when "00011001", -- t[25] = 44879108
              "010101011110111101100101000" when "00011010", -- t[26] = 45054760
              "010101100100010101111111011" when "00011011", -- t[27] = 45231099
              "010101101001101111110000001" when "00011100", -- t[28] = 45408129
              "010101101111001010110111011" when "00011101", -- t[29] = 45585851
              "010101110100100111010101101" when "00011110", -- t[30] = 45764269
              "010101111010000101001011001" when "00011111", -- t[31] = 45943385
              "010101111111100100011000011" when "00100000", -- t[32] = 46123203
              "010110000101000100111101100" when "00100001", -- t[33] = 46303724
              "010110001010100110111011000" when "00100010", -- t[34] = 46484952
              "010110010000001010010001000" when "00100011", -- t[35] = 46666888
              "010110010101101111000000001" when "00100100", -- t[36] = 46849537
              "010110011011010101001000101" when "00100101", -- t[37] = 47032901
              "010110100000111100101010111" when "00100110", -- t[38] = 47216983
              "010110100110100101100111001" when "00100111", -- t[39] = 47401785
              "010110101100001111111101110" when "00101000", -- t[40] = 47587310
              "010110110001111011101111010" when "00101001", -- t[41] = 47773562
              "010110110111101000111011110" when "00101010", -- t[42] = 47960542
              "010110111101010111100011111" when "00101011", -- t[43] = 48148255
              "010111000011000111100111101" when "00101100", -- t[44] = 48336701
              "010111001000111001000111110" when "00101101", -- t[45] = 48525886
              "010111001110101100000100011" when "00101110", -- t[46] = 48715811
              "010111010100100000011101111" when "00101111", -- t[47] = 48906479
              "010111011010010110010100110" when "00110000", -- t[48] = 49097894
              "010111100000001101101001001" when "00110001", -- t[49] = 49290057
              "010111100110000110011011101" when "00110010", -- t[50] = 49482973
              "010111101100000000101100100" when "00110011", -- t[51] = 49676644
              "010111110001111100011100001" when "00110100", -- t[52] = 49871073
              "010111110111111001101010111" when "00110101", -- t[53] = 50066263
              "010111111101111000011001001" when "00110110", -- t[54] = 50262217
              "011000000011111000100111001" when "00110111", -- t[55] = 50458937
              "011000001001111010010101100" when "00111000", -- t[56] = 50656428
              "011000001111111101100100100" when "00111001", -- t[57] = 50854692
              "011000010110000010010100011" when "00111010", -- t[58] = 51053731
              "011000011100001000100101110" when "00111011", -- t[59] = 51253550
              "011000100010010000011000111" when "00111100", -- t[60] = 51454151
              "011000101000011001101110001" when "00111101", -- t[61] = 51655537
              "011000101110100100100101111" when "00111110", -- t[62] = 51857711
              "011000110100110001000000100" when "00111111", -- t[63] = 52060676
              "011000111010111110111110100" when "01000000", -- t[64] = 52264436
              "011001000001001110100000001" when "01000001", -- t[65] = 52468993
              "011001000111011111100101111" when "01000010", -- t[66] = 52674351
              "011001001101110010010000000" when "01000011", -- t[67] = 52880512
              "011001010100000110011111001" when "01000100", -- t[68] = 53087481
              "011001011010011100010011011" when "01000101", -- t[69] = 53295259
              "011001100000110011101101011" when "01000110", -- t[70] = 53503851
              "011001100111001100101101011" when "01000111", -- t[71] = 53713259
              "011001101101100111010011111" when "01001000", -- t[72] = 53923487
              "011001110100000011100001010" when "01001001", -- t[73] = 54134538
              "011001111010100001010101110" when "01001010", -- t[74] = 54346414
              "011010000001000000110010000" when "01001011", -- t[75] = 54559120
              "011010000111100001110110010" when "01001100", -- t[76] = 54772658
              "011010001110000100100011001" when "01001101", -- t[77] = 54987033
              "011010010100101000111000110" when "01001110", -- t[78] = 55202246
              "011010011011001110110111101" when "01001111", -- t[79] = 55418301
              "011010100001110110100000010" when "01010000", -- t[80] = 55635202
              "011010101000011111110011000" when "01010001", -- t[81] = 55852952
              "011010101111001010110000011" when "01010010", -- t[82] = 56071555
              "011010110101110111011000101" when "01010011", -- t[83] = 56291013
              "011010111100100101101100001" when "01010100", -- t[84] = 56511329
              "011011000011010101101011100" when "01010101", -- t[85] = 56732508
              "011011001010000111010111001" when "01010110", -- t[86] = 56954553
              "011011010000111010101111011" when "01010111", -- t[87] = 57177467
              "011011010111101111110100101" when "01011000", -- t[88] = 57401253
              "011011011110100110100111011" when "01011001", -- t[89] = 57625915
              "011011100101011111001000001" when "01011010", -- t[90] = 57851457
              "011011101100011001010111001" when "01011011", -- t[91] = 58077881
              "011011110011010101010100111" when "01011100", -- t[92] = 58305191
              "011011111010010011000010000" when "01011101", -- t[93] = 58533392
              "011100000001010010011110101" when "01011110", -- t[94] = 58762485
              "011100001000010011101011011" when "01011111", -- t[95] = 58992475
              "011100001111010110101000101" when "01100000", -- t[96] = 59223365
              "011100010110011011010110110" when "01100001", -- t[97] = 59455158
              "011100011101100001110110011" when "01100010", -- t[98] = 59687859
              "011100100100101010000111111" when "01100011", -- t[99] = 59921471
              "011100101011110100001011101" when "01100100", -- t[100] = 60155997
              "011100110011000000000010001" when "01100101", -- t[101] = 60391441
              "011100111010001101101011110" when "01100110", -- t[102] = 60627806
              "011101000001011101001001001" when "01100111", -- t[103] = 60865097
              "011101001000101110011010100" when "01101000", -- t[104] = 61103316
              "011101010000000001100000100" when "01101001", -- t[105] = 61342468
              "011101010111010110011011011" when "01101010", -- t[106] = 61582555
              "011101011110101101001011111" when "01101011", -- t[107] = 61823583
              "011101100110000101110010001" when "01101100", -- t[108] = 62065553
              "011101101101100000001110111" when "01101101", -- t[109] = 62308471
              "011101110100111100100010011" when "01101110", -- t[110] = 62552339
              "011101111100011010101101010" when "01101111", -- t[111] = 62797162
              "011110000011111010101111111" when "01110000", -- t[112] = 63042943
              "011110001011011100101010111" when "01110001", -- t[113] = 63289687
              "011110010011000000011110011" when "01110010", -- t[114] = 63537395
              "011110011010100110001011010" when "01110011", -- t[115] = 63786074
              "011110100010001101110001101" when "01110100", -- t[116] = 64035725
              "011110101001110111010010010" when "01110101", -- t[117] = 64286354
              "011110110001100010101101100" when "01110110", -- t[118] = 64537964
              "011110111001010000000011110" when "01110111", -- t[119] = 64790558
              "011111000000111111010101101" when "01111000", -- t[120] = 65044141
              "011111001000110000100011101" when "01111001", -- t[121] = 65298717
              "011111010000100011101110001" when "01111010", -- t[122] = 65554289
              "011111011000011000110101101" when "01111011", -- t[123] = 65810861
              "011111100000001111111010101" when "01111100", -- t[124] = 66068437
              "011111101000001000111101110" when "01111101", -- t[125] = 66327022
              "011111110000000011111111011" when "01111110", -- t[126] = 66586619
              "011111111000000000111111111" when "01111111", -- t[127] = 66847231
              "100000000000000000000000000" when "10000000", -- t[128] = 67108864
              "100000001000000001000000001" when "10000001", -- t[129] = 67371521
              "100000010000000100000000101" when "10000010", -- t[130] = 67635205
              "100000011000001001000010010" when "10000011", -- t[131] = 67899922
              "100000100000010000000101011" when "10000100", -- t[132] = 68165675
              "100000101000011001001010100" when "10000101", -- t[133] = 68432468
              "100000110000100100010010001" when "10000110", -- t[134] = 68700305
              "100000111000110001011100110" when "10000111", -- t[135] = 68969190
              "100001000001000000101011000" when "10001000", -- t[136] = 69239128
              "100001001001010001111101010" when "10001001", -- t[137] = 69510122
              "100001010001100101010100001" when "10001010", -- t[138] = 69782177
              "100001011001111010110000001" when "10001011", -- t[139] = 70055297
              "100001100010010010010001110" when "10001100", -- t[140] = 70329486
              "100001101010101011111001011" when "10001101", -- t[141] = 70604747
              "100001110011000111100111111" when "10001110", -- t[142] = 70881087
              "100001111011100101011101011" when "10001111", -- t[143] = 71158507
              "100010000100000101011010110" when "10010000", -- t[144] = 71437014
              "100010001100100111100000010" when "10010001", -- t[145] = 71716610
              "100010010101001011101110101" when "10010010", -- t[146] = 71997301
              "100010011101110010000110011" when "10010011", -- t[147] = 72279091
              "100010100110011010100111111" when "10010100", -- t[148] = 72561983
              "100010101111000101010011111" when "10010101", -- t[149] = 72845983
              "100010110111110010001010110" when "10010110", -- t[150] = 73131094
              "100011000000100001001101001" when "10010111", -- t[151] = 73417321
              "100011001001010010011011100" when "10011000", -- t[152] = 73704668
              "100011010010000101110110100" when "10011001", -- t[153] = 73993140
              "100011011010111011011110101" when "10011010", -- t[154] = 74282741
              "100011100011110011010100011" when "10011011", -- t[155] = 74573475
              "100011101100101101011000100" when "10011100", -- t[156] = 74865348
              "100011110101101001101011010" when "10011101", -- t[157] = 75158362
              "100011111110101000001101100" when "10011110", -- t[158] = 75452524
              "100100000111101000111111101" when "10011111", -- t[159] = 75747837
              "100100010000101100000010001" when "10100000", -- t[160] = 76044305
              "100100011001110001010101110" when "10100001", -- t[161] = 76341934
              "100100100010111000111011000" when "10100010", -- t[162] = 76640728
              "100100101100000010110010100" when "10100011", -- t[163] = 76940692
              "100100110101001110111100101" when "10100100", -- t[164] = 77241829
              "100100111110011101011010001" when "10100101", -- t[165] = 77544145
              "100101000111101110001011100" when "10100110", -- t[166] = 77847644
              "100101010001000001010001011" when "10100111", -- t[167] = 78152331
              "100101011010010110101100011" when "10101000", -- t[168] = 78458211
              "100101100011101110011101000" when "10101001", -- t[169] = 78765288
              "100101101101001000100011110" when "10101010", -- t[170] = 79073566
              "100101110110100101000001011" when "10101011", -- t[171] = 79383051
              "100110000000000011110110100" when "10101100", -- t[172] = 79693748
              "100110001001100101000011100" when "10101101", -- t[173] = 80005660
              "100110010011001000101001010" when "10101110", -- t[174] = 80318794
              "100110011100101110101000001" when "10101111", -- t[175] = 80633153
              "100110100110010111000000110" when "10110000", -- t[176] = 80948742
              "100110110000000001110011110" when "10110001", -- t[177] = 81265566
              "100110111001101111000001111" when "10110010", -- t[178] = 81583631
              "100111000011011110101011100" when "10110011", -- t[179] = 81902940
              "100111001101010000110001011" when "10110100", -- t[180] = 82223499
              "100111010111000101010100001" when "10110101", -- t[181] = 82545313
              "100111100000111100010100010" when "10110110", -- t[182] = 82868386
              "100111101010110101110010100" when "10110111", -- t[183] = 83192724
              "100111110100110001101111011" when "10111000", -- t[184] = 83518331
              "100111111110110000001011100" when "10111001", -- t[185] = 83845212
              "101000001000110001000111101" when "10111010", -- t[186] = 84173373
              "101000010010110100100100010" when "10111011", -- t[187] = 84502818
              "101000011100111010100010001" when "10111100", -- t[188] = 84833553
              "101000100111000011000001110" when "10111101", -- t[189] = 85165582
              "101000110001001110000011111" when "10111110", -- t[190] = 85498911
              "101000111011011011101001000" when "10111111", -- t[191] = 85833544
              "101001000101101011110001111" when "11000000", -- t[192] = 86169487
              "101001001111111110011111001" when "11000001", -- t[193] = 86506745
              "101001011010010011110001011" when "11000010", -- t[194] = 86845323
              "101001100100101011101001010" when "11000011", -- t[195] = 87185226
              "101001101111000110000111011" when "11000100", -- t[196] = 87526459
              "101001111001100011001100100" when "11000101", -- t[197] = 87869028
              "101010000100000010111001010" when "11000110", -- t[198] = 88212938
              "101010001110100101001110001" when "11000111", -- t[199] = 88558193
              "101010011001001010001100000" when "11001000", -- t[200] = 88904800
              "101010100011110001110011100" when "11001001", -- t[201] = 89252764
              "101010101110011100000101001" when "11001010", -- t[202] = 89602089
              "101010111001001001000001110" when "11001011", -- t[203] = 89952782
              "101011000011111000101001111" when "11001100", -- t[204] = 90304847
              "101011001110101010111110010" when "11001101", -- t[205] = 90658290
              "101011011001011111111111101" when "11001110", -- t[206] = 91013117
              "101011100100010111101110100" when "11001111", -- t[207] = 91369332
              "101011101111010010001011110" when "11010000", -- t[208] = 91726942
              "101011111010001111010111111" when "11010001", -- t[209] = 92085951
              "101100000101001111010011101" when "11010010", -- t[210] = 92446365
              "101100010000010001111111110" when "11010011", -- t[211] = 92808190
              "101100011011010111011100111" when "11010100", -- t[212] = 93171431
              "101100100110011111101011101" when "11010101", -- t[213] = 93536093
              "101100110001101010101100111" when "11010110", -- t[214] = 93902183
              "101100111100111000100001010" when "11010111", -- t[215] = 94269706
              "101101001000001001001001011" when "11011000", -- t[216] = 94638667
              "101101010011011100100110000" when "11011001", -- t[217] = 95009072
              "101101011110110010110111111" when "11011010", -- t[218] = 95380927
              "101101101010001011111111110" when "11011011", -- t[219] = 95754238
              "101101110101100111111110001" when "11011100", -- t[220] = 96129009
              "101110000001000110110100000" when "11011101", -- t[221] = 96505248
              "101110001100101000100001111" when "11011110", -- t[222] = 96882959
              "101110011000001101001000100" when "11011111", -- t[223] = 97262148
              "101110100011110100101000101" when "11100000", -- t[224] = 97642821
              "101110101111011111000011000" when "11100001", -- t[225] = 98024984
              "101110111011001100011000011" when "11100010", -- t[226] = 98408643
              "101111000110111100101001100" when "11100011", -- t[227] = 98793804
              "101111010010101111110111000" when "11100100", -- t[228] = 99180472
              "101111011110100110000001101" when "11100101", -- t[229] = 99568653
              "101111101010011111001010010" when "11100110", -- t[230] = 99958354
              "101111110110011011010001100" when "11100111", -- t[231] = 100349580
              "110000000010011010011000001" when "11101000", -- t[232] = 100742337
              "110000001110011100011110111" when "11101001", -- t[233] = 101136631
              "110000011010100001100110101" when "11101010", -- t[234] = 101532469
              "110000100110101001110000000" when "11101011", -- t[235] = 101929856
              "110000110010110100111011110" when "11101100", -- t[236] = 102328798
              "110000111111000011001010101" when "11101101", -- t[237] = 102729301
              "110001001011010100011101100" when "11101110", -- t[238] = 103131372
              "110001010111101000110101001" when "11101111", -- t[239] = 103535017
              "110001100100000000010010010" when "11110000", -- t[240] = 103940242
              "110001110000011010110101100" when "11110001", -- t[241] = 104347052
              "110001111100111000011111111" when "11110010", -- t[242] = 104755455
              "110010001001011001010010001" when "11110011", -- t[243] = 105165457
              "110010010101111101001100111" when "11110100", -- t[244] = 105577063
              "110010100010100100010000111" when "11110101", -- t[245] = 105990279
              "110010101111001110011111010" when "11110110", -- t[246] = 106405114
              "110010111011111011111000100" when "11110111", -- t[247] = 106821572
              "110011001000101100011101011" when "11111000", -- t[248] = 107239659
              "110011010101100000001110111" when "11111001", -- t[249] = 107659383
              "110011100010010111001101110" when "11111010", -- t[250] = 108080750
              "110011101111010001011010110" when "11111011", -- t[251] = 108503766
              "110011111100001110110110110" when "11111100", -- t[252] = 108928438
              "110100001001001111100010100" when "11111101", -- t[253] = 109354772
              "110100010110010011011110111" when "11111110", -- t[254] = 109782775
              "110100100011011010101100100" when "11111111", -- t[255] = 110212452
              "---------------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y1_23 is
  port ( nY1    : in  std_logic_vector(7 downto 0);
         nExpY1 : out std_logic_vector(23+4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1_23 is
begin

  with nY1 select
    nExpY1 <= "0100110110100010110010111111" when "00000000", -- t[0] = 81407167
              "0100110111110000100101011010" when "00000001", -- t[1] = 81725786
              "0100111000111110101011010011" when "00000010", -- t[2] = 82045651
              "0100111010001101000100110001" when "00000011", -- t[3] = 82366769
              "0100111011011011110001110111" when "00000100", -- t[4] = 82689143
              "0100111100101010110010101100" when "00000101", -- t[5] = 83012780
              "0100111101111010000111010010" when "00000110", -- t[6] = 83337682
              "0100111111001001101111110001" when "00000111", -- t[7] = 83663857
              "0101000000011001101100001100" when "00001000", -- t[8] = 83991308
              "0101000001101001111100101001" when "00001001", -- t[9] = 84320041
              "0101000010111010100001001100" when "00001010", -- t[10] = 84650060
              "0101000100001011011001111011" when "00001011", -- t[11] = 84981371
              "0101000101011100100110111011" when "00001100", -- t[12] = 85313979
              "0101000110101110001000010000" when "00001101", -- t[13] = 85647888
              "0101000111111111111110000000" when "00001110", -- t[14] = 85983104
              "0101001001010010001000010001" when "00001111", -- t[15] = 86319633
              "0101001010100100100111000110" when "00010000", -- t[16] = 86657478
              "0101001011110111011010100110" when "00010001", -- t[17] = 86996646
              "0101001101001010100010110101" when "00010010", -- t[18] = 87337141
              "0101001110011101111111111001" when "00010011", -- t[19] = 87678969
              "0101001111110001110001110111" when "00010100", -- t[20] = 88022135
              "0101010001000101111000110100" when "00010101", -- t[21] = 88366644
              "0101010010011010010100110101" when "00010110", -- t[22] = 88712501
              "0101010011101111000110000000" when "00010111", -- t[23] = 89059712
              "0101010101000100001100011010" when "00011000", -- t[24] = 89408282
              "0101010110011001101000001000" when "00011001", -- t[25] = 89758216
              "0101010111101111011001010000" when "00011010", -- t[26] = 90109520
              "0101011001000101011111110110" when "00011011", -- t[27] = 90462198
              "0101011010011011111100000010" when "00011100", -- t[28] = 90816258
              "0101011011110010101101110110" when "00011101", -- t[29] = 91171702
              "0101011101001001110101011010" when "00011110", -- t[30] = 91528538
              "0101011110100001010010110011" when "00011111", -- t[31] = 91886771
              "0101011111111001000110000101" when "00100000", -- t[32] = 92246405
              "0101100001010001001111011000" when "00100001", -- t[33] = 92607448
              "0101100010101001101110101111" when "00100010", -- t[34] = 92969903
              "0101100100000010100100010001" when "00100011", -- t[35] = 93333777
              "0101100101011011110000000011" when "00100100", -- t[36] = 93699075
              "0101100110110101010010001011" when "00100101", -- t[37] = 94065803
              "0101101000001111001010101110" when "00100110", -- t[38] = 94433966
              "0101101001101001011001110010" when "00100111", -- t[39] = 94803570
              "0101101011000011111111011101" when "00101000", -- t[40] = 95174621
              "0101101100011110111011110100" when "00101001", -- t[41] = 95547124
              "0101101101111010001110111101" when "00101010", -- t[42] = 95921085
              "0101101111010101111000111101" when "00101011", -- t[43] = 96296509
              "0101110000110001111001111011" when "00101100", -- t[44] = 96673403
              "0101110010001110010001111100" when "00101101", -- t[45] = 97051772
              "0101110011101011000001000110" when "00101110", -- t[46] = 97431622
              "0101110101001000000111011110" when "00101111", -- t[47] = 97812958
              "0101110110100101100101001011" when "00110000", -- t[48] = 98195787
              "0101111000000011011010010011" when "00110001", -- t[49] = 98580115
              "0101111001100001100110111011" when "00110010", -- t[50] = 98965947
              "0101111011000000001011001000" when "00110011", -- t[51] = 99353288
              "0101111100011111000111000010" when "00110100", -- t[52] = 99742146
              "0101111101111110011010101110" when "00110101", -- t[53] = 100132526
              "0101111111011110000110010001" when "00110110", -- t[54] = 100524433
              "0110000000111110001001110011" when "00110111", -- t[55] = 100917875
              "0110000010011110100101011000" when "00111000", -- t[56] = 101312856
              "0110000011111111011001001000" when "00111001", -- t[57] = 101709384
              "0110000101100000100101000111" when "00111010", -- t[58] = 102107463
              "0110000111000010001001011100" when "00111011", -- t[59] = 102507100
              "0110001000100100000110001110" when "00111100", -- t[60] = 102908302
              "0110001010000110011011100001" when "00111101", -- t[61] = 103311073
              "0110001011101001001001011110" when "00111110", -- t[62] = 103715422
              "0110001101001100010000001000" when "00111111", -- t[63] = 104121352
              "0110001110101111101111101000" when "01000000", -- t[64] = 104528872
              "0110010000010011101000000010" when "01000001", -- t[65] = 104937986
              "0110010001110111111001011110" when "01000010", -- t[66] = 105348702
              "0110010011011100100100000001" when "01000011", -- t[67] = 105761025
              "0110010101000001100111110010" when "01000100", -- t[68] = 106174962
              "0110010110100111000100110111" when "01000101", -- t[69] = 106590519
              "0110011000001100111011010110" when "01000110", -- t[70] = 107007702
              "0110011001110011001011010111" when "01000111", -- t[71] = 107426519
              "0110011011011001110100111110" when "01001000", -- t[72] = 107846974
              "0110011101000000111000010011" when "01001001", -- t[73] = 108269075
              "0110011110101000010101011101" when "01001010", -- t[74] = 108692829
              "0110100000010000001100100000" when "01001011", -- t[75] = 109118240
              "0110100001111000011101100101" when "01001100", -- t[76] = 109545317
              "0110100011100001001000110001" when "01001101", -- t[77] = 109974065
              "0110100101001010001110001100" when "01001110", -- t[78] = 110404492
              "0110100110110011101101111010" when "01001111", -- t[79] = 110836602
              "0110101000011101101000000101" when "01010000", -- t[80] = 111270405
              "0110101010000111111100110001" when "01010001", -- t[81] = 111705905
              "0110101011110010101100000101" when "01010010", -- t[82] = 112143109
              "0110101101011101110110001001" when "01010011", -- t[83] = 112582025
              "0110101111001001011011000011" when "01010100", -- t[84] = 113022659
              "0110110000110101011010111001" when "01010101", -- t[85] = 113465017
              "0110110010100001110101110010" when "01010110", -- t[86] = 113909106
              "0110110100001110101011110110" when "01010111", -- t[87] = 114354934
              "0110110101111011111101001010" when "01011000", -- t[88] = 114802506
              "0110110111101001101001110111" when "01011001", -- t[89] = 115251831
              "0110111001010111110010000010" when "01011010", -- t[90] = 115702914
              "0110111011000110010101110010" when "01011011", -- t[91] = 116155762
              "0110111100110101010101001111" when "01011100", -- t[92] = 116610383
              "0110111110100100110000011111" when "01011101", -- t[93] = 117066783
              "0111000000010100100111101001" when "01011110", -- t[94] = 117524969
              "0111000010000100111010110101" when "01011111", -- t[95] = 117984949
              "0111000011110101101010001001" when "01100000", -- t[96] = 118446729
              "0111000101100110110101101101" when "01100001", -- t[97] = 118910317
              "0111000111011000011101100110" when "01100010", -- t[98] = 119375718
              "0111001001001010100001111110" when "01100011", -- t[99] = 119842942
              "0111001010111101000010111010" when "01100100", -- t[100] = 120311994
              "0111001100110000000000100010" when "01100101", -- t[101] = 120782882
              "0111001110100011011010111100" when "01100110", -- t[102] = 121255612
              "0111010000010111010010010010" when "01100111", -- t[103] = 121730194
              "0111010010001011100110101000" when "01101000", -- t[104] = 122206632
              "0111010100000000011000000111" when "01101001", -- t[105] = 122684935
              "0111010101110101100110110111" when "01101010", -- t[106] = 123165111
              "0111010111101011010010111101" when "01101011", -- t[107] = 123647165
              "0111011001100001011100100010" when "01101100", -- t[108] = 124131106
              "0111011011011000000011101110" when "01101101", -- t[109] = 124616942
              "0111011101001111001000100111" when "01101110", -- t[110] = 125104679
              "0111011111000110101011010101" when "01101111", -- t[111] = 125594325
              "0111100000111110101011111111" when "01110000", -- t[112] = 126085887
              "0111100010110111001010101101" when "01110001", -- t[113] = 126579373
              "0111100100110000000111100111" when "01110010", -- t[114] = 127074791
              "0111100110101001100010110011" when "01110011", -- t[115] = 127572147
              "0111101000100011011100011011" when "01110100", -- t[116] = 128071451
              "0111101010011101110100100100" when "01110101", -- t[117] = 128572708
              "0111101100011000101011011000" when "01110110", -- t[118] = 129075928
              "0111101110010100000000111100" when "01110111", -- t[119] = 129581116
              "0111110000001111110101011011" when "01111000", -- t[120] = 130088283
              "0111110010001100001000111010" when "01111001", -- t[121] = 130597434
              "0111110100001000111011100010" when "01111010", -- t[122] = 131108578
              "0111110110000110001101011010" when "01111011", -- t[123] = 131621722
              "0111111000000011111110101011" when "01111100", -- t[124] = 132136875
              "0111111010000010001111011100" when "01111101", -- t[125] = 132654044
              "0111111100000000111111110101" when "01111110", -- t[126] = 133173237
              "0111111110000000001111111111" when "01111111", -- t[127] = 133694463
              "1000000000000000000000000000" when "10000000", -- t[128] = 134217728
              "1000000010000000010000000001" when "10000001", -- t[129] = 134743041
              "1000000100000001000000001011" when "10000010", -- t[130] = 135270411
              "1000000110000010010000100100" when "10000011", -- t[131] = 135799844
              "1000001000000100000001010110" when "10000100", -- t[132] = 136331350
              "1000001010000110010010100111" when "10000101", -- t[133] = 136864935
              "1000001100001001000100100010" when "10000110", -- t[134] = 137400610
              "1000001110001100010111001100" when "10000111", -- t[135] = 137938380
              "1000010000010000001010110000" when "10001000", -- t[136] = 138478256
              "1000010010010100011111010101" when "10001001", -- t[137] = 139020245
              "1000010100011001010101000010" when "10001010", -- t[138] = 139564354
              "1000010110011110101100000010" when "10001011", -- t[139] = 140110594
              "1000011000100100100100011011" when "10001100", -- t[140] = 140658971
              "1000011010101010111110010111" when "10001101", -- t[141] = 141209495
              "1000011100110001111001111101" when "10001110", -- t[142] = 141762173
              "1000011110111001010111010111" when "10001111", -- t[143] = 142317015
              "1000100001000001010110101100" when "10010000", -- t[144] = 142874028
              "1000100011001001111000000101" when "10010001", -- t[145] = 143433221
              "1000100101010010111011101011" when "10010010", -- t[146] = 143994603
              "1000100111011100100001100110" when "10010011", -- t[147] = 144558182
              "1000101001100110101001111110" when "10010100", -- t[148] = 145123966
              "1000101011110001010100111101" when "10010101", -- t[149] = 145691965
              "1000101101111100100010101100" when "10010110", -- t[150] = 146262188
              "1000110000001000010011010010" when "10010111", -- t[151] = 146834642
              "1000110010010100100110111000" when "10011000", -- t[152] = 147409336
              "1000110100100001011101101000" when "10011001", -- t[153] = 147986280
              "1000110110101110110111101010" when "10011010", -- t[154] = 148565482
              "1000111000111100110101000111" when "10011011", -- t[155] = 149146951
              "1000111011001011010110000111" when "10011100", -- t[156] = 149730695
              "1000111101011010011010110101" when "10011101", -- t[157] = 150316725
              "1000111111101010000011011000" when "10011110", -- t[158] = 150905048
              "1001000001111010001111111010" when "10011111", -- t[159] = 151495674
              "1001000100001011000000100011" when "10100000", -- t[160] = 152088611
              "1001000110011100010101011101" when "10100001", -- t[161] = 152683869
              "1001001000101110001110110001" when "10100010", -- t[162] = 153281457
              "1001001011000000101100100111" when "10100011", -- t[163] = 153881383
              "1001001101010011101111001010" when "10100100", -- t[164] = 154483658
              "1001001111100111010110100010" when "10100101", -- t[165] = 155088290
              "1001010001111011100010111000" when "10100110", -- t[166] = 155695288
              "1001010100010000010100010110" when "10100111", -- t[167] = 156304662
              "1001010110100101101011000110" when "10101000", -- t[168] = 156916422
              "1001011000111011100111001111" when "10101001", -- t[169] = 157530575
              "1001011011010010001000111100" when "10101010", -- t[170] = 158147132
              "1001011101101001010000010111" when "10101011", -- t[171] = 158766103
              "1001100000000000111101101000" when "10101100", -- t[172] = 159387496
              "1001100010011001010000111001" when "10101101", -- t[173] = 160011321
              "1001100100110010001010010011" when "10101110", -- t[174] = 160637587
              "1001100111001011101010000001" when "10101111", -- t[175] = 161266305
              "1001101001100101110000001100" when "10110000", -- t[176] = 161897484
              "1001101100000000011100111100" when "10110001", -- t[177] = 162531132
              "1001101110011011110000011101" when "10110010", -- t[178] = 163167261
              "1001110000110111101010111000" when "10110011", -- t[179] = 163805880
              "1001110011010100001100010110" when "10110100", -- t[180] = 164446998
              "1001110101110001010101000001" when "10110101", -- t[181] = 165090625
              "1001111000001111000101000100" when "10110110", -- t[182] = 165736772
              "1001111010101101011100100111" when "10110111", -- t[183] = 166385447
              "1001111101001100011011110101" when "10111000", -- t[184] = 167036661
              "1001111111101100000010111000" when "10111001", -- t[185] = 167690424
              "1010000010001100010001111010" when "10111010", -- t[186] = 168346746
              "1010000100101101001001000101" when "10111011", -- t[187] = 169005637
              "1010000111001110101000100010" when "10111100", -- t[188] = 169667106
              "1010001001110000110000011100" when "10111101", -- t[189] = 170331164
              "1010001100010011100000111110" when "10111110", -- t[190] = 170997822
              "1010001110110110111010010000" when "10111111", -- t[191] = 171667088
              "1010010001011010111100011110" when "11000000", -- t[192] = 172338974
              "1010010011111111100111110010" when "11000001", -- t[193] = 173013490
              "1010010110100100111100010101" when "11000010", -- t[194] = 173690645
              "1010011001001010111010010011" when "11000011", -- t[195] = 174370451
              "1010011011110001100001110110" when "11000100", -- t[196] = 175052918
              "1010011110011000110011001000" when "11000101", -- t[197] = 175738056
              "1010100001000000101110010011" when "11000110", -- t[198] = 176425875
              "1010100011101001010011100010" when "11000111", -- t[199] = 177116386
              "1010100110010010100011000000" when "11001000", -- t[200] = 177809600
              "1010101000111100011100111000" when "11001001", -- t[201] = 178505528
              "1010101011100111000001010010" when "11001010", -- t[202] = 179204178
              "1010101110010010010000011100" when "11001011", -- t[203] = 179905564
              "1010110000111110001010011110" when "11001100", -- t[204] = 180609694
              "1010110011101010101111100101" when "11001101", -- t[205] = 181316581
              "1010110110010111111111111010" when "11001110", -- t[206] = 182026234
              "1010111001000101111011101000" when "11001111", -- t[207] = 182738664
              "1010111011110100100010111011" when "11010000", -- t[208] = 183453883
              "1010111110100011110101111101" when "11010001", -- t[209] = 184171901
              "1011000001010011110100111010" when "11010010", -- t[210] = 184892730
              "1011000100000100011111111011" when "11010011", -- t[211] = 185616379
              "1011000110110101110111001101" when "11010100", -- t[212] = 186342861
              "1011001001100111111010111011" when "11010101", -- t[213] = 187072187
              "1011001100011010101011001110" when "11010110", -- t[214] = 187804366
              "1011001111001110001000010100" when "11010111", -- t[215] = 188539412
              "1011010010000010010010010110" when "11011000", -- t[216] = 189277334
              "1011010100110111001001100001" when "11011001", -- t[217] = 190018145
              "1011010111101100101101111111" when "11011010", -- t[218] = 190761855
              "1011011010100010111111111100" when "11011011", -- t[219] = 191508476
              "1011011101011001111111100011" when "11011100", -- t[220] = 192258019
              "1011100000010001101100111111" when "11011101", -- t[221] = 193010495
              "1011100011001010001000011101" when "11011110", -- t[222] = 193765917
              "1011100110000011010010000111" when "11011111", -- t[223] = 194524295
              "1011101000111101001010001010" when "11100000", -- t[224] = 195285642
              "1011101011110111110000110000" when "11100001", -- t[225] = 196049968
              "1011101110110011000110000110" when "11100010", -- t[226] = 196817286
              "1011110001101111001010010111" when "11100011", -- t[227] = 197587607
              "1011110100101011111101101111" when "11100100", -- t[228] = 198360943
              "1011110111101001100000011010" when "11100101", -- t[229] = 199137306
              "1011111010100111110010100011" when "11100110", -- t[230] = 199916707
              "1011111101100110110100010111" when "11100111", -- t[231] = 200699159
              "1100000000100110100110000010" when "11101000", -- t[232] = 201484674
              "1100000011100111000111101110" when "11101001", -- t[233] = 202273262
              "1100000110101000011001101010" when "11101010", -- t[234] = 203064938
              "1100001001101010011011111111" when "11101011", -- t[235] = 203859711
              "1100001100101101001110111100" when "11101100", -- t[236] = 204657596
              "1100001111110000110010101011" when "11101101", -- t[237] = 205458603
              "1100010010110101000111011001" when "11101110", -- t[238] = 206262745
              "1100010101111010001101010011" when "11101111", -- t[239] = 207070035
              "1100011001000000000100100100" when "11110000", -- t[240] = 207880484
              "1100011100000110101101011001" when "11110001", -- t[241] = 208694105
              "1100011111001110000111111111" when "11110010", -- t[242] = 209510911
              "1100100010010110010100100001" when "11110011", -- t[243] = 210330913
              "1100100101011111010011001101" when "11110100", -- t[244] = 211154125
              "1100101000101001000100001111" when "11110101", -- t[245] = 211980559
              "1100101011110011100111110011" when "11110110", -- t[246] = 212810227
              "1100101110111110111110000111" when "11110111", -- t[247] = 213643143
              "1100110010001011000111010111" when "11111000", -- t[248] = 214479319
              "1100110101011000000011101111" when "11111001", -- t[249] = 215318767
              "1100111000100101110011011101" when "11111010", -- t[250] = 216161501
              "1100111011110100010110101101" when "11111011", -- t[251] = 217007533
              "1100111111000011101101101100" when "11111100", -- t[252] = 217856876
              "1101000010010011111000101000" when "11111101", -- t[253] = 218709544
              "1101000101100100110111101101" when "11111110", -- t[254] = 219565549
              "1101001000110110101011001000" when "11111111", -- t[255] = 220424904
              "----------------------------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_fp_exp.all;
use work.pkg_fp_exp_exp_y1.all;

entity fp_exp_exp_y1 is
  generic ( wF : positive );
  port ( nY1    : in  std_logic_vector(fp_exp_wy1(wF)-1 downto 0);
         nExpY1 : out std_logic_vector(wF+fp_exp_g(wF)-1 downto 0) );
end entity;

architecture arch of fp_exp_exp_y1 is
begin

  exp_y1_6 : if wF = 6 generate
    exp_y1 : fp_exp_exp_y1_6
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_7 : if wF = 7 generate
    exp_y1 : fp_exp_exp_y1_7
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_8 : if wF = 8 generate
    exp_y1 : fp_exp_exp_y1_8
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_9 : if wF = 9 generate
    exp_y1 : fp_exp_exp_y1_9
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_10 : if wF = 10 generate
    exp_y1 : fp_exp_exp_y1_10
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_11 : if wF = 11 generate
    exp_y1 : fp_exp_exp_y1_11
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_12 : if wF = 12 generate
    exp_y1 : fp_exp_exp_y1_12
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_13 : if wF = 13 generate
    exp_y1 : fp_exp_exp_y1_13
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_14 : if wF = 14 generate
    exp_y1 : fp_exp_exp_y1_14
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_15 : if wF = 15 generate
    exp_y1 : fp_exp_exp_y1_15
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_16 : if wF = 16 generate
    exp_y1 : fp_exp_exp_y1_16
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_17 : if wF = 17 generate
    exp_y1 : fp_exp_exp_y1_17
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_18 : if wF = 18 generate
    exp_y1 : fp_exp_exp_y1_18
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_19 : if wF = 19 generate
    exp_y1 : fp_exp_exp_y1_19
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_20 : if wF = 20 generate
    exp_y1 : fp_exp_exp_y1_20
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_21 : if wF = 21 generate
    exp_y1 : fp_exp_exp_y1_21
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_22 : if wF = 22 generate
    exp_y1 : fp_exp_exp_y1_22
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

  exp_y1_23 : if wF = 23 generate
    exp_y1 : fp_exp_exp_y1_23
      port map ( nY1    => nY1,
                 nExpY1 => nExpY1 );
  end generate;

end architecture;



-- Copyright 2003-2006 J��r��mie Detrey, Florent de Dinechin
--
-- This file is part of FPLibrary
--
-- FPLibrary is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- FPLibrary is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with FPLibrary; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package pkg_fp_exp_exp_y2 is

  component fp_exp_exp_y2_6 is
    port ( nY2    : in  std_logic_vector(2 downto 0);
           nExpY2 : out std_logic_vector(2 downto 0) );
  end component;

  component fp_exp_exp_y2_7 is
    port ( nY2    : in  std_logic_vector(3 downto 0);
           nExpY2 : out std_logic_vector(3 downto 0) );
  end component;

  component fp_exp_exp_y2_8 is
    port ( nY2    : in  std_logic_vector(4 downto 0);
           nExpY2 : out std_logic_vector(4 downto 0) );
  end component;

  component fp_exp_exp_y2_9 is
    port ( nY2    : in  std_logic_vector(3 downto 0);
           nExpY2 : out std_logic_vector(3 downto 0) );
  end component;

  component fp_exp_exp_y2_10 is
    port ( nY2    : in  std_logic_vector(4 downto 0);
           nExpY2 : out std_logic_vector(4 downto 0) );
  end component;

  component fp_exp_exp_y2_11 is
    port ( nY2    : in  std_logic_vector(5 downto 0);
           nExpY2 : out std_logic_vector(5 downto 0) );
  end component;

  component fp_exp_exp_y2_12 is
    port ( nY2    : in  std_logic_vector(4 downto 0);
           nExpY2 : out std_logic_vector(4 downto 0) );
  end component;

  component fp_exp_exp_y2_13 is
    port ( nY2    : in  std_logic_vector(5 downto 0);
           nExpY2 : out std_logic_vector(5 downto 0) );
  end component;

  component fp_exp_exp_y2_14 is
    port ( nY2    : in  std_logic_vector(6 downto 0);
           nExpY2 : out std_logic_vector(6 downto 0) );
  end component;

  component fp_exp_exp_y2_15 is
    port ( nY2    : in  std_logic_vector(5 downto 0);
           nExpY2 : out std_logic_vector(5 downto 0) );
  end component;

  component fp_exp_exp_y2_16 is
    port ( nY2    : in  std_logic_vector(6 downto 0);
           nExpY2 : out std_logic_vector(6 downto 0) );
  end component;

  component fp_exp_exp_y2_17 is
    port ( nY2    : in  std_logic_vector(7 downto 0);
           nExpY2 : out std_logic_vector(7 downto 0) );
  end component;

  component fp_exp_exp_y2_18 is
    port ( nY2    : in  std_logic_vector(6 downto 0);
           nExpY2 : out std_logic_vector(6 downto 0) );
  end component;

  component fp_exp_exp_y2_19 is
    port ( nY2    : in  std_logic_vector(7 downto 0);
           nExpY2 : out std_logic_vector(7 downto 0) );
  end component;

  component fp_exp_exp_y2_20 is
    port ( x : in  std_logic_vector(8 downto 0);
           r : out std_logic_vector(9 downto 0) );
  end component;

  component fp_exp_exp_y2_20_clk is
    port ( x   : in  std_logic_vector(8 downto 0);
           r   : out std_logic_vector(9 downto 0);
           clk : in  std_logic );
  end component;

  component fp_exp_exp_y2_21 is
    port ( x : in  std_logic_vector(9 downto 0);
           r : out std_logic_vector(10 downto 0) );
  end component;

  component fp_exp_exp_y2_21_clk is
    port ( x   : in  std_logic_vector(9 downto 0);
           r   : out std_logic_vector(10 downto 0);
           clk : in  std_logic );
  end component;

  component fp_exp_exp_y2_22 is
    port ( x : in  std_logic_vector(10 downto 0);
           r : out std_logic_vector(11 downto 0) );
  end component;

  component fp_exp_exp_y2_22_clk is
    port ( x   : in  std_logic_vector(10 downto 0);
           r   : out std_logic_vector(11 downto 0);
           clk : in  std_logic );
  end component;

  component fp_exp_exp_y2_23 is
    port ( x : in  std_logic_vector(11 downto 0);
           r : out std_logic_vector(12 downto 0) );
  end component;

  component fp_exp_exp_y2_23_clk is
    port ( x   : in  std_logic_vector(11 downto 0);
           r   : out std_logic_vector(12 downto 0);
           clk : in  std_logic );
  end component;

end package;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_6 is
  port ( nY2    : in  std_logic_vector(2 downto 0);
         nExpY2 : out std_logic_vector(2 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_6 is
begin

  with nY2 select
    nExpY2 <= "000" when "000", -- t[0] = 0
              "000" when "001", -- t[1] = 0
              "000" when "010", -- t[2] = 0
              "001" when "011", -- t[3] = 1
              "001" when "100", -- t[4] = 1
              "010" when "101", -- t[5] = 2
              "010" when "110", -- t[6] = 2
              "011" when "111", -- t[7] = 3
              "---" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_7 is
  port ( nY2    : in  std_logic_vector(3 downto 0);
         nExpY2 : out std_logic_vector(3 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_7 is
begin

  with nY2 select
    nExpY2 <= "0000" when "0000", -- t[0] = 0
              "0000" when "0001", -- t[1] = 0
              "0000" when "0010", -- t[2] = 0
              "0000" when "0011", -- t[3] = 0
              "0001" when "0100", -- t[4] = 1
              "0001" when "0101", -- t[5] = 1
              "0001" when "0110", -- t[6] = 1
              "0010" when "0111", -- t[7] = 2
              "0010" when "1000", -- t[8] = 2
              "0011" when "1001", -- t[9] = 3
              "0011" when "1010", -- t[10] = 3
              "0100" when "1011", -- t[11] = 4
              "0101" when "1100", -- t[12] = 5
              "0101" when "1101", -- t[13] = 5
              "0110" when "1110", -- t[14] = 6
              "0111" when "1111", -- t[15] = 7
              "----" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_8 is
  port ( nY2    : in  std_logic_vector(4 downto 0);
         nExpY2 : out std_logic_vector(4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_8 is
begin

  with nY2 select
    nExpY2 <= "00000" when "00000", -- t[0] = 0
              "00000" when "00001", -- t[1] = 0
              "00000" when "00010", -- t[2] = 0
              "00000" when "00011", -- t[3] = 0
              "00000" when "00100", -- t[4] = 0
              "00000" when "00101", -- t[5] = 0
              "00001" when "00110", -- t[6] = 1
              "00001" when "00111", -- t[7] = 1
              "00001" when "01000", -- t[8] = 1
              "00001" when "01001", -- t[9] = 1
              "00010" when "01010", -- t[10] = 2
              "00010" when "01011", -- t[11] = 2
              "00010" when "01100", -- t[12] = 2
              "00011" when "01101", -- t[13] = 3
              "00011" when "01110", -- t[14] = 3
              "00100" when "01111", -- t[15] = 4
              "00100" when "10000", -- t[16] = 4
              "00101" when "10001", -- t[17] = 5
              "00101" when "10010", -- t[18] = 5
              "00110" when "10011", -- t[19] = 6
              "00110" when "10100", -- t[20] = 6
              "00111" when "10101", -- t[21] = 7
              "01000" when "10110", -- t[22] = 8
              "01000" when "10111", -- t[23] = 8
              "01001" when "11000", -- t[24] = 9
              "01010" when "11001", -- t[25] = 10
              "01011" when "11010", -- t[26] = 11
              "01100" when "11011", -- t[27] = 12
              "01100" when "11100", -- t[28] = 12
              "01101" when "11101", -- t[29] = 13
              "01110" when "11110", -- t[30] = 14
              "01111" when "11111", -- t[31] = 15
              "-----" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_9 is
  port ( nY2    : in  std_logic_vector(3 downto 0);
         nExpY2 : out std_logic_vector(3 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_9 is
begin

  with nY2 select
    nExpY2 <= "0000" when "0000", -- t[0] = 0
              "0000" when "0001", -- t[1] = 0
              "0000" when "0010", -- t[2] = 0
              "0000" when "0011", -- t[3] = 0
              "0001" when "0100", -- t[4] = 1
              "0001" when "0101", -- t[5] = 1
              "0001" when "0110", -- t[6] = 1
              "0010" when "0111", -- t[7] = 2
              "0010" when "1000", -- t[8] = 2
              "0011" when "1001", -- t[9] = 3
              "0011" when "1010", -- t[10] = 3
              "0100" when "1011", -- t[11] = 4
              "0101" when "1100", -- t[12] = 5
              "0101" when "1101", -- t[13] = 5
              "0110" when "1110", -- t[14] = 6
              "0111" when "1111", -- t[15] = 7
              "----" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_10 is
  port ( nY2    : in  std_logic_vector(4 downto 0);
         nExpY2 : out std_logic_vector(4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_10 is
begin

  with nY2 select
    nExpY2 <= "00000" when "00000", -- t[0] = 0
              "00000" when "00001", -- t[1] = 0
              "00000" when "00010", -- t[2] = 0
              "00000" when "00011", -- t[3] = 0
              "00000" when "00100", -- t[4] = 0
              "00000" when "00101", -- t[5] = 0
              "00001" when "00110", -- t[6] = 1
              "00001" when "00111", -- t[7] = 1
              "00001" when "01000", -- t[8] = 1
              "00001" when "01001", -- t[9] = 1
              "00010" when "01010", -- t[10] = 2
              "00010" when "01011", -- t[11] = 2
              "00010" when "01100", -- t[12] = 2
              "00011" when "01101", -- t[13] = 3
              "00011" when "01110", -- t[14] = 3
              "00100" when "01111", -- t[15] = 4
              "00100" when "10000", -- t[16] = 4
              "00101" when "10001", -- t[17] = 5
              "00101" when "10010", -- t[18] = 5
              "00110" when "10011", -- t[19] = 6
              "00110" when "10100", -- t[20] = 6
              "00111" when "10101", -- t[21] = 7
              "01000" when "10110", -- t[22] = 8
              "01000" when "10111", -- t[23] = 8
              "01001" when "11000", -- t[24] = 9
              "01010" when "11001", -- t[25] = 10
              "01011" when "11010", -- t[26] = 11
              "01011" when "11011", -- t[27] = 11
              "01100" when "11100", -- t[28] = 12
              "01101" when "11101", -- t[29] = 13
              "01110" when "11110", -- t[30] = 14
              "01111" when "11111", -- t[31] = 15
              "-----" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_11 is
  port ( nY2    : in  std_logic_vector(5 downto 0);
         nExpY2 : out std_logic_vector(5 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_11 is
begin

  with nY2 select
    nExpY2 <= "000000" when "000000", -- t[0] = 0
              "000000" when "000001", -- t[1] = 0
              "000000" when "000010", -- t[2] = 0
              "000000" when "000011", -- t[3] = 0
              "000000" when "000100", -- t[4] = 0
              "000000" when "000101", -- t[5] = 0
              "000000" when "000110", -- t[6] = 0
              "000000" when "000111", -- t[7] = 0
              "000001" when "001000", -- t[8] = 1
              "000001" when "001001", -- t[9] = 1
              "000001" when "001010", -- t[10] = 1
              "000001" when "001011", -- t[11] = 1
              "000001" when "001100", -- t[12] = 1
              "000001" when "001101", -- t[13] = 1
              "000010" when "001110", -- t[14] = 2
              "000010" when "001111", -- t[15] = 2
              "000010" when "010000", -- t[16] = 2
              "000010" when "010001", -- t[17] = 2
              "000011" when "010010", -- t[18] = 3
              "000011" when "010011", -- t[19] = 3
              "000011" when "010100", -- t[20] = 3
              "000011" when "010101", -- t[21] = 3
              "000100" when "010110", -- t[22] = 4
              "000100" when "010111", -- t[23] = 4
              "000101" when "011000", -- t[24] = 5
              "000101" when "011001", -- t[25] = 5
              "000101" when "011010", -- t[26] = 5
              "000110" when "011011", -- t[27] = 6
              "000110" when "011100", -- t[28] = 6
              "000111" when "011101", -- t[29] = 7
              "000111" when "011110", -- t[30] = 7
              "001000" when "011111", -- t[31] = 8
              "001000" when "100000", -- t[32] = 8
              "001001" when "100001", -- t[33] = 9
              "001001" when "100010", -- t[34] = 9
              "001010" when "100011", -- t[35] = 10
              "001010" when "100100", -- t[36] = 10
              "001011" when "100101", -- t[37] = 11
              "001011" when "100110", -- t[38] = 11
              "001100" when "100111", -- t[39] = 12
              "001101" when "101000", -- t[40] = 13
              "001101" when "101001", -- t[41] = 13
              "001110" when "101010", -- t[42] = 14
              "001111" when "101011", -- t[43] = 15
              "001111" when "101100", -- t[44] = 15
              "010000" when "101101", -- t[45] = 16
              "010001" when "101110", -- t[46] = 17
              "010001" when "101111", -- t[47] = 17
              "010010" when "110000", -- t[48] = 18
              "010011" when "110001", -- t[49] = 19
              "010100" when "110010", -- t[50] = 20
              "010100" when "110011", -- t[51] = 20
              "010101" when "110100", -- t[52] = 21
              "010110" when "110101", -- t[53] = 22
              "010111" when "110110", -- t[54] = 23
              "011000" when "110111", -- t[55] = 24
              "011001" when "111000", -- t[56] = 25
              "011010" when "111001", -- t[57] = 26
              "011011" when "111010", -- t[58] = 27
              "011011" when "111011", -- t[59] = 27
              "011100" when "111100", -- t[60] = 28
              "011101" when "111101", -- t[61] = 29
              "011110" when "111110", -- t[62] = 30
              "011111" when "111111", -- t[63] = 31
              "------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_12 is
  port ( nY2    : in  std_logic_vector(4 downto 0);
         nExpY2 : out std_logic_vector(4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_12 is
begin

  with nY2 select
    nExpY2 <= "00000" when "00000", -- t[0] = 0
              "00000" when "00001", -- t[1] = 0
              "00000" when "00010", -- t[2] = 0
              "00000" when "00011", -- t[3] = 0
              "00000" when "00100", -- t[4] = 0
              "00000" when "00101", -- t[5] = 0
              "00001" when "00110", -- t[6] = 1
              "00001" when "00111", -- t[7] = 1
              "00001" when "01000", -- t[8] = 1
              "00001" when "01001", -- t[9] = 1
              "00010" when "01010", -- t[10] = 2
              "00010" when "01011", -- t[11] = 2
              "00010" when "01100", -- t[12] = 2
              "00011" when "01101", -- t[13] = 3
              "00011" when "01110", -- t[14] = 3
              "00100" when "01111", -- t[15] = 4
              "00100" when "10000", -- t[16] = 4
              "00101" when "10001", -- t[17] = 5
              "00101" when "10010", -- t[18] = 5
              "00110" when "10011", -- t[19] = 6
              "00110" when "10100", -- t[20] = 6
              "00111" when "10101", -- t[21] = 7
              "01000" when "10110", -- t[22] = 8
              "01000" when "10111", -- t[23] = 8
              "01001" when "11000", -- t[24] = 9
              "01010" when "11001", -- t[25] = 10
              "01011" when "11010", -- t[26] = 11
              "01011" when "11011", -- t[27] = 11
              "01100" when "11100", -- t[28] = 12
              "01101" when "11101", -- t[29] = 13
              "01110" when "11110", -- t[30] = 14
              "01111" when "11111", -- t[31] = 15
              "-----" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_13 is
  port ( nY2    : in  std_logic_vector(5 downto 0);
         nExpY2 : out std_logic_vector(5 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_13 is
begin

  with nY2 select
    nExpY2 <= "000000" when "000000", -- t[0] = 0
              "000000" when "000001", -- t[1] = 0
              "000000" when "000010", -- t[2] = 0
              "000000" when "000011", -- t[3] = 0
              "000000" when "000100", -- t[4] = 0
              "000000" when "000101", -- t[5] = 0
              "000000" when "000110", -- t[6] = 0
              "000000" when "000111", -- t[7] = 0
              "000001" when "001000", -- t[8] = 1
              "000001" when "001001", -- t[9] = 1
              "000001" when "001010", -- t[10] = 1
              "000001" when "001011", -- t[11] = 1
              "000001" when "001100", -- t[12] = 1
              "000001" when "001101", -- t[13] = 1
              "000010" when "001110", -- t[14] = 2
              "000010" when "001111", -- t[15] = 2
              "000010" when "010000", -- t[16] = 2
              "000010" when "010001", -- t[17] = 2
              "000011" when "010010", -- t[18] = 3
              "000011" when "010011", -- t[19] = 3
              "000011" when "010100", -- t[20] = 3
              "000011" when "010101", -- t[21] = 3
              "000100" when "010110", -- t[22] = 4
              "000100" when "010111", -- t[23] = 4
              "000101" when "011000", -- t[24] = 5
              "000101" when "011001", -- t[25] = 5
              "000101" when "011010", -- t[26] = 5
              "000110" when "011011", -- t[27] = 6
              "000110" when "011100", -- t[28] = 6
              "000111" when "011101", -- t[29] = 7
              "000111" when "011110", -- t[30] = 7
              "001000" when "011111", -- t[31] = 8
              "001000" when "100000", -- t[32] = 8
              "001001" when "100001", -- t[33] = 9
              "001001" when "100010", -- t[34] = 9
              "001010" when "100011", -- t[35] = 10
              "001010" when "100100", -- t[36] = 10
              "001011" when "100101", -- t[37] = 11
              "001011" when "100110", -- t[38] = 11
              "001100" when "100111", -- t[39] = 12
              "001101" when "101000", -- t[40] = 13
              "001101" when "101001", -- t[41] = 13
              "001110" when "101010", -- t[42] = 14
              "001110" when "101011", -- t[43] = 14
              "001111" when "101100", -- t[44] = 15
              "010000" when "101101", -- t[45] = 16
              "010001" when "101110", -- t[46] = 17
              "010001" when "101111", -- t[47] = 17
              "010010" when "110000", -- t[48] = 18
              "010011" when "110001", -- t[49] = 19
              "010100" when "110010", -- t[50] = 20
              "010100" when "110011", -- t[51] = 20
              "010101" when "110100", -- t[52] = 21
              "010110" when "110101", -- t[53] = 22
              "010111" when "110110", -- t[54] = 23
              "011000" when "110111", -- t[55] = 24
              "011001" when "111000", -- t[56] = 25
              "011010" when "111001", -- t[57] = 26
              "011010" when "111010", -- t[58] = 26
              "011011" when "111011", -- t[59] = 27
              "011100" when "111100", -- t[60] = 28
              "011101" when "111101", -- t[61] = 29
              "011110" when "111110", -- t[62] = 30
              "011111" when "111111", -- t[63] = 31
              "------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_14 is
  port ( nY2    : in  std_logic_vector(6 downto 0);
         nExpY2 : out std_logic_vector(6 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_14 is
begin

  with nY2 select
    nExpY2 <= "0000000" when "0000000", -- t[0] = 0
              "0000000" when "0000001", -- t[1] = 0
              "0000000" when "0000010", -- t[2] = 0
              "0000000" when "0000011", -- t[3] = 0
              "0000000" when "0000100", -- t[4] = 0
              "0000000" when "0000101", -- t[5] = 0
              "0000000" when "0000110", -- t[6] = 0
              "0000000" when "0000111", -- t[7] = 0
              "0000000" when "0001000", -- t[8] = 0
              "0000000" when "0001001", -- t[9] = 0
              "0000000" when "0001010", -- t[10] = 0
              "0000000" when "0001011", -- t[11] = 0
              "0000001" when "0001100", -- t[12] = 1
              "0000001" when "0001101", -- t[13] = 1
              "0000001" when "0001110", -- t[14] = 1
              "0000001" when "0001111", -- t[15] = 1
              "0000001" when "0010000", -- t[16] = 1
              "0000001" when "0010001", -- t[17] = 1
              "0000001" when "0010010", -- t[18] = 1
              "0000001" when "0010011", -- t[19] = 1
              "0000010" when "0010100", -- t[20] = 2
              "0000010" when "0010101", -- t[21] = 2
              "0000010" when "0010110", -- t[22] = 2
              "0000010" when "0010111", -- t[23] = 2
              "0000010" when "0011000", -- t[24] = 2
              "0000010" when "0011001", -- t[25] = 2
              "0000011" when "0011010", -- t[26] = 3
              "0000011" when "0011011", -- t[27] = 3
              "0000011" when "0011100", -- t[28] = 3
              "0000011" when "0011101", -- t[29] = 3
              "0000100" when "0011110", -- t[30] = 4
              "0000100" when "0011111", -- t[31] = 4
              "0000100" when "0100000", -- t[32] = 4
              "0000100" when "0100001", -- t[33] = 4
              "0000101" when "0100010", -- t[34] = 5
              "0000101" when "0100011", -- t[35] = 5
              "0000101" when "0100100", -- t[36] = 5
              "0000101" when "0100101", -- t[37] = 5
              "0000110" when "0100110", -- t[38] = 6
              "0000110" when "0100111", -- t[39] = 6
              "0000110" when "0101000", -- t[40] = 6
              "0000111" when "0101001", -- t[41] = 7
              "0000111" when "0101010", -- t[42] = 7
              "0000111" when "0101011", -- t[43] = 7
              "0001000" when "0101100", -- t[44] = 8
              "0001000" when "0101101", -- t[45] = 8
              "0001000" when "0101110", -- t[46] = 8
              "0001001" when "0101111", -- t[47] = 9
              "0001001" when "0110000", -- t[48] = 9
              "0001001" when "0110001", -- t[49] = 9
              "0001010" when "0110010", -- t[50] = 10
              "0001010" when "0110011", -- t[51] = 10
              "0001011" when "0110100", -- t[52] = 11
              "0001011" when "0110101", -- t[53] = 11
              "0001011" when "0110110", -- t[54] = 11
              "0001100" when "0110111", -- t[55] = 12
              "0001100" when "0111000", -- t[56] = 12
              "0001101" when "0111001", -- t[57] = 13
              "0001101" when "0111010", -- t[58] = 13
              "0001110" when "0111011", -- t[59] = 14
              "0001110" when "0111100", -- t[60] = 14
              "0001111" when "0111101", -- t[61] = 15
              "0001111" when "0111110", -- t[62] = 15
              "0010000" when "0111111", -- t[63] = 16
              "0010000" when "1000000", -- t[64] = 16
              "0010001" when "1000001", -- t[65] = 17
              "0010001" when "1000010", -- t[66] = 17
              "0010010" when "1000011", -- t[67] = 18
              "0010010" when "1000100", -- t[68] = 18
              "0010011" when "1000101", -- t[69] = 19
              "0010011" when "1000110", -- t[70] = 19
              "0010100" when "1000111", -- t[71] = 20
              "0010100" when "1001000", -- t[72] = 20
              "0010101" when "1001001", -- t[73] = 21
              "0010101" when "1001010", -- t[74] = 21
              "0010110" when "1001011", -- t[75] = 22
              "0010111" when "1001100", -- t[76] = 23
              "0010111" when "1001101", -- t[77] = 23
              "0011000" when "1001110", -- t[78] = 24
              "0011000" when "1001111", -- t[79] = 24
              "0011001" when "1010000", -- t[80] = 25
              "0011010" when "1010001", -- t[81] = 26
              "0011010" when "1010010", -- t[82] = 26
              "0011011" when "1010011", -- t[83] = 27
              "0011100" when "1010100", -- t[84] = 28
              "0011100" when "1010101", -- t[85] = 28
              "0011101" when "1010110", -- t[86] = 29
              "0011110" when "1010111", -- t[87] = 30
              "0011110" when "1011000", -- t[88] = 30
              "0011111" when "1011001", -- t[89] = 31
              "0100000" when "1011010", -- t[90] = 32
              "0100000" when "1011011", -- t[91] = 32
              "0100001" when "1011100", -- t[92] = 33
              "0100010" when "1011101", -- t[93] = 34
              "0100011" when "1011110", -- t[94] = 35
              "0100011" when "1011111", -- t[95] = 35
              "0100100" when "1100000", -- t[96] = 36
              "0100101" when "1100001", -- t[97] = 37
              "0100110" when "1100010", -- t[98] = 38
              "0100110" when "1100011", -- t[99] = 38
              "0100111" when "1100100", -- t[100] = 39
              "0101000" when "1100101", -- t[101] = 40
              "0101001" when "1100110", -- t[102] = 41
              "0101010" when "1100111", -- t[103] = 42
              "0101010" when "1101000", -- t[104] = 42
              "0101011" when "1101001", -- t[105] = 43
              "0101100" when "1101010", -- t[106] = 44
              "0101101" when "1101011", -- t[107] = 45
              "0101110" when "1101100", -- t[108] = 46
              "0101111" when "1101101", -- t[109] = 47
              "0101111" when "1101110", -- t[110] = 47
              "0110000" when "1101111", -- t[111] = 48
              "0110001" when "1110000", -- t[112] = 49
              "0110010" when "1110001", -- t[113] = 50
              "0110011" when "1110010", -- t[114] = 51
              "0110100" when "1110011", -- t[115] = 52
              "0110101" when "1110100", -- t[116] = 53
              "0110110" when "1110101", -- t[117] = 54
              "0110111" when "1110110", -- t[118] = 55
              "0111000" when "1110111", -- t[119] = 56
              "0111001" when "1111000", -- t[120] = 57
              "0111001" when "1111001", -- t[121] = 57
              "0111010" when "1111010", -- t[122] = 58
              "0111011" when "1111011", -- t[123] = 59
              "0111100" when "1111100", -- t[124] = 60
              "0111101" when "1111101", -- t[125] = 61
              "0111110" when "1111110", -- t[126] = 62
              "0111111" when "1111111", -- t[127] = 63
              "-------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_15 is
  port ( nY2    : in  std_logic_vector(5 downto 0);
         nExpY2 : out std_logic_vector(5 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_15 is
begin

  with nY2 select
    nExpY2 <= "000000" when "000000", -- t[0] = 0
              "000000" when "000001", -- t[1] = 0
              "000000" when "000010", -- t[2] = 0
              "000000" when "000011", -- t[3] = 0
              "000000" when "000100", -- t[4] = 0
              "000000" when "000101", -- t[5] = 0
              "000000" when "000110", -- t[6] = 0
              "000000" when "000111", -- t[7] = 0
              "000001" when "001000", -- t[8] = 1
              "000001" when "001001", -- t[9] = 1
              "000001" when "001010", -- t[10] = 1
              "000001" when "001011", -- t[11] = 1
              "000001" when "001100", -- t[12] = 1
              "000001" when "001101", -- t[13] = 1
              "000010" when "001110", -- t[14] = 2
              "000010" when "001111", -- t[15] = 2
              "000010" when "010000", -- t[16] = 2
              "000010" when "010001", -- t[17] = 2
              "000011" when "010010", -- t[18] = 3
              "000011" when "010011", -- t[19] = 3
              "000011" when "010100", -- t[20] = 3
              "000011" when "010101", -- t[21] = 3
              "000100" when "010110", -- t[22] = 4
              "000100" when "010111", -- t[23] = 4
              "000101" when "011000", -- t[24] = 5
              "000101" when "011001", -- t[25] = 5
              "000101" when "011010", -- t[26] = 5
              "000110" when "011011", -- t[27] = 6
              "000110" when "011100", -- t[28] = 6
              "000111" when "011101", -- t[29] = 7
              "000111" when "011110", -- t[30] = 7
              "001000" when "011111", -- t[31] = 8
              "001000" when "100000", -- t[32] = 8
              "001001" when "100001", -- t[33] = 9
              "001001" when "100010", -- t[34] = 9
              "001010" when "100011", -- t[35] = 10
              "001010" when "100100", -- t[36] = 10
              "001011" when "100101", -- t[37] = 11
              "001011" when "100110", -- t[38] = 11
              "001100" when "100111", -- t[39] = 12
              "001101" when "101000", -- t[40] = 13
              "001101" when "101001", -- t[41] = 13
              "001110" when "101010", -- t[42] = 14
              "001110" when "101011", -- t[43] = 14
              "001111" when "101100", -- t[44] = 15
              "010000" when "101101", -- t[45] = 16
              "010001" when "101110", -- t[46] = 17
              "010001" when "101111", -- t[47] = 17
              "010010" when "110000", -- t[48] = 18
              "010011" when "110001", -- t[49] = 19
              "010100" when "110010", -- t[50] = 20
              "010100" when "110011", -- t[51] = 20
              "010101" when "110100", -- t[52] = 21
              "010110" when "110101", -- t[53] = 22
              "010111" when "110110", -- t[54] = 23
              "011000" when "110111", -- t[55] = 24
              "011001" when "111000", -- t[56] = 25
              "011001" when "111001", -- t[57] = 25
              "011010" when "111010", -- t[58] = 26
              "011011" when "111011", -- t[59] = 27
              "011100" when "111100", -- t[60] = 28
              "011101" when "111101", -- t[61] = 29
              "011110" when "111110", -- t[62] = 30
              "011111" when "111111", -- t[63] = 31
              "------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_16 is
  port ( nY2    : in  std_logic_vector(6 downto 0);
         nExpY2 : out std_logic_vector(6 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_16 is
begin

  with nY2 select
    nExpY2 <= "0000000" when "0000000", -- t[0] = 0
              "0000000" when "0000001", -- t[1] = 0
              "0000000" when "0000010", -- t[2] = 0
              "0000000" when "0000011", -- t[3] = 0
              "0000000" when "0000100", -- t[4] = 0
              "0000000" when "0000101", -- t[5] = 0
              "0000000" when "0000110", -- t[6] = 0
              "0000000" when "0000111", -- t[7] = 0
              "0000000" when "0001000", -- t[8] = 0
              "0000000" when "0001001", -- t[9] = 0
              "0000000" when "0001010", -- t[10] = 0
              "0000000" when "0001011", -- t[11] = 0
              "0000001" when "0001100", -- t[12] = 1
              "0000001" when "0001101", -- t[13] = 1
              "0000001" when "0001110", -- t[14] = 1
              "0000001" when "0001111", -- t[15] = 1
              "0000001" when "0010000", -- t[16] = 1
              "0000001" when "0010001", -- t[17] = 1
              "0000001" when "0010010", -- t[18] = 1
              "0000001" when "0010011", -- t[19] = 1
              "0000010" when "0010100", -- t[20] = 2
              "0000010" when "0010101", -- t[21] = 2
              "0000010" when "0010110", -- t[22] = 2
              "0000010" when "0010111", -- t[23] = 2
              "0000010" when "0011000", -- t[24] = 2
              "0000010" when "0011001", -- t[25] = 2
              "0000011" when "0011010", -- t[26] = 3
              "0000011" when "0011011", -- t[27] = 3
              "0000011" when "0011100", -- t[28] = 3
              "0000011" when "0011101", -- t[29] = 3
              "0000100" when "0011110", -- t[30] = 4
              "0000100" when "0011111", -- t[31] = 4
              "0000100" when "0100000", -- t[32] = 4
              "0000100" when "0100001", -- t[33] = 4
              "0000101" when "0100010", -- t[34] = 5
              "0000101" when "0100011", -- t[35] = 5
              "0000101" when "0100100", -- t[36] = 5
              "0000101" when "0100101", -- t[37] = 5
              "0000110" when "0100110", -- t[38] = 6
              "0000110" when "0100111", -- t[39] = 6
              "0000110" when "0101000", -- t[40] = 6
              "0000111" when "0101001", -- t[41] = 7
              "0000111" when "0101010", -- t[42] = 7
              "0000111" when "0101011", -- t[43] = 7
              "0001000" when "0101100", -- t[44] = 8
              "0001000" when "0101101", -- t[45] = 8
              "0001000" when "0101110", -- t[46] = 8
              "0001001" when "0101111", -- t[47] = 9
              "0001001" when "0110000", -- t[48] = 9
              "0001001" when "0110001", -- t[49] = 9
              "0001010" when "0110010", -- t[50] = 10
              "0001010" when "0110011", -- t[51] = 10
              "0001011" when "0110100", -- t[52] = 11
              "0001011" when "0110101", -- t[53] = 11
              "0001011" when "0110110", -- t[54] = 11
              "0001100" when "0110111", -- t[55] = 12
              "0001100" when "0111000", -- t[56] = 12
              "0001101" when "0111001", -- t[57] = 13
              "0001101" when "0111010", -- t[58] = 13
              "0001110" when "0111011", -- t[59] = 14
              "0001110" when "0111100", -- t[60] = 14
              "0001111" when "0111101", -- t[61] = 15
              "0001111" when "0111110", -- t[62] = 15
              "0010000" when "0111111", -- t[63] = 16
              "0010000" when "1000000", -- t[64] = 16
              "0010001" when "1000001", -- t[65] = 17
              "0010001" when "1000010", -- t[66] = 17
              "0010010" when "1000011", -- t[67] = 18
              "0010010" when "1000100", -- t[68] = 18
              "0010011" when "1000101", -- t[69] = 19
              "0010011" when "1000110", -- t[70] = 19
              "0010100" when "1000111", -- t[71] = 20
              "0010100" when "1001000", -- t[72] = 20
              "0010101" when "1001001", -- t[73] = 21
              "0010101" when "1001010", -- t[74] = 21
              "0010110" when "1001011", -- t[75] = 22
              "0010111" when "1001100", -- t[76] = 23
              "0010111" when "1001101", -- t[77] = 23
              "0011000" when "1001110", -- t[78] = 24
              "0011000" when "1001111", -- t[79] = 24
              "0011001" when "1010000", -- t[80] = 25
              "0011010" when "1010001", -- t[81] = 26
              "0011010" when "1010010", -- t[82] = 26
              "0011011" when "1010011", -- t[83] = 27
              "0011100" when "1010100", -- t[84] = 28
              "0011100" when "1010101", -- t[85] = 28
              "0011101" when "1010110", -- t[86] = 29
              "0011110" when "1010111", -- t[87] = 30
              "0011110" when "1011000", -- t[88] = 30
              "0011111" when "1011001", -- t[89] = 31
              "0100000" when "1011010", -- t[90] = 32
              "0100000" when "1011011", -- t[91] = 32
              "0100001" when "1011100", -- t[92] = 33
              "0100010" when "1011101", -- t[93] = 34
              "0100011" when "1011110", -- t[94] = 35
              "0100011" when "1011111", -- t[95] = 35
              "0100100" when "1100000", -- t[96] = 36
              "0100101" when "1100001", -- t[97] = 37
              "0100110" when "1100010", -- t[98] = 38
              "0100110" when "1100011", -- t[99] = 38
              "0100111" when "1100100", -- t[100] = 39
              "0101000" when "1100101", -- t[101] = 40
              "0101001" when "1100110", -- t[102] = 41
              "0101010" when "1100111", -- t[103] = 42
              "0101010" when "1101000", -- t[104] = 42
              "0101011" when "1101001", -- t[105] = 43
              "0101100" when "1101010", -- t[106] = 44
              "0101101" when "1101011", -- t[107] = 45
              "0101110" when "1101100", -- t[108] = 46
              "0101111" when "1101101", -- t[109] = 47
              "0101111" when "1101110", -- t[110] = 47
              "0110000" when "1101111", -- t[111] = 48
              "0110001" when "1110000", -- t[112] = 49
              "0110010" when "1110001", -- t[113] = 50
              "0110011" when "1110010", -- t[114] = 51
              "0110100" when "1110011", -- t[115] = 52
              "0110101" when "1110100", -- t[116] = 53
              "0110110" when "1110101", -- t[117] = 54
              "0110111" when "1110110", -- t[118] = 55
              "0110111" when "1110111", -- t[119] = 55
              "0111000" when "1111000", -- t[120] = 56
              "0111001" when "1111001", -- t[121] = 57
              "0111010" when "1111010", -- t[122] = 58
              "0111011" when "1111011", -- t[123] = 59
              "0111100" when "1111100", -- t[124] = 60
              "0111101" when "1111101", -- t[125] = 61
              "0111110" when "1111110", -- t[126] = 62
              "0111111" when "1111111", -- t[127] = 63
              "-------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_17 is
  port ( nY2    : in  std_logic_vector(7 downto 0);
         nExpY2 : out std_logic_vector(7 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_17 is
begin

  with nY2 select
    nExpY2 <= "00000000" when "00000000", -- t[0] = 0
              "00000000" when "00000001", -- t[1] = 0
              "00000000" when "00000010", -- t[2] = 0
              "00000000" when "00000011", -- t[3] = 0
              "00000000" when "00000100", -- t[4] = 0
              "00000000" when "00000101", -- t[5] = 0
              "00000000" when "00000110", -- t[6] = 0
              "00000000" when "00000111", -- t[7] = 0
              "00000000" when "00001000", -- t[8] = 0
              "00000000" when "00001001", -- t[9] = 0
              "00000000" when "00001010", -- t[10] = 0
              "00000000" when "00001011", -- t[11] = 0
              "00000000" when "00001100", -- t[12] = 0
              "00000000" when "00001101", -- t[13] = 0
              "00000000" when "00001110", -- t[14] = 0
              "00000000" when "00001111", -- t[15] = 0
              "00000001" when "00010000", -- t[16] = 1
              "00000001" when "00010001", -- t[17] = 1
              "00000001" when "00010010", -- t[18] = 1
              "00000001" when "00010011", -- t[19] = 1
              "00000001" when "00010100", -- t[20] = 1
              "00000001" when "00010101", -- t[21] = 1
              "00000001" when "00010110", -- t[22] = 1
              "00000001" when "00010111", -- t[23] = 1
              "00000001" when "00011000", -- t[24] = 1
              "00000001" when "00011001", -- t[25] = 1
              "00000001" when "00011010", -- t[26] = 1
              "00000001" when "00011011", -- t[27] = 1
              "00000010" when "00011100", -- t[28] = 2
              "00000010" when "00011101", -- t[29] = 2
              "00000010" when "00011110", -- t[30] = 2
              "00000010" when "00011111", -- t[31] = 2
              "00000010" when "00100000", -- t[32] = 2
              "00000010" when "00100001", -- t[33] = 2
              "00000010" when "00100010", -- t[34] = 2
              "00000010" when "00100011", -- t[35] = 2
              "00000011" when "00100100", -- t[36] = 3
              "00000011" when "00100101", -- t[37] = 3
              "00000011" when "00100110", -- t[38] = 3
              "00000011" when "00100111", -- t[39] = 3
              "00000011" when "00101000", -- t[40] = 3
              "00000011" when "00101001", -- t[41] = 3
              "00000011" when "00101010", -- t[42] = 3
              "00000100" when "00101011", -- t[43] = 4
              "00000100" when "00101100", -- t[44] = 4
              "00000100" when "00101101", -- t[45] = 4
              "00000100" when "00101110", -- t[46] = 4
              "00000100" when "00101111", -- t[47] = 4
              "00000101" when "00110000", -- t[48] = 5
              "00000101" when "00110001", -- t[49] = 5
              "00000101" when "00110010", -- t[50] = 5
              "00000101" when "00110011", -- t[51] = 5
              "00000101" when "00110100", -- t[52] = 5
              "00000101" when "00110101", -- t[53] = 5
              "00000110" when "00110110", -- t[54] = 6
              "00000110" when "00110111", -- t[55] = 6
              "00000110" when "00111000", -- t[56] = 6
              "00000110" when "00111001", -- t[57] = 6
              "00000111" when "00111010", -- t[58] = 7
              "00000111" when "00111011", -- t[59] = 7
              "00000111" when "00111100", -- t[60] = 7
              "00000111" when "00111101", -- t[61] = 7
              "00001000" when "00111110", -- t[62] = 8
              "00001000" when "00111111", -- t[63] = 8
              "00001000" when "01000000", -- t[64] = 8
              "00001000" when "01000001", -- t[65] = 8
              "00001001" when "01000010", -- t[66] = 9
              "00001001" when "01000011", -- t[67] = 9
              "00001001" when "01000100", -- t[68] = 9
              "00001001" when "01000101", -- t[69] = 9
              "00001010" when "01000110", -- t[70] = 10
              "00001010" when "01000111", -- t[71] = 10
              "00001010" when "01001000", -- t[72] = 10
              "00001010" when "01001001", -- t[73] = 10
              "00001011" when "01001010", -- t[74] = 11
              "00001011" when "01001011", -- t[75] = 11
              "00001011" when "01001100", -- t[76] = 11
              "00001100" when "01001101", -- t[77] = 12
              "00001100" when "01001110", -- t[78] = 12
              "00001100" when "01001111", -- t[79] = 12
              "00001101" when "01010000", -- t[80] = 13
              "00001101" when "01010001", -- t[81] = 13
              "00001101" when "01010010", -- t[82] = 13
              "00001101" when "01010011", -- t[83] = 13
              "00001110" when "01010100", -- t[84] = 14
              "00001110" when "01010101", -- t[85] = 14
              "00001110" when "01010110", -- t[86] = 14
              "00001111" when "01010111", -- t[87] = 15
              "00001111" when "01011000", -- t[88] = 15
              "00001111" when "01011001", -- t[89] = 15
              "00010000" when "01011010", -- t[90] = 16
              "00010000" when "01011011", -- t[91] = 16
              "00010001" when "01011100", -- t[92] = 17
              "00010001" when "01011101", -- t[93] = 17
              "00010001" when "01011110", -- t[94] = 17
              "00010010" when "01011111", -- t[95] = 18
              "00010010" when "01100000", -- t[96] = 18
              "00010010" when "01100001", -- t[97] = 18
              "00010011" when "01100010", -- t[98] = 19
              "00010011" when "01100011", -- t[99] = 19
              "00010100" when "01100100", -- t[100] = 20
              "00010100" when "01100101", -- t[101] = 20
              "00010100" when "01100110", -- t[102] = 20
              "00010101" when "01100111", -- t[103] = 21
              "00010101" when "01101000", -- t[104] = 21
              "00010110" when "01101001", -- t[105] = 22
              "00010110" when "01101010", -- t[106] = 22
              "00010110" when "01101011", -- t[107] = 22
              "00010111" when "01101100", -- t[108] = 23
              "00010111" when "01101101", -- t[109] = 23
              "00011000" when "01101110", -- t[110] = 24
              "00011000" when "01101111", -- t[111] = 24
              "00011001" when "01110000", -- t[112] = 25
              "00011001" when "01110001", -- t[113] = 25
              "00011001" when "01110010", -- t[114] = 25
              "00011010" when "01110011", -- t[115] = 26
              "00011010" when "01110100", -- t[116] = 26
              "00011011" when "01110101", -- t[117] = 27
              "00011011" when "01110110", -- t[118] = 27
              "00011100" when "01110111", -- t[119] = 28
              "00011100" when "01111000", -- t[120] = 28
              "00011101" when "01111001", -- t[121] = 29
              "00011101" when "01111010", -- t[122] = 29
              "00011110" when "01111011", -- t[123] = 30
              "00011110" when "01111100", -- t[124] = 30
              "00011111" when "01111101", -- t[125] = 31
              "00011111" when "01111110", -- t[126] = 31
              "00100000" when "01111111", -- t[127] = 32
              "00100000" when "10000000", -- t[128] = 32
              "00100001" when "10000001", -- t[129] = 33
              "00100001" when "10000010", -- t[130] = 33
              "00100010" when "10000011", -- t[131] = 34
              "00100010" when "10000100", -- t[132] = 34
              "00100011" when "10000101", -- t[133] = 35
              "00100011" when "10000110", -- t[134] = 35
              "00100100" when "10000111", -- t[135] = 36
              "00100100" when "10001000", -- t[136] = 36
              "00100101" when "10001001", -- t[137] = 37
              "00100101" when "10001010", -- t[138] = 37
              "00100110" when "10001011", -- t[139] = 38
              "00100110" when "10001100", -- t[140] = 38
              "00100111" when "10001101", -- t[141] = 39
              "00100111" when "10001110", -- t[142] = 39
              "00101000" when "10001111", -- t[143] = 40
              "00101001" when "10010000", -- t[144] = 41
              "00101001" when "10010001", -- t[145] = 41
              "00101010" when "10010010", -- t[146] = 42
              "00101010" when "10010011", -- t[147] = 42
              "00101011" when "10010100", -- t[148] = 43
              "00101011" when "10010101", -- t[149] = 43
              "00101100" when "10010110", -- t[150] = 44
              "00101101" when "10010111", -- t[151] = 45
              "00101101" when "10011000", -- t[152] = 45
              "00101110" when "10011001", -- t[153] = 46
              "00101110" when "10011010", -- t[154] = 46
              "00101111" when "10011011", -- t[155] = 47
              "00110000" when "10011100", -- t[156] = 48
              "00110000" when "10011101", -- t[157] = 48
              "00110001" when "10011110", -- t[158] = 49
              "00110001" when "10011111", -- t[159] = 49
              "00110010" when "10100000", -- t[160] = 50
              "00110011" when "10100001", -- t[161] = 51
              "00110011" when "10100010", -- t[162] = 51
              "00110100" when "10100011", -- t[163] = 52
              "00110101" when "10100100", -- t[164] = 53
              "00110101" when "10100101", -- t[165] = 53
              "00110110" when "10100110", -- t[166] = 54
              "00110111" when "10100111", -- t[167] = 55
              "00110111" when "10101000", -- t[168] = 55
              "00111000" when "10101001", -- t[169] = 56
              "00111001" when "10101010", -- t[170] = 57
              "00111001" when "10101011", -- t[171] = 57
              "00111010" when "10101100", -- t[172] = 58
              "00111011" when "10101101", -- t[173] = 59
              "00111011" when "10101110", -- t[174] = 59
              "00111100" when "10101111", -- t[175] = 60
              "00111101" when "10110000", -- t[176] = 61
              "00111101" when "10110001", -- t[177] = 61
              "00111110" when "10110010", -- t[178] = 62
              "00111111" when "10110011", -- t[179] = 63
              "00111111" when "10110100", -- t[180] = 63
              "01000000" when "10110101", -- t[181] = 64
              "01000001" when "10110110", -- t[182] = 65
              "01000010" when "10110111", -- t[183] = 66
              "01000010" when "10111000", -- t[184] = 66
              "01000011" when "10111001", -- t[185] = 67
              "01000100" when "10111010", -- t[186] = 68
              "01000100" when "10111011", -- t[187] = 68
              "01000101" when "10111100", -- t[188] = 69
              "01000110" when "10111101", -- t[189] = 70
              "01000111" when "10111110", -- t[190] = 71
              "01000111" when "10111111", -- t[191] = 71
              "01001000" when "11000000", -- t[192] = 72
              "01001001" when "11000001", -- t[193] = 73
              "01001010" when "11000010", -- t[194] = 74
              "01001010" when "11000011", -- t[195] = 74
              "01001011" when "11000100", -- t[196] = 75
              "01001100" when "11000101", -- t[197] = 76
              "01001101" when "11000110", -- t[198] = 77
              "01001110" when "11000111", -- t[199] = 78
              "01001110" when "11001000", -- t[200] = 78
              "01001111" when "11001001", -- t[201] = 79
              "01010000" when "11001010", -- t[202] = 80
              "01010001" when "11001011", -- t[203] = 81
              "01010001" when "11001100", -- t[204] = 81
              "01010010" when "11001101", -- t[205] = 82
              "01010011" when "11001110", -- t[206] = 83
              "01010100" when "11001111", -- t[207] = 84
              "01010101" when "11010000", -- t[208] = 85
              "01010101" when "11010001", -- t[209] = 85
              "01010110" when "11010010", -- t[210] = 86
              "01010111" when "11010011", -- t[211] = 87
              "01011000" when "11010100", -- t[212] = 88
              "01011001" when "11010101", -- t[213] = 89
              "01011010" when "11010110", -- t[214] = 90
              "01011010" when "11010111", -- t[215] = 90
              "01011011" when "11011000", -- t[216] = 91
              "01011100" when "11011001", -- t[217] = 92
              "01011101" when "11011010", -- t[218] = 93
              "01011110" when "11011011", -- t[219] = 94
              "01011111" when "11011100", -- t[220] = 95
              "01100000" when "11011101", -- t[221] = 96
              "01100000" when "11011110", -- t[222] = 96
              "01100001" when "11011111", -- t[223] = 97
              "01100010" when "11100000", -- t[224] = 98
              "01100011" when "11100001", -- t[225] = 99
              "01100100" when "11100010", -- t[226] = 100
              "01100101" when "11100011", -- t[227] = 101
              "01100110" when "11100100", -- t[228] = 102
              "01100111" when "11100101", -- t[229] = 103
              "01101000" when "11100110", -- t[230] = 104
              "01101000" when "11100111", -- t[231] = 104
              "01101001" when "11101000", -- t[232] = 105
              "01101010" when "11101001", -- t[233] = 106
              "01101011" when "11101010", -- t[234] = 107
              "01101100" when "11101011", -- t[235] = 108
              "01101101" when "11101100", -- t[236] = 109
              "01101110" when "11101101", -- t[237] = 110
              "01101111" when "11101110", -- t[238] = 111
              "01110000" when "11101111", -- t[239] = 112
              "01110001" when "11110000", -- t[240] = 113
              "01110010" when "11110001", -- t[241] = 114
              "01110011" when "11110010", -- t[242] = 115
              "01110100" when "11110011", -- t[243] = 116
              "01110101" when "11110100", -- t[244] = 117
              "01110110" when "11110101", -- t[245] = 118
              "01110110" when "11110110", -- t[246] = 118
              "01110111" when "11110111", -- t[247] = 119
              "01111000" when "11111000", -- t[248] = 120
              "01111001" when "11111001", -- t[249] = 121
              "01111010" when "11111010", -- t[250] = 122
              "01111011" when "11111011", -- t[251] = 123
              "01111100" when "11111100", -- t[252] = 124
              "01111101" when "11111101", -- t[253] = 125
              "01111110" when "11111110", -- t[254] = 126
              "01111111" when "11111111", -- t[255] = 127
              "--------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_18 is
  port ( nY2    : in  std_logic_vector(6 downto 0);
         nExpY2 : out std_logic_vector(6 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_18 is
begin

  with nY2 select
    nExpY2 <= "0000000" when "0000000", -- t[0] = 0
              "0000000" when "0000001", -- t[1] = 0
              "0000000" when "0000010", -- t[2] = 0
              "0000000" when "0000011", -- t[3] = 0
              "0000000" when "0000100", -- t[4] = 0
              "0000000" when "0000101", -- t[5] = 0
              "0000000" when "0000110", -- t[6] = 0
              "0000000" when "0000111", -- t[7] = 0
              "0000000" when "0001000", -- t[8] = 0
              "0000000" when "0001001", -- t[9] = 0
              "0000000" when "0001010", -- t[10] = 0
              "0000000" when "0001011", -- t[11] = 0
              "0000001" when "0001100", -- t[12] = 1
              "0000001" when "0001101", -- t[13] = 1
              "0000001" when "0001110", -- t[14] = 1
              "0000001" when "0001111", -- t[15] = 1
              "0000001" when "0010000", -- t[16] = 1
              "0000001" when "0010001", -- t[17] = 1
              "0000001" when "0010010", -- t[18] = 1
              "0000001" when "0010011", -- t[19] = 1
              "0000010" when "0010100", -- t[20] = 2
              "0000010" when "0010101", -- t[21] = 2
              "0000010" when "0010110", -- t[22] = 2
              "0000010" when "0010111", -- t[23] = 2
              "0000010" when "0011000", -- t[24] = 2
              "0000010" when "0011001", -- t[25] = 2
              "0000011" when "0011010", -- t[26] = 3
              "0000011" when "0011011", -- t[27] = 3
              "0000011" when "0011100", -- t[28] = 3
              "0000011" when "0011101", -- t[29] = 3
              "0000100" when "0011110", -- t[30] = 4
              "0000100" when "0011111", -- t[31] = 4
              "0000100" when "0100000", -- t[32] = 4
              "0000100" when "0100001", -- t[33] = 4
              "0000101" when "0100010", -- t[34] = 5
              "0000101" when "0100011", -- t[35] = 5
              "0000101" when "0100100", -- t[36] = 5
              "0000101" when "0100101", -- t[37] = 5
              "0000110" when "0100110", -- t[38] = 6
              "0000110" when "0100111", -- t[39] = 6
              "0000110" when "0101000", -- t[40] = 6
              "0000111" when "0101001", -- t[41] = 7
              "0000111" when "0101010", -- t[42] = 7
              "0000111" when "0101011", -- t[43] = 7
              "0001000" when "0101100", -- t[44] = 8
              "0001000" when "0101101", -- t[45] = 8
              "0001000" when "0101110", -- t[46] = 8
              "0001001" when "0101111", -- t[47] = 9
              "0001001" when "0110000", -- t[48] = 9
              "0001001" when "0110001", -- t[49] = 9
              "0001010" when "0110010", -- t[50] = 10
              "0001010" when "0110011", -- t[51] = 10
              "0001011" when "0110100", -- t[52] = 11
              "0001011" when "0110101", -- t[53] = 11
              "0001011" when "0110110", -- t[54] = 11
              "0001100" when "0110111", -- t[55] = 12
              "0001100" when "0111000", -- t[56] = 12
              "0001101" when "0111001", -- t[57] = 13
              "0001101" when "0111010", -- t[58] = 13
              "0001110" when "0111011", -- t[59] = 14
              "0001110" when "0111100", -- t[60] = 14
              "0001111" when "0111101", -- t[61] = 15
              "0001111" when "0111110", -- t[62] = 15
              "0010000" when "0111111", -- t[63] = 16
              "0010000" when "1000000", -- t[64] = 16
              "0010001" when "1000001", -- t[65] = 17
              "0010001" when "1000010", -- t[66] = 17
              "0010010" when "1000011", -- t[67] = 18
              "0010010" when "1000100", -- t[68] = 18
              "0010011" when "1000101", -- t[69] = 19
              "0010011" when "1000110", -- t[70] = 19
              "0010100" when "1000111", -- t[71] = 20
              "0010100" when "1001000", -- t[72] = 20
              "0010101" when "1001001", -- t[73] = 21
              "0010101" when "1001010", -- t[74] = 21
              "0010110" when "1001011", -- t[75] = 22
              "0010111" when "1001100", -- t[76] = 23
              "0010111" when "1001101", -- t[77] = 23
              "0011000" when "1001110", -- t[78] = 24
              "0011000" when "1001111", -- t[79] = 24
              "0011001" when "1010000", -- t[80] = 25
              "0011010" when "1010001", -- t[81] = 26
              "0011010" when "1010010", -- t[82] = 26
              "0011011" when "1010011", -- t[83] = 27
              "0011100" when "1010100", -- t[84] = 28
              "0011100" when "1010101", -- t[85] = 28
              "0011101" when "1010110", -- t[86] = 29
              "0011110" when "1010111", -- t[87] = 30
              "0011110" when "1011000", -- t[88] = 30
              "0011111" when "1011001", -- t[89] = 31
              "0100000" when "1011010", -- t[90] = 32
              "0100000" when "1011011", -- t[91] = 32
              "0100001" when "1011100", -- t[92] = 33
              "0100010" when "1011101", -- t[93] = 34
              "0100011" when "1011110", -- t[94] = 35
              "0100011" when "1011111", -- t[95] = 35
              "0100100" when "1100000", -- t[96] = 36
              "0100101" when "1100001", -- t[97] = 37
              "0100110" when "1100010", -- t[98] = 38
              "0100110" when "1100011", -- t[99] = 38
              "0100111" when "1100100", -- t[100] = 39
              "0101000" when "1100101", -- t[101] = 40
              "0101001" when "1100110", -- t[102] = 41
              "0101001" when "1100111", -- t[103] = 41
              "0101010" when "1101000", -- t[104] = 42
              "0101011" when "1101001", -- t[105] = 43
              "0101100" when "1101010", -- t[106] = 44
              "0101101" when "1101011", -- t[107] = 45
              "0101110" when "1101100", -- t[108] = 46
              "0101110" when "1101101", -- t[109] = 46
              "0101111" when "1101110", -- t[110] = 47
              "0110000" when "1101111", -- t[111] = 48
              "0110001" when "1110000", -- t[112] = 49
              "0110010" when "1110001", -- t[113] = 50
              "0110011" when "1110010", -- t[114] = 51
              "0110100" when "1110011", -- t[115] = 52
              "0110101" when "1110100", -- t[116] = 53
              "0110110" when "1110101", -- t[117] = 54
              "0110110" when "1110110", -- t[118] = 54
              "0110111" when "1110111", -- t[119] = 55
              "0111000" when "1111000", -- t[120] = 56
              "0111001" when "1111001", -- t[121] = 57
              "0111010" when "1111010", -- t[122] = 58
              "0111011" when "1111011", -- t[123] = 59
              "0111100" when "1111100", -- t[124] = 60
              "0111101" when "1111101", -- t[125] = 61
              "0111110" when "1111110", -- t[126] = 62
              "0111111" when "1111111", -- t[127] = 63
              "-------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_19 is
  port ( nY2    : in  std_logic_vector(7 downto 0);
         nExpY2 : out std_logic_vector(7 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_19 is
begin

  with nY2 select
    nExpY2 <= "00000000" when "00000000", -- t[0] = 0
              "00000000" when "00000001", -- t[1] = 0
              "00000000" when "00000010", -- t[2] = 0
              "00000000" when "00000011", -- t[3] = 0
              "00000000" when "00000100", -- t[4] = 0
              "00000000" when "00000101", -- t[5] = 0
              "00000000" when "00000110", -- t[6] = 0
              "00000000" when "00000111", -- t[7] = 0
              "00000000" when "00001000", -- t[8] = 0
              "00000000" when "00001001", -- t[9] = 0
              "00000000" when "00001010", -- t[10] = 0
              "00000000" when "00001011", -- t[11] = 0
              "00000000" when "00001100", -- t[12] = 0
              "00000000" when "00001101", -- t[13] = 0
              "00000000" when "00001110", -- t[14] = 0
              "00000000" when "00001111", -- t[15] = 0
              "00000001" when "00010000", -- t[16] = 1
              "00000001" when "00010001", -- t[17] = 1
              "00000001" when "00010010", -- t[18] = 1
              "00000001" when "00010011", -- t[19] = 1
              "00000001" when "00010100", -- t[20] = 1
              "00000001" when "00010101", -- t[21] = 1
              "00000001" when "00010110", -- t[22] = 1
              "00000001" when "00010111", -- t[23] = 1
              "00000001" when "00011000", -- t[24] = 1
              "00000001" when "00011001", -- t[25] = 1
              "00000001" when "00011010", -- t[26] = 1
              "00000001" when "00011011", -- t[27] = 1
              "00000010" when "00011100", -- t[28] = 2
              "00000010" when "00011101", -- t[29] = 2
              "00000010" when "00011110", -- t[30] = 2
              "00000010" when "00011111", -- t[31] = 2
              "00000010" when "00100000", -- t[32] = 2
              "00000010" when "00100001", -- t[33] = 2
              "00000010" when "00100010", -- t[34] = 2
              "00000010" when "00100011", -- t[35] = 2
              "00000011" when "00100100", -- t[36] = 3
              "00000011" when "00100101", -- t[37] = 3
              "00000011" when "00100110", -- t[38] = 3
              "00000011" when "00100111", -- t[39] = 3
              "00000011" when "00101000", -- t[40] = 3
              "00000011" when "00101001", -- t[41] = 3
              "00000011" when "00101010", -- t[42] = 3
              "00000100" when "00101011", -- t[43] = 4
              "00000100" when "00101100", -- t[44] = 4
              "00000100" when "00101101", -- t[45] = 4
              "00000100" when "00101110", -- t[46] = 4
              "00000100" when "00101111", -- t[47] = 4
              "00000101" when "00110000", -- t[48] = 5
              "00000101" when "00110001", -- t[49] = 5
              "00000101" when "00110010", -- t[50] = 5
              "00000101" when "00110011", -- t[51] = 5
              "00000101" when "00110100", -- t[52] = 5
              "00000101" when "00110101", -- t[53] = 5
              "00000110" when "00110110", -- t[54] = 6
              "00000110" when "00110111", -- t[55] = 6
              "00000110" when "00111000", -- t[56] = 6
              "00000110" when "00111001", -- t[57] = 6
              "00000111" when "00111010", -- t[58] = 7
              "00000111" when "00111011", -- t[59] = 7
              "00000111" when "00111100", -- t[60] = 7
              "00000111" when "00111101", -- t[61] = 7
              "00001000" when "00111110", -- t[62] = 8
              "00001000" when "00111111", -- t[63] = 8
              "00001000" when "01000000", -- t[64] = 8
              "00001000" when "01000001", -- t[65] = 8
              "00001001" when "01000010", -- t[66] = 9
              "00001001" when "01000011", -- t[67] = 9
              "00001001" when "01000100", -- t[68] = 9
              "00001001" when "01000101", -- t[69] = 9
              "00001010" when "01000110", -- t[70] = 10
              "00001010" when "01000111", -- t[71] = 10
              "00001010" when "01001000", -- t[72] = 10
              "00001010" when "01001001", -- t[73] = 10
              "00001011" when "01001010", -- t[74] = 11
              "00001011" when "01001011", -- t[75] = 11
              "00001011" when "01001100", -- t[76] = 11
              "00001100" when "01001101", -- t[77] = 12
              "00001100" when "01001110", -- t[78] = 12
              "00001100" when "01001111", -- t[79] = 12
              "00001101" when "01010000", -- t[80] = 13
              "00001101" when "01010001", -- t[81] = 13
              "00001101" when "01010010", -- t[82] = 13
              "00001101" when "01010011", -- t[83] = 13
              "00001110" when "01010100", -- t[84] = 14
              "00001110" when "01010101", -- t[85] = 14
              "00001110" when "01010110", -- t[86] = 14
              "00001111" when "01010111", -- t[87] = 15
              "00001111" when "01011000", -- t[88] = 15
              "00001111" when "01011001", -- t[89] = 15
              "00010000" when "01011010", -- t[90] = 16
              "00010000" when "01011011", -- t[91] = 16
              "00010001" when "01011100", -- t[92] = 17
              "00010001" when "01011101", -- t[93] = 17
              "00010001" when "01011110", -- t[94] = 17
              "00010010" when "01011111", -- t[95] = 18
              "00010010" when "01100000", -- t[96] = 18
              "00010010" when "01100001", -- t[97] = 18
              "00010011" when "01100010", -- t[98] = 19
              "00010011" when "01100011", -- t[99] = 19
              "00010100" when "01100100", -- t[100] = 20
              "00010100" when "01100101", -- t[101] = 20
              "00010100" when "01100110", -- t[102] = 20
              "00010101" when "01100111", -- t[103] = 21
              "00010101" when "01101000", -- t[104] = 21
              "00010110" when "01101001", -- t[105] = 22
              "00010110" when "01101010", -- t[106] = 22
              "00010110" when "01101011", -- t[107] = 22
              "00010111" when "01101100", -- t[108] = 23
              "00010111" when "01101101", -- t[109] = 23
              "00011000" when "01101110", -- t[110] = 24
              "00011000" when "01101111", -- t[111] = 24
              "00011001" when "01110000", -- t[112] = 25
              "00011001" when "01110001", -- t[113] = 25
              "00011001" when "01110010", -- t[114] = 25
              "00011010" when "01110011", -- t[115] = 26
              "00011010" when "01110100", -- t[116] = 26
              "00011011" when "01110101", -- t[117] = 27
              "00011011" when "01110110", -- t[118] = 27
              "00011100" when "01110111", -- t[119] = 28
              "00011100" when "01111000", -- t[120] = 28
              "00011101" when "01111001", -- t[121] = 29
              "00011101" when "01111010", -- t[122] = 29
              "00011110" when "01111011", -- t[123] = 30
              "00011110" when "01111100", -- t[124] = 30
              "00011111" when "01111101", -- t[125] = 31
              "00011111" when "01111110", -- t[126] = 31
              "00100000" when "01111111", -- t[127] = 32
              "00100000" when "10000000", -- t[128] = 32
              "00100001" when "10000001", -- t[129] = 33
              "00100001" when "10000010", -- t[130] = 33
              "00100010" when "10000011", -- t[131] = 34
              "00100010" when "10000100", -- t[132] = 34
              "00100011" when "10000101", -- t[133] = 35
              "00100011" when "10000110", -- t[134] = 35
              "00100100" when "10000111", -- t[135] = 36
              "00100100" when "10001000", -- t[136] = 36
              "00100101" when "10001001", -- t[137] = 37
              "00100101" when "10001010", -- t[138] = 37
              "00100110" when "10001011", -- t[139] = 38
              "00100110" when "10001100", -- t[140] = 38
              "00100111" when "10001101", -- t[141] = 39
              "00100111" when "10001110", -- t[142] = 39
              "00101000" when "10001111", -- t[143] = 40
              "00101001" when "10010000", -- t[144] = 41
              "00101001" when "10010001", -- t[145] = 41
              "00101010" when "10010010", -- t[146] = 42
              "00101010" when "10010011", -- t[147] = 42
              "00101011" when "10010100", -- t[148] = 43
              "00101011" when "10010101", -- t[149] = 43
              "00101100" when "10010110", -- t[150] = 44
              "00101101" when "10010111", -- t[151] = 45
              "00101101" when "10011000", -- t[152] = 45
              "00101110" when "10011001", -- t[153] = 46
              "00101110" when "10011010", -- t[154] = 46
              "00101111" when "10011011", -- t[155] = 47
              "00110000" when "10011100", -- t[156] = 48
              "00110000" when "10011101", -- t[157] = 48
              "00110001" when "10011110", -- t[158] = 49
              "00110001" when "10011111", -- t[159] = 49
              "00110010" when "10100000", -- t[160] = 50
              "00110011" when "10100001", -- t[161] = 51
              "00110011" when "10100010", -- t[162] = 51
              "00110100" when "10100011", -- t[163] = 52
              "00110101" when "10100100", -- t[164] = 53
              "00110101" when "10100101", -- t[165] = 53
              "00110110" when "10100110", -- t[166] = 54
              "00110111" when "10100111", -- t[167] = 55
              "00110111" when "10101000", -- t[168] = 55
              "00111000" when "10101001", -- t[169] = 56
              "00111000" when "10101010", -- t[170] = 56
              "00111001" when "10101011", -- t[171] = 57
              "00111010" when "10101100", -- t[172] = 58
              "00111011" when "10101101", -- t[173] = 59
              "00111011" when "10101110", -- t[174] = 59
              "00111100" when "10101111", -- t[175] = 60
              "00111101" when "10110000", -- t[176] = 61
              "00111101" when "10110001", -- t[177] = 61
              "00111110" when "10110010", -- t[178] = 62
              "00111111" when "10110011", -- t[179] = 63
              "00111111" when "10110100", -- t[180] = 63
              "01000000" when "10110101", -- t[181] = 64
              "01000001" when "10110110", -- t[182] = 65
              "01000001" when "10110111", -- t[183] = 65
              "01000010" when "10111000", -- t[184] = 66
              "01000011" when "10111001", -- t[185] = 67
              "01000100" when "10111010", -- t[186] = 68
              "01000100" when "10111011", -- t[187] = 68
              "01000101" when "10111100", -- t[188] = 69
              "01000110" when "10111101", -- t[189] = 70
              "01000111" when "10111110", -- t[190] = 71
              "01000111" when "10111111", -- t[191] = 71
              "01001000" when "11000000", -- t[192] = 72
              "01001001" when "11000001", -- t[193] = 73
              "01001010" when "11000010", -- t[194] = 74
              "01001010" when "11000011", -- t[195] = 74
              "01001011" when "11000100", -- t[196] = 75
              "01001100" when "11000101", -- t[197] = 76
              "01001101" when "11000110", -- t[198] = 77
              "01001101" when "11000111", -- t[199] = 77
              "01001110" when "11001000", -- t[200] = 78
              "01001111" when "11001001", -- t[201] = 79
              "01010000" when "11001010", -- t[202] = 80
              "01010001" when "11001011", -- t[203] = 81
              "01010001" when "11001100", -- t[204] = 81
              "01010010" when "11001101", -- t[205] = 82
              "01010011" when "11001110", -- t[206] = 83
              "01010100" when "11001111", -- t[207] = 84
              "01010101" when "11010000", -- t[208] = 85
              "01010101" when "11010001", -- t[209] = 85
              "01010110" when "11010010", -- t[210] = 86
              "01010111" when "11010011", -- t[211] = 87
              "01011000" when "11010100", -- t[212] = 88
              "01011001" when "11010101", -- t[213] = 89
              "01011010" when "11010110", -- t[214] = 90
              "01011010" when "11010111", -- t[215] = 90
              "01011011" when "11011000", -- t[216] = 91
              "01011100" when "11011001", -- t[217] = 92
              "01011101" when "11011010", -- t[218] = 93
              "01011110" when "11011011", -- t[219] = 94
              "01011111" when "11011100", -- t[220] = 95
              "01011111" when "11011101", -- t[221] = 95
              "01100000" when "11011110", -- t[222] = 96
              "01100001" when "11011111", -- t[223] = 97
              "01100010" when "11100000", -- t[224] = 98
              "01100011" when "11100001", -- t[225] = 99
              "01100100" when "11100010", -- t[226] = 100
              "01100101" when "11100011", -- t[227] = 101
              "01100110" when "11100100", -- t[228] = 102
              "01100111" when "11100101", -- t[229] = 103
              "01100111" when "11100110", -- t[230] = 103
              "01101000" when "11100111", -- t[231] = 104
              "01101001" when "11101000", -- t[232] = 105
              "01101010" when "11101001", -- t[233] = 106
              "01101011" when "11101010", -- t[234] = 107
              "01101100" when "11101011", -- t[235] = 108
              "01101101" when "11101100", -- t[236] = 109
              "01101110" when "11101101", -- t[237] = 110
              "01101111" when "11101110", -- t[238] = 111
              "01110000" when "11101111", -- t[239] = 112
              "01110001" when "11110000", -- t[240] = 113
              "01110010" when "11110001", -- t[241] = 114
              "01110011" when "11110010", -- t[242] = 115
              "01110011" when "11110011", -- t[243] = 115
              "01110100" when "11110100", -- t[244] = 116
              "01110101" when "11110101", -- t[245] = 117
              "01110110" when "11110110", -- t[246] = 118
              "01110111" when "11110111", -- t[247] = 119
              "01111000" when "11111000", -- t[248] = 120
              "01111001" when "11111001", -- t[249] = 121
              "01111010" when "11111010", -- t[250] = 122
              "01111011" when "11111011", -- t[251] = 123
              "01111100" when "11111100", -- t[252] = 124
              "01111101" when "11111101", -- t[253] = 125
              "01111110" when "11111110", -- t[254] = 126
              "01111111" when "11111111", -- t[255] = 127
              "--------" when others;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- HOTBM instance for function e^x-x-1.
-- wI = 9; wO = 9.
-- Order-1 polynomial approximation.
-- Decomposition:
--   alpha = 5; beta = 4;
--   T_0 (ROM):     alpha_0 = 5; beta_0 = 0;
--   T_1 (PowMult): alpha_1 = 4; beta_1 = 4.
-- Guard bits: g = 1.
-- Command line: exp 9 9 1   rom 5 0   pm 4 4  ah 4 4 4  0 1  4 4 0


--------------------------------------------------------------------------------
-- TermROM instance for order-0 term.
-- Decomposition:
--   alpha_0 = 5; beta_0 = 0; wO_0 = 10.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_20_t0 is
  port ( a : in  std_logic_vector(4 downto 0);
         r : out std_logic_vector(10 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_20_t0 is
  signal x0   : std_logic_vector(4 downto 0);
  signal r0   : std_logic_vector(9 downto 0);
begin
  x0 <= a;

  with x0 select
    r0 <= "0000000001" when "00000", -- t[0] = 1
          "0000000011" when "00001", -- t[1] = 3
          "0000000111" when "00010", -- t[2] = 7
          "0000001101" when "00011", -- t[3] = 13
          "0000010101" when "00100", -- t[4] = 21
          "0000011111" when "00101", -- t[5] = 31
          "0000101011" when "00110", -- t[6] = 43
          "0000111001" when "00111", -- t[7] = 57
          "0001001001" when "01000", -- t[8] = 73
          "0001011011" when "01001", -- t[9] = 91
          "0001101111" when "01010", -- t[10] = 111
          "0010000101" when "01011", -- t[11] = 133
          "0010011101" when "01100", -- t[12] = 157
          "0010110111" when "01101", -- t[13] = 183
          "0011010011" when "01110", -- t[14] = 211
          "0011110000" when "01111", -- t[15] = 240
          "0100010000" when "10000", -- t[16] = 272
          "0100110010" when "10001", -- t[17] = 306
          "0101010110" when "10010", -- t[18] = 342
          "0101111100" when "10011", -- t[19] = 380
          "0110100100" when "10100", -- t[20] = 420
          "0111001110" when "10101", -- t[21] = 462
          "0111111010" when "10110", -- t[22] = 506
          "1000101000" when "10111", -- t[23] = 552
          "1001011000" when "11000", -- t[24] = 600
          "1010001010" when "11001", -- t[25] = 650
          "1010111110" when "11010", -- t[26] = 702
          "1011110100" when "11011", -- t[27] = 756
          "1100101100" when "11100", -- t[28] = 812
          "1101100110" when "11101", -- t[29] = 870
          "1110100010" when "11110", -- t[30] = 930
          "1111100000" when "11111", -- t[31] = 992
          "----------" when others;

  r(9 downto 0) <= r0;
  r(10 downto 10) <= (10 downto 10 => ('0'));
end architecture;


--------------------------------------------------------------------------------
-- PowerAdHoc instance for order-1 powering unit.
-- Decomposition:
--   beta_1 = 4; mu_1 = 4; lambda_1 = 4.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_20_t1_pow is
  port ( x : in  std_logic_vector(2 downto 0);
         r : out std_logic_vector(3 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_20_t1_pow is
  signal pp0 : std_logic_vector(2 downto 0);
  signal r0 : std_logic_vector(2 downto 0);
begin
  pp0(2) <= x(2);

  pp0(1) <= x(1);

  pp0(0) <= x(0);

  r0 <= pp0;
  r <= "1" & r0(2 downto 0);
end architecture;


--------------------------------------------------------------------------------
-- TermPowMult::Table instance for order-1 term Q_1.
-- Decomposition:
--   alpha_1,1 = 4; sigma'_1,1 = 3; wO_1,1 = 5.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_20_t1_t1 is
  port ( a : in  std_logic_vector(3 downto 0);
         s : in  std_logic_vector(2 downto 0);
         r : out std_logic_vector(4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_20_t1_t1 is
  signal x : std_logic_vector(6 downto 0);
begin
  x <= a & s;

  with x select
    r <= "00000" when "0000000", -- t[0] = 0
         "00000" when "0000001", -- t[1] = 0
         "00000" when "0000010", -- t[2] = 0
         "00000" when "0000011", -- t[3] = 0
         "00000" when "0000100", -- t[4] = 0
         "00000" when "0000101", -- t[5] = 0
         "00000" when "0000110", -- t[6] = 0
         "00000" when "0000111", -- t[7] = 0
         "00000" when "0001000", -- t[8] = 0
         "00000" when "0001001", -- t[9] = 0
         "00000" when "0001010", -- t[10] = 0
         "00001" when "0001011", -- t[11] = 1
         "00001" when "0001100", -- t[12] = 1
         "00010" when "0001101", -- t[13] = 2
         "00010" when "0001110", -- t[14] = 2
         "00010" when "0001111", -- t[15] = 2
         "00000" when "0010000", -- t[16] = 0
         "00000" when "0010001", -- t[17] = 0
         "00001" when "0010010", -- t[18] = 1
         "00010" when "0010011", -- t[19] = 2
         "00010" when "0010100", -- t[20] = 2
         "00011" when "0010101", -- t[21] = 3
         "00100" when "0010110", -- t[22] = 4
         "00100" when "0010111", -- t[23] = 4
         "00000" when "0011000", -- t[24] = 0
         "00001" when "0011001", -- t[25] = 1
         "00010" when "0011010", -- t[26] = 2
         "00011" when "0011011", -- t[27] = 3
         "00011" when "0011100", -- t[28] = 3
         "00100" when "0011101", -- t[29] = 4
         "00101" when "0011110", -- t[30] = 5
         "00110" when "0011111", -- t[31] = 6
         "00000" when "0100000", -- t[32] = 0
         "00001" when "0100001", -- t[33] = 1
         "00010" when "0100010", -- t[34] = 2
         "00011" when "0100011", -- t[35] = 3
         "00101" when "0100100", -- t[36] = 5
         "00110" when "0100101", -- t[37] = 6
         "00111" when "0100110", -- t[38] = 7
         "01000" when "0100111", -- t[39] = 8
         "00000" when "0101000", -- t[40] = 0
         "00010" when "0101001", -- t[41] = 2
         "00011" when "0101010", -- t[42] = 3
         "00100" when "0101011", -- t[43] = 4
         "00110" when "0101100", -- t[44] = 6
         "00111" when "0101101", -- t[45] = 7
         "01000" when "0101110", -- t[46] = 8
         "01010" when "0101111", -- t[47] = 10
         "00000" when "0110000", -- t[48] = 0
         "00010" when "0110001", -- t[49] = 2
         "00100" when "0110010", -- t[50] = 4
         "00101" when "0110011", -- t[51] = 5
         "00111" when "0110100", -- t[52] = 7
         "01000" when "0110101", -- t[53] = 8
         "01010" when "0110110", -- t[54] = 10
         "01100" when "0110111", -- t[55] = 12
         "00000" when "0111000", -- t[56] = 0
         "00010" when "0111001", -- t[57] = 2
         "00100" when "0111010", -- t[58] = 4
         "00110" when "0111011", -- t[59] = 6
         "01000" when "0111100", -- t[60] = 8
         "01010" when "0111101", -- t[61] = 10
         "01100" when "0111110", -- t[62] = 12
         "01110" when "0111111", -- t[63] = 14
         "00001" when "1000000", -- t[64] = 1
         "00011" when "1000001", -- t[65] = 3
         "00101" when "1000010", -- t[66] = 5
         "00111" when "1000011", -- t[67] = 7
         "01001" when "1000100", -- t[68] = 9
         "01011" when "1000101", -- t[69] = 11
         "01101" when "1000110", -- t[70] = 13
         "01111" when "1000111", -- t[71] = 15
         "00001" when "1001000", -- t[72] = 1
         "00011" when "1001001", -- t[73] = 3
         "00101" when "1001010", -- t[74] = 5
         "01000" when "1001011", -- t[75] = 8
         "01010" when "1001100", -- t[76] = 10
         "01101" when "1001101", -- t[77] = 13
         "01111" when "1001110", -- t[78] = 15
         "10001" when "1001111", -- t[79] = 17
         "00001" when "1010000", -- t[80] = 1
         "00011" when "1010001", -- t[81] = 3
         "00110" when "1010010", -- t[82] = 6
         "01001" when "1010011", -- t[83] = 9
         "01011" when "1010100", -- t[84] = 11
         "01110" when "1010101", -- t[85] = 14
         "10001" when "1010110", -- t[86] = 17
         "10011" when "1010111", -- t[87] = 19
         "00001" when "1011000", -- t[88] = 1
         "00100" when "1011001", -- t[89] = 4
         "00111" when "1011010", -- t[90] = 7
         "01010" when "1011011", -- t[91] = 10
         "01100" when "1011100", -- t[92] = 12
         "01111" when "1011101", -- t[93] = 15
         "10010" when "1011110", -- t[94] = 18
         "10101" when "1011111", -- t[95] = 21
         "00001" when "1100000", -- t[96] = 1
         "00100" when "1100001", -- t[97] = 4
         "00111" when "1100010", -- t[98] = 7
         "01010" when "1100011", -- t[99] = 10
         "01110" when "1100100", -- t[100] = 14
         "10001" when "1100101", -- t[101] = 17
         "10100" when "1100110", -- t[102] = 20
         "10111" when "1100111", -- t[103] = 23
         "00001" when "1101000", -- t[104] = 1
         "00101" when "1101001", -- t[105] = 5
         "01000" when "1101010", -- t[106] = 8
         "01011" when "1101011", -- t[107] = 11
         "01111" when "1101100", -- t[108] = 15
         "10010" when "1101101", -- t[109] = 18
         "10101" when "1101110", -- t[110] = 21
         "11001" when "1101111", -- t[111] = 25
         "00001" when "1110000", -- t[112] = 1
         "00101" when "1110001", -- t[113] = 5
         "01001" when "1110010", -- t[114] = 9
         "01100" when "1110011", -- t[115] = 12
         "10000" when "1110100", -- t[116] = 16
         "10011" when "1110101", -- t[117] = 19
         "10111" when "1110110", -- t[118] = 23
         "11011" when "1110111", -- t[119] = 27
         "00001" when "1111000", -- t[120] = 1
         "00101" when "1111001", -- t[121] = 5
         "01001" when "1111010", -- t[122] = 9
         "01101" when "1111011", -- t[123] = 13
         "10001" when "1111100", -- t[124] = 17
         "10101" when "1111101", -- t[125] = 21
         "11001" when "1111110", -- t[126] = 25
         "11101" when "1111111", -- t[127] = 29
         "-----" when others;
end architecture;


--------------------------------------------------------------------------------
-- TermPowMult instance for order-1 term.
-- Decomposition:
--   alpha_1 = 4; beta_1 = 4; lambda_1 = 4;  m_1 = 1;
--   Pow   (AdHoc);
--   Q_1,1 (ROM):  alpha_1,1 = 4; rho_1,1 = 0; sigma_1,1 = 4; wO_1,1 = 5.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_20_t1 is
  port ( a : in  std_logic_vector(3 downto 0);
         b : in  std_logic_vector(3 downto 0);
         r : out std_logic_vector(10 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_20_t1 is
  signal sign   : std_logic;
  signal b0     : std_logic_vector(2 downto 0);
  signal s      : std_logic_vector(3 downto 0);
  component fp_exp_exp_y2_20_t1_pow is
    port ( x : in  std_logic_vector(2 downto 0);
           r : out std_logic_vector(3 downto 0) );
  end component;

  signal a_1    : std_logic_vector(3 downto 0);
  signal sign_1 : std_logic;
  signal s_1    : std_logic_vector(2 downto 0);
  signal r0_1   : std_logic_vector(4 downto 0);
  signal r_1    : std_logic_vector(10 downto 0);
  component fp_exp_exp_y2_20_t1_t1 is
    port ( a : in  std_logic_vector(3 downto 0);
           s : in  std_logic_vector(2 downto 0);
           r : out std_logic_vector(4 downto 0) );
  end component;
begin
  sign <= not b(3);
  b0 <= b(2 downto 0) xor (2 downto 0 => sign);

  pow : fp_exp_exp_y2_20_t1_pow
    port map ( x => b0,
               r => s );

  a_1 <= a(3 downto 0);
  sign_1 <= not s(3);
  s_1 <= s(2 downto 0) xor (2 downto 0 => sign_1);
  t_1 : fp_exp_exp_y2_20_t1_t1
    port map ( a => a_1,
               s => s_1,
               r => r0_1 );
  r_1(4 downto 0) <=
    r0_1 xor (4 downto 0 => ((sign xor sign_1)));
  r_1(10 downto 5) <= (10 downto 5 => ((sign xor sign_1)));

  r <= r_1;
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_20_t1_clk is
  port ( a   : in  std_logic_vector(3 downto 0);
         b   : in  std_logic_vector(3 downto 0);
         r   : out std_logic_vector(10 downto 0);
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_exp_y2_20_t1_clk is
  signal sign   : std_logic;
  signal b0     : std_logic_vector(2 downto 0);
  signal s      : std_logic_vector(3 downto 0);
  component fp_exp_exp_y2_20_t1_pow is
    port ( x : in  std_logic_vector(2 downto 0);
           r : out std_logic_vector(3 downto 0) );
  end component;

  signal a_1     : std_logic_vector(3 downto 0);
  signal sign_1  : std_logic;
  signal s_1     : std_logic_vector(2 downto 0);
  signal r0_10   : std_logic_vector(4 downto 0);
  signal r0_1r   : std_logic_vector(4 downto 0);
  signal r_1     : std_logic_vector(10 downto 0);
  signal sign_10 : std_logic;
  signal sign_1r : std_logic;
  component fp_exp_exp_y2_20_t1_t1 is
    port ( a : in  std_logic_vector(3 downto 0);
           s : in  std_logic_vector(2 downto 0);
           r : out std_logic_vector(4 downto 0) );
  end component;
begin
  sign <= not b(3);
  b0 <= b(2 downto 0) xor (2 downto 0 => sign);

  pow : fp_exp_exp_y2_20_t1_pow
    port map ( x => b0,
               r => s );

  a_1 <= a(3 downto 0);
  sign_1 <= not s(3);
  s_1 <= s(2 downto 0) xor (2 downto 0 => sign_1);
  sign_10 <= sign xor sign_1;
  t_1 : fp_exp_exp_y2_20_t1_t1
    port map ( a => a_1,
               s => s_1,
               r => r0_10 );
  r_1(4 downto 0) <=
    r0_1r xor (4 downto 0 => sign_1r);
  r_1(10 downto 5) <= (10 downto 5 => sign_1r);

  process(clk)
  begin
    if clk'event and clk = '1' then
      r0_1r   <= r0_10;
      sign_1r <= sign_10;
    end if;
  end process;

  r <= r_1;
end architecture;


--------------------------------------------------------------------------------
-- HOTBM main component.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_20 is
  port ( x : in  std_logic_vector(8 downto 0);
         r : out std_logic_vector(9 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_20 is
  signal a_0 : std_logic_vector(4 downto 0);
  signal r_0 : std_logic_vector(10 downto 0);
  component fp_exp_exp_y2_20_t0 is
    port ( a : in  std_logic_vector(4 downto 0);
           r : out std_logic_vector(10 downto 0) );
  end component;

  signal a_1 : std_logic_vector(3 downto 0);
  signal b_1 : std_logic_vector(3 downto 0);
  signal r_1 : std_logic_vector(10 downto 0);
  component fp_exp_exp_y2_20_t1 is
    port ( a : in  std_logic_vector(3 downto 0);
           b : in  std_logic_vector(3 downto 0);
           r : out std_logic_vector(10 downto 0) );
  end component;

  signal sum : std_logic_vector(10 downto 0);
begin
  a_0 <= x(8 downto 4);
  t_0 : fp_exp_exp_y2_20_t0
    port map ( a => a_0,
               r => r_0 );

  a_1 <= x(8 downto 5);
  b_1 <= x(3 downto 0);
  t_1 : fp_exp_exp_y2_20_t1
    port map ( a => a_1,
               b => b_1,
               r => r_1 );

  sum <= r_0 + r_1;
  r <= sum(10 downto 1);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_20_clk is
  port ( x   : in  std_logic_vector(8 downto 0);
         r   : out std_logic_vector(9 downto 0);
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_exp_y2_20_clk is
  signal a_x0 : std_logic_vector(4 downto 0);
  signal a_xr : std_logic_vector(4 downto 0);
  signal r_0  : std_logic_vector(10 downto 0);
  component fp_exp_exp_y2_20_t0 is
    port ( a : in  std_logic_vector(4 downto 0);
           r : out std_logic_vector(10 downto 0) );
  end component;

  signal a_1 : std_logic_vector(3 downto 0);
  signal b_1 : std_logic_vector(3 downto 0);
  signal r_1 : std_logic_vector(10 downto 0);
  component fp_exp_exp_y2_20_t1_clk is
    port ( a   : in  std_logic_vector(3 downto 0);
           b   : in  std_logic_vector(3 downto 0);
           r   : out std_logic_vector(10 downto 0);
           clk : in  std_logic );
  end component;

  signal sum : std_logic_vector(10 downto 0);
begin
  a_x0 <= x(8 downto 4);
  t_0 : fp_exp_exp_y2_20_t0
    port map ( a => a_xr,
               r => r_0 );

  process(clk)
  begin
    if clk'event and clk = '1' then
      a_xr <= a_x0;
    end if;
  end process;

  a_1 <= x(8 downto 5);
  b_1 <= x(3 downto 0);
  t_1 : fp_exp_exp_y2_20_t1_clk
    port map ( a   => a_1,
               b   => b_1,
               r   => r_1,
               clk => clk );

  sum <= r_0 + r_1;
  r <= sum(10 downto 1);
end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- HOTBM instance for function e^x-x-1.
-- wI = 10; wO = 10.
-- Order-1 polynomial approximation.
-- Decomposition:
--   alpha = 6; beta = 4;
--   T_0 (ROM):     alpha_0 = 6; beta_0 = 0;
--   T_1 (PowMult): alpha_1 = 4; beta_1 = 4.
-- Guard bits: g = 2.
-- Command line: exp 10 10 1   rom 6 0   pm 4 4  ah 4 4 4  0 1  4 4 0


--------------------------------------------------------------------------------
-- TermROM instance for order-0 term.
-- Decomposition:
--   alpha_0 = 6; beta_0 = 0; wO_0 = 12.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_21_t0 is
  port ( a : in  std_logic_vector(5 downto 0);
         r : out std_logic_vector(12 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_21_t0 is
  signal x0   : std_logic_vector(5 downto 0);
  signal r0   : std_logic_vector(11 downto 0);
begin
  x0 <= a;

  with x0 select
    r0 <= "000000000010" when "000000", -- t[0] = 2
          "000000000100" when "000001", -- t[1] = 4
          "000000001000" when "000010", -- t[2] = 8
          "000000001110" when "000011", -- t[3] = 14
          "000000010110" when "000100", -- t[4] = 22
          "000000100000" when "000101", -- t[5] = 32
          "000000101100" when "000110", -- t[6] = 44
          "000000111010" when "000111", -- t[7] = 58
          "000001001010" when "001000", -- t[8] = 74
          "000001011100" when "001001", -- t[9] = 92
          "000001110000" when "001010", -- t[10] = 112
          "000010000110" when "001011", -- t[11] = 134
          "000010011110" when "001100", -- t[12] = 158
          "000010111000" when "001101", -- t[13] = 184
          "000011010011" when "001110", -- t[14] = 211
          "000011110001" when "001111", -- t[15] = 241
          "000100010001" when "010000", -- t[16] = 273
          "000100110011" when "010001", -- t[17] = 307
          "000101010111" when "010010", -- t[18] = 343
          "000101111101" when "010011", -- t[19] = 381
          "000110100101" when "010100", -- t[20] = 421
          "000111001111" when "010101", -- t[21] = 463
          "000111111011" when "010110", -- t[22] = 507
          "001000101001" when "010111", -- t[23] = 553
          "001001011001" when "011000", -- t[24] = 601
          "001010001011" when "011001", -- t[25] = 651
          "001010111111" when "011010", -- t[26] = 703
          "001011110101" when "011011", -- t[27] = 757
          "001100101101" when "011100", -- t[28] = 813
          "001101100111" when "011101", -- t[29] = 871
          "001110100011" when "011110", -- t[30] = 931
          "001111100001" when "011111", -- t[31] = 993
          "010000100001" when "100000", -- t[32] = 1057
          "010001100011" when "100001", -- t[33] = 1123
          "010010100111" when "100010", -- t[34] = 1191
          "010011101101" when "100011", -- t[35] = 1261
          "010100110101" when "100100", -- t[36] = 1333
          "010101111111" when "100101", -- t[37] = 1407
          "010111001011" when "100110", -- t[38] = 1483
          "011000011001" when "100111", -- t[39] = 1561
          "011001101001" when "101000", -- t[40] = 1641
          "011010111010" when "101001", -- t[41] = 1722
          "011100001110" when "101010", -- t[42] = 1806
          "011101100100" when "101011", -- t[43] = 1892
          "011110111100" when "101100", -- t[44] = 1980
          "100000010110" when "101101", -- t[45] = 2070
          "100001110010" when "101110", -- t[46] = 2162
          "100011010000" when "101111", -- t[47] = 2256
          "100100110000" when "110000", -- t[48] = 2352
          "100110010010" when "110001", -- t[49] = 2450
          "100111110111" when "110010", -- t[50] = 2551
          "101001011101" when "110011", -- t[51] = 2653
          "101011000101" when "110100", -- t[52] = 2757
          "101100101111" when "110101", -- t[53] = 2863
          "101110011011" when "110110", -- t[54] = 2971
          "110000001001" when "110111", -- t[55] = 3081
          "110001111001" when "111000", -- t[56] = 3193
          "110011101011" when "111001", -- t[57] = 3307
          "110101011111" when "111010", -- t[58] = 3423
          "110111010101" when "111011", -- t[59] = 3541
          "111001001101" when "111100", -- t[60] = 3661
          "111011000111" when "111101", -- t[61] = 3783
          "111101000011" when "111110", -- t[62] = 3907
          "111111000001" when "111111", -- t[63] = 4033
          "------------" when others;

  r(11 downto 0) <= r0;
  r(12 downto 12) <= (12 downto 12 => ('0'));
end architecture;


--------------------------------------------------------------------------------
-- PowerAdHoc instance for order-1 powering unit.
-- Decomposition:
--   beta_1 = 4; mu_1 = 4; lambda_1 = 4.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_21_t1_pow is
  port ( x : in  std_logic_vector(2 downto 0);
         r : out std_logic_vector(3 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_21_t1_pow is
  signal pp0 : std_logic_vector(2 downto 0);
  signal r0 : std_logic_vector(2 downto 0);
begin
  pp0(2) <= x(2);

  pp0(1) <= x(1);

  pp0(0) <= x(0);

  r0 <= pp0;
  r <= "1" & r0(2 downto 0);
end architecture;


--------------------------------------------------------------------------------
-- TermPowMult::Table instance for order-1 term Q_1.
-- Decomposition:
--   alpha_1,1 = 4; sigma'_1,1 = 3; wO_1,1 = 6.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_21_t1_t1 is
  port ( a : in  std_logic_vector(3 downto 0);
         s : in  std_logic_vector(2 downto 0);
         r : out std_logic_vector(5 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_21_t1_t1 is
  signal x : std_logic_vector(6 downto 0);
begin
  x <= a & s;

  with x select
    r <= "000000" when "0000000", -- t[0] = 0
         "000000" when "0000001", -- t[1] = 0
         "000000" when "0000010", -- t[2] = 0
         "000000" when "0000011", -- t[3] = 0
         "000001" when "0000100", -- t[4] = 1
         "000001" when "0000101", -- t[5] = 1
         "000001" when "0000110", -- t[6] = 1
         "000001" when "0000111", -- t[7] = 1
         "000000" when "0001000", -- t[8] = 0
         "000001" when "0001001", -- t[9] = 1
         "000001" when "0001010", -- t[10] = 1
         "000010" when "0001011", -- t[11] = 2
         "000011" when "0001100", -- t[12] = 3
         "000100" when "0001101", -- t[13] = 4
         "000100" when "0001110", -- t[14] = 4
         "000101" when "0001111", -- t[15] = 5
         "000000" when "0010000", -- t[16] = 0
         "000001" when "0010001", -- t[17] = 1
         "000011" when "0010010", -- t[18] = 3
         "000100" when "0010011", -- t[19] = 4
         "000101" when "0010100", -- t[20] = 5
         "000110" when "0010101", -- t[21] = 6
         "001000" when "0010110", -- t[22] = 8
         "001001" when "0010111", -- t[23] = 9
         "000000" when "0011000", -- t[24] = 0
         "000010" when "0011001", -- t[25] = 2
         "000100" when "0011010", -- t[26] = 4
         "000110" when "0011011", -- t[27] = 6
         "000111" when "0011100", -- t[28] = 7
         "001001" when "0011101", -- t[29] = 9
         "001011" when "0011110", -- t[30] = 11
         "001101" when "0011111", -- t[31] = 13
         "000001" when "0100000", -- t[32] = 1
         "000011" when "0100001", -- t[33] = 3
         "000101" when "0100010", -- t[34] = 5
         "000111" when "0100011", -- t[35] = 7
         "001010" when "0100100", -- t[36] = 10
         "001100" when "0100101", -- t[37] = 12
         "001110" when "0100110", -- t[38] = 14
         "010000" when "0100111", -- t[39] = 16
         "000001" when "0101000", -- t[40] = 1
         "000100" when "0101001", -- t[41] = 4
         "000110" when "0101010", -- t[42] = 6
         "001001" when "0101011", -- t[43] = 9
         "001100" when "0101100", -- t[44] = 12
         "001111" when "0101101", -- t[45] = 15
         "010001" when "0101110", -- t[46] = 17
         "010100" when "0101111", -- t[47] = 20
         "000001" when "0110000", -- t[48] = 1
         "000100" when "0110001", -- t[49] = 4
         "001000" when "0110010", -- t[50] = 8
         "001011" when "0110011", -- t[51] = 11
         "001110" when "0110100", -- t[52] = 14
         "010001" when "0110101", -- t[53] = 17
         "010101" when "0110110", -- t[54] = 21
         "011000" when "0110111", -- t[55] = 24
         "000001" when "0111000", -- t[56] = 1
         "000101" when "0111001", -- t[57] = 5
         "001001" when "0111010", -- t[58] = 9
         "001101" when "0111011", -- t[59] = 13
         "010000" when "0111100", -- t[60] = 16
         "010100" when "0111101", -- t[61] = 20
         "011000" when "0111110", -- t[62] = 24
         "011100" when "0111111", -- t[63] = 28
         "000010" when "1000000", -- t[64] = 2
         "000110" when "1000001", -- t[65] = 6
         "001010" when "1000010", -- t[66] = 10
         "001110" when "1000011", -- t[67] = 14
         "010011" when "1000100", -- t[68] = 19
         "010111" when "1000101", -- t[69] = 23
         "011011" when "1000110", -- t[70] = 27
         "011111" when "1000111", -- t[71] = 31
         "000010" when "1001000", -- t[72] = 2
         "000111" when "1001001", -- t[73] = 7
         "001011" when "1001010", -- t[74] = 11
         "010000" when "1001011", -- t[75] = 16
         "010101" when "1001100", -- t[76] = 21
         "011010" when "1001101", -- t[77] = 26
         "011110" when "1001110", -- t[78] = 30
         "100011" when "1001111", -- t[79] = 35
         "000010" when "1010000", -- t[80] = 2
         "000111" when "1010001", -- t[81] = 7
         "001101" when "1010010", -- t[82] = 13
         "010010" when "1010011", -- t[83] = 18
         "010111" when "1010100", -- t[84] = 23
         "011100" when "1010101", -- t[85] = 28
         "100010" when "1010110", -- t[86] = 34
         "100111" when "1010111", -- t[87] = 39
         "000010" when "1011000", -- t[88] = 2
         "001000" when "1011001", -- t[89] = 8
         "001110" when "1011010", -- t[90] = 14
         "010100" when "1011011", -- t[91] = 20
         "011001" when "1011100", -- t[92] = 25
         "011111" when "1011101", -- t[93] = 31
         "100101" when "1011110", -- t[94] = 37
         "101011" when "1011111", -- t[95] = 43
         "000011" when "1100000", -- t[96] = 3
         "001001" when "1100001", -- t[97] = 9
         "001111" when "1100010", -- t[98] = 15
         "010101" when "1100011", -- t[99] = 21
         "011100" when "1100100", -- t[100] = 28
         "100010" when "1100101", -- t[101] = 34
         "101000" when "1100110", -- t[102] = 40
         "101110" when "1100111", -- t[103] = 46
         "000011" when "1101000", -- t[104] = 3
         "001010" when "1101001", -- t[105] = 10
         "010000" when "1101010", -- t[106] = 16
         "010111" when "1101011", -- t[107] = 23
         "011110" when "1101100", -- t[108] = 30
         "100101" when "1101101", -- t[109] = 37
         "101011" when "1101110", -- t[110] = 43
         "110010" when "1101111", -- t[111] = 50
         "000011" when "1110000", -- t[112] = 3
         "001010" when "1110001", -- t[113] = 10
         "010010" when "1110010", -- t[114] = 18
         "011001" when "1110011", -- t[115] = 25
         "100000" when "1110100", -- t[116] = 32
         "100111" when "1110101", -- t[117] = 39
         "101111" when "1110110", -- t[118] = 47
         "110110" when "1110111", -- t[119] = 54
         "000011" when "1111000", -- t[120] = 3
         "001011" when "1111001", -- t[121] = 11
         "010011" when "1111010", -- t[122] = 19
         "011011" when "1111011", -- t[123] = 27
         "100010" when "1111100", -- t[124] = 34
         "101010" when "1111101", -- t[125] = 42
         "110010" when "1111110", -- t[126] = 50
         "111010" when "1111111", -- t[127] = 58
         "------" when others;
end architecture;


--------------------------------------------------------------------------------
-- TermPowMult instance for order-1 term.
-- Decomposition:
--   alpha_1 = 4; beta_1 = 4; lambda_1 = 4;  m_1 = 1;
--   Pow   (AdHoc);
--   Q_1,1 (ROM):  alpha_1,1 = 4; rho_1,1 = 0; sigma_1,1 = 4; wO_1,1 = 6.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_21_t1 is
  port ( a : in  std_logic_vector(3 downto 0);
         b : in  std_logic_vector(3 downto 0);
         r : out std_logic_vector(12 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_21_t1 is
  signal sign   : std_logic;
  signal b0     : std_logic_vector(2 downto 0);
  signal s      : std_logic_vector(3 downto 0);
  component fp_exp_exp_y2_21_t1_pow is
    port ( x : in  std_logic_vector(2 downto 0);
           r : out std_logic_vector(3 downto 0) );
  end component;

  signal a_1    : std_logic_vector(3 downto 0);
  signal sign_1 : std_logic;
  signal s_1    : std_logic_vector(2 downto 0);
  signal r0_1   : std_logic_vector(5 downto 0);
  signal r_1    : std_logic_vector(12 downto 0);
  component fp_exp_exp_y2_21_t1_t1 is
    port ( a : in  std_logic_vector(3 downto 0);
           s : in  std_logic_vector(2 downto 0);
           r : out std_logic_vector(5 downto 0) );
  end component;
begin
  sign <= not b(3);
  b0 <= b(2 downto 0) xor (2 downto 0 => sign);

  pow : fp_exp_exp_y2_21_t1_pow
    port map ( x => b0,
               r => s );

  a_1 <= a(3 downto 0);
  sign_1 <= not s(3);
  s_1 <= s(2 downto 0) xor (2 downto 0 => sign_1);
  t_1 : fp_exp_exp_y2_21_t1_t1
    port map ( a => a_1,
               s => s_1,
               r => r0_1 );
  r_1(5 downto 0) <=
    r0_1 xor (5 downto 0 => ((sign xor sign_1)));
  r_1(12 downto 6) <= (12 downto 6 => ((sign xor sign_1)));

  r <= r_1;
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_21_t1_clk is
  port ( a   : in  std_logic_vector(3 downto 0);
         b   : in  std_logic_vector(3 downto 0);
         r   : out std_logic_vector(12 downto 0);
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_exp_y2_21_t1_clk is
  signal sign   : std_logic;
  signal b0     : std_logic_vector(2 downto 0);
  signal s      : std_logic_vector(3 downto 0);
  component fp_exp_exp_y2_21_t1_pow is
    port ( x : in  std_logic_vector(2 downto 0);
           r : out std_logic_vector(3 downto 0) );
  end component;

  signal a_1     : std_logic_vector(3 downto 0);
  signal sign_1  : std_logic;
  signal s_1     : std_logic_vector(2 downto 0);
  signal r0_10   : std_logic_vector(5 downto 0);
  signal r0_1r   : std_logic_vector(5 downto 0);
  signal r_1     : std_logic_vector(12 downto 0);
  signal sign_10 : std_logic;
  signal sign_1r : std_logic;
  component fp_exp_exp_y2_21_t1_t1 is
    port ( a : in  std_logic_vector(3 downto 0);
           s : in  std_logic_vector(2 downto 0);
           r : out std_logic_vector(5 downto 0) );
  end component;
begin
  sign <= not b(3);
  b0 <= b(2 downto 0) xor (2 downto 0 => sign);

  pow : fp_exp_exp_y2_21_t1_pow
    port map ( x => b0,
               r => s );

  a_1 <= a(3 downto 0);
  sign_1 <= not s(3);
  s_1 <= s(2 downto 0) xor (2 downto 0 => sign_1);
  sign_10 <= sign xor sign_1;
  t_1 : fp_exp_exp_y2_21_t1_t1
    port map ( a => a_1,
               s => s_1,
               r => r0_10 );
  r_1(5 downto 0) <=
    r0_1r xor (5 downto 0 => sign_1r);
  r_1(12 downto 6) <= (12 downto 6 => sign_1r);

  process(clk)
  begin
    if clk'event and clk = '1' then
      r0_1r   <= r0_10;
      sign_1r <= sign_10;
    end if;
  end process;

  r <= r_1;
end architecture;


--------------------------------------------------------------------------------
-- HOTBM main component.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_21 is
  port ( x : in  std_logic_vector(9 downto 0);
         r : out std_logic_vector(10 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_21 is
  signal a_0 : std_logic_vector(5 downto 0);
  signal r_0 : std_logic_vector(12 downto 0);
  component fp_exp_exp_y2_21_t0 is
    port ( a : in  std_logic_vector(5 downto 0);
           r : out std_logic_vector(12 downto 0) );
  end component;

  signal a_1 : std_logic_vector(3 downto 0);
  signal b_1 : std_logic_vector(3 downto 0);
  signal r_1 : std_logic_vector(12 downto 0);
  component fp_exp_exp_y2_21_t1 is
    port ( a : in  std_logic_vector(3 downto 0);
           b : in  std_logic_vector(3 downto 0);
           r : out std_logic_vector(12 downto 0) );
  end component;

  signal sum : std_logic_vector(12 downto 0);
begin
  a_0 <= x(9 downto 4);
  t_0 : fp_exp_exp_y2_21_t0
    port map ( a => a_0,
               r => r_0 );

  a_1 <= x(9 downto 6);
  b_1 <= x(3 downto 0);
  t_1 : fp_exp_exp_y2_21_t1
    port map ( a => a_1,
               b => b_1,
               r => r_1 );

  sum <= r_0 + r_1;
  r <= sum(12 downto 2);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_21_clk is
  port ( x   : in  std_logic_vector(9 downto 0);
         r   : out std_logic_vector(10 downto 0);
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_exp_y2_21_clk is
  signal a_x0 : std_logic_vector(5 downto 0);
  signal a_xr : std_logic_vector(5 downto 0);
  signal r_0  : std_logic_vector(12 downto 0);
  component fp_exp_exp_y2_21_t0 is
    port ( a : in  std_logic_vector(5 downto 0);
           r : out std_logic_vector(12 downto 0) );
  end component;

  signal a_1 : std_logic_vector(3 downto 0);
  signal b_1 : std_logic_vector(3 downto 0);
  signal r_1 : std_logic_vector(12 downto 0);
  component fp_exp_exp_y2_21_t1_clk is
    port ( a   : in  std_logic_vector(3 downto 0);
           b   : in  std_logic_vector(3 downto 0);
           r   : out std_logic_vector(12 downto 0);
           clk : in  std_logic );
  end component;

  signal sum : std_logic_vector(12 downto 0);
begin
  a_x0 <= x(9 downto 4);
  t_0 : fp_exp_exp_y2_21_t0
    port map ( a => a_xr,
               r => r_0 );

  process(clk)
  begin
    if clk'event and clk = '1' then
      a_xr <= a_x0;
    end if;
  end process;

  a_1 <= x(9 downto 6);
  b_1 <= x(3 downto 0);
  t_1 : fp_exp_exp_y2_21_t1_clk
    port map ( a   => a_1,
               b   => b_1,
               r   => r_1,
               clk => clk );

  sum <= r_0 + r_1;
  r <= sum(12 downto 2);
end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- HOTBM instance for function e^x-x-1.
-- wI = 11; wO = 11.
-- Order-1 polynomial approximation.
-- Decomposition:
--   alpha = 6; beta = 5;
--   T_0 (ROM):     alpha_0 = 6; beta_0 = 0;
--   T_1 (PowMult): alpha_1 = 5; beta_1 = 5.
-- Guard bits: g = 2.
-- Command line: exp 11 11 1   rom 6 0   pm 5 5  ah 5 5 5  0 2  5 3 0  3 2 3


--------------------------------------------------------------------------------
-- TermROM instance for order-0 term.
-- Decomposition:
--   alpha_0 = 6; beta_0 = 0; wO_0 = 13.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_22_t0 is
  port ( a : in  std_logic_vector(5 downto 0);
         r : out std_logic_vector(13 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_22_t0 is
  signal x0   : std_logic_vector(5 downto 0);
  signal r0   : std_logic_vector(12 downto 0);
begin
  x0 <= a;

  with x0 select
    r0 <= "0000000000011" when "000000", -- t[0] = 3
          "0000000000111" when "000001", -- t[1] = 7
          "0000000001111" when "000010", -- t[2] = 15
          "0000000011011" when "000011", -- t[3] = 27
          "0000000101011" when "000100", -- t[4] = 43
          "0000000111111" when "000101", -- t[5] = 63
          "0000001010111" when "000110", -- t[6] = 87
          "0000001110011" when "000111", -- t[7] = 115
          "0000010010011" when "001000", -- t[8] = 147
          "0000010110111" when "001001", -- t[9] = 183
          "0000011011111" when "001010", -- t[10] = 223
          "0000100001011" when "001011", -- t[11] = 267
          "0000100111010" when "001100", -- t[12] = 314
          "0000101101110" when "001101", -- t[13] = 366
          "0000110100110" when "001110", -- t[14] = 422
          "0000111100010" when "001111", -- t[15] = 482
          "0001000100010" when "010000", -- t[16] = 546
          "0001001100110" when "010001", -- t[17] = 614
          "0001010101110" when "010010", -- t[18] = 686
          "0001011111010" when "010011", -- t[19] = 762
          "0001101001010" when "010100", -- t[20] = 842
          "0001110011110" when "010101", -- t[21] = 926
          "0001111110110" when "010110", -- t[22] = 1014
          "0010001010010" when "010111", -- t[23] = 1106
          "0010010110010" when "011000", -- t[24] = 1202
          "0010100010110" when "011001", -- t[25] = 1302
          "0010101111110" when "011010", -- t[26] = 1406
          "0010111101010" when "011011", -- t[27] = 1514
          "0011001011010" when "011100", -- t[28] = 1626
          "0011011001110" when "011101", -- t[29] = 1742
          "0011101000110" when "011110", -- t[30] = 1862
          "0011111000010" when "011111", -- t[31] = 1986
          "0100001000010" when "100000", -- t[32] = 2114
          "0100011000110" when "100001", -- t[33] = 2246
          "0100101001110" when "100010", -- t[34] = 2382
          "0100111011010" when "100011", -- t[35] = 2522
          "0101001101010" when "100100", -- t[36] = 2666
          "0101011111110" when "100101", -- t[37] = 2814
          "0101110010110" when "100110", -- t[38] = 2966
          "0110000110010" when "100111", -- t[39] = 3122
          "0110011010010" when "101000", -- t[40] = 3282
          "0110101110110" when "101001", -- t[41] = 3446
          "0111000011110" when "101010", -- t[42] = 3614
          "0111011001010" when "101011", -- t[43] = 3786
          "0111101111010" when "101100", -- t[44] = 3962
          "1000000101110" when "101101", -- t[45] = 4142
          "1000011100110" when "101110", -- t[46] = 4326
          "1000110100010" when "101111", -- t[47] = 4514
          "1001001100011" when "110000", -- t[48] = 4707
          "1001100100111" when "110001", -- t[49] = 4903
          "1001111101111" when "110010", -- t[50] = 5103
          "1010010111011" when "110011", -- t[51] = 5307
          "1010110001011" when "110100", -- t[52] = 5515
          "1011001011111" when "110101", -- t[53] = 5727
          "1011100110111" when "110110", -- t[54] = 5943
          "1100000010011" when "110111", -- t[55] = 6163
          "1100011110011" when "111000", -- t[56] = 6387
          "1100111011000" when "111001", -- t[57] = 6616
          "1101011000000" when "111010", -- t[58] = 6848
          "1101110101100" when "111011", -- t[59] = 7084
          "1110010011100" when "111100", -- t[60] = 7324
          "1110110010000" when "111101", -- t[61] = 7568
          "1111010001000" when "111110", -- t[62] = 7816
          "1111110000100" when "111111", -- t[63] = 8068
          "-------------" when others;

  r(12 downto 0) <= r0;
  r(13 downto 13) <= (13 downto 13 => ('0'));
end architecture;


--------------------------------------------------------------------------------
-- PowerAdHoc instance for order-1 powering unit.
-- Decomposition:
--   beta_1 = 5; mu_1 = 5; lambda_1 = 5.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_22_t1_pow is
  port ( x : in  std_logic_vector(3 downto 0);
         r : out std_logic_vector(4 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_22_t1_pow is
  signal pp0 : std_logic_vector(3 downto 0);
  signal r0 : std_logic_vector(3 downto 0);
begin
  pp0(3) <= x(3);

  pp0(2) <= x(2);

  pp0(1) <= x(1);

  pp0(0) <= x(0);

  r0 <= pp0;
  r <= "1" & r0(3 downto 0);
end architecture;


--------------------------------------------------------------------------------
-- TermPowMult::Table instance for order-1 term Q_1.
-- Decomposition:
--   alpha_1,1 = 5; sigma'_1,1 = 2; wO_1,1 = 7.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_22_t1_t1 is
  port ( a : in  std_logic_vector(4 downto 0);
         s : in  std_logic_vector(1 downto 0);
         r : out std_logic_vector(6 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_22_t1_t1 is
  signal x : std_logic_vector(6 downto 0);
begin
  x <= a & s;

  with x select
    r <= "0000000" when "0000000", -- t[0] = 0
         "0000000" when "0000001", -- t[1] = 0
         "0000001" when "0000010", -- t[2] = 1
         "0000001" when "0000011", -- t[3] = 1
         "0000000" when "0000100", -- t[4] = 0
         "0000010" when "0000101", -- t[5] = 2
         "0000011" when "0000110", -- t[6] = 3
         "0000101" when "0000111", -- t[7] = 5
         "0000001" when "0001000", -- t[8] = 1
         "0000011" when "0001001", -- t[9] = 3
         "0000110" when "0001010", -- t[10] = 6
         "0001000" when "0001011", -- t[11] = 8
         "0000001" when "0001100", -- t[12] = 1
         "0000101" when "0001101", -- t[13] = 5
         "0001000" when "0001110", -- t[14] = 8
         "0001100" when "0001111", -- t[15] = 12
         "0000010" when "0010000", -- t[16] = 2
         "0000110" when "0010001", -- t[17] = 6
         "0001011" when "0010010", -- t[18] = 11
         "0001111" when "0010011", -- t[19] = 15
         "0000010" when "0010100", -- t[20] = 2
         "0001000" when "0010101", -- t[21] = 8
         "0001101" when "0010110", -- t[22] = 13
         "0010011" when "0010111", -- t[23] = 19
         "0000011" when "0011000", -- t[24] = 3
         "0001001" when "0011001", -- t[25] = 9
         "0010000" when "0011010", -- t[26] = 16
         "0010110" when "0011011", -- t[27] = 22
         "0000011" when "0011100", -- t[28] = 3
         "0001011" when "0011101", -- t[29] = 11
         "0010010" when "0011110", -- t[30] = 18
         "0011010" when "0011111", -- t[31] = 26
         "0000100" when "0100000", -- t[32] = 4
         "0001100" when "0100001", -- t[33] = 12
         "0010101" when "0100010", -- t[34] = 21
         "0011101" when "0100011", -- t[35] = 29
         "0000100" when "0100100", -- t[36] = 4
         "0001110" when "0100101", -- t[37] = 14
         "0010111" when "0100110", -- t[38] = 23
         "0100001" when "0100111", -- t[39] = 33
         "0000101" when "0101000", -- t[40] = 5
         "0001111" when "0101001", -- t[41] = 15
         "0011010" when "0101010", -- t[42] = 26
         "0100100" when "0101011", -- t[43] = 36
         "0000101" when "0101100", -- t[44] = 5
         "0010001" when "0101101", -- t[45] = 17
         "0011100" when "0101110", -- t[46] = 28
         "0101000" when "0101111", -- t[47] = 40
         "0000110" when "0110000", -- t[48] = 6
         "0010010" when "0110001", -- t[49] = 18
         "0011111" when "0110010", -- t[50] = 31
         "0101011" when "0110011", -- t[51] = 43
         "0000110" when "0110100", -- t[52] = 6
         "0010100" when "0110101", -- t[53] = 20
         "0100001" when "0110110", -- t[54] = 33
         "0101111" when "0110111", -- t[55] = 47
         "0000111" when "0111000", -- t[56] = 7
         "0010101" when "0111001", -- t[57] = 21
         "0100100" when "0111010", -- t[58] = 36
         "0110010" when "0111011", -- t[59] = 50
         "0000111" when "0111100", -- t[60] = 7
         "0010111" when "0111101", -- t[61] = 23
         "0100110" when "0111110", -- t[62] = 38
         "0110110" when "0111111", -- t[63] = 54
         "0001000" when "1000000", -- t[64] = 8
         "0011000" when "1000001", -- t[65] = 24
         "0101001" when "1000010", -- t[66] = 41
         "0111001" when "1000011", -- t[67] = 57
         "0001000" when "1000100", -- t[68] = 8
         "0011010" when "1000101", -- t[69] = 26
         "0101011" when "1000110", -- t[70] = 43
         "0111101" when "1000111", -- t[71] = 61
         "0001001" when "1001000", -- t[72] = 9
         "0011011" when "1001001", -- t[73] = 27
         "0101110" when "1001010", -- t[74] = 46
         "1000000" when "1001011", -- t[75] = 64
         "0001001" when "1001100", -- t[76] = 9
         "0011101" when "1001101", -- t[77] = 29
         "0110000" when "1001110", -- t[78] = 48
         "1000100" when "1001111", -- t[79] = 68
         "0001010" when "1010000", -- t[80] = 10
         "0011110" when "1010001", -- t[81] = 30
         "0110011" when "1010010", -- t[82] = 51
         "1000111" when "1010011", -- t[83] = 71
         "0001010" when "1010100", -- t[84] = 10
         "0100000" when "1010101", -- t[85] = 32
         "0110101" when "1010110", -- t[86] = 53
         "1001011" when "1010111", -- t[87] = 75
         "0001011" when "1011000", -- t[88] = 11
         "0100001" when "1011001", -- t[89] = 33
         "0111000" when "1011010", -- t[90] = 56
         "1001110" when "1011011", -- t[91] = 78
         "0001011" when "1011100", -- t[92] = 11
         "0100011" when "1011101", -- t[93] = 35
         "0111010" when "1011110", -- t[94] = 58
         "1010010" when "1011111", -- t[95] = 82
         "0001100" when "1100000", -- t[96] = 12
         "0100100" when "1100001", -- t[97] = 36
         "0111101" when "1100010", -- t[98] = 61
         "1010101" when "1100011", -- t[99] = 85
         "0001100" when "1100100", -- t[100] = 12
         "0100110" when "1100101", -- t[101] = 38
         "0111111" when "1100110", -- t[102] = 63
         "1011001" when "1100111", -- t[103] = 89
         "0001101" when "1101000", -- t[104] = 13
         "0100111" when "1101001", -- t[105] = 39
         "1000010" when "1101010", -- t[106] = 66
         "1011100" when "1101011", -- t[107] = 92
         "0001101" when "1101100", -- t[108] = 13
         "0101001" when "1101101", -- t[109] = 41
         "1000100" when "1101110", -- t[110] = 68
         "1100000" when "1101111", -- t[111] = 96
         "0001110" when "1110000", -- t[112] = 14
         "0101010" when "1110001", -- t[113] = 42
         "1000111" when "1110010", -- t[114] = 71
         "1100011" when "1110011", -- t[115] = 99
         "0001110" when "1110100", -- t[116] = 14
         "0101100" when "1110101", -- t[117] = 44
         "1001001" when "1110110", -- t[118] = 73
         "1100111" when "1110111", -- t[119] = 103
         "0001111" when "1111000", -- t[120] = 15
         "0101101" when "1111001", -- t[121] = 45
         "1001100" when "1111010", -- t[122] = 76
         "1101010" when "1111011", -- t[123] = 106
         "0001111" when "1111100", -- t[124] = 15
         "0101111" when "1111101", -- t[125] = 47
         "1001110" when "1111110", -- t[126] = 78
         "1101110" when "1111111", -- t[127] = 110
         "-------" when others;
end architecture;


--------------------------------------------------------------------------------
-- TermPowMult::Table instance for order-1 term Q_2.
-- Decomposition:
--   alpha_1,2 = 3; sigma'_1,2 = 1; wO_1,2 = 4.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_22_t1_t2 is
  port ( a : in  std_logic_vector(2 downto 0);
         s : in  std_logic_vector(0 downto 0);
         r : out std_logic_vector(3 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_22_t1_t2 is
  signal x : std_logic_vector(3 downto 0);
begin
  x <= a & s;

  with x select
    r <= "0000" when "0000", -- t[0] = 0
         "0000" when "0001", -- t[1] = 0
         "0000" when "0010", -- t[2] = 0
         "0010" when "0011", -- t[3] = 2
         "0001" when "0100", -- t[4] = 1
         "0011" when "0101", -- t[5] = 3
         "0001" when "0110", -- t[6] = 1
         "0101" when "0111", -- t[7] = 5
         "0010" when "1000", -- t[8] = 2
         "0110" when "1001", -- t[9] = 6
         "0010" when "1010", -- t[10] = 2
         "1000" when "1011", -- t[11] = 8
         "0011" when "1100", -- t[12] = 3
         "1001" when "1101", -- t[13] = 9
         "0011" when "1110", -- t[14] = 3
         "1011" when "1111", -- t[15] = 11
         "----" when others;
end architecture;


--------------------------------------------------------------------------------
-- TermPowMult instance for order-1 term.
-- Decomposition:
--   alpha_1 = 5; beta_1 = 5; lambda_1 = 5;  m_1 = 2;
--   Pow   (AdHoc);
--   Q_1,1 (ROM):  alpha_1,1 = 5; rho_1,1 = 0; sigma_1,1 = 3; wO_1,1 = 7;
--   Q_1,2 (ROM):  alpha_1,2 = 3; rho_1,2 = 3; sigma_1,2 = 2; wO_1,2 = 4.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_22_t1 is
  port ( a : in  std_logic_vector(4 downto 0);
         b : in  std_logic_vector(4 downto 0);
         r : out std_logic_vector(13 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_22_t1 is
  signal sign   : std_logic;
  signal b0     : std_logic_vector(3 downto 0);
  signal s      : std_logic_vector(4 downto 0);
  component fp_exp_exp_y2_22_t1_pow is
    port ( x : in  std_logic_vector(3 downto 0);
           r : out std_logic_vector(4 downto 0) );
  end component;

  signal a_1    : std_logic_vector(4 downto 0);
  signal sign_1 : std_logic;
  signal s_1    : std_logic_vector(1 downto 0);
  signal r0_1   : std_logic_vector(6 downto 0);
  signal r_1    : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_22_t1_t1 is
    port ( a : in  std_logic_vector(4 downto 0);
           s : in  std_logic_vector(1 downto 0);
           r : out std_logic_vector(6 downto 0) );
  end component;

  signal a_2    : std_logic_vector(2 downto 0);
  signal sign_2 : std_logic;
  signal s_2    : std_logic_vector(0 downto 0);
  signal r0_2   : std_logic_vector(3 downto 0);
  signal r_2    : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_22_t1_t2 is
    port ( a : in  std_logic_vector(2 downto 0);
           s : in  std_logic_vector(0 downto 0);
           r : out std_logic_vector(3 downto 0) );
  end component;
begin
  sign <= not b(4);
  b0 <= b(3 downto 0) xor (3 downto 0 => sign);

  pow : fp_exp_exp_y2_22_t1_pow
    port map ( x => b0,
               r => s );

  a_1 <= a(4 downto 0);
  sign_1 <= not s(4);
  s_1 <= s(3 downto 2) xor (3 downto 2 => sign_1);
  t_1 : fp_exp_exp_y2_22_t1_t1
    port map ( a => a_1,
               s => s_1,
               r => r0_1 );
  r_1(6 downto 0) <=
    r0_1 xor (6 downto 0 => ((sign xor sign_1)));
  r_1(13 downto 7) <= (13 downto 7 => ((sign xor sign_1)));

  a_2 <= a(4 downto 2);
  sign_2 <= not s(1);
  s_2 <= s(0 downto 0) xor (0 downto 0 => sign_2);
  t_2 : fp_exp_exp_y2_22_t1_t2
    port map ( a => a_2,
               s => s_2,
               r => r0_2 );
  r_2(3 downto 0) <=
    r0_2 xor (3 downto 0 => ((sign xor sign_2)));
  r_2(13 downto 4) <= (13 downto 4 => ((sign xor sign_2)));

  r <= r_1 + r_2;
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_22_t1_clk is
  port ( a   : in  std_logic_vector(4 downto 0);
         b   : in  std_logic_vector(4 downto 0);
         r   : out std_logic_vector(13 downto 0);
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_exp_y2_22_t1_clk is
  signal sign   : std_logic;
  signal b0     : std_logic_vector(3 downto 0);
  signal s      : std_logic_vector(4 downto 0);
  component fp_exp_exp_y2_22_t1_pow is
    port ( x : in  std_logic_vector(3 downto 0);
           r : out std_logic_vector(4 downto 0) );
  end component;

  signal a_1     : std_logic_vector(4 downto 0);
  signal sign_1  : std_logic;
  signal s_1     : std_logic_vector(1 downto 0);
  signal r0_10   : std_logic_vector(6 downto 0);
  signal r0_1r   : std_logic_vector(6 downto 0);
  signal r_1     : std_logic_vector(13 downto 0);
  signal sign_10 : std_logic;
  signal sign_1r : std_logic;
  component fp_exp_exp_y2_22_t1_t1 is
    port ( a : in  std_logic_vector(4 downto 0);
           s : in  std_logic_vector(1 downto 0);
           r : out std_logic_vector(6 downto 0) );
  end component;

  signal a_2     : std_logic_vector(2 downto 0);
  signal sign_2  : std_logic;
  signal s_2     : std_logic_vector(0 downto 0);
  signal r0_20   : std_logic_vector(3 downto 0);
  signal r0_2r   : std_logic_vector(3 downto 0);
  signal r_2     : std_logic_vector(13 downto 0);
  signal sign_20 : std_logic;
  signal sign_2r : std_logic;
  component fp_exp_exp_y2_22_t1_t2 is
    port ( a : in  std_logic_vector(2 downto 0);
           s : in  std_logic_vector(0 downto 0);
           r : out std_logic_vector(3 downto 0) );
  end component;
begin
  sign <= not b(4);
  b0 <= b(3 downto 0) xor (3 downto 0 => sign);

  pow : fp_exp_exp_y2_22_t1_pow
    port map ( x => b0,
               r => s );

  a_1 <= a(4 downto 0);
  sign_1 <= not s(4);
  s_1 <= s(3 downto 2) xor (3 downto 2 => sign_1);
  sign_10 <= sign xor sign_1;
  t_1 : fp_exp_exp_y2_22_t1_t1
    port map ( a => a_1,
               s => s_1,
               r => r0_10 );
  r_1(6 downto 0) <=
    r0_1r xor (6 downto 0 => sign_1r);
  r_1(13 downto 7) <= (13 downto 7 => sign_1r);

  a_2 <= a(4 downto 2);
  sign_2 <= not s(1);
  s_2 <= s(0 downto 0) xor (0 downto 0 => sign_2);
  sign_20 <= sign xor sign_2;
  t_2 : fp_exp_exp_y2_22_t1_t2
    port map ( a => a_2,
               s => s_2,
               r => r0_20 );
  r_2(3 downto 0) <=
    r0_2r xor (3 downto 0 => sign_2r);
  r_2(13 downto 4) <= (13 downto 4 => sign_2r);

  process(clk)
  begin
    if clk'event and clk = '1' then
      r0_1r   <= r0_10;
      sign_1r <= sign_10;
      r0_2r   <= r0_20;
      sign_2r <= sign_20;
    end if;
  end process;
  
  r <= r_1 + r_2;
end architecture;


--------------------------------------------------------------------------------
-- HOTBM main component.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_22 is
  port ( x : in  std_logic_vector(10 downto 0);
         r : out std_logic_vector(11 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_22 is
  signal a_0 : std_logic_vector(5 downto 0);
  signal r_0 : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_22_t0 is
    port ( a : in  std_logic_vector(5 downto 0);
           r : out std_logic_vector(13 downto 0) );
  end component;

  signal a_1 : std_logic_vector(4 downto 0);
  signal b_1 : std_logic_vector(4 downto 0);
  signal r_1 : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_22_t1 is
    port ( a : in  std_logic_vector(4 downto 0);
           b : in  std_logic_vector(4 downto 0);
           r : out std_logic_vector(13 downto 0) );
  end component;

  signal sum : std_logic_vector(13 downto 0);
begin
  a_0 <= x(10 downto 5);
  t_0 : fp_exp_exp_y2_22_t0
    port map ( a => a_0,
               r => r_0 );

  a_1 <= x(10 downto 6);
  b_1 <= x(4 downto 0);
  t_1 : fp_exp_exp_y2_22_t1
    port map ( a => a_1,
               b => b_1,
               r => r_1 );

  sum <= r_0 + r_1;
  r <= sum(13 downto 2);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_22_clk is
  port ( x   : in  std_logic_vector(10 downto 0);
         r   : out std_logic_vector(11 downto 0);
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_exp_y2_22_clk is
  signal a_x0 : std_logic_vector(5 downto 0);
  signal a_xr : std_logic_vector(5 downto 0);
  signal r_0  : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_22_t0 is
    port ( a : in  std_logic_vector(5 downto 0);
           r : out std_logic_vector(13 downto 0) );
  end component;

  signal a_1 : std_logic_vector(4 downto 0);
  signal b_1 : std_logic_vector(4 downto 0);
  signal r_1 : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_22_t1_clk is
    port ( a   : in  std_logic_vector(4 downto 0);
           b   : in  std_logic_vector(4 downto 0);
           r   : out std_logic_vector(13 downto 0);
           clk : in  std_logic );
  end component;

  signal sum : std_logic_vector(13 downto 0);
begin
  a_x0 <= x(10 downto 5);
  t_0 : fp_exp_exp_y2_22_t0
    port map ( a => a_xr,
               r => r_0 );

  process(clk)
  begin
    if clk'event and clk = '1' then
      a_xr <= a_x0;
    end if;
  end process;

  a_1 <= x(10 downto 6);
  b_1 <= x(4 downto 0);
  t_1 : fp_exp_exp_y2_22_t1_clk
    port map ( a   => a_1,
               b   => b_1,
               r   => r_1,
               clk => clk );

  sum <= r_0 + r_1;
  r <= sum(13 downto 2);
end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- HOTBM instance for function e^x-x-1.
-- wI = 12; wO = 12.
-- Order-1 polynomial approximation.
-- Decomposition:
--   alpha = 6; beta = 6;
--   T_0 (ROM):     alpha_0 = 6; beta_0 = 0;
--   T_1 (PowMult): alpha_1 = 6; beta_1 = 6.
-- Guard bits: g = 1.
-- Command line: exp 12 12 1   rom 6 0   pm 6 6  ah 6 6 6  1 0  6 6 0


--------------------------------------------------------------------------------
-- TermROM instance for order-0 term.
-- Decomposition:
--   alpha_0 = 6; beta_0 = 0; wO_0 = 13.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_23_t0 is
  port ( a : in  std_logic_vector(5 downto 0);
         r : out std_logic_vector(13 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_23_t0 is
  signal x0   : std_logic_vector(5 downto 0);
  signal r0   : std_logic_vector(12 downto 0);
begin
  x0 <= a;

  with x0 select
    r0 <= "0000000000010" when "000000", -- t[0] = 2
          "0000000000110" when "000001", -- t[1] = 6
          "0000000001110" when "000010", -- t[2] = 14
          "0000000011010" when "000011", -- t[3] = 26
          "0000000101010" when "000100", -- t[4] = 42
          "0000000111110" when "000101", -- t[5] = 62
          "0000001010110" when "000110", -- t[6] = 86
          "0000001110010" when "000111", -- t[7] = 114
          "0000010010001" when "001000", -- t[8] = 145
          "0000010110101" when "001001", -- t[9] = 181
          "0000011011101" when "001010", -- t[10] = 221
          "0000100001001" when "001011", -- t[11] = 265
          "0000100111001" when "001100", -- t[12] = 313
          "0000101101101" when "001101", -- t[13] = 365
          "0000110100101" when "001110", -- t[14] = 421
          "0000111100001" when "001111", -- t[15] = 481
          "0001000100001" when "010000", -- t[16] = 545
          "0001001100101" when "010001", -- t[17] = 613
          "0001010101101" when "010010", -- t[18] = 685
          "0001011111001" when "010011", -- t[19] = 761
          "0001101001001" when "010100", -- t[20] = 841
          "0001110011101" when "010101", -- t[21] = 925
          "0001111110101" when "010110", -- t[22] = 1013
          "0010001010001" when "010111", -- t[23] = 1105
          "0010010110001" when "011000", -- t[24] = 1201
          "0010100010101" when "011001", -- t[25] = 1301
          "0010101111101" when "011010", -- t[26] = 1405
          "0010111101001" when "011011", -- t[27] = 1513
          "0011001011001" when "011100", -- t[28] = 1625
          "0011011001101" when "011101", -- t[29] = 1741
          "0011101000101" when "011110", -- t[30] = 1861
          "0011111000001" when "011111", -- t[31] = 1985
          "0100001000001" when "100000", -- t[32] = 2113
          "0100011000101" when "100001", -- t[33] = 2245
          "0100101001101" when "100010", -- t[34] = 2381
          "0100111011010" when "100011", -- t[35] = 2522
          "0101001101010" when "100100", -- t[36] = 2666
          "0101011111110" when "100101", -- t[37] = 2814
          "0101110010110" when "100110", -- t[38] = 2966
          "0110000110010" when "100111", -- t[39] = 3122
          "0110011010010" when "101000", -- t[40] = 3282
          "0110101110110" when "101001", -- t[41] = 3446
          "0111000011110" when "101010", -- t[42] = 3614
          "0111011001010" when "101011", -- t[43] = 3786
          "0111101111010" when "101100", -- t[44] = 3962
          "1000000101110" when "101101", -- t[45] = 4142
          "1000011100110" when "101110", -- t[46] = 4326
          "1000110100010" when "101111", -- t[47] = 4514
          "1001001100011" when "110000", -- t[48] = 4707
          "1001100100111" when "110001", -- t[49] = 4903
          "1001111101111" when "110010", -- t[50] = 5103
          "1010010111011" when "110011", -- t[51] = 5307
          "1010110001011" when "110100", -- t[52] = 5515
          "1011001011111" when "110101", -- t[53] = 5727
          "1011100110111" when "110110", -- t[54] = 5943
          "1100000010011" when "110111", -- t[55] = 6163
          "1100011110100" when "111000", -- t[56] = 6388
          "1100111011000" when "111001", -- t[57] = 6616
          "1101011000000" when "111010", -- t[58] = 6848
          "1101110101100" when "111011", -- t[59] = 7084
          "1110010011100" when "111100", -- t[60] = 7324
          "1110110010001" when "111101", -- t[61] = 7569
          "1111010001001" when "111110", -- t[62] = 7817
          "1111110000101" when "111111", -- t[63] = 8069
          "-------------" when others;

  r(12 downto 0) <= r0;
  r(13 downto 13) <= (13 downto 13 => ('0'));
end architecture;


--------------------------------------------------------------------------------
-- PowerAdHoc instance for order-1 powering unit.
-- Decomposition:
--   beta_1 = 6; mu_1 = 6; lambda_1 = 6.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_23_t1_pow is
  port ( x : in  std_logic_vector(4 downto 0);
         r : out std_logic_vector(5 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_23_t1_pow is
  signal pp0 : std_logic_vector(4 downto 0);
  signal r0 : std_logic_vector(4 downto 0);
begin
  pp0(4) <= x(4);

  pp0(3) <= x(3);

  pp0(2) <= x(2);

  pp0(1) <= x(1);

  pp0(0) <= x(0);

  r0 <= pp0;
  r <= "1" & r0(4 downto 0);
end architecture;


--------------------------------------------------------------------------------
-- TermPowMult::Table instance for order-1 term Q_1.
-- Decomposition:
--   alpha_1,1 = 6; wO_1,1 = 8.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_23_t1_t1 is
  port ( a : in  std_logic_vector(5 downto 0);
         r : out std_logic_vector(7 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_23_t1_t1 is
  signal x : std_logic_vector(5 downto 0);
begin
  x <= a;

  with x select
    r <= "00000010" when "000000", -- t[0] = 2
         "00000110" when "000001", -- t[1] = 6
         "00001010" when "000010", -- t[2] = 10
         "00001110" when "000011", -- t[3] = 14
         "00010010" when "000100", -- t[4] = 18
         "00010110" when "000101", -- t[5] = 22
         "00011010" when "000110", -- t[6] = 26
         "00011110" when "000111", -- t[7] = 30
         "00100010" when "001000", -- t[8] = 34
         "00100110" when "001001", -- t[9] = 38
         "00101010" when "001010", -- t[10] = 42
         "00101110" when "001011", -- t[11] = 46
         "00110010" when "001100", -- t[12] = 50
         "00110110" when "001101", -- t[13] = 54
         "00111010" when "001110", -- t[14] = 58
         "00111110" when "001111", -- t[15] = 62
         "01000010" when "010000", -- t[16] = 66
         "01000110" when "010001", -- t[17] = 70
         "01001010" when "010010", -- t[18] = 74
         "01001110" when "010011", -- t[19] = 78
         "01010010" when "010100", -- t[20] = 82
         "01010110" when "010101", -- t[21] = 86
         "01011010" when "010110", -- t[22] = 90
         "01011110" when "010111", -- t[23] = 94
         "01100010" when "011000", -- t[24] = 98
         "01100110" when "011001", -- t[25] = 102
         "01101010" when "011010", -- t[26] = 106
         "01101110" when "011011", -- t[27] = 110
         "01110010" when "011100", -- t[28] = 114
         "01110110" when "011101", -- t[29] = 118
         "01111010" when "011110", -- t[30] = 122
         "01111110" when "011111", -- t[31] = 126
         "10000010" when "100000", -- t[32] = 130
         "10000110" when "100001", -- t[33] = 134
         "10001010" when "100010", -- t[34] = 138
         "10001110" when "100011", -- t[35] = 142
         "10010010" when "100100", -- t[36] = 146
         "10010110" when "100101", -- t[37] = 150
         "10011010" when "100110", -- t[38] = 154
         "10011110" when "100111", -- t[39] = 158
         "10100010" when "101000", -- t[40] = 162
         "10100110" when "101001", -- t[41] = 166
         "10101010" when "101010", -- t[42] = 170
         "10101110" when "101011", -- t[43] = 174
         "10110010" when "101100", -- t[44] = 178
         "10110110" when "101101", -- t[45] = 182
         "10111010" when "101110", -- t[46] = 186
         "10111110" when "101111", -- t[47] = 190
         "11000010" when "110000", -- t[48] = 194
         "11000110" when "110001", -- t[49] = 198
         "11001010" when "110010", -- t[50] = 202
         "11001110" when "110011", -- t[51] = 206
         "11010010" when "110100", -- t[52] = 210
         "11010110" when "110101", -- t[53] = 214
         "11011010" when "110110", -- t[54] = 218
         "11011110" when "110111", -- t[55] = 222
         "11100010" when "111000", -- t[56] = 226
         "11100110" when "111001", -- t[57] = 230
         "11101010" when "111010", -- t[58] = 234
         "11101110" when "111011", -- t[59] = 238
         "11110010" when "111100", -- t[60] = 242
         "11110110" when "111101", -- t[61] = 246
         "11111010" when "111110", -- t[62] = 250
         "11111110" when "111111", -- t[63] = 254
         "--------" when others;
end architecture;


--------------------------------------------------------------------------------
-- TermPowMult instance for order-1 term.
-- Decomposition:
--   alpha_1 = 6; beta_1 = 6; lambda_1 = 6;  m_1 = 1;
--   Pow   (AdHoc);
--   Q_1,1 (Mult): alpha_1,1 = 6; rho_1,1 = 0; sigma_1,1 = 6; wO_1,1 = 8.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_23_t1 is
  port ( a : in  std_logic_vector(5 downto 0);
         b : in  std_logic_vector(5 downto 0);
         r : out std_logic_vector(13 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_23_t1 is
  signal sign   : std_logic;
  signal b0     : std_logic_vector(4 downto 0);
  signal s      : std_logic_vector(5 downto 0);
  component fp_exp_exp_y2_23_t1_pow is
    port ( x : in  std_logic_vector(4 downto 0);
           r : out std_logic_vector(5 downto 0) );
  end component;

  signal a_1    : std_logic_vector(5 downto 0);
  signal sign_1 : std_logic;
  signal s_1    : std_logic_vector(4 downto 0);
  signal k_1    : std_logic_vector(7 downto 0);
  signal r0_1   : std_logic_vector(14 downto 0);
  signal r_1    : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_23_t1_t1 is
    port ( a : in  std_logic_vector(5 downto 0);
           r : out std_logic_vector(7 downto 0) );
  end component;
begin
  sign <= not b(5);
  b0 <= b(4 downto 0) xor (4 downto 0 => sign);

  pow : fp_exp_exp_y2_23_t1_pow
    port map ( x => b0,
               r => s );

  a_1 <= a(5 downto 0);
  sign_1 <= not s(5);
  s_1 <= s(4 downto 0) xor (4 downto 0 => sign_1);
  t_1 : fp_exp_exp_y2_23_t1_t1
    port map ( a => a_1,
               r => k_1 );
  r0_1 <= "0" & (k_1 * (s_1 & "1"));
  r_1(7 downto 0) <=
    r0_1(14 downto 7) xor (14 downto 7 => ((sign xor sign_1)));
  r_1(13 downto 8) <= (13 downto 8 => ((sign xor sign_1)));

  r <= r_1;
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_fp_exp.all;

entity fp_exp_exp_y2_23_t1_clk is
  port ( a   : in  std_logic_vector(5 downto 0);
         b   : in  std_logic_vector(5 downto 0);
         r   : out std_logic_vector(13 downto 0);
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_exp_y2_23_t1_clk is
  signal sign   : std_logic;
  signal b0     : std_logic_vector(4 downto 0);
  signal s      : std_logic_vector(5 downto 0);
  component fp_exp_exp_y2_23_t1_pow is
    port ( x : in  std_logic_vector(4 downto 0);
           r : out std_logic_vector(5 downto 0) );
  end component;

  signal a_1     : std_logic_vector(5 downto 0);
  signal sign_1  : std_logic;
  signal s_1     : std_logic_vector(5 downto 0);
  signal k_1     : std_logic_vector(7 downto 0);
  signal r0_1    : std_logic_vector(14 downto 0);
  signal r_1     : std_logic_vector(13 downto 0);
  signal sign_x0 : std_logic;
  signal sign_xr : std_logic;
  component fp_exp_exp_y2_23_t1_t1 is
    port ( a : in  std_logic_vector(5 downto 0);
           r : out std_logic_vector(7 downto 0) );
  end component;
begin
  sign <= not b(5);
  b0 <= b(4 downto 0) xor (4 downto 0 => sign);

  pow : fp_exp_exp_y2_23_t1_pow
    port map ( x => b0,
               r => s );

  a_1 <= a(5 downto 0);
  sign_1 <= not s(5);
  s_1 <= "1" & (s(4 downto 0) xor (4 downto 0 => sign_1));
  t_1 : fp_exp_exp_y2_23_t1_t1
    port map ( a => a_1,
               r => k_1 );

  mult_r0_1 : mult_clk
    generic map ( wX    => 8,
                  wY    => 6,
                  first => 1,
                  steps => 3 )
    port map ( nX  => k_1,
               nY  => s_1,
               nR  => r0_1(13 downto 0),
               clk => clk );
  r0_1(14) <= '0';

  sign_x0 <= sign xor sign_1;
  process(clk)
  begin
    if clk'event and clk = '1' then
      sign_xr <= sign_x0;
    end if;
  end process;

  r_1(7 downto 0) <=
    r0_1(14 downto 7) xor (14 downto 7 => sign_xr);
  r_1(13 downto 8) <= (13 downto 8 => sign_xr);

  r <= r_1;
end architecture;


--------------------------------------------------------------------------------
-- HOTBM main component.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_23 is
  port ( x : in  std_logic_vector(11 downto 0);
         r : out std_logic_vector(12 downto 0) );
end entity;

architecture arch of fp_exp_exp_y2_23 is
  signal a_0 : std_logic_vector(5 downto 0);
  signal r_0 : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_23_t0 is
    port ( a : in  std_logic_vector(5 downto 0);
           r : out std_logic_vector(13 downto 0) );
  end component;

  signal a_1 : std_logic_vector(5 downto 0);
  signal b_1 : std_logic_vector(5 downto 0);
  signal r_1 : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_23_t1 is
    port ( a : in  std_logic_vector(5 downto 0);
           b : in  std_logic_vector(5 downto 0);
           r : out std_logic_vector(13 downto 0) );
  end component;

  signal sum : std_logic_vector(13 downto 0);
begin
  a_0 <= x(11 downto 6);
  t_0 : fp_exp_exp_y2_23_t0
    port map ( a => a_0,
               r => r_0 );

  a_1 <= x(11 downto 6);
  b_1 <= x(5 downto 0);
  t_1 : fp_exp_exp_y2_23_t1
    port map ( a => a_1,
               b => b_1,
               r => r_1 );

  sum <= r_0 + r_1;
  r <= sum(13 downto 1);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fp_exp_exp_y2_23_clk is
  port ( x   : in  std_logic_vector(11 downto 0);
         r   : out std_logic_vector(12 downto 0);
         clk : in  std_logic );
end entity;

architecture arch of fp_exp_exp_y2_23_clk is
  signal a_x0 : std_logic_vector(5 downto 0);
  signal a_xr : std_logic_vector(5 downto 0);
  signal r_0  : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_23_t0 is
    port ( a : in  std_logic_vector(5 downto 0);
           r : out std_logic_vector(13 downto 0) );
  end component;

  signal a_1 : std_logic_vector(5 downto 0);
  signal b_1 : std_logic_vector(5 downto 0);
  signal r_1 : std_logic_vector(13 downto 0);
  component fp_exp_exp_y2_23_t1_clk is
    port ( a   : in  std_logic_vector(5 downto 0);
           b   : in  std_logic_vector(5 downto 0);
           r   : out std_logic_vector(13 downto 0);
           clk : in  std_logic );
  end component;

  signal sum : std_logic_vector(13 downto 0);
begin
  a_x0 <= x(11 downto 6);
  t_0 : fp_exp_exp_y2_23_t0
    port map ( a => a_xr,
               r => r_0 );

  process(clk)
  begin
    if clk'event and clk = '1' then
      a_xr <= a_x0;
    end if;
  end process;

  a_1 <= x(11 downto 6);
  b_1 <= x(5 downto 0);
  t_1 : fp_exp_exp_y2_23_t1_clk
    port map ( a   => a_1,
               b   => b_1,
               r   => r_1,
               clk => clk );

  sum <= r_0 + r_1;
  r <= sum(13 downto 1);
end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_fp_exp.all;
use work.pkg_fp_exp_exp_y2.all;

entity fp_exp_exp_y2 is
  generic ( wF : positive );
  port ( nY2    : in  std_logic_vector(fp_exp_wy2(wF)-1 downto 0);
         nExpY2 : out std_logic_vector(fp_exp_wy2(wF) downto 0) );
end entity;

architecture arch of fp_exp_exp_y2 is
begin

  exp_y2_6 : if wF = 6 generate
    exp_y2 : fp_exp_exp_y2_6
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_7 : if wF = 7 generate
    exp_y2 : fp_exp_exp_y2_7
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_8 : if wF = 8 generate
    exp_y2 : fp_exp_exp_y2_8
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_9 : if wF = 9 generate
    exp_y2 : fp_exp_exp_y2_9
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_10 : if wF = 10 generate
    exp_y2 : fp_exp_exp_y2_10
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_11 : if wF = 11 generate
    exp_y2 : fp_exp_exp_y2_11
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_12 : if wF = 12 generate
    exp_y2 : fp_exp_exp_y2_12
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_13 : if wF = 13 generate
    exp_y2 : fp_exp_exp_y2_13
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_14 : if wF = 14 generate
    exp_y2 : fp_exp_exp_y2_14
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_15 : if wF = 15 generate
    exp_y2 : fp_exp_exp_y2_15
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_16 : if wF = 16 generate
    exp_y2 : fp_exp_exp_y2_16
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_17 : if wF = 17 generate
    exp_y2 : fp_exp_exp_y2_17
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_18 : if wF = 18 generate
    exp_y2 : fp_exp_exp_y2_18
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_19 : if wF = 19 generate
    exp_y2 : fp_exp_exp_y2_19
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_20 : if wF = 20 generate
    exp_y2 : fp_exp_exp_y2_20
      port map ( x => nY2,
                 r => nExpY2 );
  end generate;

  exp_y2_21 : if wF = 21 generate
    exp_y2 : fp_exp_exp_y2_21
      port map ( x => nY2,
                 r => nExpY2 );
  end generate;

  exp_y2_22 : if wF = 22 generate
    exp_y2 : fp_exp_exp_y2_22
      port map ( x => nY2,
                 r => nExpY2 );
  end generate;

  exp_y2_23 : if wF = 23 generate
    exp_y2 : fp_exp_exp_y2_23
      port map ( x => nY2,
                 r => nExpY2 );
  end generate;

end architecture;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.pkg_fp_exp.all;
use work.pkg_fp_exp_exp_y2.all;

entity fp_exp_exp_y2_clk is
  generic ( wF : positive );
  port ( nY2    : in  std_logic_vector(fp_exp_wy2(wF)-1 downto 0);
         nExpY2 : out std_logic_vector(fp_exp_wy2(wF) downto 0);
         clk    : in  std_logic );
end entity;

architecture arch of fp_exp_exp_y2_clk is
begin

  exp_y2_6 : if wF = 6 generate
    exp_y2 : fp_exp_exp_y2_6
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_7 : if wF = 7 generate
    exp_y2 : fp_exp_exp_y2_7
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_8 : if wF = 8 generate
    exp_y2 : fp_exp_exp_y2_8
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_9 : if wF = 9 generate
    exp_y2 : fp_exp_exp_y2_9
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_10 : if wF = 10 generate
    exp_y2 : fp_exp_exp_y2_10
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_11 : if wF = 11 generate
    exp_y2 : fp_exp_exp_y2_11
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_12 : if wF = 12 generate
    exp_y2 : fp_exp_exp_y2_12
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_13 : if wF = 13 generate
    exp_y2 : fp_exp_exp_y2_13
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_14 : if wF = 14 generate
    exp_y2 : fp_exp_exp_y2_14
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_15 : if wF = 15 generate
    exp_y2 : fp_exp_exp_y2_15
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_16 : if wF = 16 generate
    exp_y2 : fp_exp_exp_y2_16
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_17 : if wF = 17 generate
    exp_y2 : fp_exp_exp_y2_17
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_18 : if wF = 18 generate
    exp_y2 : fp_exp_exp_y2_18
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_19 : if wF = 19 generate
    exp_y2 : fp_exp_exp_y2_19
      port map ( nY2    => nY2,
                 nExpY2 => nExpY2(fp_exp_wy2(wF) downto 1) );
    nExpY2(0) <= '0';
  end generate;

  exp_y2_20 : if wF = 20 generate
    exp_y2 : fp_exp_exp_y2_20_clk
      port map ( x   => nY2,
                 r   => nExpY2,
                 clk => clk );
  end generate;

  exp_y2_21 : if wF = 21 generate
    exp_y2 : fp_exp_exp_y2_21_clk
      port map ( x   => nY2,
                 r   => nExpY2,
                 clk => clk );
  end generate;

  exp_y2_22 : if wF = 22 generate
    exp_y2 : fp_exp_exp_y2_22_clk
      port map ( x   => nY2,
                 r   => nExpY2,
                 clk => clk );
  end generate;

  exp_y2_23 : if wF = 23 generate
    exp_y2 : fp_exp_exp_y2_23_clk
      port map ( x   => nY2,
                 r   => nExpY2,
                 clk => clk );
  end generate;

end architecture;

