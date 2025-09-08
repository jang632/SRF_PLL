library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity tb_clarke_transform is
end tb_clarke_transform;

architecture Behavioral of tb_clarke_transform is

    SIGNAL clk     : STD_LOGIC := '0';
    SIGNAL reset   : STD_LOGIC := '0';
    SIGNAL v_a     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL v_b     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL v_c     : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL v_alpha : SIGNED(31 DOWNTO 0);
    SIGNAL v_beta  : SIGNED(31 DOWNTO 0);

    FILE txt_file : TEXT;

BEGIN

    -- Instancja modułu
    DUT: ENTITY work.clarke_transform
        PORT MAP (
            clk     => clk,
            reset   => reset,
            v_a     => v_a,
            v_b     => v_b,
            v_c     => v_c,
            v_alpha => v_alpha,
            v_beta  => v_beta
        );

    -- Generator zegara
    clk_gen : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '0'; WAIT FOR 5 ns;
            clk <= '1'; WAIT FOR 5 ns;
        END LOOP;
    END PROCESS;

    -- Proces generujący sygnały wejściowe z pliku
    stimulus_proc : PROCESS
        VARIABLE line_buf : LINE;
        VARIABLE col1_txt : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE col2_txt : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE col3_txt : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN

        -- Reset początkowy
        v_a   <= (OTHERS => '0');
        v_b   <= (OTHERS => '0');
        v_c   <= (OTHERS => '0');
        reset <= '1';
        WAIT FOR 20 ns;
        reset <= '0';

        -- Otwieranie pliku z danymi
        FILE_OPEN(txt_file, "ThreePhaseSim.txt", READ_MODE);

        -- Czytanie danych z pliku i podawanie na wejścia
        WHILE NOT ENDFILE(txt_file) LOOP
            READLINE(txt_file, line_buf);
            READ(line_buf, col1_txt);
            READ(line_buf, col2_txt);
            READ(line_buf, col3_txt);

            v_a <= col1_txt;
            v_b <= col2_txt;
            v_c <= col3_txt;

            WAIT FOR 10 ns;
        END LOOP;

        FILE_CLOSE(txt_file);
        WAIT;
    END PROCESS;

END Behavioral;
