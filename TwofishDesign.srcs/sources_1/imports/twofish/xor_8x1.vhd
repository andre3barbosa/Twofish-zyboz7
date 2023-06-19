library ieee;
use ieee.std_logic_1164.all;

entity xor_8x1 is
port(a,b,c,d,e,f,g,h : in std_logic;
     result : out std_logic);
end xor_8x1;

architecture dataflow of xor_8x1 is
begin
	process(a,b,c,d,e,f,g,h)
	begin
		result <= (a xor b xor c xor d xor e xor f xor g xor h);
	end process;
end dataflow;

