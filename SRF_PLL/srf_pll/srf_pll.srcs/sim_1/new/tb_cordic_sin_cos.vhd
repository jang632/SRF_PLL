library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cordic_sin_cos is
end tb_cordic_sin_cos;

architecture behavior of tb_cordic_sin_cos is

    component cordic_sin_cos
        PORT(
            clk        : IN  STD_LOGIC;
            reset      : IN  STD_LOGIC;
            theta      : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
            sin_value  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            cos_value  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            iterations : IN  INTEGER RANGE 1 TO 16
        );
    end component;

    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '1';
    signal theta      : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal sin_value  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal cos_value  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal iterations : INTEGER := 16;

    constant clk_period : time := 10 ns;

    constant PI        : signed(31 downto 0) := to_signed(843314857, 32);
    constant HALF_PI   : signed(31 downto 0) := to_signed(421657429, 32);
    constant TWO_PI    : signed(31 downto 0) := to_signed(1686629714, 32);
    constant PI_3_2    : signed(31 downto 0) := to_signed(1264972286, 32);
    constant PI_1_4    : signed(31 downto 0) := to_signed(210828714, 32);
    constant variable_rad    : signed(31 downto 0) := x"78000000";

begin

    uut: cordic_sin_cos
        PORT MAP (
            clk        => clk,
            reset      => reset,
            theta      => theta,
            sin_value  => sin_value,
            cos_value  => cos_value,
            iterations => iterations
        );

    clk_process : process
    begin
        while now < 1000 ns loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    stim_proc : process
    begin
        -- reset
        wait for 20 ns;
        reset <= '0';

        -- theta = 0
        theta <= std_logic_vector(to_signed(0, 32));
        wait for 10 ns;

        -- theta = π/4
        theta <= std_logic_vector(PI_1_4);
        wait for 10 ns;

        -- theta = π/2
        theta <= std_logic_vector(HALF_PI);
        wait for 10 ns;

        -- theta = π
        theta <= std_logic_vector(PI);
        wait for 10 ns;

        -- theta = 3π/2
        theta <= std_logic_vector(PI_3_2);
        wait for 10 ns;

        -- theta = 2π
        theta <= std_logic_vector(TWO_PI);
        wait for 10 ns;
        
        theta <= std_logic_vector(variable_rad);
        wait for 10 ns;

        wait;
    end process;

end behavior;
