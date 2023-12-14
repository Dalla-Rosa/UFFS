library ieee;
use ieee.std_logic_1164.all;

entity seila is 
    port (
        A, B, C : in std_logic;
        D, E : out std_logic
    );
end seila;

architecture behavior of seila is
begin
    process (A, B, C)
    begin
        D <= ((not A) and B) or ((not A) and C) or (B and C);
        E <= ( A xor B ) xor C;
    end process;
end behavior;