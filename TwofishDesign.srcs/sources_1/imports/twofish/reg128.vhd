library ieee; 
use ieee.std_logic_1164.all; 

entity reg128 is 
  port(clock,clr,enable : in  std_logic;
       data : in std_logic_vector (127 downto 0);
       q : out std_logic_vector (127 downto 0)); 
end reg128; 

architecture behavior of reg128 is 
component reg01
port(clock,clr,enable,data : in  std_logic;
       q : out std_logic); 
end component;

begin 
aa: for i in 0 to 127 generate
    	bb: reg01 port map(clock,clr,enable,data(i),q(i));
    end generate;
end behavior;

  

