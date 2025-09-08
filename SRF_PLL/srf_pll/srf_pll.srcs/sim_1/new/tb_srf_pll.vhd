library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

ENTITY tb_srf_pll IS
END tb_srf_pll;

ARCHITECTURE behavior OF tb_srf_pll IS

    SIGNAL clk   : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';
    SIGNAL v_a   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL v_b   : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL v_c   : STD_LOGIC_VECTOR(15 DOWNTO 0);

    SIGNAL omega : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL phase : STD_LOGIC_VECTOR(63 DOWNTO 0);

    FILE txt_file : TEXT;

BEGIN

    DUT: ENTITY work.srf_pll
        PORT MAP (
            clk   => clk,
            reset => reset,
            v_a   => v_a,
            v_b   => v_b,
            v_c   => v_c,
            omega => omega,
            phase => phase
        );

    clk_gen : PROCESS
    BEGIN
        WHILE TRUE LOOP
            clk <= '0'; WAIT FOR 7812 ns;
            clk <= '1'; WAIT FOR 7812 ns;
        END LOOP;
    END PROCESS;

    stimulus_proc : PROCESS
        VARIABLE line_buf : LINE;
        VARIABLE col1_txt : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE col2_txt : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE col3_txt : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        v_a <= (OTHERS => '0');
        v_b <= (OTHERS => '0');
        v_c <= (OTHERS => '0');
        reset <= '1';
        WAIT FOR 25000 ns;
        reset <= '0';

        FILE_OPEN(txt_file, "ThreePhaseHarmonics_64kHz_16bit.txt", READ_MODE);

        WHILE NOT ENDFILE(txt_file) LOOP
            READLINE(txt_file, line_buf);
            READ(line_buf, col1_txt);
            READ(line_buf, col2_txt);
            READ(line_buf, col3_txt);

            v_a <= col1_txt;
            v_b <= col2_txt;
            v_c <= col3_txt;

            WAIT FOR 15625 ns;
        END LOOP;

        FILE_CLOSE(txt_file);
        WAIT;
    END PROCESS;

END behavior;
