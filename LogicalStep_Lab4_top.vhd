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
			reset				: in std_logic;	-- Input reset bit
         clkin      	 	: in  std_logic;	-- Clock Input
			sm_clken			: out	std_logic;	-- Clock enable output
			blink		  		: out std_logic	-- blink output bit
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
		clk_input, reset, sm_clken, blink_sig, ns_request, ew_request, switch			: IN std_logic; -- 
		ns_green, ns_amber, ns_red, ew_green, ew_amber, ew_red								: OUT std_logic;
		ns_crossing, ew_crossing	: OUT std_logic;
		fourbit_state_number : OUT std_logic_vector(3 downto 0);
		ns_clear, ew_clear : OUT std_logic
	);
	end component;

	CONSTANT	sim_mode								: boolean := FALSE;
	SIGNAL rst, rst_n_filtered, synch_rst			    : std_logic;
	SIGNAL sm_clken, blink_sig							: std_logic;
	SIGNAL pb_n_filtered, pb							: std_logic_vector(3 downto 0);
	SIGNAL ew_req, ns_req					: std_logic;
	SIGNAL ns_green, ns_amber, ns_red, ew_green, ew_amber, ew_red : std_logic;
	SIGNAL ns_crossing, ew_crossing : std_logic;
	SIGNAL NSLIGHTS, EWLIGHTS	: std_logic_vector(6 downto 0);
	SIGNAL ns_clear, ew_clear : std_logic;
	SIGNAL ew_out, ns_out : std_logic;
	SIGNAL off_mode : std_logic;

BEGIN

INST0: pb_filters		port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters		port map (rst_n_filtered, rst, pb_n_filtered, pb);

INST3: clock_generator 	port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

INSTMID: synchronizer port map (clkin_50, synch_rst, rst, synch_rst);

INSTEW: synchronizer port map (clkin_50, synch_rst, pb(1), ew_req);
INSTEWHOLDREG: holding_register port map (clkin_50, synch_rst, ew_clear, ew_req, ew_out);
leds(3) <= ew_out;

INSTNS: synchronizer port map (clkin_50, synch_rst, pb(0), ns_req);
INSTNSHOLDREG : holding_register port map (clkin_50, synch_rst, ns_clear, ns_req, ns_out);
leds(1) <= ns_out;

INSTSTATEMACHINE : State_Machine port map (clkin_50, synch_rst, sm_clken, blink_sig, ns_out, ew_out, off_mode, ns_green, ns_amber, ns_red, ew_green, ew_amber, ew_red, ns_crossing, ew_crossing, leds(7 downto 4), ns_clear, ew_clear);

leds(0) <= ns_crossing;
leds(2) <= ew_crossing;

off_mode <= sw(0);

NSLIGHTS(6 downto 0) <= ns_amber & "00" & ns_green & "00" & ns_red;
EWLIGHTS(6 downto 0) <= ew_amber & "00" & ew_green & "00" & ew_red; 

INSTLIGHTS : segment7_mux port map (clkin_50, NSLIGHTS, EWLIGHTS, seg7_data, seg7_char2, seg7_char1);

END SimpleCircuit;
