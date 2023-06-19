library ieee;
use ieee.std_logic_1164.all;

entity sub_opselect is
port (rotate_before : in std_logic;
      F_fct : in std_logic_vector(31 downto 0);
      input : in std_logic_vector(31 downto 0);
      output : out std_logic_vector(31 downto 0));
end sub_opselect;

architecture struct of sub_opselect is
component mux_2x32
port (sel : in std_logic;
      in_0 : in std_logic_vector (31 downto 0);
      in_1 : in std_logic_vector (31 downto 0);
      output : out std_logic_vector (31 downto 0));
end component;

component xor_2x32
port (a : in std_logic_vector(31 downto 0);
      b : in std_logic_vector(31 downto 0);
      result : out std_logic_vector(31 downto 0));
end component;

component rol1_32  
port (data : in std_logic_vector(31 downto 0);
      q : out std_logic_vector(31 downto 0));
end component;

component ror1_32 
port (data : in std_logic_vector(31 downto 0);
      q : out std_logic_vector(31 downto 0));
end component;

signal rolinput,outmux1,outmux1_xor_f,ror_outmux1_xor_f
			 :	std_logic_vector (31 downto 0 ); 

begin

rotleft1: rol1_32 
port map (data => input,
	    q => rolinput);

sel1: mux_2x32 
port map(  sel => rotate_before,
	   in_0 => input,
	   in_1 => rolinput,
	   output =>outmux1);

xor1: xor_2x32
port map (a => F_fct,
	    b => outmux1,
	    result => outmux1_xor_f);

rotright1: ror1_32
port map (data => outmux1_xor_f,
	    q => ror_outmux1_xor_f);

sel2: mux_2x32
port map(   sel => rotate_before,
	    in_0 => ror_outmux1_xor_f,
	    in_1 => outmux1_xor_f,
	    output => output);
end struct;

















