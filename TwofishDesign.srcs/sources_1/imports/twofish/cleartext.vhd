library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--Building block of cleartext
entity cleartext is
port(input : in std_logic_vector(127 downto 0); --data to encrypt input
	clk : in std_logic; --clock signal
	reset : in std_logic;
	latch_cleartext : in std_logic; --enable input register latching
	K0,K1,K2,K3 : in std_logic_vector(31 downto 0); --K-Subkeys iput
	P0xorK0 : out std_logic_vector(31 downto 0); --LS 32-bit vector whitening
	P1xorK1 : out std_logic_vector(31 downto 0); --Second LS 32-bit vector whitening
	P2xorK2 : out std_logic_vector(31 downto 0); --Second to MS 32-bit vector whitening
	P3xorK3 : out std_logic_vector(31 downto 0)); --MS 32-bit vecto whitening
end cleartext;

--Start cleartext structure description
architecture mixed OF cleartext is

component xor_2x32 
port(A : in std_logic_vector(31 downto 0);
B : in std_logic_vector(31 downto 0);
Result : out std_logic_vector(31 downto 0));
end component;

component reg128  
port(clock,clr,enable : in  std_logic;
     data : in std_logic_vector (127 downto 0);
     q : out std_logic_vector (127 downto 0)); 
end component; 

signal cleartext_out : std_logic_vector(127 downto 0); --output signal
--Cleartext: input to enc/dec unit: latching input into register, input whitening and S0 and S1 sub-key generation
begin

-- Latching input into register
cleartext_input: reg128
port map (data => input,
	    clock => clk,
		  clr => reset,
	    enable => latch_cleartext,
	    q => cleartext_out);

-- input whitening by XORing input to deifferent K-Subkeys
P0K0_xor : xor_2x32
port map (A => cleartext_out(31 downto 0),
          B => K0,
	    Result => P0xorK0);
P1K1_xor : xor_2x32
port map (A => cleartext_out(63 downto 32),
	    B => K1,
	    Result => P1xorK1);
P2K2_xor : xor_2x32
port map (A => cleartext_out(95 downto 64),
	    B => K2,
	    Result => P2xorK2);
P3K3_xor : xor_2x32
port map (A => cleartext_out(127 downto 96),
 	    B => K3,
	    Result => P3xorK3);
end mixed;


