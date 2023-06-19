library ieee;
use ieee.std_logic_1164.all;

entity xor_3x1 is
port(dataa,datab,datac : in std_logic;
     result : out std_logic);
end xor_3x1;

architecture dataflow of xor_3x1 is
begin
	process(dataa,datab,datac)
	begin
		result <= (dataa xor datab xor datac);
	end process;
end dataflow;


