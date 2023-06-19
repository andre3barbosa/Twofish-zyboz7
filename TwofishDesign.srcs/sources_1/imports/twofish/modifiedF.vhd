library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--Main: used to compute K-subkeys and as main buildig block of enc/dec
entity modifiedF is
port (input : in std_logic_vector(31 downto 0);
	in_S0 : in std_logic_vector(31 downto 0); --S0 for S-boxes in h_fctn module
	in_S1 : in std_logic_vector(31 downto 0); --S1 for S-boxes in h_fctn module
	clk : in std_logic;
	reset : in std_logic;
	sel_odd : in std_logic; --input selecting btw even path or odd path
	sel_k : in std_logic; --input selecting btw calculating a key or an encryption/decryption
	in_load_reg : in std_logic; --Signal commanding the load of the reg on even path
	out_even : out std_logic_vector(31 downto 0); --output of main on even path
	out_odd : out std_logic_vector(31 downto 0)); --output of main on odd path
end modifiedF;

--Building block of main
architecture mixed OF modifiedF is
--
--component DECLARATION
--
--h-function modules
component h_fctn 
port (input : in std_logic_vector(31 downto 0);
	S0 : in std_logic_vector(31 downto 0);
	S1 : in std_logic_vector(31 downto 0);
	output : out std_logic_vector(31 downto 0));
end component;

--pht modules
component pht 
port (A_in : in std_logic_vector(31 downto 0);
      B_in : in std_logic_vector(31 downto 0);
      A_out : out std_logic_vector(31 downto 0);
      B_out : out std_logic_vector(31 downto 0));
end component;

--Multiplexer modules
component mux_2x32 
port(sel : in std_logic;
	in_0 : in std_logic_vector(31 downto 0);
	in_1 : in std_logic_vector(31 downto 0);
	output : out std_logic_vector(31 downto 0));
end component;

--register
component reg32  
port(clock,clr,enable : in  std_logic;
     data : in std_logic_vector (31 downto 0);
     q : out std_logic_vector (31 downto 0));
end component;

--rotate left 8 bit
component rol8_32  
port (data : in std_logic_vector(31 downto 0);
      q : out std_logic_vector(31 downto 0));
end component;

--rotate left 9 bit
component rol9_32  
port (data : in std_logic_vector(31 downto 0);
      q : out std_logic_vector(31 downto 0));
end component;

--
--SIGNAL DECLARATION
--
Signal
	sel_odd_k,
	load_odd_reg,
	load_even_reg,
	sel_odd_result,
	last_sel_odd_k : std_logic;
Signal
	rotated_input, --P1 Xor K1 rotated left 8 times
	sig_in_h, --input to h_function
	sig_out_h, --output of h_function
	Rotated_out_h, --output of the h_fctn rol 8 times
	in_reg, --input to the register on the odd path
	out_odd_reg, --output of the register on the odd path
	out_even_reg, --output of the reg of even path
	out_pht_even, --output of the pht on the even path
	out_pht_odd, --output of the pht on the odd path
	rotated_out_pht_odd,--output of the pht on the odd path rol 9 times
	sig_out_odd : std_logic_vector(31 downto 0); --output of the main on the odd path

--Start Main’s structure description
begin
-- control
sel_odd_k <= sel_odd AND sel_k;
sel_odd_result <= sel_odd AND (NOT sel_k);
load_odd_reg <= sel_odd AND in_load_reg;
load_even_reg <= (NOT sel_odd) AND in_load_reg;

--Rotate input to the left 8 time
rol8_input: rol8_32
port map (data => input,
          q => rotated_input);

-- Choose input of h-function: rotate only if we
-- we are compute an odd result (and not a k!)
mux_choose_hin : mux_2x32
port map(sel => sel_odd_result,
	    in_0 => input,
	    in_1 => rotated_input,
	    output => sig_in_h);

--h-function transformation
h_block : h_fctn
port map (input => sig_in_h,
	    S0 => in_S0,
	    S1 => in_S1,
          output => sig_out_h);

--rotate to the left the output of the h_function 8 times
rol8_sig_out_h: rol8_32
port map (data => sig_out_h,
	    q => rotated_out_h);

--Multiplex between out_h and rotated out_h
mux_out_h_rotated_out_h : mux_2x32
port map(sel => sel_odd_k,
	    in_1 => rotated_out_h,
	    in_0 => sig_out_h,
	    output => in_reg);

--Register to contain results on even path
even_reg : reg32
port map(data => in_reg,
	   clock => clk,
		 clr => reset,
	   enable => load_even_reg,
	   q => out_even_reg);

--Register to contain results on odd path
odd_reg : reg32
port map(data => in_reg,
	   clock => clk,
		 clr => reset,
	   enable => load_odd_reg,
	   q => out_odd_reg);

--Register to store last sel_odd
sel_odd_k_reg : process(clk)
begin
IF (clk'event AND clk = '1') THEN
	last_sel_odd_k <= sel_odd_k;
end IF;
end process;
--Pseudo Hadamard Transformation of signals
pht1 : pht
port map (A_in => out_even_reg,
	    B_in => out_odd_reg,
	    A_out => out_pht_even,
	    B_out => out_pht_odd);

--Rotating the output of the PHT on the odd path left nine times
rol9_out_pht_odd: rol9_32
port map (data => out_pht_odd ,
	    q => rotated_out_pht_odd);

--Multiplex, on the odd side, btw. the output of the pht and the output of the pht rol X9
mux_out : mux_2x32
port map(sel => last_sel_odd_k,
	    in_1 => rotated_out_pht_odd,
	    in_0 => out_pht_odd,
	    output => sig_out_odd);
--Assign output values from signals
				out_even <= out_pht_even;
				out_odd <= sig_out_odd;
end mixed;








