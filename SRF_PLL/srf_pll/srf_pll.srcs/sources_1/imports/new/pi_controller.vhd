library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package pkg is
    type t_array is array (natural range <>) of signed;
end package;

package body pkg is
end package body;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.pkg.all;


entity pi_controller is
port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    ce       : in  std_logic;
    data_in  : in  signed(31 downto 0);
    data_out : out signed(31 downto 0)
);
end pi_controller;

architecture Behavioral of pi_controller is

signal d_data_in : signed(31 downto 0);
signal u         : signed(63 downto 0);

--constant b0 : signed(31 downto 0) := x"32020C4A"; -- float: 50.0080
--constant b1 : signed(31 downto 0) := x"CE020C4A"; -- float: -49.9920

--constant W0         : signed(63 downto 0) := x"013a28c59d544a70";
--constant leak_coeff : signed(31 downto 0) := x"7ffffea8";
constant b0 : signed(31 downto 0) := x"00B7113D"; -- float: 0.7151
constant b1 : signed(31 downto 0) := x"FF4D0757";

constant W0         : signed(63 downto 0) := x"013a28c59d544a70";
constant leak_coeff : signed(31 downto 0) := x"7fffffff";

function truncate(data_in : signed; limit : signed) return signed is
    variable data_out : signed(data_in'range);
begin
    if data_in > limit then
        data_out := limit;
    elsif data_in < -limit then
        data_out := -limit;
    else
        data_out := data_in;
    end if;  
    return data_out;
end function;

begin

 
 process(clk)
 begin
    if (rising_edge(clk)) then
        if(rst = '1') then 
            d_data_in <= (others => '0');
        else
            if(ce = '1') then
                d_data_in <= data_in;
            end if;
        end if;
    end if;
 end process;

process(clk)
variable t0 : signed(63 downto 0);
variable t1 : signed(63 downto 0);
variable t3 : signed(63 downto 0);
begin
    if (rising_edge(clk)) then
        if(rst = '1') then
           u <= W0;
        else
           if(ce = '1') then
               t0 := b0 * data_in;
               t1 := b1 * d_data_in;
               t3 := leak_coeff*u(63 downto 32);
               u  <= shift_left(t3,1) + t0 + t1;
           end if;
        end if;
    end if;
end process;

data_out <= shift_left(u(63 downto 32),4); 

end Behavioral;
