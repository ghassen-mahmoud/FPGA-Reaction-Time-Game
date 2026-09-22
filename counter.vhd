library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.all;

entity counter is
    port (
        clock : in  std_logic;
        sclr  : in  std_logic;
        q     : out std_logic_vector(28 downto 0)
    );
end counter;

architecture SYN of counter is

    signal sub_wire0 : std_logic_vector(28 downto 0);

    component lpm_counter
        generic (
            lpm_direction     : string;
            lpm_port_updown   : string;
            lpm_type          : string;
            lpm_width         : natural
        );

        port (
            clock : in  std_logic;
            sclr  : in  std_logic;
            q     : out std_logic_vector(28 downto 0)
        );
    end component;

begin

    q <= sub_wire0;

    LPM_COUNTER_component : lpm_counter
        generic map (
            lpm_direction   => "UP",
            lpm_port_updown => "PORT_UNUSED",
            lpm_type        => "LPM_COUNTER",
            lpm_width       => 29
        )
        port map (
            clock => clock,
            sclr  => sclr,
            q     => sub_wire0
        );

end SYN;