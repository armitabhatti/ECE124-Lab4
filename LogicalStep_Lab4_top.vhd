-- Author: Group 4, Armita Bhatti, Ryan Sadeghi-Javid
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
    clkin_50	    : in	std_logic;							-- The 50 MHz FPGA Clockinput
	rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	sw   			: in  	std_logic_vector(7 downto 0); -- The switch inputs
    leds			: out 	std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	
--	--PART F simulation signals
--	sm_clken_sim, blink_sig_sim	: out std_logic; -- state machine clock signal and blink signal
--	NSLight_sim, EWLight_sim : out std_logic_vector(2 downto 0); -- in order AGR
	
	-------------------------------------------------------------
	
   seg7_data 	: out 	std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   component segment7_mux port (
             clk        	: in  	std_logic := '0';
			 DIN2 			: in  	std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 			: in  	std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
   );
   end component;

   component clock_generator port (
			sim_mode			: in boolean;
			reset				: in std_logic;
            clkin      		    : in  std_logic;
			sm_clken			: out	std_logic;
			blink		  		: out std_logic
  );
   end component;

    component pb_filters port (
			clkin				: in std_logic;
			rst_n				: in std_logic;
			rst_n_filtered	    : out std_logic;
			pb_n				: in  std_logic_vector (3 downto 0);
			pb_n_filtered	    : out	std_logic_vector(3 downto 0)							 
 );
   end component;

	component pb_inverters port (
			rst_n				: in  std_logic;
			rst				    : out	std_logic;							 
			pb_n_filtered	    : in  std_logic_vector (3 downto 0);
			pb					: out	std_logic_vector(3 downto 0)							 
  );
   end component;
	
	component synchronizer port(
			clk					: in std_logic;
			reset					: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
   end component; 
  component holding_register port (
			clk					: in std_logic;
			reset					: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
  end component;			
  
  component TLC_State_Machine is port(
	clk_input, clk_enbl, reset, blink_sig,
	
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
END component;

----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode										: boolean := FALSE;  -- set to FALSE for LogicalStep board downloads																						-- set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, synch_rst			: std_logic;
	SIGNAL sm_clken, blink_sig							: std_logic; 
	SIGNAL pb_n_filtered, pb							: std_logic_vector(3 downto 0); 
	SIGNAL EW_hold_reg_sig, NS_hold_reg_sig		: std_logic; --initialized two signals to store output of synch to input of holdreg
	SIGNAL NSLight, EWLight								: std_logic_vector(2 downto 0); -- blink, amber, green, red
	SIGNAL NSDecoder, EWDecoder						: std_logic_vector(6 downto 0); 
	SIGNAL NSClear, EWClear								: std_logic;
	SIGNAl Statenumber									: std_Logic_vector(3 downto 0);
	signal EW_sig_out, NS_sig_out						:std_logic;
	signal NS_cross_allowed, EW_cross_allowed    :std_logic;
	
BEGIN

	NSDecoder <= NSLight(2)&'0'&'0'&NSLight(1)&'0'&'0'&NSLight(0); --concatenates light signal vector into seven seg mux to display adg
	EWDecoder <= EWLight(2)&'0'&'0'&EWLight(1)&'0'&'0'&EWLight(0); --concatenates light signal vector into seven seg mux to display adg
	
	
	leds(7 downto 4) <= Statenumber; --assign leds to display state number
	
	
	--INTERNAL SIGNALS FOR SIM
	-- assign simulation signals the value of the internal signals to get simulation wave form!
--	sm_clken_sim <= sm_clken;
--	blink_sig_sim <= blink_sig;
--	NSLight_sim <= NSLight;
--	EWLight_sim <= EWLight;
	
	leds(3) <= EW_sig_out; -- displays that request to cross EW
   leds(1) <= NS_sig_out; -- displays

   leds(0) <= NS_cross_allowed;
   leds(2) <= EW_cross_allowed;


----------------------------------------------------------------------------------------------------
INST0: pb_filters		   port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered); -- filters PB
INST1: pb_inverters		port map (rst_n_filtered, rst, pb_n_filtered, pb); -- inverts PB
INST2: synchronizer     port map (clkin_50,synch_rst, rst, synch_rst);	-- the synchronizer is also reset by synch_rst.
INST3: clock_generator 	port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig); --generates clock for state machine and blink signal

-- EAST WEST
INST4: synchronizer     port map (clkin_50, synch_rst, pb(1), EW_hold_reg_sig); -- synchronizes east west holding register signal
INST5: holding_register port map (clkin_50, synch_rst, EWClear, EW_hold_reg_sig, EW_sig_out); -- holds the request for pedestrian signal EW

-- NORTH SOUTH
INST6: synchronizer     port map (clkin_50,synch_rst, pb(0), NS_hold_reg_sig); -- synchronizes north south holding register signal
INST7: holding_register port map (clkin_50, synch_rst, NSClear, NS_hold_reg_sig, NS_sig_out); -- holds the request for pedestrian signal NS

INST8: TLC_State_Machine port map (clkin_50, sm_clken, synch_rst, blink_sig, NS_sig_out, EW_sig_out, NS_cross_allowed, NSLight, EW_cross_allowed, EWLight, Statenumber, NSClear, EWClear); 
INST9: segment7_mux port map (clkin_50, NSDecoder, EWDecoder, seg7_data, seg7_char2, seg7_char1); -- takes in NS and EW concatenated signal and puts it on respective digits





END SimpleCircuit;
