-- Members: Adnan Eddeb, Afnan Alam | Lab4_REPORT | LS201 | Group 21

-- Importing libraries and necessary packages
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Defines the state machine entity, which is a mealy state machine as there is inputs effecting which state is next.
entity State_Machine IS 
  port (
    clk_input, reset, sm_clken, blink_sig, ns_request, ew_request, switch : IN std_logic; -- input for clock, reset, clock enable, blink signal, pedestrian requests and Switch 0 bit
    ns_green, ns_amber, ns_red, ew_green, ew_amber, ew_red : OUT std_logic; -- Output for the trafic signals, 3 different values for each ns and ew, these outputs can have 3 values each being 0 off, 1 on, blink_sig for blinking
    ns_crossing, ew_crossing : OUT std_logic; --Led output to indicate when crossing is allowed
    fourbit_state_number : OUT std_logic_vector(3 downto 0); -- led output using binary numerical representation of which state is on
    ns_clear, ew_clear : OUT std_logic -- output to clear pedestrian crossing signals
  );
end entity;

--Definition of mealy state machine logic
architecture SM of State_Machine is
  type STATE_NAMES IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, off_state); -- declaration of 16 states + an offline mode state which is similar to the off_state, however it acts differently as the 7 seg mux display blinks during this state
  signal current_state, next_state : STATE_NAMES; -- defining signals which are of type STATE_NAMES
begin

  --Register which uses the clock to update states in the mealy state machine
Register_Section: process(clk_input)
begin
  if rising_edge(clk_input) then -- When the clock is on a rising edge
    if (reset = '1') then -- if the reset value is 1,
      current_state <= S0; -- then we want the state machine to go back to state 0, essentialy restarting
    elsif (reset = '0' and sm_clken = '1') then --if the reset is 0 and the clock enable is 1 then we want the state machine to change states like normal
      current_state <= next_state; -- this changes the current state to the next state which is defined in the transition section
    end if;
  end if;
end process;

--Definition of the transition section, which is the sequential logic section of the state machine.vhd
Transition_Section: process(current_state)
begin
  -- The following block is similar to a switch case statement in c++, where we define the function of the state machine for each state
  case current_state is
    when S0 => -- When the state is 0 or 1 we want: check if there is a pedestrian request, if there is skip to state 6 to speed up the trafic light, if
		if (ew_request = '1' AND ns_request = '0') then
        next_state <= S6;
      else
        next_state <= S1;
		end if;
    when S1 =>
		if (ew_request = '1' AND ns_request = '0') then
        next_state <= S6;
      else
        next_state <= S2;
		end if;
    -- states 2 to 7 have normal logic simply moving to the next state
    when S2 => next_state <= S3;
    when S3 => next_state <= S4;
    when S4 => next_state <= S5;
    when S5 => next_state <= S6;
    when S6 => next_state <= S7;
    when S7 => next_state <= S8;
    when S8 => -- When state is 8 or 9 we do something similar to states 0 and 1 where we have a request that will either skip to state 14, or move to the next state
	 if (ew_request = '0' AND ns_request = '1') then
        next_state <= S14;
      else
        next_state <= S9;
		end if;
    when S9 =>
	 if (ew_request = '0' AND ns_request = '1') then
        next_state <= S14;
      else
        next_state <= S10;
      end if;      
      --states 10 to 14 have normal logic simply moving to the next state
    when S10 => next_state <= S11;
    when S11 => next_state <= S12;
    when S12 => next_state <= S13;
    when S13 => next_state <= S14;
    when S14 => next_state <= S15;
    when S15 => -- when the offline mode switch is on we want to switch to offline mode, if it is switched off, we simply loop back to state 0
		if (switch = '1') then
			next_state <= off_state;
		else
			next_state <= S0;
			end if;
	 when off_state => -- the state machine will remain in the off_state as long as the switch is on, if it is off it follows logic like state 15
		if (switch = '1') then
			next_state <= off_state;
		else
			next_state <= s0;
		end if;
  end case;
end process;

Decoder_Section: process(current_state)
begin
  case current_state is
    when S0 | S1 =>
      ns_clear <= '0'; 
      ns_green <= blink_sig; 
      ns_amber <= '0'; ns_red <= '0'; 
      ns_crossing <= '0';
      ew_clear <= '0'; 
      ew_green <= '0'; 
      ew_amber <= '0'; 
      ew_red <= '1'; 
      ew_crossing <= '0';
    when S2 | S3 | S4 | S5 =>
      ns_clear <= '0'; 
      ns_green <= '1'; 
      ns_amber <= '0'; 
      ns_red <= '0'; 
      ns_crossing <= '1';
      ew_clear <= '0'; 
      ew_green <= '0'; 
      ew_amber <= '0'; 
      ew_red <= '1'; 
      ew_crossing <= '0';
    when S6 =>
      ns_clear <= '1'; 
      ns_green <= '0'; 
      ns_amber <= '1'; 
      ns_red <= '0'; 
      ns_crossing <= '0';
      ew_clear <= '0'; 
      ew_green <= '0'; 
      ew_amber <= '0'; 
      ew_red <= '1'; 
      ew_crossing <= '0';
    when S7 =>
      ns_clear <= '0'; 
      ns_green <= '0'; 
      ns_amber <= '1'; 
      ns_red <= '0'; 
      ns_crossing <= '0';
      ew_clear <= '0'; 
      ew_green <= '0'; 
      ew_amber <= '0'; 
      ew_red <= '1'; 
      ew_crossing <= '0';
    when S8 | S9 =>
      ns_clear <= '0'; 
      ns_green <= '0'; 
      ns_amber <= '0'; 
      ns_red <= '1'; 
      ns_crossing <= '0';
      ew_clear <= '0'; 
      ew_green <= blink_sig; 
      ew_amber <= '0'; 
      ew_red <= '0'; 
      ew_crossing <= '0';
    when S10 | S11 | S12 | S13 =>
      ns_clear <= '0'; 
      ns_green <= '0'; 
      ns_amber <= '0'; 
      ns_red <= '1'; 
      ns_crossing <= '0';
      ew_clear <= '0'; 
      ew_green <= '1'; 
      ew_amber <= '0'; 
      ew_red <= '0'; 
      ew_crossing <= '1';
    when S14 =>
      ns_clear <= '0'; 
      ns_green <= '0'; 
      ns_amber <= '0'; 
      ns_red <= '1'; 
      ns_crossing <= '0';
      ew_clear <= '1'; 
      ew_green <= '0'; 
      ew_amber <= '1'; 
      ew_red <= '0'; 
      ew_crossing <= '0';
    when S15 =>
      ns_clear <= '0'; 
		  ns_green <= '0'; 
		  ns_amber <= '0'; 
		  ns_red <= '1'; 
		  ns_crossing <= '0';
      ew_clear <= '0'; 
		  ew_green <= '0'; 
		  ew_amber <= '1'; 
		  ew_red <= '0'; 
		  ew_crossing <= '0';
	 when off_state =>
      ns_clear <= '0'; 
		  ns_green <= '0'; 
		  ns_amber <= '0'; 
		  ns_red <= blink_sig; 
		  ns_crossing <= '0';
      ew_clear <= '0'; 
		  ew_green <= '0'; 
		  ew_amber <= blink_sig; 
		  ew_red <= '0'; 
		  ew_crossing <= '0';		
  end case;

  case current_state is
    when S0  => fourbit_state_number <= "0000";
    when S1  => fourbit_state_number <= "0001";
    when S2  => fourbit_state_number <= "0010";
    when S3  => fourbit_state_number <= "0011";
    when S4  => fourbit_state_number <= "0100";
    when S5  => fourbit_state_number <= "0101";
    when S6  => fourbit_state_number <= "0110";
    when S7  => fourbit_state_number <= "0111";
    when S8  => fourbit_state_number <= "1000";
    when S9  => fourbit_state_number <= "1001";
    when S10 => fourbit_state_number <= "1010";
    when S11 => fourbit_state_number <= "1011";
    when S12 => fourbit_state_number <= "1100";
    when S13 => fourbit_state_number <= "1101";
    when S14 => fourbit_state_number <= "1110";
    when S15 => fourbit_state_number <= "1111";
	 when off_state => fourbit_state_number <= "1111";
  end case;
end process;

end architecture SM;
