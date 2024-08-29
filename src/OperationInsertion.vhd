LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY OperationInsertion IS
	PORT(
		CLK            : IN  STD_LOGIC;
		RST            : IN  STD_LOGIC;
		INT            : IN  STD_LOGIC;
		PC             : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC_PAUSER      : OUT STD_LOGIC;
		BUFFER_ALLOWER : OUT STD_LOGIC;
		Op             : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		PCo            : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END OperationInsertion;

ARCHITECTURE a_OperationInsertion OF OperationInsertion IS

	-- Define states for the finite state machine
        TYPE state_type IS (IDLE, INT_PC, INT_CCR);
        SIGNAL state: state_type;

	BEGIN

		STATE_CALCULATOR: PROCESS (CLK, RST)
		BEGIN
			IF (RST = '1') THEN
				state <= IDLE;
			ELSIF RISING_EDGE(CLK) THEN
				CASE state IS
					WHEN IDLE =>
						IF (INT = '1') THEN
							state <= INT_PC;
						END IF;
					WHEN INT_PC =>
						state <= INT_CCR;
					WHEN INT_CCR =>
						state <= IDLE;
				END CASE;
			END IF;
		END PROCESS STATE_CALCULATOR;

		STATE_OUTPUT: PROCESS (state)
		BEGIN
			CASE state IS
				WHEN IDLE =>
					PC_PAUSER      <= '0';
					BUFFER_ALLOWER <= '0';
					PCo            <= (OTHERS => '0');
					Op             <= (OTHERS => '0');
				WHEN INT_PC =>
					PC_PAUSER      <= '1';
					BUFFER_ALLOWER <= '1';
					PCo            <= std_logic_vector(unsigned(PC) + 1);
					Op             <= "1110100000000000";
				WHEN INT_CCR =>
					PC_PAUSER      <= '0';
					BUFFER_ALLOWER <= '1';
					PCo            <= (OTHERS => '0');
					Op             <= "1111000000000000";
			END CASE;
		END PROCESS STATE_OUTPUT;

END a_OperationInsertion;






