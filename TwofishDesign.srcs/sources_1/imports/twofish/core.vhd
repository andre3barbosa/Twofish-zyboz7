library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- External interface of twofish cipher implementation
entity core is
port(--inport : in std_logic_vector(127 downto 0); --input from cleartext entity
    plaintext3_i : in std_logic_vector(31 downto 0);
    plaintext2_i : in std_logic_vector(31 downto 0);
    plaintext1_i : in std_logic_vector(31 downto 0);
    plaintext0_i : in std_logic_vector(31 downto 0);
	--inkey : in std_logic_vector (127 downto 0); -- input from keymodule entity
	globalkey3_i : in std_logic_vector(31 downto 0);
    globalkey2_i : in std_logic_vector(31 downto 0);
    globalkey1_i : in std_logic_vector(31 downto 0);
    globalkey0_i : in std_logic_vector(31 downto 0);
	clk : in std_logic; --Clock signal
	reset : in std_logic;
	usr_ld_key : in std_logic; --Usr requests load key
	usr_start : in std_logic; --Usr requests start
	usr_encrypt : in std_logic; --Usr requests encrypt
	idle : out std_logic; --Device is idle
	--outCiphertext : out std_logic_vector(127 downto 0));--output after one iteration through enc/dec
    cryptotext3_o : out std_logic_vector(31 downto 0);   
    cryptotext2_o : out std_logic_vector(31 downto 0);
    cryptotext1_o : out std_logic_vector(31 downto 0);
    cryptotext0_o : out std_logic_vector(31 downto 0);
    
    initVector3_i : in std_logic_vector(31 downto 0);   
    initVector2_i : in std_logic_vector(31 downto 0);
    initVector1_i : in std_logic_vector(31 downto 0);
    initVector0_i : in std_logic_vector(31 downto 0));
end core;

architecture mixed of core is

component CBCmode
port(
    IVvector : in std_logic_vector(127 downto 0);
    plaintext_i : in std_logic_vector(127 downto 0);
    cyphertext : in std_logic_vector(127 downto 0);
    finishEnc : in std_logic;
    clk : in std_logic;
    usr_encrypt: in std_logic;
    plaintext_o : out std_logic_vector(127 downto 0)
    );
end component;

component CBCmode_des
port(
    IVvector : in std_logic_vector(127 downto 0);
    cypher_i : in std_logic_vector(127 downto 0);
    cypher_text : in std_logic_vector(127 downto 0);
    finishDec : in std_logic;
    clk : in std_logic;
    usr_encrypt: in std_logic;
    delay: in std_logic;
    plaintext_o : out std_logic_vector(127 downto 0)
    );
end component;

component little_endian_converter
port (big_endian : in std_logic_vector(127 downto 0);
      little_endian : out std_logic_vector(127 downto 0));
end component;

component control 
port (pre_param_even : in std_logic_vector(31 downto 0);
	pre_param_odd : in std_logic_vector(31 downto 0);
	clk : in std_logic;
	reset : in std_logic;
	ld_key : in std_logic;
	start_i : in std_logic;
	sel_enc : in std_logic;
	input_f : out std_logic_vector(31 downto 0);
	latch_cleartext : out std_logic;
	latch_key : out std_logic;
	sel_odd : out std_logic;
	sel_k : out std_logic;
	param_source_is_result : out std_logic;
	load_reg_pre_even : out std_logic;
	load_reg_pre_odd : out std_logic;
	load_reg_post_even : out std_logic;
	load_reg_post_odd : out std_logic;
	latch_cipher_MS : out std_logic;
	latch_cipher_LS : out std_logic;
	load_reg_evenk : out std_logic;
	load_reg_oddk : out std_logic;
	load_modf_reg : out std_logic;
	ctrl_encrypt : out std_logic;
	idle : out std_logic;
	finishEnc : out std_logic;
	finishDec : out std_logic;
	delay : out std_logic); 
end component;

component keymodule 
port (key : in std_logic_vector(127 downto 0);
	latch_key : in std_logic;
	clk : in std_logic;
	reset : in std_logic;
	S0,S1 : out std_logic_vector(31 downto 0);
	keyout : out std_logic_vector(127 downto 0));
end component;

component modifiedF 
port (input : in std_logic_vector(31 downto 0);
	in_S0 : in std_logic_vector(31 downto 0); --S0 for S-boxes in h_fctn module
	in_S1 : in std_logic_vector(31 downto 0); --S1 for S-boxes in h_fctn module
	clk : in std_logic;
	reset : in std_logic;
      sel_odd : in std_logic; --input selecting btw even path or odd path
	sel_k : in std_logic; --input selecting btw calculating a key or an encryption/decryption
	in_load_reg : in std_logic; --signal commanding the load of the reg on even path
	out_even : out std_logic_vector(31 downto 0); --output of main on even path
	out_odd : out std_logic_vector(31 downto 0)); --output of main on odd path
end component;

component adder32
port (dataa, datab : in  std_logic_vector(31 downto 0) ;
      cout : out std_logic ;
      cin  : in std_logic:= '0';
      result : out std_logic_vector(31 downto 0)) ;
end component;

component reg32  
port(clock,clr,enable : in  std_logic;
	 data : in std_logic_vector (31 downto 0);
       q : out std_logic_vector (31 downto 0));
end component; 

-- selection of mode: encrypt/decrypt
component opselect 
port( encrypt : in std_logic;
	F_fct_A : in std_logic_vector(31 downto 0);
	F_fct_B : in std_logic_vector(31 downto 0);
	in_A : in std_logic_vector(31 downto 0);
	in_B : in std_logic_vector(31 downto 0);
	out_A : out std_logic_vector(31 downto 0);
	out_B : out std_logic_vector(31 downto 0));
end component;

--cleartext module
component cleartext 
port (input : in std_logic_vector(127 downto 0);
	clk : in std_logic;
	reset : in std_logic;
	latch_cleartext : in std_logic;
	K0,K1,K2,K3 : in std_logic_vector(31 downto 0);
	P0xorK0 : out std_logic_vector(31 downto 0);
	P1xorK1 : out std_logic_vector(31 downto 0);
	P2xorK2 : out std_logic_vector(31 downto 0);
	P3xorK3 : out std_logic_vector(31 downto 0));
end component;

--ciphetext module
component ciphertext 
port (K4,K5,K6,K7 : in std_logic_vector(31 downto 0);
	line0,line1,line2,line3 : in std_logic_vector(31 downto 0);
	clk : in std_logic;
	reset : in std_logic;
	latch_MS : in std_logic;
	latch_LS : in std_logic;
	ciphertext : out std_logic_vector(127 downto 0));
end component;

signal
	P0xorK0, P1xorK1,
	P2xorK2, P3xorK3,
	modf_out_even, modf_out_odd,
	S0, S1,
	evenK, oddK,
	f_out_even, f_out_odd,pre_param_even, 
	pre_param_odd,post_param_even, 
	post_param_odd,
	input_f,out_round_even, out_round_odd,source_pre_even_reg, 	
	source_pre_odd_reg,
	source_post_even_reg, source_post_odd_reg,
	f_in_S0, f_in_S1
	: std_logic_vector(31 downto 0);
signal
	key, input, output, outkey, inputP128, inputK128, output128, vector128, outCBC, outCBCdec : std_logic_vector(127 downto 0); 
signal
	latch_cleartext, latch_key,
	sel_odd, sel_k,
	param_source_is_result,
	latch_cipher_LS, latch_cipher_MS,
	load_reg_evenk,
	load_reg_oddk,
	load_modf_reg,
	ctrl_encrypt,
	load_reg_pre_even, load_reg_pre_odd,
	load_reg_post_even, load_reg_post_odd,
	s_finishEnc,
	s_finishDec,
	s_delay
	: std_logic;

begin

inputP128 <= plaintext3_i & plaintext2_i & plaintext1_i & plaintext0_i;
inputK128 <= globalkey3_i & globalkey2_i & globalkey1_i & globalkey0_i;
vector128 <= initVector3_i & initVector2_i & initVector1_i & initVector0_i;


cryptotext3_o <= outCBCdec(127 downto 96);
cryptotext2_o <= outCBCdec(95 downto 64);
cryptotext1_o <= outCBCdec(63 downto 32);
cryptotext0_o <= outCBCdec(31 downto 0);
--little endian convertion

-- Encryption
CBCmode_enc: CBCmode
port map(  IVvector => vector128,
       plaintext_i => inputP128,
       cyphertext => outCBCdec, 
       finishEnc => s_finishEnc,
       clk => clk,
       usr_encrypt => usr_encrypt,
       plaintext_o => outCBC);
       
-- Desencryption       
CBCmode_dec: CBCmode_des
port map(  IVvector => vector128,
       cypher_i => output128,
       cypher_text => inputP128,
       finishDec => s_finishDec,
       clk => clk,
       usr_encrypt => usr_encrypt,
       delay => s_delay,
       plaintext_o => outCBCdec);

little_endian_input: little_endian_converter
port map ( big_endian => outCBC,
		little_endian => input);

little_endian_key: little_endian_converter
port map ( big_endian => inputK128,
		little_endian => key);

little_endian_output: little_endian_converter
port map ( big_endian => output,
		little_endian => output128);

twofishController: control
port map ( pre_param_even => pre_param_even,
	      pre_param_odd => pre_param_odd,
		clk => clk,
		reset => reset,
		input_f => input_f,
		ld_key => usr_ld_key,
		start_i => usr_start,
		sel_enc => usr_encrypt,
		latch_cleartext => latch_cleartext,
		latch_key => latch_key,
		sel_odd => sel_odd,
		sel_k => sel_k,
		param_source_is_result => param_source_is_result,
		latch_cipher_LS => latch_cipher_LS,
		latch_cipher_MS => latch_cipher_MS,
		load_reg_pre_even => load_reg_pre_even,
		load_reg_pre_odd => load_reg_pre_odd,
		load_reg_post_even => load_reg_post_even,
		load_reg_post_odd => load_reg_post_odd,
		load_reg_evenk => load_reg_evenk,
		load_reg_oddk => load_reg_oddk,
		load_modf_reg => load_modf_reg,
		ctrl_encrypt => ctrl_encrypt,
		idle => idle,
		finishEnc=>s_finishEnc,
		finishDec=>s_finishDec,
		delay=>s_delay		
		);

-- This modules holds the cleartext input module and
-- and prepares the parameters when given correct K values.
cleartext_module: cleartext
port map (input => input,
		clk => clk,
		reset => reset,
		latch_cleartext => latch_cleartext,
		K0 => modf_out_even,
		K1 => modf_out_odd,
		K2 => modf_out_even,
		K3 => modf_out_odd,
		P0xorK0 => P0xorK0,
		P1xorK1 => P1xorK1,
		P2xorK2 => P2xorK2,
		P3xorK3 => P3xorK3);

-- select the correct S input to modified F:
-- S if computing a result,
-- M if computing a k
selectSorM : process (sel_k,sel_odd,key,s0,s1) 
begin
if (sel_k = '1') THEN
	if (sel_odd = '1') THEN
		-- computing a K
		-- S0 = M3, S1 = M1
		f_in_S0 <= outkey(127 downto 96);
		f_in_S1 <= outkey(63 downto 32);
	else
		-- computing a K
		-- S0 = M2, S1 = M0
		f_in_S0 <= outkey(95 downto 64);
		f_in_S1 <= outkey(31 downto 0);
	end if;
else
	-- computing a result
	-- S0 = S0, S1 = S1
	f_in_S0 <= S0;
	f_in_S1 <= S1;
end if;
end process;

-- This module holds most of the F function. It
-- can either compute two K�s or perform two
-- subfunctions of encryption or decryption.
f_fct_sub: modifiedF
port map (input => input_f,
		in_S0 => f_in_S0,
		in_S1 => f_in_S1,
		clk => clk,
	  	reset => reset,
		sel_odd => sel_odd,
		sel_k => sel_k,
		in_load_reg => load_modf_reg,
		out_even => modf_out_even,
		out_odd => modf_out_odd);

-- k2r+8 register (even k)
reg_evenk: reg32
port map (data => modf_out_even,
		clock => clk,
		clr => reset,
		enable => load_reg_evenk,
		q => evenk);

-- k2r+9 register (odd k)
reg_oddk: reg32
port map(data => modf_out_odd,
		clock => clk,
		clr => reset,
		enable => load_reg_oddk,
		q => oddk);

-- 32-bit adder: even K + even result of h
add_even : adder32
port map (dataa => modf_out_even,
		datab => evenk,
		result => f_out_even);

-- 32-bit adder: odd K + odd result of h
add_odd : adder32
port map (dataa => modf_out_odd,
		datab => oddk,
		result => f_out_odd);

-- final operation of round: encrypt or decrypt?
opsel : opselect
port map(encrypt => ctrl_encrypt,
		F_fct_A => f_out_even,
		F_fct_B => f_out_odd,
		in_A => post_param_even,
		in_B => post_param_odd,
		out_A => out_round_even,
		out_B => out_round_odd);

-- choose the source of next parameters...
choose_in_param_pre_even: process (param_source_is_result,out_round_even,
					     out_round_odd,pre_param_even,pre_param_odd,
					     P0xork0,P1xorK1,P2xorK2,P3xorK3) 
begin
if (param_source_is_result = '1') THEN
	source_pre_even_reg <= out_round_even;
	source_pre_odd_reg <= out_round_odd;
	source_post_even_reg <= pre_param_even;
	source_post_odd_reg <= pre_param_odd;
else
	source_pre_even_reg <= P0xorK0;
	source_pre_odd_reg <= P1xorK1;
	source_post_even_reg <= P2xorK2;
	source_post_odd_reg <= P3xorK3;
end if;
end process ;

-- line 0: the parameter is used on even
-- values at the beginning of the round
-- (K0 in first round)
reg_pre_even_param_reg: reg32
port map (data => source_pre_even_reg,
		clock => clk,
		clr => reset,
		enable => load_reg_pre_even,
		q => pre_param_even);

-- line 1: the parameter is used on odd
-- values at the beginning of the round
-- (K1 in first round)
reg_pre_odd_param_reg: reg32
port map (data => source_pre_odd_reg,
		clock => clk,
		clr => reset,
		enable => load_reg_pre_odd,
		q => pre_param_odd);
	
-- line 2: the parameter is used on even
-- values at the end of the round
-- (K2 in first round)
reg_post_even_param_reg: reg32
port map (data => source_post_even_reg,
		clock => clk,
		clr => reset,
		enable => load_reg_post_even,
		q => post_param_even);

-- line 3: the parameter is used on odd
-- values at the end of the round
-- (K3 in first round)
reg_post_odd_param_reg: reg32
port map (data => source_post_odd_reg,
		clock => clk,
		clr => reset,
		enable => load_reg_post_odd,
		q => post_param_odd);

-- handle the output
-- HAS TO UNDO THE LAST SWAP!!!
ciphertext_module: ciphertext
port map (K4 => modf_out_even,
		K5 => modf_out_odd,
		K6 => modf_out_even,
		K7 => modf_out_odd,
		line0 => post_param_even,
		line1 => post_param_odd,
		line2 => pre_param_even,
		line3 => pre_param_odd,
		clk => clk,
		reset => reset,
		latch_LS => latch_cipher_LS,
		latch_MS => latch_cipher_MS,
		ciphertext => output);

-- This register holds the 128-bit key...
reg_key : keymodule
port map (key => key,
		latch_key => latch_key,
		clk => clk,
		reset => reset,
		S0 => S0,
		S1 => S1,
		keyout => outkey);
end mixed;







