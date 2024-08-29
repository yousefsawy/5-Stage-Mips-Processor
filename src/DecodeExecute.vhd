LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DecodeExecute IS
	PORT (
		CLK                : IN  STD_LOGIC;
		RST                : IN  STD_LOGIC;
		FLUSH              : IN  STD_LOGIC;
		PAUSE              : IN  STD_LOGIC;
		FORCE_INSERT_BOTH  : IN  STD_LOGIC;
		FORCE_INSERT_Rsrc1 : IN  STD_LOGIC;
		FORCE_INSERT_Rsrc2 : IN  STD_LOGIC;
		FORCE_INPUT_Rsrc1  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		FORCE_INPUT_Rsrc2  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_NextPC      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_NextPC     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_ConSignal   : IN  STD_LOGIC_VECTOR(22 DOWNTO 0);
		OutData_ConSignal  : OUT STD_LOGIC_VECTOR(22 DOWNTO 0);
		InData_ALUopCode   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		OutData_ALUopCode  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		InData_Rsrc1Addr   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutData_Rsrc1Addr  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		InData_Rsrc1Data   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_Rsrc1Data  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_Rsrc2Addr   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutData_Rsrc2Addr  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		InData_Rsrc2Data   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_Rsrc2Data  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_Immediate   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_Immediate  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_Rdst1Addr   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutData_Rdst1Addr  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		InData_Rdst2Addr   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutData_Rdst2Addr  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END DecodeExecute;

ARCHITECTURE a_DecodeExecute OF DecodeExecute IS

	SIGNAL NextPC    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    	SIGNAL ConSignal : STD_LOGIC_VECTOR(22 DOWNTO 0);
	SIGNAL ALUopCode : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Rsrc1Addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rsrc1Data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rsrc2Data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Immediate : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr : STD_LOGIC_VECTOR(2 DOWNTO 0);

	BEGIN
		PROCESS (CLK, RST, FORCE_INSERT_BOTH, FORCE_INSERT_Rsrc1, FORCE_INSERT_Rsrc2)
		BEGIN
			IF (RST = '1') THEN
				NextPC    <= (OTHERS => '0');
				ConSignal <= (OTHERS => '0');
				ALUopCode <= (OTHERS => '0');
				Rsrc1Addr <= (OTHERS => '0');
				Rsrc1Data <= (OTHERS => '0');
				Rsrc2Addr <= (OTHERS => '0');
				Rsrc2Data <= (OTHERS => '0');
				Immediate <= (OTHERS => '0');
				Rdst1Addr <= (OTHERS => '0');
				Rdst2Addr <= (OTHERS => '0');
			ELSIF (FORCE_INSERT_BOTH = '1') THEN
				Rsrc1Data <= FORCE_INPUT_Rsrc1;
				Rsrc2Data <= FORCE_INPUT_Rsrc1;
			ELSIF (FORCE_INSERT_Rsrc1 = '1') THEN
				Rsrc1Data <= FORCE_INPUT_Rsrc1;
			ELSIF (FORCE_INSERT_Rsrc2 = '1') THEN
				Rsrc2Data <= FORCE_INPUT_Rsrc1;
			ELSIF FALLING_EDGE(CLK) THEN
				IF (FLUSH = '1') THEN
					NextPC    <= (OTHERS => '0');
					ConSignal <= (OTHERS => '0');
					ALUopCode <= (OTHERS => '0');
					Rsrc1Addr <= (OTHERS => '0');
					Rsrc1Data <= (OTHERS => '0');
					Rsrc2Addr <= (OTHERS => '0');
					Rsrc2Data <= (OTHERS => '0');
					Immediate <= (OTHERS => '0');
					Rdst1Addr <= (OTHERS => '0');
					Rdst2Addr <= (OTHERS => '0');
				ELSIF (PAUSE = '0') THEN
					NextPC    <= InData_NextPC;
					ConSignal <= InData_ConSignal;
					ALUopCode <= InData_ALUopCode;
					Rsrc1Addr <= InData_Rsrc1Addr;
					Rsrc1Data <= InData_Rsrc1Data;
					Rsrc2Addr <= InData_Rsrc2Addr;
					Rsrc2Data <= InData_Rsrc2Data;
					Immediate <= InData_Immediate;
					Rdst1Addr <= InData_Rdst1Addr;
					Rdst2Addr <= InData_Rdst2Addr;
				END IF;
			END IF;
		END PROCESS;	
		OutData_NextPC    <= NextPC;
		OutData_ConSignal <= ConSignal;
		OutData_ALUopCode <= ALUopCode;
		OutData_Rsrc1Addr <= Rsrc1Addr;
		OutData_Rsrc1Data <= Rsrc1Data;
		OutData_Rsrc2Addr <= Rsrc2Addr;
		OutData_Rsrc2Data <= Rsrc2Data;
		OutData_Immediate <= Immediate;
		OutData_Rdst1Addr <= Rdst1Addr;
		OutData_Rdst2Addr <= Rdst2Addr;

END a_DecodeExecute;

