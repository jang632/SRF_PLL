
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ema_filter is
    Port(
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
end EMA_filter;

architecture Behavioral of ema_filter is
type pipeline is array (0 to 1) of signed(31 downto 0);
SIGNAL ema_pip : pipeline;
SIGNAL ema_val : signed(31 downto 0) := (others => '0');

begin
    PROCESS(clk)
    BEGIN
        IF(reset = '1') THEN
            ema_val <= (others => '0');
            data_out <= (others => '0');
        ELSIF(rising_edge(clk)) THEN
            ema_val <= ema_val + shift_right(signed(data_in) - ema_val, 9);
            data_out <= STD_LOGIC_VECTOR(ema_val);
        END IF;
    END PROCESS;           

end Behavioral;
