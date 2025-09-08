library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shift_register is
    Port (
        clk       : IN STD_LOGIC;
        reset     : IN STD_LOGIC;
        v_alpha   : IN SIGNED(31 DOWNTO 0);
        v_beta    : IN SIGNED(31 DOWNTO 0);
        v_alpha_del : OUT SIGNED(31 DOWNTO 0);
        v_beta_del  : OUT SIGNED(31 DOWNTO 0)
    );
end shift_register;

architecture Behavioral of shift_register is

    TYPE delay_array is array(0 to 14) of SIGNED(31 DOWNTO 0);
    SIGNAL alpha_delay_line : delay_array := (others => (others => '0'));
    SIGNAL beta_delay_line  : delay_array := (others => (others => '0'));

begin

    PROCESS(clk)
    BEGIN
        IF reset = '1' THEN 
            alpha_delay_line <= (others => (others => '0'));
            beta_delay_line  <= (others => (others => '0'));
            v_alpha_del      <= (others => '0');
            v_beta_del       <= (others => '0');
        ELSIF rising_edge(clk) THEN
            FOR i IN 14 DOWNTO 1 LOOP
                alpha_delay_line(i) <= alpha_delay_line(i - 1);
                beta_delay_line(i)  <= beta_delay_line(i - 1);
            END LOOP;
            alpha_delay_line(0) <= v_alpha;
            beta_delay_line(0)  <= v_beta;
            v_alpha_del <= alpha_delay_line(14);
            v_beta_del  <= beta_delay_line(14);
        END IF;
    END PROCESS;

end Behavioral;
