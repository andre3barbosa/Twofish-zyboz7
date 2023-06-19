library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity rol8_32 is 
port (data : in std_logic_vector(31 downto 0);
      q : out std_logic_vector(31 downto 0));
end rol8_32;

architecture behavior of rol8_32 is
begin
reg: process(data)
begin
	q <= data(23 downto 0) & data(31 downto 24); --rotate left 8 bit
end process;
end behavior; 


