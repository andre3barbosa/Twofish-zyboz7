library ieee ;
use ieee.std_logic_1164.all ;

entity adder32 is
   port( dataa, datab : in  std_logic_vector(31 downto 0) ;
         cout : out std_logic ;
         cin  : in std_logic ;
         result : out std_logic_vector(31 downto 0)) ;
end adder32;

architecture behavior of adder32 is
   component adder01 
     port( dataa    : in std_logic ;
            datab    : in std_logic ;
            cin  : in std_logic ;
            result  : out std_logic ;
            cout : out std_logic ) ;
   end component;
   signal  c: std_logic_vector(31 downto 1) ;

begin
   g: for i in 0 to 31 generate

      g0: if (i = 0) generate
          x0: adder01 port map(dataa(0), datab(0), cin, result(0), c(1)) ;
      end generate g0 ;

      g1: if ((i > 0) and (i < 31)) generate
          x0: adder01 port map(dataa(i), datab(i), c(i), result(i), c(i+1)) ;
      end generate g1 ;

      g2: if (i = 31) generate
          x0: adder01 port map(dataa(31), datab(31), c(31), result(31), cout) ;
      end generate g2 ;
   end generate g ;
end behavior;












