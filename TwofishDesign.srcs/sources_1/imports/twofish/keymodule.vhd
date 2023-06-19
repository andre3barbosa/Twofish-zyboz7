library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- 		    128-bit key
--                  |
-- latch_key ---> keyreg
-- |               | |
-- |-----------> ---------
-- |              |   |
-- |            RS_matrix
-- |    -----------|-----------
-- |    |                     |
-- --> S0reg                  |
--      |                     |
--      S0                    S1

entity keymodule is
port (key : in std_logic_vector(127 downto 0);
	latch_key : in std_logic;
	clk : in std_logic;
	reset : in std_logic;
	S0,S1 : out std_logic_vector(31 downto 0);
	keyout : out std_logic_vector(127 downto 0));
end keymodule;

architecture mixed of keymodule is
	
component rsmatrix 
port (m0,m1,m2,m3,m4,m5,m6,m7 : in std_logic_vector(7 downto 0);
      s0,s1,s2,s3 : out std_logic_vector(7 downto 0));
end component;

component reg128  
port(clock,clr,enable : in  std_logic;
     data : in std_logic_vector (127 downto 0);
     q : out std_logic_vector (127 downto 0)); 
end component; 

component reg32  
port(clock,clr,enable : in  std_logic;
     data : in std_logic_vector (31 downto 0);
     q : out std_logic_vector (31 downto 0));
end component; 

component mux_2x64
port (sel : in std_logic;
	in_0 : in std_logic_vector(63 downto 0);
	in_1 : in std_logic_vector(63 downto 0);
	output : out std_logic_vector(63 downto 0));
end component;

signal RS_input : std_logic_vector(63 downto 0);
signal RS_output : std_logic_vector(31 downto 0);
signal regkey_output : std_logic_vector(127 downto 0);

begin
keyreg : reg128
port map(data => key,
	   clock => clk,
	   clr => reset,
	   enable => latch_key,
	   q => regkey_output);
	   keyout <= regkey_output;

-- choose input of RS_Matrix
RSinputChoice: mux_2x64
port map(sel => latch_key,
	   in_0 => regkey_output(127 downto 64),
	   in_1 => key(63 downto 0),
	   output => RS_input);

-- compute S
compute_S: rsmatrix
port map (m0 => RS_input(7 downto 0),
	    m1 => RS_input(15 downto 8),
	    m2 => RS_input(23 downto 16),
	    m3 => RS_input(31 downto 24),
	    m4 => RS_input(39 downto 32),
	    m5 => RS_input(47 downto 40),
	    m6 => RS_input(55 downto 48),
	    m7 => RS_input(63 downto 56),
	    s0 => RS_output(7 downto 0),
	    s1 => RS_output(15 downto 8),
	    s2 => RS_output(23 downto 16),
	     s3 => RS_output(31 downto 24));
-- store S0 if it’s being computed
S0reg : reg32
	port map(data => RS_output,
		   clock => clk,
		   clr => reset,
		   enable => latch_key,
		   q => S0);
-- latch S1 to the output... Will be correct
-- soon after latch_key drops to 0.
S1 <= RS_output;
end mixed;




