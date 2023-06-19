library ieee;
use ieee.std_logic_1164.all;

entity xor_4x8 is
port(x : in std_logic_vector(7 downto 0);
y : in std_logic_vector(7 downto 0);
z : in std_logic_vector(7 downto 0);
w : in std_logic_vector(7 downto 0);
result : out std_logic_vector(7 downto 0));
END xor_4x8;


architecture behavior of xor_4x8 is
component xor_4x1
	PORT(x,y,z,w : in std_logic;
             result : out std_logic);
END component;

begin 
aa: for i in 0 to 7 generate
    	bb: xor_4x1 port map(x(i),y(i),z(i),w(i),result(i));
    end generate;
end behavior;


