-- Afnan Alam and Adnan Eddeb, Lab 4 Report, Lab Section 201, Group 21

-- Importing libraries and necessary packages
library ieee;
use ieee.std_logic_1164.all;

-- Defining PB_Inverters entity
entity PB_inverters is port (
	rst_n			: in	std_logic;		-- Input reset
	rst				: out std_logic;		-- Output reset
 	pb_n_filtered	: in  std_logic_vector (3 downto 0);	-- Input 4 bit button vetor
	pb				: out	std_logic_vector(3 downto 0)	-- Output 4 bit button vector (Inverted from input)
); 
end PB_inverters;

-- Logic for PB_Invertors
architecture ckt of PB_inverters is
begin
-- Inverting both the reset and filtered button inputs
rst <= NOT(rst_n);
pb <= NOT(pb_n_filtered);

end ckt;
