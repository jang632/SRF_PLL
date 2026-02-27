library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY srf_pll IS
    PORT (
        clk    : in  std_logic;
        rst    : in  std_logic;
        v_n    : in  signed(15 downto 0);
        omega  : out signed(31 downto 0);
        phase  : out signed(31 downto 0)
    );
END srf_pll;

ARCHITECTURE Behavioral OF srf_pll IS

    signal clk_10M : std_logic := '0';
    signal reset   : std_logic := '0';
    signal enable  : std_logic;

    SIGNAL v_d       : SIGNED(31 DOWNTO 0);
    SIGNAL v_q       : SIGNED(31 DOWNTO 0);

    SIGNAL omega_int       : SIGNED(31 DOWNTO 0);
    SIGNAL theta_int       : SIGNED(31 DOWNTO 0);
    SIGNAL theta_saturated : SIGNED(31 DOWNTO 0);

--    CONSTANT Ts      : SIGNED(31 DOWNTO 0) := x"0000A7C6";
    CONSTANT Ts      : SIGNED(31 DOWNTO 0) := x"0000a7c6";

    SIGNAL v_q_ema   : SIGNED(31 DOWNTO 0) := (OTHERS => '0');
    
    signal v     : signed(31 downto 0);
    signal qv    : signed(31 downto 0);
    signal theta : signed(31 downto 0);
    
     component enable_generator
     generic(
         COUNT : integer := 1
     );
     port(
         clk        : in  std_logic;
         rst        : in  std_logic;
         enable_out : out std_logic
     );
     end component;
    

--     component clk_wiz_0
--     port (
--        clk_out1 : out std_logic;
--        clk_in1  : in  std_logic
--     );
--     end component;

    component MAF_filter
        generic(
            DATA_WIDTH    : integer := 16;
            WINDOW_LENGTH : integer := 500;
            FIXED_POINT   : integer := 6
        );
        port(
            clk      : in std_logic;
            rst      : in std_logic;
            ce       : in std_logic;
            data_in  : in  signed(DATA_WIDTH-1 downto 0);
            data_out : out signed(DATA_WIDTH-1 downto 0)
        );
    end component;
    
    component sogi
    generic(
        WIDTH : integer := 16
    );
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        ce       : in  std_logic;
        v_n      : in  signed(WIDTH-1 downto 0);
        v        : out signed(2*WIDTH-1 downto 0);
        qv       : out signed(2*WIDTH-1 downto 0)
    );
    end component;
    
    component notch_filter
    port(
        clk : in std_logic;
        rst : in std_logic;
        ce  : in std_logic;
        data_in  : in signed(31 downto 0);
        data_out : out signed(31 downto 0)
    );
    end component;



    component parke_transform is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        ce      : in  std_logic;
        v_alpha : in  signed(31 downto 0);
        v_beta  : in  signed(31 downto 0);
        theta   : in  signed(31 downto 0);
        v_d     : out signed(31 downto 0);
        v_q     : out signed(31 downto 0)
    );
    end component;

    component pi_controller is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        ce       : in  std_logic;
        data_in  : in  signed(31 downto 0); --fixed point 24
        data_out : out signed(31 downto 0)  --fixed point 20
    );
    end component;
    
    component integrator is
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        ce       : in  std_logic;
        data_in  : in  signed(31 downto 0); --fixed point 20
        data_out : out signed(31 downto 0)
    );
    end component;

    component ema_filter is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        ce       : in  std_logic;
        data_in  : in  signed(31 DOWNTO 0);
        data_out : out signed(31 DOWNTO 0)
    );
    end component;

begin

    u_enable_generator : enable_generator
    generic map (
        COUNT => 20
    )
    port map (
        clk        => clk_10M,
        rst        => rst,
        enable_out => enable 
    );

--    u_pll : clk_wiz_0
--    port map (
--        clk_out1 => clk_10M,
--        clk_in1  => clk
--    );

--    u_maf_filter_inst : MAF_filter
--    generic map (
--        DATA_WIDTH    => 32,
--        WINDOW_LENGTH => 500,
--        FIXED_POINT   => 24
--    )
--    port map (
--        clk      => clk,      -- Twój zegar systemowy
--        rst      => rst,      -- Twój sygnał resetu
--        ce       => '1',   -- Sygnał zezwolenia (obecnie ignorowany wewnątrz)
--        data_in  => v_q,
--        data_out => v_q_ema
--    );

    u_sogi : sogi
    generic map (
        WIDTH => 16
    )
    port map (
        clk     => clk,
        rst     => rst,
        ce      => '1',
        v_n     => v_n,
        v       => v,
        qv      => qv
    );

    parke_inst : parke_transform
    port map (
        clk     => clk,
        rst     => rst,
        ce      => '1',
        v_alpha => v,
        v_beta  => qv,
        theta   => theta_int,
        v_d     => v_d,
        v_q     => v_q
    );

    pi_ctrl_inst : pi_controller
    port map (
        clk      => clk,
        rst      => rst,
        ce       => '1',
        data_in  => v_q_ema,
        data_out => omega_int
    );

    u_ema : ema_filter
    port map (
        clk      => clk,
        reset    => rst,
        ce       => '1',
        data_in  => v_q,
        data_out => v_q_ema
    );
    
--     u_notch_filter : notch_filter
--    port map(
--        clk      => clk,
--        rst      => rst,
--        ce       => '1',
--        data_in  => v_q,
--        data_out => v_q_ema
--    );

    
    u_integrator : integrator
    port map (
        clk      => clk,
        rst      => rst,
        ce       => '1',
        data_in  => omega_int,
        data_out => theta_int
    );
    
    phase <= theta_int;
    omega <= omega_int;

END Behavioral;