library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- 			 	  S0 		        S1
-- 			   	  |                 |
-- 		              |                 |
-- incoming --> BANK1 --> XOR --> BANK2 --> XOR --> BANK3 --> outcome
--
-- Bank1: q0,q1,q0,q1
-- Bank2: q0,q0,q1,q1
-- Bank3: q1,q0,q1,q0
--
--S-boxes used for multiple permutation
entity S_boxes is
port( income : in std_logic_vector(31 downto 0);
		S0 : in std_logic_vector(31 downto 0);
		S1 : in std_logic_vector(31 downto 0);
		outcome : out std_logic_vector(31 downto 0);
		out_bank1_x,
		in_bank2_x,
		out_bank2_x,
		in_bank3_x : out std_logic_vector(31 downto 0));
end S_boxes;

--Building block of the S-boxes
architecture struct OF S_boxes IS
--
-- component declaration
--
--q1 permutation modules
component Perm_q1 
port( input :in std_logic_vector(7 downto 0);
		output :out std_logic_vector(7 downto 0));
end component;

--q0 permutation modules
component Perm_q0 
port( input :in std_logic_vector(7 downto 0);
		output :out std_logic_vector(7 downto 0));
end component;

--XOR modules
component xor_2x32
PORT(a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		result : out std_logic_vector(31 downto 0));
end component;

--SIGNAL DECLARATION
Signal
out_bank1, --Output of the first bank of q-permutations
in_bank2, --Input to the second bank of q-permutations (after XORing with S0)
out_bank2, --Output of the second bank of q-permutations
in_bank3, --Input to the third bank of q-permutations (after XORing with S1)
out_bank3 : std_logic_vector(31 downto 0); --Output of the third bank of q-permutations

--start of s_boxes structure
BEGIN
out_bank1_x <= out_bank1;
in_bank2_x <= in_bank2;
out_bank2_x <= out_bank2;
in_bank3_x <= in_bank3;
--
-- BANK 1
--
--first permutation in S-box 0
S_box0_bank1 : Perm_q0
port map( input => income(7 downto 0),
				output => out_bank1(7 downto 0));
--first permutation in S-box 1
S_box1_bank1 : Perm_q1
port map( input => income(15 downto 8),
				output => out_bank1(15 downto 8));
--first permutation in S-box 2
S_box2_bank1 : Perm_q0
port map( input => income(23 downto 16),
				output => out_bank1(23 downto 16));
--first permutation in S-box 3
S_box3_bank1 : Perm_q1
port map( input => income(31 downto 24),
				output => out_bank1(31 downto 24));

--XOR the converted output of the first bank of permutations and S0
XOR_S0 : xor_2x32
port map( a => out_bank1,
				b => S0,
				result => in_bank2);
--
-- BANK 2
--
--Second permutation in S-box 0
S_box0_bank2 : Perm_q0
port map( input => in_bank2(7 downto 0),
				output => out_bank2(7 downto 0));
--Second permutation in S-box 1
S_box1_bank2 : Perm_q0
port map( input => in_bank2(15 downto 8),
				output => out_bank2(15 downto 8));
--Second permutation in S-box 2
S_box2_bank2 : Perm_q1
port map( input => in_bank2(23 downto 16),
				output => out_bank2(23 downto 16));
--Second permutation in S-box 3
S_box3_bank2 : Perm_q1
port map( input => in_bank2(31 downto 24),
				output => out_bank2(31 downto 24));
--
-- BANK2 XOR S1
--

XOR_S1 : xor_2x32
port map( a => out_bank2,
				b => S1,
				result => in_bank3);
--
-- BANK 3
--
--Third permutation in S-box 0
S_box0_bank3 : Perm_q1
port map( input => in_bank3(7 downto 0),
				output => out_bank3(7 downto 0));
--Third permutation in S-box 1
S_box1_bank3 : Perm_q0
port map( input => in_bank3(15 downto 8),
				output => out_bank3(15 downto 8));
--Third permutation in S-box 2
S_box2_bank3 : Perm_q1
port map( input => in_bank3(23 downto 16),
				output => out_bank3(23 downto 16));
--Thirdd permutation in S-box 3
S_box3_bank3 : Perm_q0
port map( input => in_bank3(31 downto 24),
				output => out_bank3(31 downto 24));
--
-- Final result
--
--Assigning output from signal
outcome <= out_bank3;
end struct;


