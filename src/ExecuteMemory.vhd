LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ExecuteMemory IS
	PORT (
		CLK               : IN  STD_LOGIC;
		RST               : IN  STD_LOGIC;
		FLUSH             : IN  STD_LOGIC;
		InData_NextPC     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_NextPC    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_ConSignal  : IN  STD_LOGIC_VECTOR(22 DOWNTO 0);
		OutData_ConSignal : OUT STD_LOGIC_VECTOR(22 DOWNTO 0);
		InData_ALUresult  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_ALUresult : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_ALUflag    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		OutData_ALUflag   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		InData_Rsrc2Data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_Rdst1Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutData_Rdst1Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		InData_Rdst2Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutData_Rdst2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END ExecuteMemory;

ARCHITECTURE a_ExecuteMemory OF ExecuteMemory IS

	SIGNAL NextPC    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    	SIGNAL ConSignal : STD_LOGIC_VECTOR(22 DOWNTO 0);
	SIGNAL ALUresult : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALUflag   : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Rsrc2Data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL SP        : STD_LOGIC_VECTOR(31 DOWNTO 0);

	BEGIN
		PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN
				NextPC    <= (OTHERS => '0');
				ConSignal <= (OTHERS => '0');
				ALUresult <= (OTHERS => '0');
				ALUflag   <= (OTHERS => '0');
				Rsrc2Data <= (OTHERS => '0');
				Rdst1Addr <= (OTHERS => '0');
				Rdst2Addr <= (OTHERS => '0');
			ELSIF FALLING_EDGE(CLK) THEN
				IF (FLUSH = '1') THEN
					NextPC    <= (OTHERS => '0');
					ConSignal <= (OTHERS => '0');
					ALUresult <= (OTHERS => '0');
					ALUflag   <= (OTHERS => '0');
					Rsrc2Data <= (OTHERS => '0');
					Rdst1Addr <= (OTHERS => '0');
					Rdst2Addr <= (OTHERS => '0');
				ELSE
					NextPC    <= InData_NextPC;
					ConSignal <= InData_ConSignal;
					ALUresult <= InData_ALUresult;
					ALUflag   <= InData_ALUflag;
					Rsrc2Data <= InData_Rsrc2Data;
					Rdst1Addr <= InData_Rdst1Addr;
					Rdst2Addr <= InData_Rdst2Addr;
				END IF;
			END IF;
		END PROCESS;	
		OutData_NextPC    <= NextPC;
		OutData_ConSignal <= ConSignal;
		OutData_ALUresult <= ALUresult;
		OutData_ALUflag   <= ALUflag;
		OutData_Rsrc2Data <= Rsrc2Data;
		OutData_Rdst1Addr <= Rdst1Addr;
		OutData_Rdst2Addr <= Rdst2Addr;
END a_ExecuteMemory;

