library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity tb_notch_filter is
end tb_notch_filter;

architecture tb of tb_notch_filter is

    constant CLK_PERIOD : time := 20 us;
    constant Ts : real := 1.0/50000.0;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal ce       : std_logic := '1';
    signal data_in  : signed(31 downto 0) := (others => '0');
    signal data_out : signed(31 downto 0);

begin

    uut: entity work.notch_filter
        port map (
            clk      => clk,
            rst      => rst,
            ce       => ce,
            data_in  => data_in,
            data_out => data_out
        );

    clk <= not clk after CLK_PERIOD/2;

    process
    variable n : integer := 0;
    variable t : real := 0.0;
    variable sig : real := 0.0;
    begin
        rst <= '1';
        ce <= '1';
        wait for 40 us;
        rst <= '0';

        for i in 0 to 10000 loop
            t := Ts*real(n);
            wait until rising_edge(clk);
            sig := sin(2*10*math_pi*t) + sin(2*100*math_pi*t);
            data_in <= to_signed(integer(sig*2.0**24),32);
            n := n+1;
        end loop;

        wait;
    end process;

end tb;