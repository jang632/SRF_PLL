library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity enable_generator is
    generic(
        COUNT : integer := 156
    );
    port(
        clk        : in  std_logic;
        rst        : in  std_logic;
        enable_out : out std_logic
    );
end enable_generator;

architecture Behavioral of enable_generator is

signal counter : unsigned(15 downto 0);

begin

process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            counter    <= (others => '0');
            enable_out <= '0';
        else
            if(counter < COUNT-1) then 
                counter    <= counter + 1;
                enable_out <= '0';
            else
                counter    <= (others => '0');
                enable_out <= '1';
            end if;
        end if;
    end if;
end process;

end Behavioral;
