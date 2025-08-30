
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sogi is
    PORT(
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        v_in  : IN STD_LOGIC_VECTOR (31 DOWNTO 0); --28
        v_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        qv    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
end sogi;

architecture Behavioral of sogi is
SIGNAL v_int : signed(63 DOWNTO 0);--30
SIGNAL qv_int : signed(63 DOWNTO 0);--60
CONSTANT Ts : signed(31 DOWNTO 0) := x"00001062"; --32b/28
CONSTANT k : signed(31 DOWNTO 0) := x"0199999a"; --32b/28
CONSTANT omega_int : signed(31 DOWNTO 0) := x"013a28c6"; --32b/16
CONSTANT k_omega : signed(31 DOWNTO 0) := x"01f6a7a3"; --32b/20
begin

PROCESS(clk)
variable v_var : signed(63 DOWNTO 0); --60
variable qv_var : signed(63 DOWNTO 0);--60

variable diff1 : signed(31 DOWNTO 0);--60

variable mult1 : signed(63 DOWNTO 0);
variable mult2 : signed(95 DOWNTO 0);
variable mult3 : signed(95 DOWNTO 0);
variable mult4 : signed(95 DOWNTO 0);

variable dv : signed(63 DOWNTO 0);
variable dqv : signed(95 DOWNTO 0);

BEGIN 
        
     IF(rising_edge(clk)) THEN     
        IF(reset = '1') THEN 
            v_out <= (others => '0');
            qv <= (others => '0');          
            v_var := (others => '0');
            qv_var := x"0000000000000000";
            mult1 := (others => '0');
            mult2 := (others => '0');
            mult3 := (others => '0');
            mult4 := (others => '0');
        ELSE
            diff1 := signed(v_in) - shift_left(v_var(63 DOWNTO 32),16);--32b/28
            mult1 := k_omega * diff1; --64b/48
            mult2 := omega_int*qv_var; --96b/60   
            dv := mult1 - shift_left(mult2(95 DOWNTO 32),20); --64b/48   
            mult3 := Ts*dv; --96b/76   
            v_var := v_var + mult3(95 DOWNTO 32); --64b/44  
            dqv := omega_int * v_var; --96b/60
            mult4 := Ts*dqv(95 DOWNTO 32); --96b/56   
            qv_var := qv_var + shift_left(mult4(95 DOWNTO 32),20); --64b/44
               
            v_out <= STD_LOGIC_VECTOR(shift_left(v_var(63 downto 32),16));
            qv <= STD_LOGIC_VECTOR(shift_left(qv_var(63 downto 32),16));
        END IF;
    END IF;
END PROCESS;

end Behavioral;
