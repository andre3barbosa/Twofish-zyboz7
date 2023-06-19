library ieee;
use ieee.std_logic_1164.all;

entity xor_8x8 is
port (a : in std_logic_vector(7 downto 0);
b : in std_logic_vector(7 downto 0);
c : in std_logic_vector(7 downto 0);
d : in std_logic_vector(7 downto 0);
e : in std_logic_vector(7 downto 0);
f : in std_logic_vector(7 downto 0);
g : in std_logic_vector(7 downto 0);
h : in std_logic_vector(7 downto 0);
result : out std_logic_vector(7 downto 0));
end xor_8x8;


architecture behavior of xor_8x8 is
component xor_8x1
	PORT(A,B,C,D,E,F,G,H : in std_logic;
             result : out std_logic);
END component;

begin 
aa: for i in 0 to 7 generate
    	bb: xor_8x1 port map(a(i),b(i),c(i),d(i),e(i),f(i),g(i),h(i),result(i));
    end generate;
end behavior;

