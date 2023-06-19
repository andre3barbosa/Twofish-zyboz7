library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--Ciphertext: output part of the twofish enc/dec system: output whitening and result latching

entity ciphertext is
port(K4,K5,K6,K7 : in std_logic_vector(31 downto 0); --input for K-Subkeys
	line0,line1,line2,line3 : in std_logic_vector(31 downto 0); --inputs derived from 16 iterations in core component
	clk : in std_logic; --Clock signal
	reset : in std_logic;
	latch_MS : in std_logic; --signal enabling latching of results into result register for MS 64 bits
	latch_LS : in std_logic; --signal enabling latching of results into result register for LS 64 bits
	ciphertext : out std_logic_vector(127 downto 0)); --Enc/Dec result
end ciphertext;

--Start of ciphertext structure description
architecture mixed OF ciphertext is

component xor_2x32 
port (A : in std_logic_vector(31 downto 0);
	B : in std_logic_vector(31 downto 0);
	Result : out std_logic_vector(31 downto 0));
end component;

component reg32  
port(clock,clr,enable : in  std_logic;
     data : in std_logic_vector (31 downto 0);
     q : out std_logic_vector (31 downto 0));
end component; 

signal C0, C1, C2, C3: std_logic_vector(31 downto 0); --Register output signal
signal K4xorL0, K5xorL1,K6xorL2, K7xorL3: std_logic_vector(31 downto 0); --Resulting signal for XOR of inputs with different K-Subkeys
begin

-- Writing result of enc/dec to output register for LS 32-bit vector
C0_reg: reg32
port map (data => K4xorL0,
	    clock => clk,
		  clr => reset,
	    enable => latch_LS,
	    q => C0);

-- Writing result of enc/dec to output register for second LS 32-bit vector
C1_reg: reg32
port map (data => K5xorL1,
	    clock => clk,
	    clr => reset,
	    enable => latch_LS,
	    q => C1);

-- Writing result of enc/dec to output register for second MS 32-bit vector
C2_reg: reg32
port map (data => K6xorL2,
	    clock => clk,
		  clr => reset,
	    enable => latch_MS,
	    q => C2);

-- Writing result of enc/dec to output register for MS 32-bit vector
C3_reg: reg32
port map (data => K7xorL3,
	    clock => clk,
	    clr => reset,
	    enable => latch_MS,
	    q => C3);
--
-- output whitening
--

-- XOR LS 32-bit vector with K-Subkey K4
L0K4_xor : xor_2x32
port map (A => line0,
	    B => K4,
	    Result => K4xorL0);

-- XOR second LS 32-bit vector with K-Subkey K5
L1K5_xor : xor_2x32
port map (A => line1,
	    B => K5,
	    Result => K5xorL1);

-- XOR second MS 32-bit vector with K-Subkey K6
L2K6_xor : xor_2x32
port map (A => line2,
	    B => K6,
	    Result => K6xorL2);

-- XOR MS 32-bit vector with K-Subkey K7
L3K7_xor : xor_2x32
port map (A => line3,
	    B => K7,
	    Result => K7xorL3);

--Concatenating and assigning output its value from signal
output: process(C3,C2,C1,C0)
begin
ciphertext <= C3 & C2 & C1 & C0;
end process output;
end mixed;






