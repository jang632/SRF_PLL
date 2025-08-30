library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity psc is
    PORT( 
        clk      : IN STD_LOGIC;
        reset    : IN  STD_LOGIC;
        alpha_v  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alpha_qv : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        beta_v   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        beta_qv  : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alpha    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        beta     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
     );
end psc;

architecture Behavioral of psc is

begin

PROCESS(clk) 
BEGIN 
    IF(rising_edge(clk)) THEN 
        IF(reset = '1') THEN 
            alpha <= (OTHERS => '0');
            beta  <= (OTHERS => '0');
        ELSE 
            alpha <= STD_LOGIC_VECTOR(shift_right(signed(alpha_v) - signed(beta_qv),1));
            beta <= STD_LOGIC_VECTOR(shift_right(signed(alpha_qv) + signed(beta_v),1));
        END IF; 
    END IF;
END PROCESS;

end Behavioral;
