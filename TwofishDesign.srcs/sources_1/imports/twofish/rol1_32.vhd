library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity rol1_32 is 
port (data : in std_logic_vector(31 downto 0);
      q : out std_logic_vector(31 downto 0));
end rol1_32;

architecture behavior of rol1_32 is
begin
reg: process(data)
begin
	q <= data(30 downto 0) & data(31); --rotate left 1 bit
end process;
end behavior; 


