library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_shift_register is
end tb_shift_register;

architecture Behavioral of tb_shift_register is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal v_alpha   : std_logic_vector(31 downto 0) := (others => '0');
    signal v_beta    : std_logic_vector(31 downto 0) := (others => '0');
    signal v_alpha_del : std_logic_vector(31 downto 0);
    signal v_beta_del  : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: entity work.shift_register
        port map (
            clk       => clk,
            reset     => reset,
            v_alpha   => v_alpha,
            v_beta    => v_beta,
            v_alpha_del => v_alpha_del,
            v_beta_del  => v_beta_del
        );

    clk_process : process
    begin
        while True loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    stim_proc: process
    begin

        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        v_alpha <= x"00010001";
        v_beta  <= x"00020002";
        wait for clk_period;

        v_alpha <= x"00030003";
        v_beta  <= x"00040004";
        wait for clk_period;

        v_alpha <= x"00050005";
        v_beta  <= x"00060006";
        wait for clk_period;

        wait for clk_period * 20;

        v_alpha <= x"000A000A";
        v_beta  <= x"000B000B";
        wait for clk_period * 20;

        wait;
    end process;

end Behavioral;
