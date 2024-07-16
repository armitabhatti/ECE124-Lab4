library ieee;
use ieee.std_logic_1164.all;


entity holding_register is port (

			clk					: in std_logic;
			reset				: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout				: out std_logic
  );
 end holding_register;
 
 architecture circuit of holding_register is

	Signal sreg				: std_logic;
	--signal D				: std_logic; --declare temp signal to store combinational logic
	-- No need for D here; however, it does not affect anything adding or removing it. I edited your CORRECT code to me more simppler :)

BEGIN

	process (clk) is
	
	begin
		
--		D <= (reset NOR register_clr) AND (din OR sreg); -- set temp equal to D input in the D flip flop
--		
--		if rising_edge(clk) then
--			sreg <= D; -- if rising edge on clock, then set output as temp variable
--		end if;
--		
--		dout <= sreg; --set dout as sreg finally
		if (rising_edge(clk)) then
		
		sreg <= (register_clr NOR reset) AND (sreg OR din);
		
		end if;
		
	end process;
	
	dout <= sreg;

end;