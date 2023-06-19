library ieee;
use ieee.std_logic_1164.all;

entity xor_4x1 is
port (x,y,z,w : in std_logic;
     result : out std_logic);
end xor_4x1;

architecture dataflow of xor_4x1 is
begin
	process(x,y,z,w)
	begin
		result <= (x xor y xor z xor w);
	end process;
end dataflow;


