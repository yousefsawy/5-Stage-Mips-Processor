LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY memor IS
	PORT (
		CLK       : IN  STD_LOGIC;
	    	RST       : IN  STD_LOGIC;
		Addr      : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
    		-- READ --
    		MemRead   : IN  STD_LOGIC;
    		ReadData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    		-- WRITE --
    		MemWrite  : IN  STD_LOGIC;
    		WriteData : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- PROTECT AND FREE --
		free_i    : IN  STD_LOGIC;
		prot_i    : IN  STD_LOGIC;
		-- RAISE EXCEPTION --
		EXCEP     : OUT STD_LOGIC
    	);
END memor;

ARCHITECTURE a_memor OF memor IS

	-- (15 DOWNTO 0) data bits
	-- (16) enable for specific address (PROTECT, FREE)
	-- PROTECTED == 1 (prevent write if equals 1)
	-- FREE == 0 (enable write operations if equal 0)
	TYPE dm_type IS ARRAY(0 TO 4095) OF STD_LOGIC_VECTOR(16 DOWNTO 0);
    	SIGNAL datamemory : dm_type;

	BEGIN
		PROCESS (CLK, RST)
        	BEGIN
    	        	IF (RST = '1') THEN
    		        	datamemory <= ((OTHERS => (OTHERS => '0'))); -- CLEAR THE MEMORY
				ReadData <= (OTHERS => '0');		     -- OUTPUT ZEROS
				EXCEP <= '0';				     -- REMOVE ANY EXCEPTIONS
    		        ELSIF RISING_EDGE(CLK) THEN
				-- CHECK FREE / PROTECTED FLAGS --
				IF (free_i = '1') THEN
					EXCEP <= '0';
					-- REMOVE PROTECTION AND CLEAR CONTENT --
					datamemory(to_integer(unsigned(Addr))) <= (OTHERS => '0');
				ELSIF (prot_i = '1') THEN
					EXCEP <= '0';
					-- SET AS PROTECTED --
					datamemory(to_integer(unsigned(Addr)))(16) <= '1';
				END IF;
				-- CHECK READ ENABLE --
    		        	IF (memRead = '1') THEN
					EXCEP <= '0';
					-- LITTLE ENDIAN READING (GREAT ADDRESS DATA) & (LOWER ADDRESS DATA) --
    			                ReadData <= datamemory(to_integer(unsigned(Addr)+1))(15 DOWNTO 0)
						    & datamemory(to_integer(unsigned(Addr)))(15 DOWNTO 0);
				ELSE
					EXCEP <= '0';
					-- OUTPUT THE INPUT DATA --
					ReadData <= WriteData;
    		  	        END IF;
				-- CHECK WRITE ENABLE --
    		            	IF (memWrite = '1') THEN
					-- CHECK IF PROTECTED --
					IF (datamemory(to_integer(unsigned(Addr)))(16) = '0') THEN
						EXCEP <= '0';
						-- LITTLE ENDIAN WRITING (MOST SIGNIFICANT IN THE GREATER ADDRESS) --
						--                   AND (LEAST SIGNIFICANT IN THE LOWER ADDRESS)  --
    		               			datamemory(to_integer(unsigned(Addr)))  (15 DOWNTO 0) <= WriteData(15 DOWNTO 0);
						datamemory(to_integer(unsigned(Addr)+1))(15 DOWNTO 0) <= WriteData(31 DOWNTO 16);
					ELSE
						-- IF PROTECTED AND WANTS TO WRITE, RAISE EXCEPTION --
						EXCEP <= '1';
					END IF;
    		            	END IF;
    		        END IF;
    	    	END PROCESS;  
END a_memor;
