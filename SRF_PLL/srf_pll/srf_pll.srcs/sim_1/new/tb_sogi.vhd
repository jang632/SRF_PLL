library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity tb_sogi is
end tb_sogi;

architecture behavior of tb_sogi is
    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';
    signal v_in  : std_logic_vector(31 downto 0);
    signal v_out : std_logic_vector(31 downto 0);
    signal qv    : std_logic_vector(31 downto 0);

    file txt_file : text;
begin
    -- Instancja DUT
    DUT: entity work.sogi
        port map (
            clk   => clk,
            reset => reset,
            v_in  => v_in,
            v_out => v_out,
            qv    => qv
        );

    -- Zegar 64 kHz (okres 15,625 µs = 7812 ns high + 7812 ns low)
    clk_gen : process
    begin
        while true loop
            clk <= '0'; wait for 7812 ns;
            clk <= '1'; wait for 7812 ns;
        end loop;
    end process;

    -- Bodźce - wczytywanie próbek z pliku tekstowego
    stimulus_proc : process
        variable line_buf : line;
        variable col1_txt : std_logic_vector(31 downto 0);
        variable vg_temp  : signed(31 downto 0);
    begin
        -- Reset
        v_in  <= (others => '0');
        reset <= '1';
        wait for 23000 ns;
        reset <= '0';

        -- Otwórz plik z danymi sinusoidalnymi
        file_open(txt_file, "SinglePhaseHarmonics_64kHz_32bit.txt", read_mode);

        while not endfile(txt_file) loop
            readline(txt_file, line_buf);
            read(line_buf, col1_txt);
            
            -- Konwersja 16-bit do 32-bit (z przesunięciem w górę do Q28)
            vg_temp := signed(col1_txt);
            v_in <= std_logic_vector(shift_right(vg_temp,3));

            wait for 15625 ns; -- krok czasowy próbkowania
        end loop;

        file_close(txt_file);
        wait;
    end process;
end behavior;
