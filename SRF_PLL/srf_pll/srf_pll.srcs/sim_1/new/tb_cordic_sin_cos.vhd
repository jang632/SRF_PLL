library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY tb_cordic_sin_cos IS
END tb_cordic_sin_cos;

ARCHITECTURE behavior OF tb_cordic_sin_cos IS

    COMPONENT cordic_sin_cos
        GENERIC (
            iterations : INTEGER
        );
        PORT(
            clk       : IN  STD_LOGIC;
            reset     : IN  STD_LOGIC;
            theta     : IN  SIGNED(31 DOWNTO 0);
            sin_value : OUT SIGNED(31 DOWNTO 0);
            cos_value : OUT SIGNED(31 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk        : STD_LOGIC := '0';
    SIGNAL reset      : STD_LOGIC := '1';
    SIGNAL theta      : SIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sin_value  : SIGNED(31 DOWNTO 0);
    SIGNAL cos_value  : SIGNED(31 DOWNTO 0);
    SIGNAL iterations : INTEGER := 16;

    CONSTANT clk_period : TIME := 10 ns;

    CONSTANT PI        : SIGNED(31 DOWNTO 0) := to_signed(843314857, 32);
    CONSTANT HALF_PI   : SIGNED(31 DOWNTO 0) := to_signed(421657429, 32);
    CONSTANT TWO_PI    : SIGNED(31 DOWNTO 0) := to_signed(1686629714, 32);
    CONSTANT PI_3_2    : SIGNED(31 DOWNTO 0) := to_signed(1264972286, 32);
    CONSTANT PI_1_4    : SIGNED(31 DOWNTO 0) := to_signed(210828714, 32);
    CONSTANT VARIABLE_RAD : SIGNED(31 DOWNTO 0) := x"78000000";

BEGIN

    uut: cordic_sin_cos
        GENERIC MAP (
            iterations => iterations
        )
        PORT MAP (
            clk       => clk,
            reset     => reset,
            theta     => theta,
            sin_value => sin_value,
            cos_value => cos_value
        );

    clk_process : PROCESS
    BEGIN
        WHILE now < 1000 ns LOOP
            clk <= '0';
            WAIT FOR clk_period / 2;
            clk <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
        WAIT;
    END PROCESS;

    stim_proc : PROCESS
    BEGIN
        WAIT FOR 20 ns;
        reset <= '0';

        theta <= to_signed(0, 32);
        WAIT FOR 10 ns;

        theta <= PI_1_4;
        WAIT FOR 10 ns;

        theta <= HALF_PI;
        WAIT FOR 10 ns;

        theta <= PI;
        WAIT FOR 10 ns;

        theta <= PI_3_2;
        WAIT FOR 10 ns;

        theta <= TWO_PI;
        WAIT FOR 10 ns;

        theta <= VARIABLE_RAD;
        WAIT FOR 10 ns;

        WAIT;
    END PROCESS;

END behavior;
