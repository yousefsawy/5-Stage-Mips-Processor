LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FetchDecode IS
	PORT (
		CLK                 : IN  STD_LOGIC;
		RST                 : IN  STD_LOGIC;
		FLUSH               : IN  STD_LOGIC;
		PAUSE               : IN  STD_LOGIC;
		FORCE               : IN  STD_LOGIC;
		FORCED_INST         : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		FORCED_PC           : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_Instruction  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		OutData_Instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		InData_NextPC       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_NextPC      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END FetchDecode;

ARCHITECTURE a_FetchDecode OF FetchDecode IS

	-- REGISTER --
    	SIGNAL Instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL NextPC : STD_LOGIC_VECTOR(31 DOWNTO 0);

	BEGIN
		PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN
				Instruction <= (OTHERS => '0');
				NextPC      <= (OTHERS => '0');
			ELSIF FALLING_EDGE(CLK) THEN
				IF (FLUSH = '1') THEN
					Instruction <= (OTHERS => '0');
					NextPC      <= (OTHERS => '0');
				ELSIF (FORCE = '1') THEN
					Instruction <= FORCED_INST;
					NextPC      <= FORCED_PC;
				ELSIF (PAUSE = '0') THEN 
					Instruction <= InData_Instruction;
					NextPC      <= InData_NextPC;
				END IF;
			END IF;
		END PROCESS;	
		OutData_Instruction <= Instruction;
		OutData_NextPC      <= NextPC;
END a_FetchDecode;
