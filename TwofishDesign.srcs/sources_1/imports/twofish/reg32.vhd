library ieee; 
use ieee.std_logic_1164.all; 

entity reg32 is 
  port(data : in std_logic_vector (31 downto 0);
       clock,clr,enable : in  std_logic;
       q : out std_logic_vector (31 downto 0)); 
end reg32; 

architecture behavior of reg32 is 
component reg01
port(clock,clr,enable, data : in  std_logic;
       q : out std_logic); 
end component;

begin 
aa: for i in 0 to 31 generate
    	bb: reg01 port map(clock,clr,enable,data(i),q(i));
    end generate;
end behavior;

  

