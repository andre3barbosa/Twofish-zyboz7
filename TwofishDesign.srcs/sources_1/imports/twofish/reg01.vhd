library ieee; 
use ieee.std_logic_1164.all; 

entity reg01 is 
port (clock, clr, data, enable : in  std_logic;
      q : out std_logic); 
end reg01; 
architecture dataflow of reg01 is 
begin 
process (clock,clr) 
begin 
if (clr ='1') then
	q <='0';
elsif (clock'event and clock='1') then 
	if (enable='1') then 
     		q <= data; 
     	end if;
end if; 
end process; 
end dataflow;




