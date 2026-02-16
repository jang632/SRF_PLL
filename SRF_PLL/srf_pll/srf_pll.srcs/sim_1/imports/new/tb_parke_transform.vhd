library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_parke_transform is
end entity;

architecture tb of tb_parke_transform is

    constant CLK_PERIOD : time := 10 ns;

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';

    signal v_alpha : signed(31 downto 0);
    signal v_beta  : signed(31 downto 0);
    signal theta   : signed(31 downto 0);

    signal v_d     : signed(31 downto 0);
    signal v_q     : signed(31 downto 0);

    -- =====================================
    -- Fixed-point Q28 vectors
    -- =====================================

    type vec_t is array (natural range <>) of signed(31 downto 0);

    constant alpha_vec : vec_t := (
        to_signed( 0, 32),
        to_signed( 67108864, 32),    -- 0.25
        to_signed(134217728, 32),    -- 0.5
        to_signed( 67108864, 32),
        to_signed( 0, 32),
        to_signed(-67108864, 32),
        to_signed(-134217728, 32),
        to_signed(-67108864, 32)
    );

    constant beta_vec : vec_t := (
        to_signed(134217728, 32),    -- 0.5
        to_signed( 67108864, 32),
        to_signed( 0, 32),
        to_signed(-67108864, 32),
        to_signed(-134217728, 32),
        to_signed(-67108864, 32),
        to_signed( 0, 32),
        to_signed( 67108864, 32)
    );

begin

    -- =====================================
    -- Clock
    -- =====================================
    clk <= not clk after CLK_PERIOD/2;

    -- =====================================
    -- DUT
    -- =====================================
    uut : entity work.parke_transform
        port map (
            clk     => clk,
            rst     => rst,
            v_alpha => v_alpha,
            v_beta  => v_beta,
            theta   => theta,
            v_d     => v_d,
            v_q     => v_q
        );

    -- =====================================
    -- Stimulus
    -- =====================================
    stim_proc : process
    begin
        -- theta = pi/6 = 0.5235987756 → Q28
        theta <= to_signed(140552476, 32);

        v_alpha <= (others => '0');
        v_beta  <= (others => '0');

        -- reset
        rst <= '1';
        wait for 5 * CLK_PERIOD;
        rst <= '0';

        -- feed samples
        for i in alpha_vec'range loop
            wait until rising_edge(clk);
            v_alpha <= alpha_vec(i);
            v_beta  <= beta_vec(i);
        end loop;

        -- flush pipeline (CORDIC + delay)
        for i in 0 to 40 loop
            wait until rising_edge(clk);
        end loop;

        report "TB Q28 finished." severity note;
        wait;
    end process;

end architecture;
