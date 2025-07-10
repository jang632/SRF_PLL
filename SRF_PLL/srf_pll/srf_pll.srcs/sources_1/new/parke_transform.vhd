library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parke_transform is
    PORT(
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        v_a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        v_c : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        theta : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        v_d : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        v_q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );     
end parke_transform;

architecture Behavioral of parke_transform is

    SIGNAL v_alpha : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL v_beta : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL sin_val : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL cos_val : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL iterations : INTEGER := 16;
    SIGNAL ready : STD_LOGIC;
    
    SIGNAL v_d_int : STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL v_q_int : STD_LOGIC_VECTOR(63 DOWNTO 0);
    

    SIGNAL v_alpha_delayed : STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL v_beta_delayed : STD_LOGIC_VECTOR(31 downto 0);
    
     component clarke_transform
        Port (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            v_a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_c : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            v_alpha : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            v_beta : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component;
    
    component cordic_sin_cos
        Port (
            clk        : in STD_LOGIC;
            reset      : in STD_LOGIC;
            theta      : in STD_LOGIC_VECTOR(31 downto 0);
            sin_value  : out STD_LOGIC_VECTOR(31 downto 0);
            cos_value  : out STD_LOGIC_VECTOR(31 downto 0);
            iterations : in integer range 1 to 16
        );
    end component;
    
    component shift_register
        Port (
            clk         : IN  STD_LOGIC;
            reset       : IN  STD_LOGIC;
            v_alpha     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            v_beta      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            v_alpha_del : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            v_beta_del  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
   end component;
   
   
    
BEGIN

    clarke_inst : clarke_transform
        port map (
            clk      => clk,
            reset    => reset,
            v_a      => v_a,
            v_b      => v_b,
            v_c      => v_c,
            v_alpha  => v_alpha,
            v_beta   => v_beta
        );
        
    cordic_inst : cordic_sin_cos
        port map (
            clk        => clk,
            reset      => reset,
            theta      => theta,
            sin_value  => sin_val,
            cos_value  => cos_val,
            iterations => iterations
        );
        
        delay_inst : shift_register
        port map (
            clk         => clk,
            reset       => reset,
            v_alpha     => v_alpha,
            v_beta      => v_beta,
            v_alpha_del => v_alpha_delayed,
            v_beta_del  => v_beta_delayed
        );
        
        

    PROCESS(clk)
    BEGIN 
        IF(reset='1') THEN 
            v_d_int<=(others => '0');
            v_q_int<=(others => '0');
        ELSIF(rising_edge(clk)) THEN 
            v_d_int <= STD_LOGIC_VECTOR(signed(v_alpha_delayed)*signed(cos_val) + signed(v_beta_delayed)*signed(sin_val));
            v_q_int <= STD_LOGIC_VECTOR(signed(v_beta_delayed)*signed(cos_val) - signed(v_alpha_delayed)*signed(sin_val));   
        END IF;
    END PROCESS;
    
    v_d<=v_d_int(63 DOWNTO 32);
    v_q<=v_q_int(63 DOWNTO 32); 

end Behavioral;
