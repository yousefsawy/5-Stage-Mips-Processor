LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MemoryWriteback IS
	PORT (
		CLK               : IN  STD_LOGIC;
		RST               : IN  STD_LOGIC;
		InData_ConSignal  : IN  STD_LOGIC_VECTOR(19 DOWNTO 0);
		OutData_ConSignal : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
		InData_Flags      : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		OutData_Flags     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		InData_MemData    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_MemData   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_Rsrc2Data  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutData_Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		InData_Rdst1Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutData_Rdst1Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		InData_Rdst2Addr  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		OutData_Rdst2Addr : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);
END MemoryWriteback;

ARCHITECTURE a_MemoryWriteback OF MemoryWriteback IS

    	SIGNAL ConSignal : STD_LOGIC_VECTOR(19 DOWNTO 0);
	SIGNAL Flags     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL MemData   : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr : STD_LOGIC_VECTOR(2 DOWNTO 0);

	BEGIN
		PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN
				ConSignal <= (OTHERS => '0');
				Flags     <= (OTHERS => '0');
				MemData   <= (OTHERS => '0');
				Rsrc2Data <= (OTHERS => '0');
				Rdst1Addr <= (OTHERS => '0');
				Rdst2Addr <= (OTHERS => '0');
			ELSIF FALLING_EDGE(CLK) THEN
				ConSignal <= InData_ConSignal;
				Flags     <= InData_Flags;
				MemData   <= InData_MemData;
				Rsrc2Data <= InData_Rsrc2Data;
				Rdst1Addr <= InData_Rdst1Addr;
				Rdst2Addr <= InData_Rdst2Addr;
			END IF;
		END PROCESS;
		OutData_ConSignal <= ConSignal;
		OutData_Flags     <= Flags;
		OutData_MemData   <= MemData;
		OutData_Rsrc2Data <= Rsrc2Data;
		OutData_Rdst1Addr <= Rdst1Addr;
		OutData_Rdst2Addr <= Rdst2Addr;
END a_MemoryWriteback;
