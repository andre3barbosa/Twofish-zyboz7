library ieee;
use ieee.std_logic_1164.all;

entity xor_2x4 is
PORT(a : in std_logic_vector(3 downto 0);
		b : in std_logic_vector(3 downto 0);
		result : out std_logic_vector(3 downto 0));
end xor_2x4;

architecture behavior of xor_2x4 is
component xor_2x1
PORT(a,b : in std_logic;
     result : out std_logic);
END component;

begin 
aa: for i in 0 to 3 generate
    	bb: xor_2x1 port map(a(i),b(i),result(i));
    end generate;
end behavior;




