LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY StalledForwardUnit IS
	PORT (
		-- IS STALLED?
		STALLED            : IN  STD_LOGIC;
		-- CURRENT ADDRESSES IN THE EXECUTE --
		Rsrc1Addr_DE       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rsrc2Addr_DE       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- ADDRESSES_WRITEBACK --
		Rdst1Addr_WB       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		Rdst2Addr_WB       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- ADDRESSES DEPENDENCIES --
		Rdst1WB_WB         : IN  STD_LOGIC;
		Rdst2WB_WB         : IN  STD_LOGIC;
		-- TAKE WHO
		FORCE_UPDATE_Rsrc1 : OUT STD_LOGIC;
		FORCE_UPDATE_Rsrc2 : OUT STD_LOGIC
	);
END StalledForwardUnit;


ARCHITECTURE a_StalledForwardUnit OF StalledForwardUnit IS

	SIGNAL IS_SAME_Rsrc1_Rdst1 : STD_LOGIC;
	SIGNAL IS_SAME_Rsrc1_Rdst2 : STD_LOGIC;
	SIGNAL IS_SAME_Rsrc2_Rdst1 : STD_LOGIC;
	SIGNAL IS_SAME_Rsrc2_Rdst2 : STD_LOGIC;

	BEGIN
		IS_SAME_Rsrc1_Rdst1 <= '1' WHEN ((Rsrc1Addr_DE = Rdst1Addr_WB) and (Rdst1WB_WB = '1') and (STALLED = '1')) ELSE '0';
		IS_SAME_Rsrc1_Rdst2 <= '1' WHEN ((Rsrc1Addr_DE = Rdst2Addr_WB) and (Rdst2WB_WB = '1') and (STALLED = '1')) ELSE '0';
		IS_SAME_Rsrc2_Rdst1 <= '1' WHEN ((Rsrc2Addr_DE = Rdst1Addr_WB) and (Rdst1WB_WB = '1') and (STALLED = '1')) ELSE '0';
		IS_SAME_Rsrc2_Rdst2 <= '1' WHEN ((Rsrc2Addr_DE = Rdst2Addr_WB) and (Rdst2WB_WB = '1') and (STALLED = '1')) ELSE '0';

		FORCE_UPDATE_Rsrc1 <= IS_SAME_Rsrc1_Rdst1 or IS_SAME_Rsrc1_Rdst2;
		FORCE_UPDATE_Rsrc2 <= IS_SAME_Rsrc2_Rdst1 or IS_SAME_Rsrc2_Rdst2;

END ARCHITECTURE;