library ieee;
use ieee.std_logic_1164.all;

-- Pseudo-Hadamard Transform:
--
-- A_in --- + -------------> A_out = A_in + B_in
-- 		| 			|
-- 		| 			|
-- 		| 			|
-- 		| 			|
-- 		B_in -----------> + ----> B_out = A_in + 2B_in
--
-- All inputs and outputs are 32-bits wide. Additions
-- are done in modulo 2^32.
--
entity pht is
port(A_in : in std_logic_vector(31 downto 0);
		B_in : in std_logic_vector(31 downto 0);
		A_out : out std_logic_vector(31 downto 0);
		B_out : out std_logic_vector(31 downto 0));
end pht;

-- Structural implementation
--
-- A_in ----------
-- 			| ----> A_out
-- B_in ----------
--
-- A_in ----------
-- 			| ----> B_out
-- B_in --- << ---
--
architecture struct OF pht is
component adder32
   port( dataa, datab : in  std_logic_vector(31 downto 0) ;
         cout : out std_logic ;
         cin  : in std_logic:= '0';
         result : out std_logic_vector(31 downto 0)) ;
end component;

signal B_in_x2 : std_logic_vector (31 downto 0);
begin
-- top adder: A_out = A_in + B_in
top_adder : adder32
port map (dataa => A_in,
	    datab => B_in,
          result => A_out);

-- bottom adder: A_out = A_in + 2B_in
bottom_adder : adder32
port map (dataa => A_in,
	    datab => B_in_x2,
	    result => B_out);

-- Compute 2B_in by shifting B_in left by one.
two_times_2B_in: process (B_in,B_in_x2) 
begin
for i IN 31 downto 1 loop
	B_in_x2(i) <= B_in(i-1);
end loop;
B_in_x2(0) <= '0';
end process two_times_2B_in;
end struct;


