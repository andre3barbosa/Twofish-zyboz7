--
-- |s0| |01 A4 55 87 5A 58 DB 9E| |m0|
-- |s1| = |A4 56 82 F3 1E C6 68 E5| o |m1|
-- |s2| |02 A1 FC C1 47 AE 3D 19| |m2|
-- |s3| |A4 55 87 5A 58 DB 9E 03| |m3|
-- |m4|
-- |m5|
-- |m6|
-- |m7|
--
-- In Galois field GF(2^8) with primitive polynomial
-- x^8 + x^6 + x^3 + x^2 + 1.
--
--
library ieee;
use ieee.std_logic_1164.all;
entity rsmatrix is
port(m0 : in std_logic_vector(7 downto 0);
     m1 : in std_logic_vector(7 downto 0);
     m2 : in std_logic_vector(7 downto 0);
     m3 : in std_logic_vector(7 downto 0);
     m4 : in std_logic_vector(7 downto 0);
     m5 : in std_logic_vector(7 downto 0);
     m6 : in std_logic_vector(7 downto 0);
     m7 : in std_logic_vector(7 downto 0);
     s0 : out std_logic_vector(7 downto 0);
     s1 : out std_logic_vector(7 downto 0);
     s2 : out std_logic_vector(7 downto 0);
     s3 : out std_logic_vector(7 downto 0));
end rsmatrix;

architecture struct of rsmatrix is

component multgf_A4 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_55 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_87 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_5A 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_58 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_DB 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_9E 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_56 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_82 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_F3 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_1E 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_C6 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_68 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_E5 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_02
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_A1
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_FC 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_C1 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_47 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_AE 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_3D 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_19 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component multgf_03 
port(inbyte : in std_logic_vector(7 downto 0);
	  outbyte : out std_logic_vector(7 downto 0));
end component;

component xor_8x8 
port(A : in std_logic_vector(7 downto 0);
B : in std_logic_vector(7 downto 0);
C : in std_logic_vector(7 downto 0);
D : in std_logic_vector(7 downto 0);
E : in std_logic_vector(7 downto 0);
F : in std_logic_vector(7 downto 0);
G : in std_logic_vector(7 downto 0);
H : in std_logic_vector(7 downto 0);
result : out std_logic_vector(7 downto 0));
end component;
SIGNAL m0x01, m1xA4, m2x55, m3x87, m4x5A, m5x58, m6xDB, m7x9E,
m0xA4, m1x56, m2x82, m3xF3, m4x1E, m5xC6, m6x68, m7xE5,
m0x02, m1xA1, m2xFC, m3xC1, m4x47, m5xAE, m6x3D, m7x19,
m1x55, m2x87, m3x5A, m4x58, m5xDB, m6x9E, m7x03
: STD_LOGIC_VECTOR(7 downto 0);
begin
--
-- compute first row
--
m0x01 <= m0;
m1xA4_comp: multgf_A4 PORT MAP (inbyte => m1, outbyte => m1xA4);
m2x55_comp: multgf_55 PORT MAP (inbyte => m2, outbyte => m2x55);
m3x87_comp: multgf_87 PORT MAP (inbyte => m3, outbyte => m3x87);
m4x5A_comp: multgf_5A PORT MAP (inbyte => m4, outbyte => m4x5A);
m5x58_comp: multgf_58 PORT MAP (inbyte => m5, outbyte => m5x58);
m6xDB_comp: multgf_DB PORT MAP (inbyte => m6, outbyte => m6xDB);
m7x9E_comp: multgf_9E PORT MAP (inbyte => m7, outbyte => m7x9E);
--
-- computer second row
--
m0xA4_comp: multgf_A4 PORT MAP (inbyte => m0, outbyte => m0xA4);
m1x56_comp: multgf_56 PORT MAP (inbyte => m1, outbyte => m1x56);
m2x82_comp: multgf_82 PORT MAP (inbyte => m2, outbyte => m2x82);
m3xF3_comp: multgf_F3 PORT MAP (inbyte => m3, outbyte => m3xF3);
m4x1E_comp: multgf_1E PORT MAP (inbyte => m4, outbyte => m4x1E);
m5xC6_comp: multgf_C6 PORT MAP (inbyte => m5, outbyte => m5xC6);
m6x68_comp: multgf_68 PORT MAP (inbyte => m6, outbyte => m6x68);
m7xE5_comp: multgf_E5 PORT MAP (inbyte => m7, outbyte => m7xE5);
--
-- computer third row
--
m0x02_comp: multgf_02 PORT MAP (inbyte => m0, outbyte => m0x02);
m1xA1_comp: multgf_A1 PORT MAP (inbyte => m1, outbyte => m1xA1);
m2xFC_comp: multgf_FC PORT MAP (inbyte => m2, outbyte => m2xFC);
m3xC1_comp: multgf_C1 PORT MAP (inbyte => m3, outbyte => m3xC1);
m4x47_comp: multgf_47 PORT MAP (inbyte => m4, outbyte => m4x47);
m5xAE_comp: multgf_AE PORT MAP (inbyte => m5, outbyte => m5xAE);
m6x3D_comp: multgf_3D PORT MAP (inbyte => m6, outbyte => m6x3D);
m7x19_comp: multgf_19 PORT MAP (inbyte => m7, outbyte => m7x19);
--
-- computer fourth row
--
-- m0xA4 is already done
m1x55_comp: multgf_55 PORT MAP (inbyte => m1, outbyte => m1x55);
m2x87_comp: multgf_87 PORT MAP (inbyte => m2, outbyte => m2x87);
m3x5A_comp: multgf_5A PORT MAP (inbyte => m3, outbyte => m3x5A);
m4x58_comp: multgf_58 PORT MAP (inbyte => m4, outbyte => m4x58);
m5xDB_comp: multgf_DB PORT MAP (inbyte => m5, outbyte => m5xDB);
m6x9E_comp: multgf_9E PORT MAP (inbyte => m6, outbyte => m6x9E);
m7x03_comp: multgf_03 PORT MAP (inbyte => m7, outbyte => m7x03);
--
-- add elements of row 1
--
row1_xor: xor_8x8
PORT MAP ( A => m0x01,
B => m1xA4,
C => m2x55,
D => m3x87,
E => m4x5A,
F => m5x58,
G => m6xDB, 
H => m7x9E,
result => s0 );
--
-- add elements of row 2
--
row2_xor: xor_8x8
PORT MAP ( A => m0xA4,
B => m1x56,
C => m2x82,
D => m3xF3,
E => m4x1E,
F => m5xC6,
G => m6x68,
H => m7xE5,
result => s1 );
--
-- add elements of row 3
--
row3_xor: xor_8x8
PORT MAP ( A => m0x02,
B => m1xA1,
C => m2xFC,
D => m3xC1,
E => m4x47,
F => m5xAE,
G => m6x3D,
H => m7x19,
result => s2 );
--
-- add elements of row 4
--
row4_xor: xor_8x8
PORT MAP ( A => m0xA4,
B => m1x55,
C => m2x87,
D => m3x5A,
E => m4x58,
F => m5xDB,
G => m6x9E,
H => m7x03,
result => s3 );
end struct;
--
-- The following multiplications are carriend out
-- in the Galois field GF(2^8) with primitve polynomial
-- x^8 + x^6 + x^3 + x^2 + 1.
--
-- The number is in hexadecimal. inbyte is the input
-- vector and outbyte the output vector.
--
--
-- A4
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_A4 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_A4;

architecture struct of multgf_A4 is
begin
outbyte(7) <= inbyte(6) XOR inbyte(0);
outbyte(6) <= inbyte(5);
outbyte(5) <= inbyte(6) XOR inbyte(4) XOR inbyte(0);
outbyte(4) <= inbyte(5) XOR inbyte(3);
outbyte(3) <= inbyte(7) XOR inbyte(4) XOR inbyte(2);
outbyte(2) <= inbyte(7) XOR inbyte(3) XOR inbyte(1) XOR inbyte(0);
outbyte(1) <= inbyte(2);
outbyte(0) <= inbyte(7) XOR inbyte(1);
end struct;
--
-- 55
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_55 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_55;

architecture struct of multgf_55 is
begin
outbyte(7) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(1);
outbyte(6) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(0);
outbyte(5) <= inbyte(7) XOR inbyte(4) XOR inbyte(3) XOR inbyte(1);
outbyte(4) <= inbyte(7) XOR inbyte(6) XOR inbyte(3) XOR inbyte(2) XOR inbyte(0);
outbyte(3) <= inbyte(6) XOR inbyte(5) XOR inbyte(2) XOR inbyte(1);
outbyte(2) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(0);
outbyte(1) <= inbyte(7) XOR inbyte(3) XOR inbyte(1);
outbyte(0) <= inbyte(7) XOR inbyte(6) XOR inbyte(2) XOR inbyte(0);
end struct;
--
-- 87
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_87 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_87;

architecture struct of multgf_87 is
begin
outbyte(7) <= inbyte(6) XOR inbyte(4) XOR inbyte(2) XOR inbyte(0);
outbyte(6) <= inbyte(7) XOR inbyte(5) XOR inbyte(3) XOR inbyte(1);
outbyte(5) <= inbyte(7);
outbyte(4) <= inbyte(6);
outbyte(3) <= inbyte(7) XOR inbyte(5);
outbyte(2) <= inbyte(2) XOR inbyte(0);
outbyte(1) <= inbyte(6) XOR inbyte(4) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(0) <= inbyte(7) XOR inbyte(5) XOR inbyte(3) XOR inbyte(1) XOR inbyte(0);
end struct;
--
-- 5A
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_5A is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_5A;

architecture struct of multgf_5A is
begin
outbyte(7) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(1);
outbyte(6) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(3) XOR inbyte(0);
outbyte(5) <= inbyte(5) XOR inbyte(2) XOR inbyte(1);
outbyte(4) <= inbyte(7) XOR inbyte(4) XOR inbyte(1) XOR inbyte(0);
outbyte(3) <= inbyte(7) XOR inbyte(6) XOR inbyte(3) XOR inbyte(0);
outbyte(2) <= inbyte(5) XOR inbyte(4) XOR inbyte(2) XOR inbyte(1);
outbyte(1) <= inbyte(6) XOR inbyte(3) XOR inbyte(0);
outbyte(0) <= inbyte(7) XOR inbyte(5) XOR inbyte(2);
end struct;
--
-- 58
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_58 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_58;

architecture struct of multgf_58 is
begin
outbyte(7) <= inbyte(7) XOR inbyte(4) XOR inbyte(1);
outbyte(6) <= inbyte(6) XOR inbyte(3) XOR inbyte(0);
outbyte(5) <= inbyte(5) XOR inbyte(4) XOR inbyte(2) XOR inbyte(1);
outbyte(4) <= inbyte(7) XOR inbyte(4) XOR inbyte(3) XOR inbyte(1) XOR inbyte(0);
outbyte(3) <= inbyte(6) XOR inbyte(3) XOR inbyte(2) XOR inbyte(0);
outbyte(2) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(2);
outbyte(1) <= inbyte(6) XOR inbyte(3);
outbyte(0) <= inbyte(5) XOR inbyte(2);
end struct;
--
-- DB
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_DB is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_DB;

architecture struct of multgf_DB is
begin
outbyte(7) <= inbyte(6) XOR inbyte(5) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(6) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(1) XOR inbyte(0);
outbyte(5) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1);
outbyte(4) <= inbyte(6) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(3) <= inbyte(5) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(2) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(4);
outbyte(1) <= inbyte(7) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(0) <= inbyte(7) XOR inbyte(6) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
end struct;
--
-- 9E
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_9E is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_9E;

architecture struct of multgf_9E is
begin
outbyte(7) <= inbyte(5) XOR inbyte(3) XOR inbyte(2) XOR inbyte(0);
outbyte(6) <= inbyte(7) XOR inbyte(4) XOR inbyte(2) XOR inbyte(1);
outbyte(5) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(2) XOR inbyte(1);
outbyte(4) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(1) XOR inbyte(0);
outbyte(3) <= inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(0);
outbyte(2) <= inbyte(5) XOR inbyte(4) XOR inbyte(0);
outbyte(1) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(2) XOR inbyte(0);
outbyte(0) <= inbyte(6) XOR inbyte(4) XOR inbyte(3) XOR inbyte(1);
end struct;
--
-- 56
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_56 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_56;

architecture struct of multgf_56 is
begin
outbyte(7) <= inbyte(5) XOR inbyte(1);
outbyte(6) <= inbyte(4) XOR inbyte(0);
outbyte(5) <= inbyte(7) XOR inbyte(5) XOR inbyte(3) XOR inbyte(1);
outbyte(4) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(2) XOR inbyte(0);
outbyte(3) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(3) XOR inbyte(1);
outbyte(2) <= inbyte(6) XOR inbyte(4) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(1) <= inbyte(7) XOR inbyte(3) XOR inbyte(0);
outbyte(0) <= inbyte(6) XOR inbyte(2);
end struct;
--
-- 82
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_82 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_82;

architecture struct of multgf_82 is
begin
outbyte(7) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(2) XOR inbyte(0);
outbyte(6) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(1);
outbyte(5) <= inbyte(7) XOR inbyte(5) XOR inbyte(3);
outbyte(4) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(2);
outbyte(3) <= inbyte(6) XOR inbyte(5) XOR inbyte(3) XOR inbyte(1);
outbyte(2) <= inbyte(6);
outbyte(1) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(2) XOR inbyte(0);
outbyte(0) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(3) XOR inbyte(1);
end struct;
--
-- F3
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_F3 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_F3;

architecture struct of multgf_F3 is
begin
outbyte(7) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(1) XOR inbyte(0);
outbyte(6) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(0);
outbyte(5) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(3) XOR inbyte(1) XOR inbyte(0);
outbyte(4) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(3) XOR inbyte(2) XOR inbyte(0);
outbyte(3) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(2) XOR inbyte(1);
outbyte(2) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(3);
outbyte(1) <= inbyte(7) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(0) <= inbyte(7) XOR inbyte(6) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
end struct;
--
-- 1E
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_1E is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_1E;

architecture struct of multgf_1E is
begin
outbyte(7) <= inbyte(4) XOR inbyte(3);
outbyte(6) <= inbyte(7) XOR inbyte(3) XOR inbyte(2);
outbyte(5) <= inbyte(6) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1);
outbyte(4) <= inbyte(7) XOR inbyte(5) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(3) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(2) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(1) XOR inbyte(0);
outbyte(1) <= inbyte(6) XOR inbyte(5) XOR inbyte(0);
outbyte(0) <= inbyte(5) XOR inbyte(4);
end struct;
--
-- C6
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_C6 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_C6;

architecture struct of multgf_C6 is
begin
outbyte(7) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(6) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(5) <= inbyte(7) XOR inbyte(6) XOR inbyte(4);
outbyte(4) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(3);
outbyte(3) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(2);
outbyte(2) <= inbyte(7) XOR inbyte(2) XOR inbyte(0);
outbyte(1) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(0);
outbyte(0) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1);
end struct;
--
-- 68
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_68 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_68;

architecture struct of multgf_68 is
begin
outbyte(7) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1);
outbyte(6) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(5) <= inbyte(4) XOR inbyte(2) XOR inbyte(0);
outbyte(4) <= inbyte(3) XOR inbyte(1);
outbyte(3) <= inbyte(7) XOR inbyte(2) XOR inbyte(0);
outbyte(2) <= inbyte(7) XOR inbyte(5) XOR inbyte(3) XOR inbyte(2);
outbyte(1) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3);
outbyte(0) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2);
end struct;
--
-- E5
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_E5 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_E5;

architecture struct of multgf_E5 is
begin
outbyte(7) <= inbyte(7) XOR inbyte(5) XOR inbyte(3) XOR inbyte(1) XOR inbyte(0);
outbyte(6) <= inbyte(6) XOR inbyte(4) XOR inbyte(2) XOR inbyte(0);
outbyte(5) <= inbyte(0);
outbyte(4) <= inbyte(7);
outbyte(3) <= inbyte(6);
outbyte(2) <= inbyte(3) XOR inbyte(1) XOR inbyte(0);
outbyte(1) <= inbyte(7) XOR inbyte(5) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1);
outbyte(0) <= inbyte(6) XOR inbyte(4) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
end struct;
--
-- 02
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_02 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_02;

architecture struct of multgf_02 is
begin
outbyte(7) <= inbyte(6);
outbyte(6) <= inbyte(7) XOR inbyte(5);
outbyte(5) <= inbyte(4);
outbyte(4) <= inbyte(3);
outbyte(3) <= inbyte(7) XOR inbyte(2);
outbyte(2) <= inbyte(7) XOR inbyte(1);
outbyte(1) <= inbyte(0);
outbyte(0) <= inbyte(7);
end struct;
--
-- A1
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_A1 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_A1;

architecture struct of multgf_A1 is
begin
outbyte(7) <= inbyte(6) XOR inbyte(5) XOR inbyte(0);
outbyte(6) <= inbyte(5) XOR inbyte(4);
outbyte(5) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(0);
outbyte(4) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2);
outbyte(3) <= inbyte(6) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1);
outbyte(2) <= inbyte(7) XOR inbyte(6) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1);
outbyte(1) <= inbyte(7) XOR inbyte(2) XOR inbyte(1);
outbyte(0) <= inbyte(7) XOR inbyte(6) XOR inbyte(1) XOR inbyte(0);
end struct;
--
-- FC
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_FC is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_FC;

architecture struct of multgf_FC is
begin
outbyte(7) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(1) XOR inbyte(0);
outbyte(6) <= inbyte(6) XOR inbyte(5) XOR inbyte(3) XOR inbyte(0);
outbyte(5) <= inbyte(6) XOR inbyte(5) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(4) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(1) XOR inbyte(0);
outbyte(3) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(3) XOR inbyte(0);
outbyte(2) <= inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(1) <= inbyte(6) XOR inbyte(3) XOR inbyte(2);
outbyte(0) <= inbyte(7) XOR inbyte(5) XOR inbyte(2) XOR inbyte(1);
end struct;
--
-- C1
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_C1 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_C1;

architecture struct of multgf_C1 is
begin
outbyte(7) <= inbyte(7) XOR inbyte(6) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(6) <= inbyte(6) XOR inbyte(5) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(5) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(3);
outbyte(4) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(2);
outbyte(3) <= inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(1);
outbyte(2) <= inbyte(6) XOR inbyte(1);
outbyte(1) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1);
outbyte(0) <= inbyte(7) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
end struct;
--
-- 47
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_47 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_47;

architecture struct of multgf_47 is
begin
outbyte(7) <= inbyte(3) XOR inbyte(1);
outbyte(6) <= inbyte(7) XOR inbyte(2) XOR inbyte(0);
outbyte(5) <= inbyte(6) XOR inbyte(3);
outbyte(4) <= inbyte(5) XOR inbyte(2);
outbyte(3) <= inbyte(7) XOR inbyte(4) XOR inbyte(1);
outbyte(2) <= inbyte(6) XOR inbyte(1) XOR inbyte(0);
outbyte(1) <= inbyte(5) XOR inbyte(3) XOR inbyte(1) XOR inbyte(0);
outbyte(0) <= inbyte(4) XOR inbyte(2) XOR inbyte(0);
end struct;
--
-- AE
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_AE is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_AE;

architecture struct of multgf_AE is
begin
outbyte(7) <= inbyte(6) XOR inbyte(4) XOR inbyte(0);
outbyte(6) <= inbyte(5) XOR inbyte(3);
outbyte(5) <= inbyte(7) XOR inbyte(6) XOR inbyte(2) XOR inbyte(0);
outbyte(4) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(1);
outbyte(3) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(0);
outbyte(2) <= inbyte(5) XOR inbyte(3) XOR inbyte(0);
outbyte(1) <= inbyte(6) XOR inbyte(2) XOR inbyte(0);
outbyte(0) <= inbyte(7) XOR inbyte(5) XOR inbyte(1);
end struct;
--
-- 3D
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_3D is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_3D;

architecture struct of multgf_3D is
begin
outbyte(7) <= inbyte(3) XOR inbyte(2);
outbyte(6) <= inbyte(2) XOR inbyte(1);
outbyte(5) <= inbyte(7) XOR inbyte(3) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(4) <= inbyte(7) XOR inbyte(6) XOR inbyte(2) XOR inbyte(1) XOR inbyte(0);
outbyte(3) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(1) XOR inbyte(0);
outbyte(2) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2) XOR inbyte(0);
outbyte(1) <= inbyte(5) XOR inbyte(4) XOR inbyte(1);
outbyte(0) <= inbyte(4) XOR inbyte(3) XOR inbyte(0);
end struct;
--
-- 19
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_19 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_19;

architecture struct of multgf_19 is
begin
outbyte(7) <= inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(3);
outbyte(6) <= inbyte(5) XOR inbyte(4) XOR inbyte(3) XOR inbyte(2);
outbyte(5) <= inbyte(6) XOR inbyte(5) XOR inbyte(2) XOR inbyte(1);
outbyte(4) <= inbyte(5) XOR inbyte(4) XOR inbyte(1) XOR inbyte(0);
outbyte(3) <= inbyte(7) XOR inbyte(4) XOR inbyte(3) XOR inbyte(0);
outbyte(2) <= inbyte(5) XOR inbyte(4) XOR inbyte(2);
outbyte(1) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(1);
outbyte(0) <= inbyte(7) XOR inbyte(6) XOR inbyte(5) XOR inbyte(4) XOR inbyte(0);
end struct;
--
-- 03
--
library ieee;
use ieee.std_logic_1164.all;

entity multgf_03 is
PORT(inbyte : in std_logic_vector(7 downto 0);
outbyte : out std_logic_vector(7 downto 0));
end multgf_03;
architecture struct of multgf_03 is
begin
outbyte(7) <= inbyte(7) XOR inbyte(6);
outbyte(6) <= inbyte(7) XOR inbyte(6) XOR inbyte(5);
outbyte(5) <= inbyte(5) XOR inbyte(4);
outbyte(4) <= inbyte(4) XOR inbyte(3);
outbyte(3) <= inbyte(7) XOR inbyte(3) XOR inbyte(2);
outbyte(2) <= inbyte(7) XOR inbyte(2) XOR inbyte(1);
outbyte(1) <= inbyte(1) XOR inbyte(0);
outbyte(0) <= inbyte(7) XOR inbyte(0);
end struct;












