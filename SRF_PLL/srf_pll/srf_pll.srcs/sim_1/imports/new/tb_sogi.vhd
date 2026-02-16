library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity tb_sogi is
end entity;

architecture tb of tb_sogi is
    constant WIDTH : integer := 16;

    constant FS        : real := 64000.0;
    constant F_SIGNAL  : real := 50.0;
    constant CLK_PER   : time := 15.625 us;
    constant AMP       : real := 0.5;

    constant H3_AMP  : real := 0.08;
    constant H5_AMP  : real := 0.05;
    constant H7_AMP  : real := 0.07;
    constant H13_AMP : real := 0.07;
    constant H14_AMP : real := 0.05;

    constant ADC_MAX : real := 2.0**(WIDTH-1) - 1.0;

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal v_n     : signed(WIDTH-1 downto 0);
    signal v   : signed(2*WIDTH-1 downto 0);
    signal qv  : signed(2*WIDTH-1 downto 0);

begin

    uut : entity work.sogi
        generic map (
            WIDTH => WIDTH
        )
        port map (
            clk     => clk,
            rst     => rst,
            v_n     => v_n,
            v       => v,
            qv      => qv
        );

    clk <= not clk after CLK_PER/2;

    process
        variable n      : integer := 0;
        variable t      : real;
        variable v_real : real;
        variable v_int  : integer;
    begin
        rst <= '1';
        v_n <= (others => '0');
        wait for CLK_PER;
        rst <= '0';

        while n < 6000 loop
            wait until rising_edge(clk);

            t := real(n) / FS;

            v_real :=
                AMP * sin(2.0 * math_pi * F_SIGNAL * t) +
                AMP * H3_AMP  * sin(2.0 * math_pi * 3.0  * F_SIGNAL * t) +
                AMP * H5_AMP  * sin(2.0 * math_pi * 5.0  * F_SIGNAL * t) +
                AMP * H7_AMP  * sin(2.0 * math_pi * 7.0  * F_SIGNAL * t) +
                AMP * H13_AMP * sin(2.0 * math_pi * 13.0 * F_SIGNAL * t) +
                AMP * H14_AMP * sin(2.0 * math_pi * 14.0 * F_SIGNAL * t);

            v_int := integer(v_real * ADC_MAX);

            if v_int > integer(ADC_MAX) then
                v_int := integer(ADC_MAX);
            elsif v_int < -integer(ADC_MAX) then
                v_int := -integer(ADC_MAX);
            end if;

            v_n <= to_signed(v_int, WIDTH);
            n := n + 1;
        end loop;

        wait;
    end process;

end architecture;
