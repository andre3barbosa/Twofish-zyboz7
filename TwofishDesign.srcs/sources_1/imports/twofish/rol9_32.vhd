library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity rol9_32 is 
port (data : in std_logic_vector(31 downto 0);
      q : out std_logic_vector(31 downto 0));
end rol9_32;

architecture behavior of rol9_32 is
begin
reg: process(data)
begin
	q <= data(22 downto 0) & data(31 downto 23); --rotate left 9 bit
end process;
end behavior; 


