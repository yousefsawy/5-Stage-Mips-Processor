LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SignExtender IS
	PORT ( 
		input_16  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
           	output_32 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END SignExtender;

ARCHITECTURE a_SignExtender OF SignExtender IS

	BEGIN
		PROCESS(input_16)
		BEGIN

        		IF input_16(15) = '1' THEN -- Check the sign bit
            			-- Sign extend by padding with 1s
            			output_32 <= x"FFFF" & input_16;
        		ELSE
            			-- Sign extend by padding with 0s
            			output_32 <= x"0000" & input_16;
        		END IF;

    		END PROCESS;
END a_SignExtender;
