library ieee;
use ieee.std_logic_1164.all;

entity comportamento is
    port (
            A, B, C: in std_logic;
            D, E, F: out std_logic
    );
end comportamento;

architecture alg_comport1 of comportamento is
begin
    process (A, B, C)
    begin 
        D <= (A nor (not B)) xor (not((not C) nand (not B)));
        E <= ((not B) nand (not(C))) or (not(B));
        F <= ((not B)nand(not C)) xor ((not B)and(not C)); 
    end process;
end alg_comport1;




-- architecture alg_comport2 of comportamento is
--     process (B, C)
--     begin 
--         if B = '1' and C = '1' then
--             ANDE <= (not C) and (not B);
--         end if;
--     end process;
-- end alg_comport2;

-- architecture alg_comport3 of comportamento is
--     process (alg_comport2, B)
--     begin
--         if B = '0' and alg_comport2 = '1' then
--             E <= (not B) or alg_comport2
--         end if;
--     end process;
-- end alg_comport3;

-- architecture alg_comport4 of comportamento is 
--     process (C,B)
--     begin  
--         if C = '1' and B ='1' then
--             C <= (not C) and (not B)
--         end if;
--     end process;
-- end alg_comport4;