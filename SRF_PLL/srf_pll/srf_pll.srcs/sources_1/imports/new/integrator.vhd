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

entity integrator is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        ce       : in  std_logic;
        data_in  : in  signed(31 downto 0);
        data_out : out signed(31 downto 0)
    );
end integrator;

architecture Behavioral of integrator is

    constant K           : signed(31 downto 0) := x"00004189";
    constant TWO_PI      : signed(63 downto 0) := x"00323d70a3d70a3e";
    
    signal d_data_in     : signed(31 downto 0);
    signal r_add         : signed(31 downto 0);
    signal r_mult        : signed(63 downto 0); 
    signal r_data_out    : signed(63 downto 0);
    signal n_data_out    : signed(31 downto 0);

begin
    
     process(clk)
     begin
        if (rising_edge(clk)) then
            if(rst = '1') then 
                d_data_in <= (others => '0');
            else
                if (ce = '1') then
                    d_data_in <= data_in;
                end if;
            end if;
        end if;
      end process;
     
     process(clk)
     variable v_add  : signed(31 downto 0);
     variable v_mult : signed(63 downto 0); 
     begin
        if(rising_edge(clk)) then 
            if (rst = '1') then 
                r_data_out <= (others => '0');
                r_mult     <= (others => '0');
                r_add      <= (others => '0');
            else
                if(ce = '1') then

                    v_mult     := K*(data_in + d_data_in);
                    r_data_out <= r_data_out + v_mult;
                    
                    if (r_data_out > TWO_PI) then
                        r_data_out <= (others => '0');
                    elsif (r_data_out < x"0000000000000000") then
                        r_data_out <= r_data_out + TWO_PI;
                    end if;

                end if;
            end if;
         end if;
      end process;
      
      data_out <= shift_left(r_data_out(63 downto 32), 9);
      
end Behavioral;
