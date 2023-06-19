library ieee;
use ieee.std_logic_1164.all;

entity xor_2x1 is
port(a,b : in std_logic;
     result : out std_logic);
end xor_2x1;

architecture dataflow of xor_2x1 is
begin
	process(a,b)
	begin
		result <= (a xor b);
	end process;
end dataflow;


