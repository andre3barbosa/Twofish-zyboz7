library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity cntr is
port (clk : in std_logic;
	enable : in std_logic;
	clr : in std_logic;
	encrypt : in std_logic;
	out_cntr : out integer range 0 to 39);
end cntr;

architecture behavior of cntr is
signal cnt_sig : integer range 0 to 39;
begin
process (clk)
begin
if (clk'EVENT AND clk = '1') then
	if clr = '1' then
		if encrypt = '1' then
			cnt_sig <= 0;
		else
			cnt_sig <= 4;
		end if;
	elsif enable = '1' then
		if encrypt = '1' then
			if cnt_sig = 3 then
				cnt_sig <= 8;
			elsif cnt_sig = 39 then
			cnt_sig <= 4;
			elsif cnt_sig = 7 then
			cnt_sig <= 0;
			else
			cnt_sig <= cnt_sig +1;
			end if;
		else
			if cnt_sig = 5 then
				cnt_sig <= 6;
			elsif cnt_sig = 7 then
				cnt_sig <= 38;
			elsif cnt_sig = 9 then
				cnt_sig <= 0;
			elsif cnt_sig = 1 then
				cnt_sig <= 2;
			elsif cnt_sig = 3 then
				cnt_sig <= 4;
			elsif conv_std_logic_vector(cnt_sig,8)(0)='0' then -- even
				cnt_sig <= cnt_sig + 1;
			else
				cnt_sig <= cnt_sig - 3;
			end if;
		end if;
	end if;
end if;
end process;
out_cntr <= cnt_sig;
end behavior;

