LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY StackPointer IS
	PORT (
		CLK       : IN  STD_LOGIC;
		RST       : IN  STD_LOGIC;
		SP_INC    : IN  STD_LOGIC;
		SP_DEC    : IN  STD_LOGIC;
		SP_OUTPUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END StackPointer;

ARCHITECTURE a_StackPointer OF StackPointer IS
	-- REGISTER --
    	SIGNAL SP : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- LOGIC --
	SIGNAL SP_ADD_TWO : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SP_SUB_TWO : STD_LOGIC_VECTOR(31 DOWNTO 0);

	BEGIN

		PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN
				SP <= x"FFFFFFFE";
			ELSIF RISING_EDGE(CLK) THEN
				IF (SP_INC = '1') THEN
					SP <= SP_ADD_TWO;
				END IF;
				IF (SP_DEC = '1') THEN
					SP <= SP_SUB_TWO;
				END IF;
			END IF;
		END PROCESS;

		SP_ADD_TWO <= std_logic_vector(unsigned(SP) + 2);
		SP_SUB_TWO <= std_logic_vector(unsigned(SP) - 2);

		SP_OUTPUT <= SP         WHEN (SP_DEC = '1')
		ELSE         SP_ADD_TWO WHEN (SP_INC = '1')
		ELSE         SP;

END a_StackPointer;

