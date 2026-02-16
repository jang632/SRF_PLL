library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.pkg.all;

entity tb_pi_controller is
end tb_pi_controller;

architecture sim of tb_pi_controller is

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal data_in  : signed(31 downto 0) := (others => '0');
    signal data_out : signed(31 downto 0);

    -- Parametry symulacji (Real)
    constant CLK_PERIOD : time := 10 ns;
    constant SCALE_24   : real := 16777216.0; -- 2^24 (format Q24)
    
    -- Sygnały pomocnicze do obserwacji w symulatorze (Waveform)
    signal debug_feedback : real := 0.0;
    signal debug_setpoint : real := 1.0; -- Zadajemy skok na 1.0
    signal debug_error    : real := 0.0;

begin

    -- Instancja Twojego kontrolera
    dut : entity work.pi_controller
        port map (
            clk      => clk,
            rst      => rst,
            data_in  => data_in,
            data_out => data_out
        );

    -- Generator zegara
    clk <= not clk after CLK_PERIOD/2;

    -- PROCES SYMULACJI OBIEKTU (Zamknięcie pętli)
    process
        -- Parametry modelu obiektu G(s) = 1 / (tau*s + 1)
        -- a_obj i b_obj wyliczone dla Ts = 10ns i tau = 1ms (przykładowo)
        -- y[n] = a*y[n-1] + b*u[n]
        variable v_feedback : real := 0.0;
        variable v_setpoint : real := 1.0; -- Wartość zadana (skok jednostkowy)
        variable v_error    : real := 0.0;
        variable v_u_float  : real := 0.0;
        
        -- Współczynniki modelu fizycznego (dobrane, by widzieć ruch na wykresie)
        constant a_obj : real := 0.9995; 
        constant b_obj : real := 0.0005;
    begin
        -- Reset systemu
        rst <= '1';
        data_in <= (others => '0');
        wait for 100 ns;
        rst <= '0';

        -- Pętla sterowania (Loop feedback)
        -- Będzie działać przez 10000 cykli, co pozwoli zobaczyć odpowiedź
        for i in 0 to 10000 loop
            wait until rising_edge(clk);
            
            -- 1. Oblicz błąd (Setpoint - Feedback)
            v_error := v_setpoint - v_feedback;
            
            -- 2. Podaj błąd na wejście kontrolera (Konwersja na Q24)
            data_in <= to_signed(integer(v_error * SCALE_24), 32);
            
            -- 3. Pozwól kontrolerowi przetworzyć dane (opóźnienie o 1-2 cykle)
            wait until rising_edge(clk);
            
            -- 4. Odczytaj wyjście kontrolera i przelicz fizykę obiektu
            -- Przyjmujemy, że data_out to też Q24 (jeśli masz inne Q, zmień SCALE)
            v_u_float := real(to_integer(data_out)) / SCALE_24;
            
            -- Równanie różnicowe obiektu (Inercja)
            v_feedback := (a_obj * v_feedback) + (b_obj * v_u_float);
            
            -- Przypisanie do sygnałów debugowania (widoczne w oknie Waveform jako Analog)
            debug_feedback <= v_feedback;
            debug_setpoint <= v_setpoint;
            debug_error    <= v_error;
            
        end loop;

        report "Symulacja zakonczona. Sprawdz wykresy!";
        wait;
    end process;

end sim;