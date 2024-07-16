library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity TLC_State_Machine IS Port
(
	clk_input, clk_enbl, reset, blink_sig,
	-- You forgot clk_enbl/ here :)
	NS_hold_reg_sig			: IN std_logic; -- holds north south pedestrian crossing signal
	EW_hold_reg_sig			: IN std_logic; -- holds east west pedestrain crossing signal
	
	--North South
	NS_crossing_display						: OUT std_logic; --indicates that green NS light is on
	NSLight 										: OUT std_logic_vector (2 downto 0); -- north/south lights in order : amber (G), green(D), red (A)

	--East West
	EW_crossing_display 						: OUT std_logic; -- indicates that green EW light is on
	EWLight										: OUT std_logic_vector (2 downto 0); -- east/west lights in order: amber (G), green(D), red (A)
	
	StateNumber 								: OUT std_logic_vector (3 downto 0); -- to be displayed on leds 7-4, and will clear the appropriate holding reg signal at 0110 and 1110
	NSClear, EWClear							: OUT std_logic
	
 );
END ENTITY;
 

 Architecture SM of TLC_State_Machine is
 
 
 TYPE STATE_NAMES IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15);   -- list all the STATE_NAMES values

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


 BEGIN
 

 -------------------------------------------------------------------------------
 --State Machine:
 -------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS EXAMPLE
 
Register_Section: PROCESS (clk_input)  -- this process updates with a clock
BEGIN
	IF(rising_edge(clk_input)) THEN
		IF (reset = '1') THEN
			current_state <= S0;
		ELSIF (clk_enbl = '1') THEN -- condition here is clk_enbl = '1'
			current_state <= next_State;
		END IF;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS EXAMPLE

Transition_Section: PROCESS (current_state) 

BEGIN
  CASE current_state IS
        WHEN S0 =>		
				IF (EW_hold_reg_sig ='1' AND NS_hold_reg_sig='0') THEN
					next_state <= S6;
				ELSE
				next_state <= S1;
				END IF;

         WHEN S1 =>		
					IF (EW_hold_reg_sig ='1' AND NS_hold_reg_sig='0') THEN
					next_state <= S6;
				ELSE
				next_state <= S2;
				END IF;

         WHEN S2 =>		
					next_state <= S3;
				
				
         WHEN S3 =>		
				next_state <= S4;

         WHEN S4 =>		
					next_state <= S5;

         WHEN S5 =>		
					next_state <= S6;
				
         WHEN S6 =>		
				next_state <= S7;
				
         WHEN S7 =>		
				next_state <= S8;
			
			WHEN S8 =>
				IF(NS_hold_reg_sig='1' AND EW_hold_reg_sig='0') THEN			-- checks for if hold register signal is high
					next_state <= S14;
				ELSE
					next_state <= S9;
				END IF;
				
			WHEN S9 =>		
				IF(NS_hold_reg_sig='1' AND EW_hold_reg_sig='0') THEN			-- checks for if hold register signal is high
					next_state <= S14;
				ELSE
					next_state <= S10;
				END IF;
			
			WHEN S10 =>		
				next_state <= S11;
			
			WHEN S11 =>		
				next_state <= S12;
			
			WHEN S12 =>		
				next_state <= S13;
			
			WHEN S13 =>		
				next_state <= S14;
			
			WHEN S14 =>		
				next_state <= S15;
			
			WHEN S15 =>		
				next_state <= S0;
				
	  END CASE;
 END PROCESS;
 

-- DECODER SECTION PROCESS EXAMPLE (MOORE FORM SHOWN)

Decoder_Section: PROCESS (current_state) 

BEGIN
     CASE current_state IS
	  
	  WHEN S0 =>		
			NSlight <= '0'&blink_sig&'0';
			NS_crossing_display <= '0';
			
			EWlight <= "001";
			EW_crossing_display <= '0';
			
			StateNumber <= "0000";
			
			NSClear <= '0';
			EWClear <= '0';
			
         WHEN S1 =>		
			NSlight <= '0'&blink_sig&'0';
			NS_crossing_display <= '0';
			
			EWlight <= "001";
			EW_crossing_display <= '0';
			
			StateNumber <= "0001";
			
			NSClear <= '0';
			EWClear <= '0';

         WHEN S2 =>	
			NSlight <= "010";
			NS_crossing_display <= '1';
			
			EWlight <= "001";
			EW_crossing_display <= '0';
			
			StateNumber <= "0010";
			
			NSClear <= '0';
			EWClear <= '0';
			
         WHEN S3 =>		
			NSlight <= "010";
			NS_crossing_display <= '1';
			
			EWlight <= "001";
			EW_crossing_display <= '0';
			
			StateNumber <= "0011";
			
			NSClear <= '0';
			EWClear <= '0';

         WHEN S4 =>		
			NSlight <= "010";
			NS_crossing_display <= '1';
			
			EWlight <= "001";
			EW_crossing_display <= '0';
			
			StateNumber <= "0100";
			
			NSClear <= '0';
			EWClear <= '0';

         WHEN S5 =>		
			NSlight <= "010";
			NS_crossing_display <= '1';
			
			EWlight <= "001";
			EW_crossing_display <= '0';
			
			StateNumber <= "0101";
			
			NSClear <= '0';
			EWClear <= '0';
				
         WHEN S6 =>	
			NSlight <= "100";
			NS_crossing_display <= '0';
			
				
			EWlight <= "001";
			EW_crossing_display <= '0';
			
			StateNumber <= "0110";
			
			NSClear <= '1';
			EWClear <= '0';
				
         WHEN S7 =>		
			NSlight <= "100";
			NS_crossing_display <= '0';
			
			EWlight <= "001";
			EW_crossing_display <= '0';
			
			StateNumber <= "0111";
			
			NSClear <= '0';
			EWClear <= '0';
				
			WHEN S8 =>		
			NSlight <= "001";
			NS_crossing_display <= '0';
			
			EWlight <= '0'&blink_sig&'0';
			EW_crossing_display <= '0';
			
			StateNumber <= "1000";
			
			NSClear <= '0';
			EWClear <= '0';
			
			WHEN S9 =>		
			NSlight <= "001";
			NS_crossing_display <= '0';
			
			EWlight <= '0'&blink_sig&'0';
			EW_crossing_display <= '0';
			
			StateNumber <= "1001";
			
			NSClear <= '0';
			EWClear <= '0';
			
			WHEN S10 =>		
			NSlight <= "001";
			NS_crossing_display <= '0';
			
			EWlight <= "010";
			EW_crossing_display <= '1';
			
			StateNumber <= "1010";
			
			NSClear <= '0';
			EWClear <= '0';
			
			WHEN S11 =>		
			NSlight <= "001";
			NS_crossing_display <= '0';
			
			EWlight <= "010";
			EW_crossing_display <= '1';
			
			StateNumber <= "1011";
			
			NSClear <= '0';
			EWClear <= '0';
			
			WHEN S12 =>		
			NSlight <= "001";
			NS_crossing_display <= '0';
			
			EWlight <= "010";
			EW_crossing_display <= '1';
			
			StateNumber <= "1100";
			
			NSClear <= '0';
			EWClear <= '0';
			
			WHEN S13 =>		
			NSlight <= "001";
			NS_crossing_display <= '0';
			
			EWlight <= "010";
			EW_crossing_display <= '1';
			
			StateNumber <= "1101";
			
			NSClear <= '0';
			EWClear <= '0';
			
			WHEN S14 =>	
			NSlight <= "001";
			NS_crossing_display <= '0';
			
			EWlight <= "100";
			EW_crossing_display <= '0';
			
			StateNumber <= "1110";
			
			NSClear <= '0';
			EWClear <= '1';
			
			WHEN S15 =>		
			NSlight <= "001";
			NS_crossing_display <= '0';
			
			EWlight <= "100";
			EW_crossing_display <= '0';
			
			StateNumber <= "1111";
			
			NSClear <= '0';
			EWClear <= '0';
			
	  
			
	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;
