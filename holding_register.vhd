-- Afnan Alam and Adnan Eddeb, Lab 4 Report, Lab Section 201, Group 21

library ieee;
use ieee.std_logic_1164.all;

-- Declaring the holding register entity 
entity holding_register is port (
	clk           : in std_logic;		-- Clock Input
	reset         : in std_logic;		-- Input Reset Signal
	register_clr  : in std_logic;		-- Input for the Reset Clear
	din           : in std_logic;		-- Data Input
	dout          : out std_logic		-- Data Output
);
end holding_register;

-- Logic of the holding register 
architecture circuit of holding_register is
	-- defining signals to hold register 
	signal sreg : std_logic;
	-- storing a temporary variable to simplify logic in the if statement
	signal d    : std_logic;
begin
	d <= (sreg OR din) AND (NOT(reset OR register_clr));

	synced_system : process(clk)
	begin
		-- only proceeds if the clock is on the rising edge
		if (rising_edge(clk)) then
			-- Stores d in the register and outputs it in data output
			sreg <= d;
			dout <= d;
		end if;
	end process;
end;
