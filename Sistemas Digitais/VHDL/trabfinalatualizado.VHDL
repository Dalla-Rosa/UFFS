library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity batalhaNaval is
    port (
        SW : in std_logic_vector(9 downto 0); -- coordenadas
        KEY : in std_logic_vector(3 downto 0); -- clock = key(0) & reset = key(3)

        LEDR : out std_logic_vector(9 downto 0); -- tiros acertados
        LEDG : out std_logic_vector(7 downto 0); -- tiros errados
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0);
    );
end batalhaNaval;

architecture batalhaNaval_behav of batalhaNaval is

    type state_type is (B, P1, P2, S, V, L);

    signal state : state_type := B;
    signal tiros : integer range 0 to 6 := 6;
    signal navio1, navio2 : std_logic_vector(3 downto 0);
    signal tirosAcertados : std_logic_vector(3 downto 0) := "0000";

    function codificar (
        cordenada_in: in std_logic_vector(3 downto 0))
        return std_logic_vector is
        variable code_out : std_logic_vector(3 downto 0);
    begin
        if cordenada_in = "0000" then
            code_out := "0001";
        elsif cordenada_in = "0001" then
            code_out := "0010";
        elsif cordenada_in = "0010" then
            code_out := "0100";
        elsif cordenada_in = "0011" then
            code_out := "1000";
        elsif cordenada_in = "0100" then
            code_out := "1001";
        elsif cordenada_in = "0101" then
            code_out := "1010";
        elsif cordenada_in = "0110" then
            code_out := "1100";
        elsif cordenada_in = "0111" then
            code_out := "1110";
        elsif cordenada_in = "1000" then
            code_out := "1011";
        elsif cordenada_in = "1001" then
            code_out := "0101";
        elsif cordenada_in = "1010" then
            code_out := "0111";
        elsif cordenada_in = "1011" then
            code_out := "0110";
        elsif cordenada_in = "1100" then
            code_out := "1111";
        elsif cordenada_in = "1101" then
            code_out := "0000";
        elsif cordenada_in = "1110" then
            code_out := "1101";
        elsif cordenada_in = "1111" then
            code_out := "0011";
        end if;
        return code_out;
    end function;

begin
    process(KEY)
        variable aux_navio : std_logic_vector(3 downto 0);
        variable coord_b : std_logic_vector(3 downto 0);
        variable auxtiros : std_logic_vector(3 downto 0);
        variable auxmunicoes : integer range 0 to 6;
    begin
        if KEY(0) = '0' then
            state <= B;
            LEDR <= "0000000000";
            LEDG <= "00000000";
            tirosAcertados <= "0000";
        elsif (KEY(1)'event and KEY(1) = '0') then
            case state is
                when B =>
                    state <= P1;
                    tiros <= 6;

                when P1 =>
                    coord_b(0) := SW(0);
                    coord_b(1) := SW(1);
                    coord_b(2) := SW(2);
                    coord_b(3) := SW(3);

                    aux_navio := codificar(coord_b);
                    navio1 <= aux_navio;

                    LEDR <= (others => '0');
                    LEDR(0) <= '1';
                    state <= P2;

                when P2 =>
                    coord_b(0) := SW(0);
                    coord_b(1) := SW(1);
                    coord_b(2) := SW(2);
                    coord_b(3) := SW(3);

                    aux_navio := codificar(coord_b);
                    navio2 <= aux_navio;

                    if (aux_navio = navio1) then
                        LEDR <= "1111111111";
                    else
                        LEDR <= (others => '0');
                        LEDR(1) <= '1';
                        state <= S;
                    end if;

                when S =>
                    LEDR <= (others => '0');
                    if tiros > 0 then
                        coord_b(0) := SW(0);
                        coord_b(1) := SW(1);
                        coord_b(2) := SW(2);
                        coord_b(3) := SW(3);

                        auxmunicoes := tiros;
                        auxtiros := tirosAcertados;

                        if coord_b = navio1 then
                            auxtiros(0) <= '1';
                            if auxmunicoes = 1 then
                                auxmunicoes := auxmunicoes + 1;
                            end if;
                        elsif coord_b = navio2 or coord_b = codificar(navio2 + "0001") then
                            auxtiros(1) <= '1';
                            if auxmunicoes = 1 then
                                auxmunicoes := auxmunicoes + 1;
                            end if;
                        else
                            LEDR <= "1111111111";
                        end if;

                        auxmunicoes := auxmunicoes - 1;
                    end if;

                    tiros <= auxmunicoes;
                    tirosAcertados <= auxtiros;

                    if tirosAcertados = "011" then
                        state <= V;
                    elsif tiros < 1 then
                        state <= L;
                    end if;

                when V =>
                    state <= B;
                when L =>
                    state <= B;
            end case;
        end if;
    end process;

    process(state)
    begin
        case state is
            when B =>
                HEX3 <= "1111110";
                HEX2 <= "1111110";
                HEX0 <= "1111110";
                HEX1 <= "1111110";

            when P1 =>
                HEX3 <= "1111110";
                HEX2 <= "1111110";
                HEX0 <= "1111110";
                HEX1 <= "0000001";

            when P2 =>
                HEX3 <= "1111110";
                HEX2 <= "1111110";
                HEX0 <= "1111110";
                HEX1 <= "1111110";

            when S =>
                HEX2 <= "1111111";
                case tiros is
                    when 0 =>
                        HEX3 <= "0000001";
                        HEX2 <= "1111110";

                    when 1 =>
                        HEX2 <= "1111110";
                        HEX3 <= "1111111";

                    when 2 =>
                        HEX2 <= "1111110";
                        HEX3 <= "0000110";

                    when 3 =>
                        HEX2 <= "1111110";
                        HEX3 <= "0000001";

                    when 4 =>
                        HEX2 <= "1111110";
                        HEX3 <= "1111110";

                    when 5 =>
                        HEX2 <= "1111110";
                        HEX3 <= "0000000";

                    when 6 =>
                        HEX2 <= "1111110";
                        HEX3 <= "0000000";
                end case;

            when V =>
                HEX3 <= "1111110";
                HEX2 <= "0000111";
                HEX1 <= "1111110";
                HEX0 <= "1111110";

            when L =>
                HEX3 <= "1111110";
                HEX2 <= "1111110";
                HEX1 <= "1111110";
                HEX0 <= "1111110";
        end case;
    end process;

end batalhaNaval_behav;
