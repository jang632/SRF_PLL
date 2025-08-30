library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity srf_pll is
    PORT (
        clk    : IN  STD_LOGIC;                         -- 1MHz
        reset  : IN  STD_LOGIC;
        v_a    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);     -- 14 bit binary point
        v_b    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);     -- 14 bit binary point
        v_c    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);     -- 14 bit binary point
        omega  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);     -- 16 bit binary point
        phase  : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)      -- 60 bit binary point
    );
end srf_pll;

architecture Behavioral of srf_pll is

    SIGNAL v_alpha         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL v_beta          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    SIGNAL theta           : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL v_d             : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL v_q             : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL omega_int       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL theta_int       : signed(63 DOWNTO 0);
    SIGNAL theta_64        : STD_LOGIC_VECTOR(63 DOWNTO 0);

    CONSTANT Ts            : signed(31 DOWNTO 0) := x"00000863";

    SIGNAL v_q_ema         : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');

    component parke_transform
        Port (
            clk   : IN  STD_LOGIC;
            reset : IN  STD_LOGIC;
            v_a   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_b   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_c   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            theta : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            v_d   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            v_q   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;

    component pi_controller
        Port (
            clk       : IN  STD_LOGIC;
            reset     : IN  STD_LOGIC;
            error_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            omega_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;

    component ema_filter is
        Port (
            clk      : IN  STD_LOGIC;
            reset    : IN  STD_LOGIC;
            data_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    end component;

BEGIN

    parke_inst : parke_transform
        port map (
            clk     => clk,
            reset   => reset,
            v_a     => v_a,
            v_b     => v_b,
            v_c     => v_c,
            theta   => theta,
            v_d     => v_d,
            v_q     => v_q
        );

    pi_ctrl_inst : pi_controller
        port map (
            clk       => clk,
            reset     => reset,
            error_in  => v_q_ema,
            omega_out => omega_int
        );

    ema_inst : ema_filter
        port map (
            clk      => clk,
            reset    => reset,
            data_in  => v_q,
            data_out => v_q_ema
        );

    PROCESS(clk)
    BEGIN
        IF (reset = '1') THEN
            theta_int <= (others => '0');
        ELSIF rising_edge(clk) THEN
            theta_int <= theta_int + shift_left(signed(omega_int) * Ts, 13);
            IF (theta_int > x"6487ED5110BBA800") THEN
                theta_int <= theta_int - x"6487ED5110BBA800";
            ELSIF (theta_int < x"0000000000000000") THEN
                theta_int <= theta_int + x"6487ED5110BBA800";
            END IF;
        END IF;
    END PROCESS;

    theta <= STD_LOGIC_VECTOR(theta_int(63 DOWNTO 32));
    omega <= omega_int;
    phase <= STD_LOGIC_VECTOR(theta_int);

end Behavioral;
