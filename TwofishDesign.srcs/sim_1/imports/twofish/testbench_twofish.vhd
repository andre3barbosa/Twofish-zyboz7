library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity testbench_twofish is end;

architecture testbench of testbench_twofish is

file vector_file : text is in "/home/carlos/VivadoWork/twofish-team/IP/TwofishDesign/twofishen.inp";
file output_file : text is out "/home/carlos/VivadoWork/twofish-team/IP/TwofishDesign/twofishen.out";

component core
port(	inPort : in std_logic_vector(127 downto 0); 
  	inkey : in std_logic_vector(127 downto 0);
	clk : in std_logic; 
  	reset : in std_logic;
	usr_ld_key : in std_logic; 
	usr_start : in std_logic; 
	usr_encrypt : in std_logic; 
	idle : out std_logic; 
	outCiphertext : out std_logic_vector(127 downto 0));
end component;

constant ClkPerioda : time := 10 ns;

signal clk : std_logic := '0';
signal usr_ld_key,usr_start,usr_encrypt,idle,reset : std_logic;
signal inPort,inkey,outCiphertext : std_logic_vector(127 downto 0);

begin

clk <= not(clk) after ClkPerioda/2;
main : core
port map(
  inPort => inPort,
  inkey => inkey,
  usr_ld_key => usr_ld_key,
  usr_start => usr_start,
  usr_encrypt => usr_encrypt,
  clk => clk,
  reset => reset,
  idle => idle,
  outCiphertext => outCiphertext);

test: process

variable VectorLine,outvecs : line;
variable vusr_ld_key,vusr_start, vusr_encrypt,vreset : std_logic;
variable vinPort,vinkey : std_logic_vector(127 downto 0);
variable out_vec : std_logic_vector(128 downto 0);
begin
 wait for 3* ClkPerioda;
 while not endfile(vector_file) loop
 readline(vector_file, VectorLine);
 if VectorLine(1) = '#' then
 assert false report "Test complete";
 end if;

 read(VectorLine,vusr_ld_key);
 read(VectorLine,vusr_start);
 read(VectorLine,vusr_encrypt);
 read(VectorLine,vreset);
 read(VectorLine,vinkey);
 read(VectorLine,vinPort);
 

 usr_ld_key <= vusr_ld_key;
 usr_start <= vusr_start;
 usr_encrypt <= vusr_encrypt;
 reset <= vreset;
 inkey <= vinkey;
 inPort <= vinPort;
 
 wait for ClkPerioda;
 out_vec := idle & outCiphertext;
-- write(outvecs,out_vec);
-- writeline(output_file, outvecs);
 end loop;
 wait for 3* ClkPerioda;
 wait;
 assert false report "Test complete";
 end process test;
end testbench;



