library ieee;
use ieee.std_logic_1164.all;

entity adder01 is
  port (dataa, datab, cin: in std_logic;
        result, cout: out std_logic);
end adder01;

architecture dataflow of adder01 is
begin
  result <= dataa xor datab xor cin;
  cout <= (dataa and datab) or (cin and (dataa or datab));
end dataflow;


