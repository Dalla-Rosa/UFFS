library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity finalproject is
    port (
        SW : in std_logic_vector(9 downto 0); -- cordinates collection
        KEY : in std_logic_vector(3 downto 0); -- clock = key(0) & reset = key(3)

        LEDR : out std_logic_vector(9 downto 0); -- shot connected
        LEDG : out std_logic_vector(7 downto 0); -- shot missed
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0)
    );
end finalproject;

architecture finalproject_behav of finalproject is

	type state_type is (B, P1, P2, P3, S, V, L);
	
	signal state : state_type := B;
	signal bullets : integer range 0 to 6 := 6 ;
	signal navio1, navio2, navio3_1, navio3_2 : std_logic_vector(3 downto 0);
	signal tirosAcertados : std_logic_vector(3 downto 0) := "0000";
	
	function codify (
		coord_in : in std_logic_vector(3 downto 0))
		return std_logic_vector is
		variable code_out : std_logic_vector(3 downto 0);
	begin
		if coord_in = "0000" then
			code_out := "0001";
		elsif coord_in = "0001" then
			code_out := "0010";
		elsif coord_in = "0010" then
			code_out := "0100";
		elsif coord_in = "0011" then
			code_out := "1000";
		elsif coord_in = "0100" then
			code_out := "1001";
		elsif coord_in = "0101" then
			code_out := "1010";
		elsif coord_in = "0110" then
			code_out := "1100";
		elsif coord_in = "0111" then
			code_out := "1110";
		elsif coord_in = "1000" then
			code_out := "1011";
		elsif coord_in = "1001" then
			code_out := "0101";
		elsif coord_in = "1010" then
			code_out := "0111";
		elsif coord_in = "1011" then
			code_out := "0110";
		elsif coord_in = "1100" then
			code_out := "1111";
		elsif coord_in = "1101" then
			code_out := "0000";
		elsif coord_in = "1110" then
			code_out := "1101";
		elsif coord_in = "1111" then
			code_out := "0011";
		end if;
		return code_out;
	end function;

begin
	process(KEY)
		variable orientation : std_logic;
		variable aux_boat, aux_boat_long, aux_shoot : std_logic_vector(3 downto 0);
		variable coord_b : std_logic_vector(3 downto 0);
		variable aux_bullet : integer range 0 to 6;
	begin
		if KEY(0) = '0' then
			state <= B;
			LEDR <= "0000000000";
			LEDG <= "00000000";
			bullets <= 6;
			shotsHitted <= "0000";
		elsif (KEY(1)'event and KEY(1) = '0') then
			case state is
				when B =>
					state <= P1;
					bullets <= 6;
					shotsHitted <= "0000";
					LEDR <= "0000000000";
					LEDG <= "00000000";
					
				when P1 =>
					for i in 0 to 3 loop
						coord_b(i) := SW(i);
					end loop;
					
					aux_boat := codify(coord_b);
					boat1 <= aux_boat;
					
					for i in 0 to 3 loop
						LEDR(i) <= aux_boat(i);
					end loop;
					
					LEDG(7) <= '1';
					state <= P2;
					
				when P2 =>
					LEDR <= "0000000000";
					
					for i in 0 to 3 loop
						coord_b(i) := SW(i);
					end loop;
					
					aux_boat := codify(coord_b);
					boat2 <= aux_boat;
					
					if(aux_boat = boat1) then
						LEDR <= "1111111111";
					else
						for i in 0 to 3 loop
							LEDR(i) <= aux_boat(i);
						end loop;
						
						LEDG(6) <= '1';
						state <= P3;
					end if;
					
				when P3 =>
					LEDR <= "0000000000";
					orientation := SW(4);
					
					for i in 0 to 3 loop
						coord_b(i) := SW(i);
					end loop;
					
					if orientation = '1' then
					-- vertical
							aux_boat := codify(coord_b);
							aux_boat_long := codify(std_logic_vector(unsigned(coord_b) + "0100"));
							
							boat3_1 <= aux_boat;
							boat3_2 <= aux_boat_long;
							
							if (aux_boat = boat1) or (aux_boat = boat2) or (aux_boat_long = boat1) or (aux_boat_long = boat2) then
								LEDR <= "1111111111";
							else
								for i in 0 to 3 loop
									LEDR(i+5) <= aux_boat(i);
								end loop;

								for i in 0 to 3 loop
									LEDR(i) <= aux_boat_long(i);
								end loop;
								
								LEDG(5) <= '1';
								LEDG(4) <= '1';
								state <= S;
								LEDR <= "0000000000";
							end if;
						end if;
					else 
					-- horizontal
							aux_boat := codify(coord_b);
							aux_boat_long := codify(std_logic_vector(unsigned(coord_b) + "0001"));
							
							boat3_1 <= aux_boat;
							boat3_2 <= aux_boat_long;
							
							if (aux_boat = boat1) or (aux_boat = boat2) or (aux_boat_long = boat1) or (aux_boat_long = boat2) then
								LEDR <= "1111111111";
							else
								for i in 0 to 3 loop
									LEDR(i+5) <= aux_boat(i);
								end loop;

								for i in 0 to 3 loop
									LEDR(i) <= aux_boat_long(i);
								end loop;
								
								LEDG(5) <= '1';
								LEDG(4) <= '1';
								state <= S;
								LEDR <= "0000000000";
							end if;
						end if;
					end if;
					
				when S =>
					LEDR <= "0000000000";
					aux_shoot := shotsHitted;
					aux_bullet := bullets;
					
					if bullets > 0 then
						for i in 0 to 3 loop
							coord_b(i) := SW(i);
						end loop;
						
						if codify(coord_b) = boat1 then
							aux_shoot(0) := '1';
							LEDG(7) <= '0';
							if (aux_bullet = 1) and (shotsHitted(0) = '0') then aux_bullet := aux_bullet + 1; end if;
						elsif codify(coord_b) = boat2 then
							aux_shoot(1) := '1';
							LEDG(6) <= '0';
							if (aux_bullet = 1) and (shotsHitted(1) = '0') then aux_bullet := aux_bullet + 1; end if;
						elsif codify(coord_b) = boat3_1 then
							aux_shoot(2) := '1';
							LEDG(5) <= '0';
							if (aux_bullet = 1) and (shotsHitted(2) = '0') then aux_bullet := aux_bullet + 1; end if;
						elsif codify(coord_b) = boat3_2 then
							aux_shoot(3) := '1';
							LEDG(4) <= '0';
							if (aux_bullet = 1) and (shotsHitted(3) = '0') then aux_bullet := aux_bullet + 1; end if;
						else
							LEDR <= "1111111111";
						end if;
						
						aux_bullet := aux_bullet - 1;
						
						shotsHitted <= aux_shoot;
						bullets <= aux_bullet;
					end if;
						
					if aux_shoot = "1111" then
						state <= V;
					elsif aux_bullet < 1 then
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
				HEX3 <= "0000010";
				HEX2 <= "1000000";

			when P1 =>
				HEX3 <= "0000011";
				HEX2 <= "1111001";
				
			when P2 =>
				HEX3 <= "0000011";
				HEX2 <= "0100100";
				
			when P3 =>
				HEX3 <= "0000011";
				HEX2 <= "0110000";

			when S =>
				HEX2 <= "1111111";
				case bullets is
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
				HEX3 <= "1000001";
				HEX2 <= "1111111";
				HEX1 <= "1111111";
				HEX0 <= "1111111";
			when L =>
				HEX3 <= "0100001";
				HEX2 <= "1111111";
				HEX1 <= "1111111";
				HEX0 <= "1111111";
			end case;
	end process;
end finalproject_behav;
