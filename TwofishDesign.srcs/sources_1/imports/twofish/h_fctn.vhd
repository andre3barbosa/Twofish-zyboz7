--
-- -------- -----
-- input-->|S-box |---->|MDS|--> output
-- -------- -----
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--h-function combines s-boxes and maximum distance separable matrix
entity h_fctn is
port( input : in std_logic_vector(31 downto 0);
	S0 : in std_logic_vector(31 downto 0);
	S1 : in std_logic_vector(31 downto 0);
	output : out std_logic_vector(31 downto 0));
end h_fctn;

--Building block of the h_fctn
architecture struct OF h_fctn is

component S_boxes 
port( income : in std_logic_vector(31 downto 0);
	S0 : in std_logic_vector(31 downto 0);
	S1 : in std_logic_vector(31 downto 0);
	outcome : out std_logic_vector(31 downto 0));
end component;
--maximum distance separable matrix
component mds 
port( y0 : in std_logic_vector(7 downto 0);
	y1 : in std_logic_vector(7 downto 0);
	y2 : in std_logic_vector(7 downto 0);
	y3 : in std_logic_vector(7 downto 0);
	z0 : out std_logic_vector(7 downto 0);
	z1 : out std_logic_vector(7 downto 0);
	z2 : out std_logic_vector(7 downto 0);
	z3 : out std_logic_vector(7 downto 0));
end component;
Signal
out_mds, --output of the MDS
out_S_box : std_logic_vector(31 downto 0); --output of the S-boxes
--Start of the h-function structure
BEGin
--S-box that permutes the input and XORs it with S0 and S1
S_box1 : S_boxes
port map( income => input,
	    S0 => S0,
	    S1 => S1,
	    outcome => out_S_box);

--MDS
mds1 : mds
port map( y0 => out_S_box(7 downto 0),
	    y1 => out_S_box(15 downto 8),
	    y2 => out_S_box(23 downto 16),
	    y3 => out_S_box(31 downto 24),
	    z0 => out_mds(7 downto 0),
	    z1 => out_mds(15 downto 8),
	    z2 => out_mds(23 downto 16),
	    z3 => out_mds(31 downto 24));
--Assigning output its value form signal
output <= out_mds;
end struct;


