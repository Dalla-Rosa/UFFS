library ieee;
use ieee.std_logic_1164.all;

entity mux is
    port (
    I : in std_logic_vector (3 downto 0); -- Input
    SEL : in std_logic_vector (1 downto 0); -- Select
    Y : out std_logic -- Output
    );
end entity mux;

architecture comportamento of mux is 
begin
    process (I,SEL)
    begin
        if SEL = "00" then
            Y <= I(0);
        elsif SEL = "01" then
            Y <= I(1);
        elsif SEL = "10" then
            Y <= i(2);
        else
            Y <= i(3);
        end if;
    end process;
end comportamento;
        
