LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY InstrCache IS
	PORT (
		CLK          : IN  STD_LOGIC;
		Addr         : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		ResetAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		IntptAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ExcptAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    		Instruction  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    	);
END InstrCache;

ARCHITECTURE a_InstrCache OF InstrCache IS

	TYPE ic_type IS ARRAY(0 TO 4095) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    	SIGNAL instructioncache : ic_type;

	BEGIN
		ExcptAddress <= instructioncache(1001) & instructioncache(1000); 
		IntptAddress <= instructioncache(3) & instructioncache(2);
		ResetAddress <= instructioncache(1) & instructioncache(0);
		PROCESS (CLK)
		BEGIN
			Instruction <= instructioncache(to_integer(unsigned(Addr)));
		END PROCESS;
END a_InstrCache;
