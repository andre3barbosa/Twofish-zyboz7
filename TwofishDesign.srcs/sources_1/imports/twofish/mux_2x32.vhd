library ieee;
use ieee.std_logic_1164.all;
-- Multiplexer that selects between in_0 and in_1.
-- in_0 is returned if sel is 0, in_1 is returned
-- otherwise.

entity mux_2x32 is
port(sel : in std_logic;
		in_0 : in std_logic_vector(31 downto 0);
		in_1 : in std_logic_vector(31 downto 0);
		output : out std_logic_vector(31 downto 0));
end mux_2x32;

architecture behavior of mux_2x32 is
begin
mux : process(sel,in_0,in_1)
begin
if sel = '0' then
	output <= in_0;
else
	output <= in_1;
end if;
end process;
end behavior;




