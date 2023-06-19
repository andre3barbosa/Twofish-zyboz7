--Library Declaration
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

--Control: Controller module used to synchronize enc/dec different steps
entity control is
port( pre_param_even : in std_logic_vector(31 downto 0);
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
	finishEnc: out std_logic;
	finishDec: out std_logic;
	delay: out std_logic);
end control;

--Building block of controller
architecture mix of control is
--
--component DECLARATION
--  
--counter module
component cntr 
port (clk : in std_logic;
	enable : in std_logic;
	clr : in std_logic;
	encrypt : in std_logic;
	out_cntr : out integer range 0 to 39 );
end component;

component mainOneShot 
port (i_clk : in std_logic;
	i_rst : in std_logic;
	i_signal : in std_logic;
	o_one_shot : out std_logic );
end component;


--component OneShot
--port (i_clk: in std_logic;
--    i_rst : in std_logic;
--	i_signal : in std_logic;
--	o_one_shot : out std_logic);
--end component;  
--
--type DECLARATION
--
type state_type is (my_idle, load_keyA, compute_K0, compute_K1, compute_K2,
			  compute_K3, compute_K4, compute_K5, compute_K6, compute_K7, extra_cycle,
			  compute_K2r_8, compute_K2r_9, compute_even, compute_odd);

--
--signal DECLARATION
--

signal 
    finishAux: std_logic := '0'; --variable that indicates the finish of encryption
signal
    finishDecAux: std_logic := '0';
signal
    delayAux: std_logic := '0';


signal
	state : state_type;
signal
	cnt_enbl : std_logic;
signal
	out_count : std_logic_vector(7 downto 0);
signal
	out_count_int : integer range 0 to 39;
signal
	load_encrypt : std_logic;
signal
	load_reg_evenk_nextcc,
	load_reg_oddk_nextcc,
	load_reg_post_odd_nextcc,
	load_reg_pre_odd_nextcc,
	load_reg_post_even_nextcc,
	load_reg_pre_even_nextcc,
	latch_cipher_MS_nextcc,
	latch_cipher_LS_nextcc,
	param_source_is_result_nextcc,
	reset_cntr, start,
	ctrl_enc_sig : std_logic;

--Start of controller structure description
begin
ctrl_encrypt <= ctrl_enc_sig;
cntr1 : cntr
port map( clk => clk,
	    enable => cnt_enbl,
	    clr => reset_cntr,
	    encrypt => sel_enc,
	    out_cntr => out_count_int);
	    
oneShotMain: mainOneShot
port map(i_clk => clk,
	    i_rst => reset,
	    i_signal => start_i,
	    o_one_shot => start);

--oneShot1: OneShot
--port map(i_clk => clk,
--	    i_rst => reset,
--	    i_signal => start_i,
--	    o_one_shot => start);

process (clk,reset)
begin
if reset ='1' then
	state <= my_idle;
elsif clk'EVENT AND clk = '1' then
	case state is
		when my_idle =>
			if ld_key = '1' then
				state <= load_keyA;
			elsif start = '1' then
				state <= compute_K0;
			else state <= my_idle;
			end if;
			 delayAux <= '0';
		when compute_K0 =>
			state <= compute_K1;
		when compute_K1 =>
			state <= compute_K2;
		when compute_K2 =>
			state <= compute_K3;
		when compute_K3 =>
			state <= compute_K2r_8;
		when compute_K2r_8 =>
			state <= compute_K2r_9;
		when compute_K2r_9 =>
			state <= compute_even;
		when compute_even =>
			state <= compute_odd;
		when compute_odd =>
			if ( ((out_count = "00000100") AND (ctrl_enc_sig = '1'))
			OR ((out_count = "00000000") AND (ctrl_enc_sig = '0')) ) then
				state <= compute_K4;
			else
				state <= compute_K2r_8;
			end if;
		when load_keyA =>
			state <= my_idle; 
		when compute_K4 =>
			state <= compute_K5;
		when compute_K5 =>
			state <= compute_K6;
		when compute_K6 =>
			state <= compute_K7;
		when compute_K7 =>
			state <= extra_cycle;	
		    finishAux <= '1';
		    if(finishAux = '1')then
		          finishDecAux <= '1'; 
		    end if;
		    
	    when extra_cycle =>
	       state <= my_idle;    
           delayAux <= '1';	       
	       
	end case;
end if;
end process;
with state select
	input_f <=  (out_count & out_count & out_count & out_count) when my_idle,
			(out_count & out_count & out_count & out_count) when load_KeyA,
			(out_count & out_count & out_count & out_count) when compute_K0,
			(out_count & out_count & out_count & out_count) when compute_K1,
			(out_count & out_count & out_count & out_count) when compute_K2,
			(out_count & out_count & out_count & out_count) when compute_K3,
			(out_count & out_count & out_count & out_count) when compute_K4,
			(out_count & out_count & out_count & out_count) when compute_K5,
			(out_count & out_count & out_count & out_count) when compute_K6,
			(out_count & out_count & out_count & out_count) when compute_K7,
			(out_count & out_count & out_count & out_count) when compute_K2r_8,
			(out_count & out_count & out_count & out_count) when compute_K2r_9,
			pre_param_even when compute_even,
			pre_param_odd when compute_odd,
			(out_count & out_count & out_count & out_count) when extra_cycle;
with state select
latch_key <= '0' when my_idle,
		 '1' when load_KeyA,
		 '0' when compute_K0,
		 '0' when compute_K1,
		 '0' when compute_K2,
		 '0' when compute_K3,
		 '0' when compute_K4,
		 '0' when compute_K5,
		 '0' when compute_K6,
		 '0' when compute_K7,
		 '0' when compute_K2r_8,
		 '0' when compute_K2r_9,
		 '0' when compute_even,
		 '0' when compute_odd,
		 '0' when extra_cycle;
with state select
	reset_cntr <= '1' when my_idle,
			  '0' when load_KeyA,
			  '0' when compute_K0,
			  '0' when compute_K1,
			  '0' when compute_K2,
			  '0' when compute_K3,
			  '0' when compute_K4,
			  '0' when compute_K5,
			  '0' when compute_K6,
			  '0' when compute_K7,
			  '0' when compute_K2r_8,
			  '0' when compute_K2r_9,
			  '0' when compute_even,
			  '0' when compute_odd,
			  '1' when extra_cycle;
with state select
	latch_cleartext <= '1' when my_idle,
				 '0' when load_KeyA,
				 '0' when compute_K0,
				 '0' when compute_K1,
				 '0' when compute_K2,
				 '0' when compute_K3,
				 '0' when compute_K4,
				 '0' when compute_K5,
				 '0' when compute_K6,
				 '0' when compute_K7,
				 '0' when compute_K2r_8,
				 '0' when compute_K2r_9,
				 '0' when compute_even,
				 '0' when compute_odd,
				 '1' when extra_cycle;
with state select
	sel_odd <=  '0' when my_idle,
			'0' when load_KeyA,
			'0' when compute_K0,
			'1' when compute_K1,
			'0' when compute_K2,
			'1' when compute_K3,
			'0' when compute_K4,
			'1' when compute_K5,
			'0' when compute_K6,
			'1' when compute_K7,
			'0' when compute_K2r_8,
			'1' when compute_K2r_9,
			'0' when compute_even,
			'1' when compute_odd,
			'0' when extra_cycle;
with state select
	sel_k <=  '0' when my_idle,
		    '0' when load_KeyA,
		    '1' when compute_K0,
		    '1' when compute_K1,
		    '1' when compute_K2,
		    '1' when compute_K3,
		    '1' when compute_K4,
		    '1' when compute_K5,
		    '1' when compute_K6,
		    '1' when compute_K7,
		    '1' when compute_K2r_8,
		    '1' when compute_K2r_9,
		    '0' when compute_even,
		    '0' when compute_odd,
		    '0' when extra_cycle;
with state select
	param_source_is_result_nextcc <= '0' when my_idle,
						   '0' when load_KeyA,
						   '0' when compute_K0,
						   '0' when compute_K1,
						   '0' when compute_K2,
						   '0' when compute_K3,
						   '1' when compute_K4,
						   '1' when compute_K5,
						   '1' when compute_K6,
						   '1' when compute_K7,
						   '1' when compute_K2r_8,
						   '1' when compute_K2r_9,
						   '1' when compute_even,
						   '1' when compute_odd,
						   '0' when extra_cycle;
with state select
load_reg_pre_even_nextcc <= '0' when my_idle,
				    '0' when load_KeyA,
				    '0' when compute_K0,
				    '1' when compute_K1,
				    '0' when compute_K2,
				    '0' when compute_K3,
				    '0' when compute_K4,
				    '0' when compute_K5,
				    '0' when compute_K6,
				    '0' when compute_K7,
				    '0' when compute_K2r_8,
				    '0' when compute_K2r_9,
				    '0' when compute_even,
				    '1' when compute_odd,
				    '0' when extra_cycle;

with state select
load_reg_pre_odd_nextcc <= '0' when my_idle,
				   '0' when load_KeyA,
				   '0' when compute_K0,
				   '1' when compute_K1,
				   '0' when compute_K2,
				   '0' when compute_K3,
				   '0' when compute_K4,
				   '0' when compute_K5,
				   '0' when compute_K6,
				   '0' when compute_K7,
				   '0' when compute_K2r_8,
				   '0' when compute_K2r_9,
				   '0' when compute_even,
				   '1' when compute_odd,
				   '0' when extra_cycle;
with state select
load_reg_post_even_nextcc <= '0' when my_idle,
				     '0' when load_KeyA,
				     '0' when compute_K0,
				     '0' when compute_K1,
				     '0' when compute_K2,
				     '1' when compute_K3,
				     '0' when compute_K4,
				     '0' when compute_K5,
				     '0' when compute_K6,
				     '0' when compute_K7,
				     '0' when compute_K2r_8,
				     '0' when compute_K2r_9,
				     '0' when compute_even,
				     '1' when compute_odd,
				     '0' when extra_cycle;
with state select
load_reg_post_odd_nextcc <= '0' when my_idle,
				    '0' when load_KeyA,
				    '0' when compute_K0,
				    '0' when compute_K1,
				    '0' when compute_K2,
				    '1' when compute_K3,
				    '0' when compute_K4,
				    '0' when compute_K5,
				    '0' when compute_K6,
				    '0' when compute_K7,
				    '0' when compute_K2r_8,
				    '0' when compute_K2r_9,
				    '0' when compute_even,
				    '1' when compute_odd,
				    '0' when extra_cycle;
with state select
latch_cipher_MS_nextcc <= '0' when my_idle,
				  '0' when load_KeyA,
				  '0' when compute_K0,
				  '0' when compute_K1,
				  '0' when compute_K2,
				  '0' when compute_K3,
				  '0' when compute_K4,
				  '0' when compute_K5,
				  '0' when compute_K6,
				  '1' when compute_K7,
				  '0' when compute_K2r_8,
				  '0' when compute_K2r_9,
				  '0' when compute_even,
				  '0' when compute_odd,
				  '0' when extra_cycle;
with state select
latch_cipher_LS_nextcc <= '0' when my_idle,
				  '0' when load_KeyA,
				  '0' when compute_K0,
				  '0' when compute_K1,
				  '0' when compute_K2,
				  '0' when compute_K3,
				  '0' when compute_K4,
				  '1' when compute_K5,
				  '0' when compute_K6,
				  '0' when compute_K7,
				  '0' when compute_K2r_8,
				  '0' when compute_K2r_9,
				  '0' when compute_even,
				  '0' when compute_odd,
				  '0' when extra_cycle;
with state select
load_reg_evenk_nextcc <= '0' when my_idle,
				 '0' when load_KeyA,
				 '0' when compute_K0,
				 '0' when compute_K1,
				 '0' when compute_K2,
				 '0' when compute_K3,
				 '0' when compute_K4,
				 '0' when compute_K5,
				 '0' when compute_K6,
				 '0' when compute_K7,
				 '0' when compute_K2r_8,
				 '1' when compute_K2r_9,
				 '0' when compute_even,
				 '0' when compute_odd,
				 '0' when extra_cycle;
with state select
load_reg_oddk_nextcc <= '0' when my_idle,
				'0' when load_KeyA,
				'0' when compute_K0,
				'0' when compute_K1,
				'0' when compute_K2,
				'0' when compute_K3,
				'0' when compute_K4,
				'0' when compute_K5,
				'0' when compute_K6,
				'0' when compute_K7,
				'0' when compute_K2r_8,
				'1' when compute_K2r_9,
				'0' when compute_even,
				'0' when compute_odd,
				'0' when extra_cycle;
with state select
load_modf_reg <= '1' when my_idle,
			'1' when load_KeyA,
			'1' when compute_K0,
			'1' when compute_K1,
			'1' when compute_K2,
			'1' when compute_K3,
			'1' when compute_K4,
			'1' when compute_K5,
			'1' when compute_K6,
			'1' when compute_K7,
			'1' when compute_K2r_8,
			'1' when compute_K2r_9,
			'1' when compute_even,
			'1' when compute_odd,
			'1' when extra_cycle;
with state select
load_encrypt <=  '1' when my_idle,
			'0' when load_KeyA,
			'0' when compute_K0,
			'0' when compute_K1,
			'0' when compute_K2,
			'0' when compute_K3,
			'0' when compute_K4,
			'0' when compute_K5,
			'0' when compute_K6,
			'0' when compute_K7,
			'0' when compute_K2r_8,
			'0' when compute_K2r_9,
			'0' when compute_even,
			'0' when compute_odd,
			'1' when extra_cycle;
with state select
idle <= '1' when my_idle,
	  '0' when load_KeyA,
	  '0' when compute_K0,
	  '0' when compute_K1,
	  '0' when compute_K2,
	  '0' when compute_K3,
	  '0' when compute_K4,
	  '0' when compute_K5,
	  '0' when compute_K6,
	  '0' when compute_K7,
	  '0' when compute_K2r_8,
	  '0' when compute_K2r_9,
	  '0' when compute_even,
	  '0' when compute_odd,
	  '1' when extra_cycle;
with state select
cnt_enbl <= '0' when my_idle,
		'0' when load_KeyA,
		'1' when compute_K0,
		'1' when compute_K1,
		'1' when compute_K2,
		'1' when compute_K3,
		'1' when compute_K4,
		'1' when compute_K5,
		'1' when compute_K6,
		'1' when compute_K7,
		'1' when compute_K2r_8,
		'1' when compute_K2r_9,
		'0' when compute_even,
		'0' when compute_odd,
		'0' when extra_cycle;
sel_encrypt_reg: process(clk)
begin
if (clk'EVENT AND clk = '1') then
	if (load_encrypt = '1') then
		ctrl_enc_sig <= sel_enc;
	end if;
end if;
end process;
delay_ctrl: process(clk)
begin
if (clk'EVENT AND clk = '1') then
	param_source_is_result <= param_source_is_result_nextcc;
	load_reg_evenk <= load_reg_evenk_nextcc;
	load_reg_oddk <= load_reg_oddk_nextcc;
	load_reg_post_odd <= load_reg_post_odd_nextcc;
	load_reg_pre_odd <= load_reg_pre_odd_nextcc;
	load_reg_post_even <= load_reg_post_even_nextcc;
	load_reg_pre_even <= load_reg_pre_even_nextcc;
	latch_cipher_MS <= latch_cipher_MS_nextcc;
	latch_cipher_LS <= latch_cipher_LS_nextcc;
end if;
end process;

finishEnc <= finishAux;
finishDec <= finishDecAux;
delay <= delayAux;

out_count <= conv_std_logic_vector(out_count_int,8);
end mix;



