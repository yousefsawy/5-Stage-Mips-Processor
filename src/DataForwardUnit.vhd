LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DataForwardUnit IS
	PORT (
		-- CURRENT ADDRESSES IN THE EXECUTE --
		Rsrc1Addr       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rsrc1Data       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rsrc2Addr       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rsrc2Data       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- ADDRESSES PERVIOUSLY IN EXECUTION STAGE --
		Rdst1Addr_MEM   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rdst1Data_MEM   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		WB1_MEM         : IN  STD_LOGIC;
		Rdst2Addr_MEM   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rdst2Data_MEM   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		WB2_MEM         : IN  STD_LOGIC;
		-- ADDRESSES PERVIOUSLY IN MEMORY STAGE --
		Rdst1Addr_WB    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rdst1Data_WB    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		WB1_WB          : IN  STD_LOGIC;
		Rdst2Addr_WB    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rdst2Data_WB    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		WB2_WB          : IN  STD_LOGIC;
		-- DATA TO BE USED IN THE EXECUTION STAGE --
		Rsrc1_FinalData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rsrc2_FinalData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END DataForwardUnit;

ARCHITECTURE a_DataForwardUnit OF DataForwardUnit IS
	BEGIN
		------------------------ DATA FORWARDING FOR REGISTER SOURCE 1 ------------------------
		Rsrc1_FinalData <= Rdst1Data_MEM WHEN (Rsrc1Addr = Rdst1Addr_MEM and WB1_MEM = '1')
		ELSE		   Rdst2Data_MEM WHEN (Rsrc1Addr = Rdst2Addr_MEM and WB2_MEM = '1')
		ELSE		   Rdst1Data_WB  WHEN (Rsrc1Addr = Rdst1Addr_WB  and WB1_WB  = '1')
		ELSE		   Rdst2Data_WB  WHEN (Rsrc1Addr = Rdst2Addr_WB  and WB2_WB  = '1')
		ELSE		   Rsrc1Data;
		---------------------------------------------------------------------------------------
		------------------------ DATA FORWARDING FOR REGISTER SOURCE 2 ------------------------
		Rsrc2_FinalData <= Rdst1Data_MEM WHEN (Rsrc2Addr = Rdst1Addr_MEM and WB1_MEM = '1')
		ELSE               Rdst2Data_MEM WHEN (Rsrc2Addr = Rdst2Addr_MEM and WB2_MEM = '1')
		ELSE               Rdst1Data_WB  WHEN (Rsrc2Addr = Rdst1Addr_WB  and WB1_WB  = '1')
		ELSE               Rdst2Data_WB  WHEN (Rsrc2Addr = Rdst2Addr_WB  and WB2_WB  = '1')
		ELSE               Rsrc2Data;
		---------------------------------------------------------------------------------------
END ARCHITECTURE;
