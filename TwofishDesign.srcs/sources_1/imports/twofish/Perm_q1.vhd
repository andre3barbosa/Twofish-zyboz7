library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--Perm_q1: Block used for q1-type of permutation
entity Perm_q1 is
port( input : in std_logic_vector(7 downto 0);
		output : out std_logic_vector(7 downto 0));
end Perm_q1;

architecture struct OF Perm_q1 IS

component xor_2x4
port(a : in std_logic_vector(3 downto 0);
		b : in std_logic_vector(3 downto 0);
		result : out std_logic_vector(3 downto 0));
end component;

component xor_3x4
port(dataa : in std_logic_vector(3 downto 0);
		datab : in std_logic_vector(3 downto 0);
		datac : in std_logic_vector(3 downto 0);
		result : out std_logic_vector(3 downto 0));
end component;

Signal 
a_xor_b, --a XOR b
rotated_b, --b rotated right one time
a_zero, --(a(0),0,0,0) vector
befor_t1, --signal before lookup table t1
a_prime, --a prime (output of lookup table t0)
b_prime, --b prime (output of lookup table t1)
ap_xor_bp, --a prime XOR b prime
rotated_bp, --b prime rotated right one time
ap_zero, --(a’(0),0,0,0) vector
befor_t3 : std_logic_vector(3 downto 0); --input signal to lookup table t3

Signal
permuted_input : std_logic_vector(7 downto 0); --output of the q0 block

--Start of q0 permutation structure
begin
-- input = a&b
-- rotate b right once
-- b(3 downto 0) is input(3 downto 0)
rotated_b(3) <= input(0); 
rotated_b(2) <= input(3); 
rotated_b(1) <= input(2);
rotated_b(0) <= input(1);
--build a vector with (a(0),0,0,0)
-- a(3 downto 0) is input(7 downto 4)
a_zero(3) <= input(4);
a_zero(2) <= '0';
a_zero(1) <= '0';
a_zero(0) <= '0';
--rotate b_prime right once
rotated_bp(3) <= b_prime(0);
rotated_bp(2) <= b_prime(3);
rotated_bp(1) <= b_prime(2);
rotated_bp(0) <= b_prime(1);
--build a vector with (ap(0),0,0,0)
ap_zero(3) <= a_prime(0);
ap_zero(2) <= '0';
ap_zero(1) <= '0';
ap_zero(0) <= '0';
--
-- Computer a xor b
--

--xor a and b
xor1 : xor_2x4
port MAP( a => input(7 downto 4),
				b => input(3 downto 0),
				result => a_xor_b);
--
-- Compute a xor (b >>> 1) xor (a(0),0,0,0)
--
--xor a, rotated b and a_zero vector
xor2 : xor_3x4
port MAP( dataa => input(7 downto 4),
				datab => rotated_b,
				datac => a_zero,
				result => befor_t1);

--xor a_prime and b_prime
xor3 : xor_2x4
port MAP( a => a_prime,
				b => b_prime,
				result => ap_xor_bp);

--
-- a’ xor (b’ >>> 1) xor (a’(0),0,0,0)
--
--xor rotated b_prime, a_prime and ap_zero vector
xor4 : xor_3x4
port MAP( dataa => a_prime,
				datab => rotated_bp,
				datac => ap_zero,
				result => befor_t3);
--
-- lookup table t0
--
q1_t0 : process (a_xor_b,a_prime)
begin
if a_xor_b = "0000" then a_prime <= "0010"; -- 2
elsif a_xor_b = "0001" then a_prime <= "1000"; -- 8
elsif a_xor_b = "0010" then a_prime <= "1011"; -- B
elsif a_xor_b = "0011" then a_prime <= "1101"; -- D
elsif a_xor_b = "0100" then a_prime <= "1111"; -- F
elsif a_xor_b = "0101" then a_prime <= "0111"; -- 7
elsif a_xor_b = "0110" then a_prime <= "0110"; -- 6
elsif a_xor_b = "0111" then a_prime <= "1110"; -- E
elsif a_xor_b = "1000" then a_prime <= "0011"; -- 3
elsif a_xor_b = "1001" then a_prime <= "0001"; -- 1
elsif a_xor_b = "1010" then a_prime <= "1001"; -- 9
elsif a_xor_b = "1011" then a_prime <= "0100"; -- 4
elsif a_xor_b = "1100" then a_prime <= "0000"; -- 0
elsif a_xor_b = "1101" then a_prime <= "1010"; -- A
elsif a_xor_b = "1110" then a_prime <= "1100"; -- C
else a_prime <= "0101"; -- 5
end if;
end process;
--lookup table t1
q1_t1 : process (befor_t1,b_prime)
begin
if befor_t1 = "0000" then b_prime <= "0001"; -- 1
elsif befor_t1 = "0001" then b_prime <= "1110"; -- E
elsif befor_t1 = "0010" then b_prime <= "0010"; -- 2
elsif befor_t1 = "0011" then b_prime <= "1011"; -- B
elsif befor_t1 = "0100" then b_prime <= "0100"; -- 4
elsif befor_t1 = "0101" then b_prime <= "1100"; -- C
elsif befor_t1 = "0110" then b_prime <= "0011"; -- 3
elsif befor_t1 = "0111" then b_prime <= "0111"; -- 7
elsif befor_t1 = "1000" then b_prime <= "0110"; -- 6
elsif befor_t1 = "1001" then b_prime <= "1101"; -- D
elsif befor_t1 = "1010" then b_prime <= "1010"; -- A
elsif befor_t1 = "1011" then b_prime <= "0101"; -- 5
elsif befor_t1 = "1100" then b_prime <= "1111"; -- F
elsif befor_t1 = "1101" then b_prime <= "1001"; -- 9
elsif befor_t1 = "1110" then b_prime <= "0000"; -- 0
else b_prime <= "1000"; -- 8
end if;
end process;
--lookup table t2
q1_t2 : process (ap_xor_bp,permuted_input)
begin
if ap_xor_bp = "0000" then permuted_input(7 downto 4) <= "0100"; -- 4
elsif ap_xor_bp = "0001" then permuted_input(7 downto 4) <= "1100"; -- C
elsif ap_xor_bp = "0010" then permuted_input(7 downto 4) <= "0111"; -- 7
elsif ap_xor_bp = "0011" then permuted_input(7 downto 4) <= "0101"; -- 5
elsif ap_xor_bp = "0100" then permuted_input(7 downto 4) <= "0001"; -- 1
elsif ap_xor_bp = "0101" then permuted_input(7 downto 4) <= "0110"; -- 6
elsif ap_xor_bp = "0110" then permuted_input(7 downto 4) <= "1001"; -- 9
elsif ap_xor_bp = "0111" then permuted_input(7 downto 4) <= "1010"; -- A
elsif ap_xor_bp = "1000" then permuted_input(7 downto 4) <= "0000"; -- 0
elsif ap_xor_bp = "1001" then permuted_input(7 downto 4) <= "1110"; -- E
elsif ap_xor_bp = "1010" then permuted_input(7 downto 4) <= "1101"; -- D
elsif ap_xor_bp = "1011" then permuted_input(7 downto 4) <= "1000"; -- 8
elsif ap_xor_bp = "1100" then permuted_input(7 downto 4) <= "0010"; -- 2
elsif ap_xor_bp = "1101" then permuted_input(7 downto 4) <= "1011"; -- B
elsif ap_xor_bp = "1110" then permuted_input(7 downto 4) <= "0011"; -- 3
else permuted_input(7 downto 4) <= "1111"; -- F
end if;
end process;
--lookup table t3
q1_t3 : process (befor_t3,permuted_input)
begin
if befor_t3 = "0000" then permuted_input(3 downto 0) <= "1011"; -- B
elsif befor_t3 = "0001" then permuted_input(3 downto 0) <= "1001"; -- 9
elsif befor_t3 = "0010" then permuted_input(3 downto 0) <= "0101"; -- 5
elsif befor_t3 = "0011" then permuted_input(3 downto 0) <= "0001"; -- 1
elsif befor_t3 = "0100" then permuted_input(3 downto 0) <= "1100"; -- C
elsif befor_t3 = "0101" then permuted_input(3 downto 0) <= "0011"; -- 3
elsif befor_t3 = "0110" then permuted_input(3 downto 0) <= "1101"; -- D
elsif befor_t3 = "0111" then permuted_input(3 downto 0) <= "1110"; -- E
elsif befor_t3 = "1000" then permuted_input(3 downto 0) <= "0110"; -- 6
elsif befor_t3 = "1001" then permuted_input(3 downto 0) <= "0100"; -- 4
elsif befor_t3 = "1010" then permuted_input(3 downto 0) <= "0111"; -- 7
elsif befor_t3 = "1011" then permuted_input(3 downto 0) <= "1111"; -- F
elsif befor_t3 = "1100" then permuted_input(3 downto 0) <= "0010"; -- 2
elsif befor_t3 = "1101" then permuted_input(3 downto 0) <= "0000"; -- 0
elsif befor_t3 = "1110" then permuted_input(3 downto 0) <= "1000"; -- 8
else permuted_input(3 downto 0) <= "1010"; -- A
end if;
end process;
--assigning value to the output
-- output = b&a (see page 10 of twofish)
output <= permuted_input(3 downto 0) & permuted_input(7 downto 4); -----MAKE SURE THIS WORKS WELL!!!!
end struct;


