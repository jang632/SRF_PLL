library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY pi_controller IS
    PORT (
        clk       : IN  STD_LOGIC;
        reset     : IN  STD_LOGIC;
        error_in  : IN  SIGNED(31 DOWNTO 0);
        omega_out : OUT SIGNED(31 DOWNTO 0)
    );
END pi_controller;

ARCHITECTURE Behavioral OF pi_controller IS

    CONSTANT kiTs       : SIGNED(31 DOWNTO 0) := x"00013000";
    CONSTANT kp         : SIGNED(31 DOWNTO 0) := x"1C800000";
    SIGNAL integrator   : SIGNED(63 DOWNTO 0);
    SIGNAL omega_int    : SIGNED(63 DOWNTO 0);

BEGIN

    PROCESS(clk)
    BEGIN
        IF reset = '1' THEN
            integrator <= x"0051B2E0BED80000";
            omega_int  <= x"0146B9C34774D610";
        ELSIF rising_edge(clk) THEN
                integrator <= integrator + error_in * kiTs;
                omega_int  <= integrator + kp * error_in;

                IF integrator > x"03E8000000000000" THEN
                    integrator <= x"03E8000000000000";
                ELSIF integrator < x"FC18000000000000" THEN
                    integrator <= x"FC18000000000000";
                END IF;
        END IF;
    END PROCESS;

    omega_out <= shift_left(omega_int(63 DOWNTO 32), 2);

END Behavioral;
