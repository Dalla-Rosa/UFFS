library ieee;
use ieee.std_logic_1164.all;

entity comportamento is
    port (
        A, B, C, D: in std_logic;
        S: out std_logic
    );
end comportamento;

architecture or_comportamento of comportamento is
begin
    process (A,B,C,D)
    begin 
        S <= A or B or C or D;
    end process;
end or_comportamento;
