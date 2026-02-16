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

    clk <= not clk after CLK_PERIOD/2;

    uut: entity work.integrator
        port map (
            clk      => clk,
            rst      => rst,
            data_in  => data_in,
            data_out => data_out
        );

    stim_proc: process
    begin
        rst <= '1';
        wait for 2*CLK_PERIOD;
        rst <= '0';

        data_in <= to_signed(0,32); wait for CLK_PERIOD;
        data_in <= to_signed(0,32); wait for CLK_PERIOD;
        data_in <= to_signed(1048576,32); wait for CLK_PERIOD;
        data_in <= to_signed(1048576,32); wait for CLK_PERIOD;
        data_in <= to_signed(1048576,32); wait for CLK_PERIOD;
        data_in <= to_signed(1048576,32); wait for CLK_PERIOD;
        data_in <= to_signed(0,32); wait for CLK_PERIOD;

        wait;
    end process;

end architecture;
