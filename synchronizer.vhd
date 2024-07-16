library ieee;
use ieee.std_logic_1164.all;


entity synchronizer is port (

			clk			: in std_logic;
			reset		: in std_logic;
			din			: in std_logic;
			dout		: out std_logic
  );
 end synchronizer;
 
 
architecture circuit of synchronizer is

	Signal sreg				: std_logic_vector(1 downto 0);

BEGIN

	--process (din, clk) is -- we need whatever in the process block be just sensitive to the clk edge (din being in the sensitivity list turns out an asynchronous behaviour; but we are building a synchronizer with just clk here :)
	process (clk) is
		begin
	
		if rising_edge(clk) then --synrchonously update the outputs
			if reset = '1' then
				sreg <= "00"; --synchronous reset signal
			else --if reset is not high
				sreg(0) <= din; -- set sreg's first position to to input's value for 1st flip flop
				-- we are still checking for the same conditions: reset is low and clock is rising edge
				sreg(1) <= sreg(0); -- treat sreg(0) as D input into 2nd flip flop to assign sreg(1)
			end if;
		end if;
			
	--dout <=sreg(1); --assign output to 2nd flip flop's output
	-- I Moved this assignment out of the process because The placement of dout <= sreg(1); outside the process can help avoid glitches because dout is assigned a stable value immediately after sreg(1) is updated.
			
	end process;
	dout <=sreg(1);
end;