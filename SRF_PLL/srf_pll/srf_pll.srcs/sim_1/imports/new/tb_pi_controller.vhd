library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.pkg.all;

entity tb_pi_controller is
end tb_pi_controller;

architecture sim of tb_pi_controller is

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal data_in  : signed(31 downto 0) := (others => '0');
    signal data_out : signed(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant SCALE_24   : real := 16777216.0;
    
    signal debug_feedback : real := 0.0;
    signal debug_setpoint : real := 1.0;
    signal debug_error    : real := 0.0;

begin

    dut : entity work.pi_controller
        port map (
            clk      => clk,
            rst      => rst,
            data_in  => data_in,
            data_out => data_out
        );

    clk <= not clk after CLK_PERIOD/2;

    process
        variable v_feedback : real := 0.0;
        variable v_setpoint : real := 1.0;
        variable v_error    : real := 0.0;
        variable v_u_float  : real := 0.0;
        
        constant a_obj : real := 0.9995; 
        constant b_obj : real := 0.0005;
    begin
        rst <= '1';
        data_in <= (others => '0');
        wait for 100 ns;
        rst <= '0';

        for i in 0 to 10000 loop
            wait until rising_edge(clk);
            
            v_error := v_setpoint - v_feedback;
            
            data_in <= to_signed(integer(v_error * SCALE_24), 32);
            
            wait until rising_edge(clk);
            
            v_u_float := real(to_integer(data_out)) / SCALE_24;
            
            v_feedback := (a_obj * v_feedback) + (b_obj * v_u_float);
            
            debug_feedback <= v_feedback;
            debug_setpoint <= v_setpoint;
            debug_error    <= v_error;
            
        end loop;
        wait;
    end process;

end sim;
