-- Afnan Alam and Adnan Eddeb, Lab 4 Report, Lab Section 201, Group 21

-- Importing libraries and necessary packages
library ieee;
use ieee.std_logic_1164.all;

-- Defining the synchronizer entity
entity synchronizer is
  port (
    clk   : in  std_logic;	-- clock input
    reset : in  std_logic;	-- reset inputp
    din   : in  std_logic;	-- data input
    dout  : out std_logic	-- data output
  );
end synchronizer;

-- logic for the synchronizer
architecture circuit of synchronizer is

	-- signal keeping track of synchronizer register contents
  signal sreg : std_logic_vector(1 downto 0);


begin
  synced_process : process(clk)
  begin
	-- Only continues if the clock is on the rising edge
	if rising_edge(clk) then
		-- Resets the values stored in the register to zero
		if reset = '1' then
			sreg <= "00";
		-- If the reset signal is not active, the register contents are shifted bit
		else
			sreg(1) <= sreg(0); -- shifts values from first register to the second
			sreg(0) <= din;		-- stores the data input in the first register
		end if;
	end if;
	end process synced_process;
	dout <= sreg(1);			-- Outputs the value stored in the second register
end circuit;
