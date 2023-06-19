library ieee;
use ieee.std_logic_1164.all;

-- Maximum Distance Separable matrix
--
-- Each entry is 8-bits wide. The following operation is
-- performed in the Galois field GF(2^8). 
--
-- |z0| 		|01 EF 5B 5B| 		|y0|
-- |z1| =         |5B EF EF 01|   o       |y1|
-- |z2| 		|EF 5B 01 EF| 		|y2|
-- |z3| 		|EF 01 EF 5B| 		|y3|
--
entity mds is
port (y0 : in std_logic_vector(7 downto 0);
	y1 : in std_logic_vector(7 downto 0);
	y2 : in std_logic_vector(7 downto 0);
	y3 : in std_logic_vector(7 downto 0);
	z0 : out std_logic_vector(7 downto 0);
	z1 : out std_logic_vector(7 downto 0);
	z2 : out std_logic_vector(7 downto 0);
	z3 : out std_logic_vector(7 downto 0));
end mds;

architecture struct of mds is
-- multiplication by 5B
component multgf_5B
port (x : in std_logic_vector(7 downto 0);
	y : out std_logic_vector(7 downto 0));
end component;

-- multiplication by EF
component multgf_EF
port (x : in std_logic_vector(7 downto 0);
	y : out std_logic_vector(7 downto 0));
end component;

-- bit-wise xor of 4 8-bit vectors
component xor_4x8
port (x : in std_logic_vector (7 DOWNTO 0);
	y : in std_logic_vector (7 DOWNTO 0);
	z : in std_logic_vector (7 DOWNTO 0);
	w : in std_logic_vector (7 DOWNTO 0);
	result : out std_logic_vector (7 DOWNTO 0));
end component;

-- result of multiplications
signal y0xEF : std_logic_vector(7 downto 0);
signal y0x5B : std_logic_vector(7 downto 0);
signal y1xEF : std_logic_vector(7 downto 0);
signal y1x5B : std_logic_vector(7 downto 0);
signal y2xEF : std_logic_vector(7 downto 0);
signal y2x5B : std_logic_vector(7 downto 0);
signal y3xEF : std_logic_vector(7 downto 0);
signal y3x5B : std_logic_vector(7 downto 0);
begin
--
-- Do multiplications
--
y0xEF_comp: multgf_EF
port map ( x => y0,y => y0xEF);
y0x5B_comp: multgf_5B
port map ( x => y0,y => y0x5B);
y1xEF_comp: multgf_EF
port map ( x => y1,y => y1xEF);
y1x5B_comp: multgf_5B
port map ( x => y1,y => y1x5B);
y2xEF_comp: multgf_EF
port map ( x => y2,y => y2xEF);
y2x5B_comp: multgf_5B
port map ( x => y2,y => y2x5B);
y3xEF_comp: multgf_EF
port map ( x => y3,y => y3xEF);
y3x5B_comp: multgf_5B
port map ( x => y3,y => y3x5B);

--
-- do the additions (row by row)
--
-- (An addition in GF corresponds to an XOR.)
--
-- z0 = y0x01 + y1xEF + y2x5B + y3x5B
z0_xor: xor_4x8
port map (x => y0,
	    y => y1xEF,
	    z => y2x5B,
	    w => y3x5B,
	    result => z0 );
-- z1 = y0x5B + y1xEF + y2xEF + y3x01
z1_xor: xor_4x8
port map ( x => y0x5B,
	     y => y1xEF,
	     z => y2xEF,
	     w => y3,
	     result => z1 );
-- z2 = y0xEF + y1x5B + y2x01 + y3xEF
z2_xor: xor_4x8
port map ( x => y0xEF,
	     y => y1x5B,
	     z => y2,
	     w => y3xEF,
	     result => z2 );
-- z3 = y0xEF + y1x01 + y2xEF + y3x5B
z3_xor: xor_4x8
port map ( x => y0xEF,
		y => y1,
		z => y2xEF,
		w => y3x5B,
		result => z3 );

end struct;
library ieee;
use ieee.std_logic_1164.all;

-- Multiplication of an 8-bit vector by 0h5B in
-- Galois field GF9(2^8).
--
-- x: input vector
-- y: output vector
--
entity multgf_5B is
port(
x : in std_logic_vector(7 downto 0);
y : out std_logic_vector(7 downto 0));
end multgf_5B;

architecture struct of multgf_5B is
begin
y(0) <= x(2) XOR x(0);
y(1) <= x(3) XOR x(1) XOR x(0);
y(2) <= x(4) XOR x(2) XOR x(1);
y(3) <= x(5) XOR x(3) XOR x(0);
y(4) <= x(6) XOR x(4) XOR x(1) XOR x(0);
y(5) <= x(7) XOR x(5) XOR x(1);
y(6) <= x(6) XOR x(0);
y(7) <= x(7) XOR x(1);
end struct;

library ieee;
use ieee.std_logic_1164.all;

-- Multiplication of an 8-bit vector by 0hEF in
-- Galois field GF9(2^8). See section 4.2 of
-- "Twofish: A 128-Bit Block Cipher" for
-- details.
--
-- x: input vector
-- y: output vector
--
entity multgf_EF is
port(
x : in std_logic_vector(7 downto 0);
y : out std_logic_vector(7 downto 0));
end multgf_EF;

architecture struct of multgf_EF is
begin
y(0) <= x(2) XOR x(1) XOR x(0);
y(1) <= x(3) XOR x(2) XOR x(1) XOR x(0);
y(2) <= x(4) XOR x(3) XOR x(2) XOR x(1) XOR x(0);
y(3) <= x(5) XOR x(4) XOR x(3) XOR x(0);
y(4) <= x(6) XOR x(5) XOR x(4) XOR x(1);
y(5) <= x(7) XOR x(6) XOR x(5) XOR x(1) XOR x(0);
y(6) <= x(7) XOR x(6) XOR x(0);
y(7) <= x(7) XOR x(1) XOR x(0);
end struct;




