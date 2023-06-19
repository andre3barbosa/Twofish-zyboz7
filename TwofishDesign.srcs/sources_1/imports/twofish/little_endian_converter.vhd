library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity little_endian_converter is 
port (big_endian : in std_logic_vector(127 downto 0);
      little_endian : out std_logic_vector(127 downto 0));
end little_endian_converter;

architecture behavior of little_endian_converter is

signal le0,le1,le2,le3,le4,le5,le6,le7,le8,le9,le10,le11,le12,le13,le14,le15 
	 : std_logic_vector(7 downto 0);



begin
	process(big_endian)
	begin
	--little endian convertion
	le0 <=big_endian(7 downto 0);
	le1 <=big_endian(15 downto 8);
	le2 <=big_endian(23 downto 16);
	le3 <=big_endian(31 downto 24);
	le4 <=big_endian(39 downto 32);
	le5 <=big_endian(47 downto 40);
	le6 <=big_endian(55 downto 48);
	le7 <=big_endian(63 downto 56);
	le8 <=big_endian(71 downto 64);
	le9 <=big_endian(79 downto 72);
	le10 <=big_endian(87 downto 80);
	le11 <=big_endian(95 downto 88);
	le12 <=big_endian(103 downto 96);
	le13 <=big_endian(111 downto 104);
	le14 <=big_endian(119 downto 112);
	le15 <=big_endian(127 downto 120);

	end process;

little_endian <= le0 & le1 & le2 & le3 & le4 & le5 & le6 & le7 & le8 & le9 & le10 & le11 & 
	           le12 & le13 & le14 & le15;   

end behavior; 


