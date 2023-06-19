library ieee;
use ieee.std_logic_1164.all;

entity xor_3x4 is
PORT(dataa : in std_logic_vector(3 downto 0);
datab : in std_logic_vector(3 downto 0);
datac : in std_logic_vector(3 downto 0);
result : out std_logic_vector(3 downto 0));
end xor_3x4;

architecture behavior of xor_3x4 is
component xor_3x1
PORT(dataa,datab,datac : in std_logic;
     result : out std_logic);
END component;

begin 
aa: for i in 0 to 3 generate
    	bb: xor_3x1 port map(dataa(i),datab(i),datac(i),result(i));
    end generate;
end behavior;


