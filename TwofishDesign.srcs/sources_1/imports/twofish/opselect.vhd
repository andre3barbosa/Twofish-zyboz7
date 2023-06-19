-- This module performs the operation
-- that defines a block as a decrypter
-- or encrypter.

library ieee;
use ieee.std_logic_1164.all;

-- Operation selector
--
-- This module includes all parts of the
-- cipher that differ if it is in encryption
-- or decryption mode.
--
-- Encryption:
-- 	            in_A	   in_B
-- 	             | 	    |
--                 |        |
--  F-fct_A ----> xor      <<< 1
--  F-function     |        |
--  F-fct_B --------------> xor
--                 |        |
--                >>> 1     |
--                 |        |
--                out_A    out_B
--
--
-- Decryption:
--                in_A     in_B
--                 |        |
--                <<< 1     |
--                 |        |
--  F-fct_A ----> xor       |
--  F-function     |        |
--  F-fct_B --------------> xor
--                 |        |
--                 |       >>> 1
--                 |        |
--                out_A    out_B
--
--
-- encrypt: encryption mode / not decryption mode
-- F-fct_A: even output of F-function (top)
-- F-fct_B: odd output of F-function (bottom)
-- in_A: third input to the round
-- in_B: fourth input to the round
-- out_A: third output of the round
-- out_B: fourth output of the round
---

entity opselect is
port (encrypt : in std_logic;
	F_fct_A : in std_logic_vector(31 downto 0);
	F_fct_B : in std_logic_vector(31 downto 0);
	in_A : in std_logic_vector(31 downto 0);
	in_B : in std_logic_vector(31 downto 0);
	out_A : out std_logic_vector(31 downto 0);
	out_B : out std_logic_vector(31 downto 0));
end opselect;

architecture struct of opselect is
-- subcomponent
component sub_opselect 
port (rotate_before : in std_logic;
	F_fct : in std_logic_vector(31 downto 0);
	input : in std_logic_vector(31 downto 0);
	output : out std_logic_vector(31 downto 0));
end component;
signal decrypt : std_logic;
begin
-- left subcomponent:
-- do: rol, xor for decryption
-- xor, ror for encryption
-- => "rotate_before" when "encrypt" is 0
leftsub : sub_opselect
port map (rotate_before => decrypt,
		F_fct => F_fct_A,
		input => in_A,
		output => out_A);
-- right subcomponent:
-- do: rol, xor for encryption
-- xor, ror for decryption
-- => "rotate_before" when "encrypt" is 1
rightsub : sub_opselect
port map (rotate_before => encrypt,
		F_fct => F_fct_B,
		input => in_B,
		output => out_B);
		decrypt <= not encrypt;
end struct;



