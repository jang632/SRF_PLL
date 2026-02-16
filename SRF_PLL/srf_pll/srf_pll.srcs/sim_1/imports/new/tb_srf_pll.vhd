library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity tb_srf_pll is
end entity;

architecture tb of tb_srf_pll is

    constant WIDTH : integer := 16;

    -- Parametry sygnału
    constant FS        : real := 64000.0;       -- Hz
    constant F_SIGNAL  : real := 50.0;          -- Hz
    constant SLOW_PER  : time := 15.625 us;     -- 64 kHz
    constant FAST_PER  : time := 100 ns;        -- 10 MHz
    constant AMP       : real := 0.9;

    -- Harmoniczne - Amplitudy
    constant H3_AMP  : real := 0.1;
    constant H5_AMP  : real := 0.1;
    constant H7_AMP  : real := 0.08;

    -- Harmoniczne - Przesunięcia fazowe (w stopniach)
    -- Różne fazy zmieniają kształt fali (np. robią ją bardziej "szpiczastą" lub płaską)
    constant H1_PHASE_DEG : real := 44.0;   -- Faza podstawowa
    constant H3_PHASE_DEG : real := 0.0;  -- Przesunięcie 3. harmonicznej
    constant H5_PHASE_DEG : real := 0.0; -- Przesunięcie 5. harmonicznej
    constant H7_PHASE_DEG : real := 0.0; -- Przesunięcie 7. harmonicznej

    constant ADC_MAX : real := 2.0**(WIDTH-1) - 1.0;

    signal clk      : std_logic := '0';
    signal slw_clk  : std_logic := '0';
    signal rst      : std_logic := '0';

    signal v_n      : signed(WIDTH-1 downto 0);
    signal omega    : signed(31 downto 0);
    signal phase    : signed(31 downto 0);

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    uut : entity work.srf_pll
        port map (
            clk     => clk,
            rst     => rst,
            v_n     => v_n,
            omega   => omega,
            phase   => phase
        );

    --------------------------------------------------------------------
    -- Zegary
    --------------------------------------------------------------------
    clk <= not clk after FAST_PER/2;
    slw_clk <= not slw_clk after SLOW_PER/2;

    --------------------------------------------------------------------
    -- Generator próbek
    --------------------------------------------------------------------
    process
        variable n      : integer := 500;
        variable t      : real;
        variable v_real : real;
        variable v_int  : integer;
        
        -- Zmienne pomocnicze do przeliczenia stopni na radiany
        constant RAD_CONV : real := math_pi / 180.0;
        variable phi1     : real := H1_PHASE_DEG * RAD_CONV;
        variable phi3     : real := H3_PHASE_DEG * RAD_CONV;
        variable phi5     : real := H5_PHASE_DEG * RAD_CONV;
        variable phi7     : real := H7_PHASE_DEG * RAD_CONV;
        
    begin
        -- Reset
        rst <= '1';
        v_n <= (others => '0');
        wait for 5*SLOW_PER;
        rst <= '0';

        -- Próbki
        while n < 80000 loop
            wait until rising_edge(slw_clk);

            t := real(n) / FS;

            -------------------------------------------------------------
            -- LOGIKA ZANIKU NAPIĘCIA (VOLTAGE DIP)
            -------------------------------------------------------------
            if (n >= 30000 and n < 50000) then
                v_real := 0.0;
            else
                -- SINUS + HARMONICZNE Z FAZAMI
                -- Wzór: A * sin(2*pi*f*t + faza_w_radianach)
                v_real := 
                    AMP * sin(2.0 * math_pi * F_SIGNAL * t + phi1) +
                    AMP * H3_AMP * sin(2.0 * math_pi * 3.0 * F_SIGNAL * t + phi3) +
                    AMP * H5_AMP * sin(2.0 * math_pi * 5.0 * F_SIGNAL * t + phi5) +
                    AMP * H7_AMP * sin(2.0 * math_pi * 7.0 * F_SIGNAL * t + phi7);
            end if;
            -------------------------------------------------------------

            v_int := integer(v_real * ADC_MAX);

            -- Zabezpieczenie (saturacja)
            if v_int > integer(ADC_MAX) then v_int := integer(ADC_MAX); end if;
            if v_int < -integer(ADC_MAX) then v_int := -integer(ADC_MAX); end if;

            v_n <= to_signed(v_int, WIDTH);

            n := n + 1;
        end loop;

        wait;
    end process;

end architecture;