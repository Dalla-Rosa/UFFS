library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trabfinal is
    port (
        SW   : in std_logic_vector(9 downto 0); -- coordenadas
        KEY  : in std_logic_vector(3 downto 0); -- clock = key(0) & reset = key(3)

        LEDR : out std_logic_vector(9 downto 0); -- tiros acertados
        LEDG : out std_logic_vector(7 downto 0); -- tiros errados
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0)
    );
end trabfinal;

architecture batalhaNaval_behav of trabfinal is

    type state_type is (B, P1, P2, S, V, V2, L, L2);

    signal state        : state_type := B;
    signal balasCanhao  : integer range 0 to 6 := 6 ;
    signal navio1, navio2, navio2_1: std_logic_vector(3 downto 0);
    signal tirosAcertados : std_logic_vector(3 downto 0) := "0000";

    function analisar (
        cordenada_in: in std_logic_vector(3 downto 0))
        return std_logic_vector is 
        variable codigo_saida : std_logic_vector(3 downto 0);
    begin
        if cordenada_in = "0000" then
            codigo_saida := "0001";
        elsif cordenada_in = "0001" then
            codigo_saida := "0010";
        elsif cordenada_in = "0010" then
            codigo_saida := "0100";
        elsif cordenada_in = "0011" then
            codigo_saida := "1000";
        elsif cordenada_in = "0100" then
            codigo_saida := "1001";
        elsif cordenada_in = "0101" then
            codigo_saida := "1010";
        elsif cordenada_in = "0110" then
            codigo_saida := "1100";
        elsif cordenada_in = "0111" then
            codigo_saida := "1110";
        elsif cordenada_in = "1000" then
            codigo_saida := "1011";
        elsif cordenada_in = "1001" then
            codigo_saida := "0101";
        elsif cordenada_in = "1010" then
            codigo_saida := "0111";
        elsif cordenada_in = "1011" then
            codigo_saida := "0110";
        elsif cordenada_in = "1100" then
            codigo_saida := "1111";
        elsif cordenada_in = "1101" then
            codigo_saida := "0000";
        elsif cordenada_in = "1110" then
            codigo_saida := "1101";
        elsif cordenada_in = "1111" then
            codigo_saida := "0011";
        end if;
        return codigo_saida;
    end function;

begin
    process(KEY)
        variable aux_navio          : std_logic_vector(3 downto 0);
        variable aux_navio_cauda    : std_logic_vector(3 downto 0);
        variable coord_barco        : std_logic_vector(3 downto 0);
        variable auxshots           : std_logic_vector(3 downto 0);
        variable auxbalasCanhao     : integer range 0 to 6;
    begin
        if KEY(0) = '0' then
            state <= B;
            LEDR  <= "0000000000";
            LEDG  <= "00000000";
            tirosAcertados <= "0000";
        elsif (KEY(1)'event and KEY(1) = '0') then
            case state is
                when B =>
                    state <= P1;
                    balasCanhao <= 6;

                when P1 =>
                    coord_barco(0) := SW(0);
                    coord_barco(1) := SW(1);
                    coord_barco(2) := SW(2);
                    coord_barco(3) := SW(3);

                    aux_navio := analisar(coord_barco);
                    navio1 <= aux_navio;

                    LEDR(0) <= aux_navio(0);
                    LEDR(1) <= aux_navio(1);
                    LEDR(2) <= aux_navio(2);
                    LEDR(3) <= aux_navio(3);

                    LEDG(7) <= '1';
                    state <= P2;

                when P2 =>
                    LEDR <= "0000000000";

                    coord_barco(0) := SW(0);
                    coord_barco(1) := SW(1);
                    coord_barco(2) := SW(2);
                    coord_barco(3) := SW(3);

                    aux_navio := analisar(coord_barco);
                    if(aux_navio = navio1) then
                        LEDG(7) <= '1';
                    else 
                        navio2 <= aux_navio;

                        if(sw(9) = '0') then -- escolher linha vertical
                            if (coord_barco(3) = '1') and (coord_barco(2) = '1') then 
                                LEDR <= "1111111";
                            else 
                                aux_navio_cauda := analisar(std_logic_vector(unsigned(coord_barco) + "0100"));

                                navio2_1 <= aux_navio_cauda;

                                if (aux_navio = navio1) or (aux_navio = navio2) or (aux_navio_cauda = navio1) or (aux_navio_cauda = navio2) then
                                    LEDR <= "111111111";
                                else
                                    for i in 0 to 3 loop
                                        LEDR(i+5) <= aux_navio(i);
                                    end loop;
                                    for i in 0 to 3 loop
                                        LEDR(i) <= aux_navio_cauda(i);
                                    end loop;

                                    LEDG(5) <= '1';
                                    LEDG(4) <= '1';
                                    state <= S;
                                    LEDR <= "0000000000";
                                end if;
                            end if;
                        else
                            if (coord_barco(3) = '1') and (coord_barco(2) = '1') then 
                                LEDR <= "1111111";
                            else 
                                aux_navio_cauda := analisar(std_logic_vector(unsigned(coord_barco) + "0100"));

                                navio2_1 <= aux_navio_cauda;

                                if (aux_navio = navio1) or (aux_navio = navio2) or (aux_navio_cauda = navio1) or (aux_navio_cauda = navio2) then
                                    LEDR <= "111111111";
                                else
                                    for i in 0 to 3 loop
                                        LEDR(i+5) <= aux_navio(i);
                                    end loop;
                                    for i in 0 to 3 loop
                                        LEDR(i) <= aux_navio_cauda(i);
                                    end loop;

                                    LEDG(5) <= '1';
                                    LEDG(4) <= '1';
                                    state <= S;
                                    LEDR <= "0000000000";
                                end if;
                            end if;
                            end if;
                    end if;
                when S =>
                    LEDR <= "0000000000";
                    if balasCanhao > 0 then
                        coord_barco(0) := SW(0);
                        coord_barco(1) := SW(1);
                        coord_barco(2) := SW(2);
                        coord_barco(3) := SW(3);

                        auxbalasCanhao := balasCanhao;
                        auxshots := tirosAcertados;
                        if analisar(coord_barco) = navio1 then
                            auxshots(0) := '1';
                            LEDG(7) <= '0';
                            if auxbalasCanhao = 1 then auxbalasCanhao := auxbalasCanhao + 1; end if;
                        elsif analisar(coord_barco) = navio2 then
                            auxshots(1) := '1';
                            LEDG(6) <= '0';
                            if auxbalasCanhao = 1 then auxbalasCanhao := auxbalasCanhao + 1; end if;
                        elsif analisar(coord_barco) = navio2_1 then
                            auxshots(2) := '1';
                            LEDG(5) <= '0';
                            if auxbalasCanhao = 1 then auxbalasCanhao := auxbalasCanhao + 1; end if;
                        else
                            LEDR <= "1111111111";
                        end if;

                        auxbalasCanhao := auxbalasCanhao - 1;

                        balasCanhao <= auxbalasCanhao;
                        tirosAcertados <= auxshots;
                    end if;

                    if tirosAcertados = "1111" then
                        state <= V;
                    elsif balasCanhao < 1 then
                        state <= L;
                    end if;
                when V =>
                    state <= V2;
                when V2 =>
                    state <= B;
                when L =>
                    state <= L2;
                when L2 =>
                    state <= B;
            end case;
        end if;
    end process;

    process(state)
    begin
        case state is
            when B =>
                HEX3 <= "1000001";
                HEX2 <= "0001000";
                HEX1 <= "1001111";
                HEX0 <= "1111111";

            when P1 =>
                HEX3 <= "0000011";
                HEX2 <= "0001000";
                HEX1 <= "1111001";
                HEX0 <= "1111111";

            when P2 =>
                HEX3 <= "0000011";
                HEX2 <= "0001000";
                HEX1 <= "0100100";
                HEX0 <= "1111111";

            when S =>
                HEX2 <= "1111111";
                case balasCanhao is
                    when 0 =>
                        HEX3 <= "1000000";
                    when 1 =>
                        HEX3 <= "1111001";
                    when 2 =>
                        HEX3 <= "0100100";
                    when 3 =>
                        HEX3 <= "0110000";
                    when 4 =>
                        HEX3 <= "0011001";
                    when 5 =>
                        HEX3 <= "0010010";
                    when 6 =>
                        HEX3 <= "0000010";       
                end case;

            when V =>
                HEX3 <= "0011001";
                HEX2 <= "1000000";
                HEX1 <= "1000001";
                HEX0 <= "1111111";

            when V2 =>
                HEX3 <= "0011001";
                HEX2 <= "1000000";
                HEX1 <= "1000001";
                HEX0 <= "1111111";

            when L =>
                HEX3 <= "0011001";
                HEX2 <= "1000000";
                HEX1 <= "1000001";
                HEX0 <= "1111111";

            when L2 =>
                HEX3 <= "1000111";
                HEX2 <= "1000000";
                HEX1 <= "0010010";
                HEX0 <= "0000110";
        end case;
    end process;

end batalhaNaval_behav;
