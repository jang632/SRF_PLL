library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pkg.all;

entity tb_shift_buffer is
end entity;

architecture tb of tb_shift_buffer is
    constant LENGTH : integer := 3;
    constant WIDTH  : integer := 8;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal data_in  : signed(WIDTH-1 downto 0);
    signal data_out : t_array(0 to LENGTH-1)(WIDTH-1 downto 0);

    constant T : time := 10 ns;
begin

    uut : entity work.shift_buffer
        generic map (
            LENGTH => LENGTH,
            WIDTH  => WIDTH
        )
        port map (
            clk      => clk,
            rst      => rst,
            data_in  => data_in,
            data_out => data_out
        );

    clk <= not clk after T/2;

    process
    begin
        rst <= '1';
        data_in <= (others => '0');
        wait for T;
        rst <= '0';
        wait for 5ns;

        for i in 0 to 10 loop
            data_in <= to_signed(i, WIDTH);
            wait for T;
        end loop;

        wait;
    end process;

end architecture;
