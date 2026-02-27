
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;


library work;
use work.pkg.all;

entity notch_filter is
    port(
        clk : in std_logic;
        rst : in std_logic;
        ce  : in std_logic;
        data_in  :  in signed(31 downto 0); -- fp 24
        data_out : out signed(31 downto 0)  -- fp 24
    );
end notch_filter;

architecture Behavioral of notch_filter is

signal y : signed(31 downto 0);

constant DEPTH        : integer := 3;
constant DATA_WIDTH_y : integer := 32;
constant DATA_WIDTH_x : integer := 32;
constant SATURATION_y : signed(DATA_WIDTH_y-1 downto 0) := shift_left(to_signed(200, 32), 24);


signal buf_y :  t_array(0 to DEPTH-1)(DATA_WIDTH_y-1 downto 0);
signal buf_x :  t_array(0 to DEPTH-1)(DATA_WIDTH_x-1 downto 0);

signal v1_s : signed(64 downto 0);
signal v2_s : signed(64 downto 0);

signal m1 : signed(64 downto 0);
signal m2 : signed(64 downto 0);
signal m3 : signed(64 downto 0);

signal fir_reg : signed(65 downto 0) := (others => '0');

constant b0 : signed(31 downto 0) := x"7FFFFFFF";
constant b1 : signed(31 downto 0) := x"80000000";
constant b2 : signed(31 downto 0) := x"7FFFFFFF";
constant a0 : signed(31 downto 0) := x"33322A45";
constant a1 : signed(31 downto 0) := x"EB851EB8";

function truncate(data_in : signed; limit : signed) return signed is 
    variable data_out : signed(data_in'range); 
begin
    if data_in > limit then
        data_out := limit;
    elsif data_in < -limit then
        data_out := -limit;
    else
        data_out := data_in;
    end if;  
    return data_out;
end function;

component shift_buffer 
    generic(
        DATA_WIDTH  : integer;
        FIXED_POINT : integer;
        INIT        : real;
        DEPTH       : integer
    );
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;
        ce       : in  std_logic;
        data_in  : in  signed(DATA_WIDTH-1 downto 0);
        data_out : out t_array(0 to DEPTH-1)(DATA_WIDTH-1 downto 0)
    );
end component;

begin

u_shift_buffer_y : shift_buffer
    generic map(
        DATA_WIDTH  => DATA_WIDTH_y,
        FIXED_POINT => 0,
        INIT        => 0.0,
        DEPTH       => 3
    )
    port map(
        clk      => clk,
        rst      => rst,
        ce       => ce,
        data_in  => y,
        data_out => buf_y
    );
    
u_shift_buffer_x : shift_buffer
generic map(
    DATA_WIDTH  => DATA_WIDTH_x,
    FIXED_POINT => 0,
    INIT        => 0.0,
    DEPTH       => 3
)
port map(
    clk      => clk,
    rst      => rst,
    ce       => ce,
    data_in  => data_in,
    data_out => buf_x
);

process(clk)
    variable v1 : signed(64 downto 0);
    variable v2 : signed(64 downto 0);
    variable acc : signed(66 downto 0);
    variable v3 : signed(66 downto 0);
begin
if(rising_edge(clk)) then
    if(rst = '1')then   
        y <= (others => '0');
        fir_reg <= (others => '0');
        m1 <= (others => '0');
        m2 <= (others => '0');
        m3 <= (others => '0');
    else
        if(ce = '1') then
            m1 <= resize(b0 * data_in, 65);
            m2 <= resize(b1 * buf_x(0), 65);
            m3 <= resize(b2 * buf_x(1), 65);
            
            fir_reg <= resize(m1,66) + resize(m2,66)+ resize(m3,66); -- fp 53 
                     
            v1    := a0*resize(y,33);      -- fixed point 24+29=53
            v2    := a1*resize(buf_y(0),33); -- fixed point 53 
            acc := resize(fir_reg,67)
                 + resize(v1, 67)  -- 
                 + resize(v2, 67);

            v3 := shift_left(acc,6); -- fp 59
            y <= v3(66 downto 35);
        end if;
    end if;
 end if;
end process;

data_out <= y;

end Behavioral;
