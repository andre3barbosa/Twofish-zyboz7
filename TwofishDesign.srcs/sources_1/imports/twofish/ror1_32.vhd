library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ror1_32 is 
port (data : in std_logic_vector(31 downto 0);
      q : out std_logic_vector(31 downto 0));
end ror1_32;

architecture behavior of ror1_32 is
begin
reg: process(data)
begin
	q <= data(0) & data(31 downto 1); --rotate right 1 bit
end process;
end behavior; 

