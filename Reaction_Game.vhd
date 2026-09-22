library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reaction_game is
    port (
        CLOCK_50 : in  std_logic;
        KEY0     : in  std_logic;
        KEY1     : in  std_logic;

        LED      : out std_logic;

        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0)
    );
end reaction_game;

architecture rtl of reaction_game is

    type state_type is (
        IDLE,
        WAIT_RANDOM,
        LED_ON,
        RESULT,
		  case_9999
    );

    signal state : state_type := IDLE;

    signal lfsr : std_logic_vector(15 downto 0)
        := "1011010011010110";

    signal random_delay : integer range 1 to 5 := 1;

    signal second_count : integer range 0 to 49999999 := 0;

    signal elapsed_sec : integer range 0 to 5 := 0;

    signal counter_q : std_logic_vector(28 downto 0);

    signal counter_reset : std_logic := '1';

    signal reaction_ms : integer range 0 to 9999 := 0;

    signal digit0 : integer range 0 to 9 := 0;
    signal digit1 : integer range 0 to 9 := 0;
    signal digit2 : integer range 0 to 9 := 0;
    signal digit3 : integer range 0 to 9 := 0;

begin

    counter_inst : entity work.counter
        port map (
            clock => CLOCK_50,
            sclr  => counter_reset,
            q     => counter_q
        );

    process(CLOCK_50)

        variable feedback      : std_logic;
        variable counter_value : integer;

    begin

        if rising_edge(CLOCK_50) then

            if KEY1 = '0' then

                reaction_ms  <= 0;
                second_count <= 0;
                elapsed_sec  <= 0;

                counter_reset <= '1';

                state <= IDLE;

                LED <= '0';

            else

                feedback :=
                    lfsr(15) xor
                    lfsr(13) xor
                    lfsr(12) xor
                    lfsr(10);

                lfsr <= lfsr(14 downto 0) & feedback;

                case state is

                    when IDLE =>

                        LED <= '0';

                        counter_reset <= '1';

                        if KEY0 = '0' then

                            random_delay <=
                                (to_integer(unsigned(lfsr(2 downto 0))) mod 5) + 1;

                            second_count <= 0;
                            elapsed_sec  <= 0;

                            state <= WAIT_RANDOM;

                        end if;


                    when WAIT_RANDOM =>
						     

                        LED <= '0';

                        counter_reset <= '1';
								 

                        if second_count = 49999999 then

                            second_count <= 0;

                            if elapsed_sec + 1 >= random_delay then

                                elapsed_sec <= 0;

                                counter_reset <= '1';

                                state <= LED_ON;

                            else

                                elapsed_sec <= elapsed_sec + 1;

                            end if;

                        else

                            second_count <= second_count + 1;

                        end if;
                    

                    when LED_ON =>
						  
   
                        LED <= '1';
								
					 if to_integer(unsigned(counter_q)) >= 499950000 then
					   reaction_ms <= 9999;
        counter_reset <= '1';


        
            state <= case_9999;
        end if;

   		
								


                        counter_reset <= '0';

                        if KEY0 = '0' then

                            counter_value :=
                                to_integer(unsigned(counter_q));

                            reaction_ms <= counter_value / 50000;

                            if counter_value / 50000 > 9999 then

                                reaction_ms <= 9999;

                            end if;

                            state <= RESULT;

                        end if;


                    when RESULT =>

                        LED <= '0';

                        counter_reset <= '1';

                        if KEY0 = '0' then

                            random_delay <=
                                (to_integer(unsigned(lfsr(2 downto 0))) mod 5) + 1;

                            second_count <= 0;
                            elapsed_sec  <= 0;

                            state <= WAIT_RANDOM;

                        end if;
						when case_9999 =>
						   
        if KEY0 = '0' then
		  
                            random_delay <=
                                (to_integer(unsigned(lfsr(2 downto 0))) mod 5) + 1;

                            second_count <= 0;
                            elapsed_sec  <= 0;
            state <= WAIT_RANDOM;
        end if;

                end case;

            end if;

        end if;

    end process;


    digit0 <= reaction_ms mod 10;
    digit1 <= (reaction_ms / 10) mod 10;
    digit2 <= (reaction_ms / 100) mod 10;
    digit3 <= (reaction_ms / 1000) mod 10;


    process(digit0, digit1, digit2, digit3)

    begin
	     
		  

        case digit0 is
            when 0 => HEX0 <= "1000000";
            when 1 => HEX0 <= "1111001";
            when 2 => HEX0 <= "0100100";
            when 3 => HEX0 <= "0110000";
            when 4 => HEX0 <= "0011001";
            when 5 => HEX0 <= "0010010";
            when 6 => HEX0 <= "0000010";
            when 7 => HEX0 <= "1111000";
            when 8 => HEX0 <= "0000000";
            when 9 => HEX0 <= "0010000";
            when others => HEX0 <= "1111111";
        end case;


        case digit1 is
            when 0 => HEX1 <= "1000000";
            when 1 => HEX1 <= "1111001";
            when 2 => HEX1 <= "0100100";
            when 3 => HEX1 <= "0110000";
            when 4 => HEX1 <= "0011001";
            when 5 => HEX1 <= "0010010";
            when 6 => HEX1 <= "0000010";
            when 7 => HEX1 <= "1111000";
            when 8 => HEX1 <= "0000000";
            when 9 => HEX1 <= "0010000";
            when others => HEX1 <= "1111111";
        end case;


        case digit2 is
            when 0 => HEX2 <= "1000000";
            when 1 => HEX2 <= "1111001";
            when 2 => HEX2 <= "0100100";
            when 3 => HEX2 <= "0110000";
            when 4 => HEX2 <= "0011001";
            when 5 => HEX2 <= "0010010";
            when 6 => HEX2 <= "0000010";
            when 7 => HEX2 <= "1111000";
            when 8 => HEX2 <= "0000000";
            when 9 => HEX2 <= "0010000";
            when others => HEX2 <= "1111111";
        end case;


        case digit3 is
            when 0 => HEX3 <= "1000000";
            when 1 => HEX3 <= "1111001";
            when 2 => HEX3 <= "0100100";
            when 3 => HEX3 <= "0110000";
            when 4 => HEX3 <= "0011001";
            when 5 => HEX3 <= "0010010";
            when 6 => HEX3 <= "0000010";
            when 7 => HEX3 <= "1111000";
            when 8 => HEX3 <= "0000000";
            when 9 => HEX3 <= "0010000";
            when others => HEX3 <= "1111111";
        end case;

    end process;

end rtl;