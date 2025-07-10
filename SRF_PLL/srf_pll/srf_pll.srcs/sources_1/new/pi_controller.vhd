
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pi_controller is
    Port(
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        error_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        omega_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
end pi_controller;

architecture Behavioral of pi_controller is
    CONSTANT kiTs : signed(31 DOWNTO 0) := x"00066666";
    CONSTANT kp : signed(31 DOWNTO 0) := x"42800000";
    SIGNAL integrator : signed(63 DOWNTO 0);
    SIGNAL omega_int : signed(63 DOWNTO 0);
begin   
    PROCESS(clk)
    BEGIN 
        IF(reset = '1') THEN 
            integrator <= (others => '0');
            omega_int <= (others => '0');
        ELSIF(rising_edge(clk)) THEN                   
            integrator <= integrator + signed(error_in)*kiTs;
            omega_int <=  integrator + kp*signed(error_in);  
                    
            IF(integrator > x"03e8000000000000") THEN 
                integrator <=  x"03e8000000000000";
            ELSIF(integrator < x"fc18000000000000") THEN 
                integrator <= x"fc18000000000000";
            END IF;
            
        END IF;
    END PROCESS;        

omega_out <= STD_LOGIC_VECTOR(shift_left(omega_int(63 DOWNTO 32),2));

end Behavioral;
