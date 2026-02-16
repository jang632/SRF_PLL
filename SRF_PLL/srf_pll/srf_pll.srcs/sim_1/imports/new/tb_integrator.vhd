library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_integrator is
end entity;

architecture tb of tb_integrator is

    constant CLK_PERIOD : time := 10 ns;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal data_in  : signed(31 downto 0) := (others=>'0'); 
    signal data_out : signed(31 downto 0);

begin

    -- =========================
    -- Clock
    -- =========================
    clk <= not clk after CLK_PERIOD/2;

    -- =========================
    -- DUT instancja
    -- =========================
    uut: entity work.integrator
        port map (
            clk      => clk,
            rst      => rst,
            data_in  => data_in,
            data_out => data_out
        );

    -- =========================
    -- Stimulus proces - Q20
    -- =========================
    stim_proc: process
    begin
        -- reset
        rst <= '1';
        wait for 2*CLK_PERIOD;
        rst <= '0';

        -- proste próbki w Q20
        data_in <= to_signed(0,32); wait for CLK_PERIOD;
        data_in <= to_signed(0,32); wait for CLK_PERIOD;
        data_in <= to_signed(1048576,32); wait for CLK_PERIOD; -- 1.0 Q20
        data_in <= to_signed(1048576,32); wait for CLK_PERIOD;
        data_in <= to_signed(1048576,32); wait for CLK_PERIOD;
        data_in <= to_signed(1048576,32); wait for CLK_PERIOD;
        data_in <= to_signed(0,32); wait for CLK_PERIOD;

        -- zatrzymaj symulację
        wait;
    end process;

end architecture;
