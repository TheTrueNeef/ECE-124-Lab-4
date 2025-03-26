-- Afnan Alam and Adnan Eddeb, Lab 4 Report, Lab Section 201, Group 21

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Define top level inputs and outputs

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
    clkin_50	    : in	std_logic;
	rst_n			: in	std_logic;
	pb_n			: in	std_logic_vector(3 downto 0);
 	sw   			: in  	std_logic_vector(7 downto 0);
    leds			: out 	std_logic_vector(7 downto 0);
	seg7_data 	: out 	std_logic_vector(6 downto 0);
	seg7_char1  : out	std_logic;
	seg7_char2  : out	std_logic
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   
	component segment7_mux port (
             clk        	: in  	std_logic := '0';
			 DIN2 			: in  	std_logic_vector(6 downto 0);
			 DIN1 			: in  	std_logic_vector(6 downto 0);
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
   );
   end component;
	
	-- clock gen component
	
   component clock_generator port (
			sim_mode			: in boolean;		-- Bool value for simulation status
			reset				: in std_logic;		-- Input reset bit
         clkin      	 	: in  std_logic;		-- Clock Input
			sm_clken			: out	std_logic;	-- Clock enable output
			blink		  		: out std_logic		-- blink output bit
  );
   end component;
	
	-- define pb filters

    component pb_filters port (
			clkin				: in std_logic; -- Input block
			rst_n				: in std_logic; -- Reset input bit
			rst_n_filtered	: out std_logic;-- Filtered reset output bit
			pb_n				: in  std_logic_vector (3 downto 0); -- Button input 4 bit vector
			pb_n_filtered	: out	std_logic_vector(3  downto 0)  -- Filtered button output
 );
   end component;

	-- define pb inverter component
	
	component pb_inverters port (
			rst_n				: in  std_logic; -- Input reset bit
			rst			   : out	std_logic; -- Output rest bit
			pb_n_filtered  : in  std_logic_vector (3 downto 0); -- Input 4 bit vector
			pb					: out	std_logic_vector(3 downto 0)   -- Filtered 4 bit output button
  );
   end component;
	
	-- defining the synchronizer component
	
	component synchronizer port(
			clk				: in std_logic; -- Clock Input
			reset				: in std_logic; -- Reset Input
			din				: in std_logic; -- Input data bit
			dout				: out std_logic -- Output data bit
  );
   end component; 

	-- Holding register component
	
   component holding_register port (
			clk				: in std_logic; -- Input for clock
			reset				: in std_logic; -- Input for reset
			register_clr	: in std_logic; -- Input to clear register
			din				: in std_logic; -- Data input bit
	 		dout				: out std_logic -- Data output bit
   );
   end component;

  -- defines state machine component
  
	component State_Machine port (
		clk_input, reset, sm_clken, blink_sig, ns_request, ew_request, switch			: IN std_logic; 		-- Inputs for clock, reset, enable, blink sig and pedestrian inputs
		ns_green, ns_amber, ns_red, ew_green, ew_amber, ew_red								: OUT std_logic;	-- Output for green, amber and red lights (1 when on, 0 when off) in both NS and EW directions
		ns_crossing, ew_crossing	: OUT std_logic;		-- Output to indicate NS and EW crossing
		fourbit_state_number : OUT std_logic_vector(3 downto 0); -- 4 bit output to represent the current state of the machine (in binary)
		ns_clear, ew_clear : OUT std_logic -- Output to clear pedestrian requests for ns and ew
	);
	end component;

	CONSTANT	sim_mode								: boolean := FALSE; -- set to FALSE for LogicalStep board downloads, set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, synch_rst			    : std_logic;		-- Signals to hold reset values
	SIGNAL sm_clken, blink_sig							: std_logic;		-- Signal holding blink and enable values
	SIGNAL pb_n_filtered, pb							: std_logic_vector(3 downto 0);	-- Signal holding button values
	SIGNAL ew_req, ns_req					: std_logic;					-- Signal holding pedestrian request values
	SIGNAL ns_green, ns_amber, ns_red, ew_green, ew_amber, ew_red : std_logic; -- Signal holding the traffic light values
	SIGNAL ns_crossing, ew_crossing : std_logic;							-- Signal holding the pedestrian crossing values (corresponding to the LEDS on the board)
	SIGNAL NSLIGHTS, EWLIGHTS	: std_logic_vector(6 downto 0);				-- To hold the concatenated traffic digit values
	SIGNAL ns_clear, ew_clear : std_logic;									-- Holds the clear signals for the ns and ew pedestrian requests
	SIGNAL ew_out, ns_out : std_logic;										-- Signal for the traffic light outputs
	SIGNAL off_mode : std_logic;											-- Signal handling the offline mode setting

BEGIN
-- filters and inverts the button inputs 
INST0: pb_filters		port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters		port map (rst_n_filtered, rst, pb_n_filtered, pb);

-- generates the clock signal
INST3: clock_generator 	port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

-- Used for the synchronizer which generates the synchronous reset signal 
INSTMID: synchronizer port map (clkin_50, synch_rst, rst, synch_rst);

-- synchronizer and holding reg for EW traffic light
INSTEW: synchronizer port map (clkin_50, synch_rst, pb(1), ew_req);
INSTEWHOLDREG: holding_register port map (clkin_50, synch_rst, ew_clear, ew_req, ew_out);
-- outputs the signal to LED(3)
leds(3) <= ew_out;

-- synchronizer and holding reg for NS traffic light
INSTNS: synchronizer port map (clkin_50, synch_rst, pb(0), ns_req);
INSTNSHOLDREG : holding_register port map (clkin_50, synch_rst, ns_clear, ns_req, ns_out);
-- outputs the signal to LED(1)
leds(1) <= ns_out;

-- Instance of state machine which transitions between states, controls most of the traffic light logic
INSTSTATEMACHINE : State_Machine port map (clkin_50, synch_rst, sm_clken, blink_sig, ns_out, ew_out, off_mode, ns_green, ns_amber, ns_red, ew_green, ew_amber, ew_red, ns_crossing, ew_crossing, leds(7 downto 4), ns_clear, ew_clear);

-- outputs hte crossing state for NS and EW to the LEDS
leds(0) <= ns_crossing;
leds(2) <= ew_crossing;

-- stores value regarding the offline mode
off_mode <= sw(0);

-- concatenates and stores the traffic light values
NSLIGHTS(6 downto 0) <= ns_amber & "00" & ns_green & "00" & ns_red;
EWLIGHTS(6 downto 0) <= ew_amber & "00" & ew_green & "00" & ew_red; 

-- Uses the segment 7 mux to display the traffic light light valueson the FPGA or Waveform depending on SIM_MODE 
INSTLIGHTS : segment7_mux port map (clkin_50, NSLIGHTS, EWLIGHTS, seg7_data, seg7_char2, seg7_char1);

END SimpleCircuit;
