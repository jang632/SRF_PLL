library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pi_controller is
end tb_pi_controller;

architecture behavior of tb_pi_controller is

    signal clk        : std_logic := '0';
    signal reset      : std_logic := '1';
    signal error_in   : std_logic_vector(31 downto 0) := (others => '0');
    signal omega_out  : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

begin

    DUT: entity work.pi_controller
        port map (
            clk       => clk,
            reset     => reset,
            error_in  => error_in,
            omega_out => omega_out
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

 stimulus_process: process
begin

    reset <= '1';
    error_in <= (others => '0');
    wait for 20 ns;

    reset <= '0';
    wait for 20 ns;

    -- 0.0
    error_in <= x"00000000";
    wait for 100 ns;

    -- 1.0
    error_in <= x"10000000";
    wait for 100 ns;

    -- 2.0
    error_in <= x"20000000";
    wait for 100 ns;

    -- 3.0
    error_in <= x"30000000";
    wait for 100 ns;

    -- 4.0
    error_in <= x"40000000";
    wait for 200 ns;

    -- Zjazd w dół: -1.0
    error_in <= x"F0000000";
    wait for 100 ns;

    -- -2.0
    error_in <= x"E0000000";
    wait for 100 ns;

    error_in <= x"00000000";
    wait;

end process;


end behavior;
