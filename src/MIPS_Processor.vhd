LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-------------------------------------------------------------------------------------------------
ENTITY MIPS_Processor IS
	PORT (
		CLK     : IN  STD_LOGIC;
		RST     : IN  STD_LOGIC;
		INT     : IN  STD_LOGIC;
		INPORT  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		OUTPORT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R0      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R1      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R2      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R3      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R4      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R5      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R6      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		R7      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		FLAGS   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		EXCP    : OUT STD_LOGIC
	);
END MIPS_Processor;
-------------------------------------------------------------------------------------------------

ARCHITECTURE a_MIPS_Processor OF MIPS_Processor IS
	---------------------------------------- FETCH COMPONENTS ---------------------------------------
	COMPONENT PCount IS
		PORT (
			CLK      : IN  STD_LOGIC;
			RST      : IN  STD_LOGIC;
			ResetVal : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			INT      : IN  STD_LOGIC;
			IntptVal : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			EXCP     : IN  STD_LOGIC;
			EXCPVal  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			PAUSE    : IN  STD_LOGIC;
			JUMP     : IN  STD_LOGIC;
			JMPVAL   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			RET      : IN  STD_LOGIC;
			RETVAL   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			BRKPROT  : IN  STD_LOGIC;
			NewValue : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			Outdata  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT InstrCache IS
		PORT (
			CLK          : IN  STD_LOGIC;
			Addr         : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
			ResetAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			IntptAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ExcptAddress : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    			Instruction  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT OperationInsertion IS
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
	END COMPONENT;
	-------------------------------------------------------------------------------------------------
	----------------------------------- FETCH / DECODE COMPONENTS -----------------------------------
	COMPONENT FetchDecode IS
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
	END COMPONENT;
	-------------------------------------------------------------------------------------------------
	--------------------------------------- DECODE COMPONENTS ---------------------------------------
	COMPONENT registerfile IS
		PORT (
			CLK       : IN  STD_LOGIC;
			RST       : IN  STD_LOGIC;
			Rsrc1     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc2     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc1Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rsrc2Data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			WE1       : IN  STD_LOGIC;
			Rdst1     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			RdstData1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			WE2       : IN  STD_LOGIC;
			Rdst2     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			RdstData2 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			R0        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R1        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R2        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R3        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R4        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R5        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R6        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			R7        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT ControlUnit IS
		PORT (
			INSTRUCTION     : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
			CONTROL_SIGNALS : OUT STD_LOGIC_VECTOR(22 DOWNTO 0);
			ALU_OPCODE      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT SignExtender IS
		PORT (
			input_16  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        	   	output_32 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	-------------------------------------------------------------------------------------------------
	---------------------------------- DECODE / EXECUTE COMPONENTS ----------------------------------
	COMPONENT DecodeExecute IS
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
	END COMPONENT;
	-------------------------------------------------------------------------------------------------
	--------------------------------------- EXECUTE COMPONENTS --------------------------------------
	COMPONENT OurALU IS
		PORT (
			OPERATION : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			OP1, OP2 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			RESULT :    OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			FLAGS :     OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT CCR IS
		PORT (
			CLK     : IN  STD_LOGIC;
			RST     : IN  STD_LOGIC;
			ZNF     : IN  STD_LOGIC;
			OVCF    : IN  STD_LOGIC;
			FlagIn  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			FlagOut : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	-------------------------------------------------------------------------------------------------
	---------------------------------- EXECUTE / MEMORY COMPONENTS ----------------------------------
	COMPONENT ExecuteMemory IS
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
	END COMPONENT;
	-------------------------------------------------------------------------------------------------
	--------------------------------------- MEMORY COMPONENTS ---------------------------------------
	COMPONENT StackPointer IS
		PORT (
			CLK       : IN  STD_LOGIC;
			RST       : IN  STD_LOGIC;
			SP_INC    : IN  STD_LOGIC;
			SP_DEC    : IN  STD_LOGIC;
			SP_OUTPUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT memor IS
		PORT (
			CLK       : IN  STD_LOGIC;
	    		RST       : IN  STD_LOGIC;
			Addr      : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
    			MemRead   : IN  STD_LOGIC;
    			ReadData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    			MemWrite  : IN  STD_LOGIC;
    			WriteData : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			free_i    : IN  STD_LOGIC;
			prot_i    : IN  STD_LOGIC;
			EXCEP     : OUT STD_LOGIC
	    	);
	END COMPONENT;
	-------------------------------------------------------------------------------------------------
	--------------------------------- MEMORY / WRITEBACK COMPONENTS ---------------------------------
	COMPONENT MemoryWriteback IS
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
	END COMPONENT;
	-------------------------------------------------------------------------------------------------
	-------------------------------------- WRITEBACK COMPONENTS -------------------------------------
	COMPONENT OutReg IS
		PORT (
			CLK        : IN  STD_LOGIC;
			RST        : IN  STD_LOGIC;
			OutEnable  : IN  STD_LOGIC;
			Data_IN    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutputPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	-------------------------------------------------------------------------------------------------
	------------------------------------ OUT OF BUFFER COMPONENTS -----------------------------------
	COMPONENT JumpForwardUnit IS
		PORT (
			Rsrc_IN_E        : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst_IN_WB       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			ZF_IN_WB         : IN  STD_LOGIC;
			MR_IN_WB         : IN  STD_LOGIC;
			ENABLE_BRANCHING : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT DataForwardUnit IS
		PORT (
			Rsrc1Addr       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc1Data       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rsrc2Addr       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc2Data       : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rdst1Addr_MEM   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst1Data_MEM   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB1_MEM         : IN  STD_LOGIC;
			Rdst2Addr_MEM   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst2Data_MEM   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB2_MEM         : IN  STD_LOGIC;
			Rdst1Addr_WB    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst1Data_WB    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB1_WB          : IN  STD_LOGIC;
			Rdst2Addr_WB    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst2Data_WB    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			WB2_WB          : IN  STD_LOGIC;
			Rsrc1_FinalData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			Rsrc2_FinalData : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT MemUseUnit IS
		PORT (
			Rsrc1Addr         : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc2Addr         : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst1Addr_MEM     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			MEM_READ          : IN  STD_LOGIC;
			FIRST_DEPENDENCY  : IN  STD_LOGIC;
		    	SECOND_DEPENDENCY : IN  STD_LOGIC;
			STALL             : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT StalledForwardUnit IS
		PORT (
			STALLED            : IN  STD_LOGIC;
			Rsrc1Addr_DE       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rsrc2Addr_DE       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst1Addr_WB       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst2Addr_WB       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			Rdst1WB_WB         : IN  STD_LOGIC;
			Rdst2WB_WB         : IN  STD_LOGIC;
			FORCE_UPDATE_Rsrc1 : OUT STD_LOGIC;
			FORCE_UPDATE_Rsrc2 : OUT STD_LOGIC
		);
	END COMPONENT;
	-------------------------------------------------------------------------------------------------

	----------------------------------------- FETCH SIGNALS -----------------------------------------
	SIGNAL PC_PAUSER             : STD_LOGIC;
	SIGNAL PC                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL RESET_ADDRESS         : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL INTERRUPT_ADDRESS     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EXCEPTION_ADDRESS     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL NewPC                 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL CurrInstr_FROM_IC     : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL STOP_FETCHING_FROM_OI : STD_LOGIC;
	SIGNAL FETCH_FORCE_FROM_OI   : STD_LOGIC;
	SIGNAL OPERATION_FROM_OI     : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL PC_FROM_OI            : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	----------------------------------------- DECODE SIGNALS ----------------------------------------
	SIGNAL FETCH_DECODE_FLUSHER           : STD_LOGIC;
	SIGNAL FETCH_DECODE_PAUSER            : STD_LOGIC;
	-- F/D REGISTER OUTPUTS
	SIGNAL CurrentInstr_FROM_FDP          : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL NextPC_FROM_FDP	              : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- DIVIDE F/D VALUES
	SIGNAL Rsrc1Addr_DIV_CurrInstr        : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rsrc2Addr_DIV_CurrInstr        : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL RdstAddr_DIV_CurrInstr         : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL OpCode_DIV_CurrInstr           : STD_LOGIC_VECTOR(4 DOWNTO 0);
	-- REGISTER FILE OUTPUTS
	SIGNAL Rsrc1Data_FROM_RF              : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_RF              : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- CONTROL UNIT OUTPUTS
	SIGNAL SIGNALS_FROM_CONTROL           : STD_LOGIC_VECTOR(22 DOWNTO 0);
	SIGNAL ALUopCode_FROM_CONTROL         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- HANDLING SWAP ISSUE
	SIGNAL Rdst1Addr_FROM_MUXING          : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-- HANDLING IMMEDIATE VALUES
	SIGNAL ImmediateVal_FROM_EXTEND_ZEROS : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_EXTEND_SIGN  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_MUXING       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	----------------------------------------- EXECUTE SIGNALS ---------------------------------------
	SIGNAL DECODE_EXECUTE_FLUSHER : STD_LOGIC;
	SIGNAL DECODE_EXECUTE_PAUSER  : STD_LOGIC;
	-- D/E REGISTER OUTPUTS
	SIGNAL NextPC_FROM_DEP        : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SIGNALS_FROM_DEP       : STD_LOGIC_VECTOR(22 DOWNTO 0);
	SIGNAL ALUopCode_FROM_DEP     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Rsrc1Addr_FROM_DEP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rsrc1Data_FROM_DEP     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Addr_FROM_DEP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_DEP     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ImmediateVal_FROM_DEP  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr_FROM_DEP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr_FROM_DEP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-- ALU OUTPUTS
	SIGNAL ALUresult_FROM_ALU     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALUflag_FROM_ALU       : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- FLAGS REGISTER INPUT
	SIGNAL FLAGS_INTO_CCR         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- FLAGS REGISTER OUTPUT
	SIGNAL FLAGS_FROM_CCR         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-- HANDLING FUNCTIONS
	SIGNAL Rsrc2Data_FROM_MUXING  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_OR_IN_FROM_MUXING  : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	------------------------------------------ MEMORY SIGNALS ---------------------------------------
	SIGNAL EXECUTE_MEMORY_FLUSHER : STD_LOGIC;
	-- E/M REGISTER OUTPUTS
	SIGNAL NextPC_FROM_EMP        : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SIGNALS_FROM_EMP       : STD_LOGIC_VECTOR(22 DOWNTO 0);
	SIGNAL ALUresult_FROM_EMP     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL FLAGS_FROM_EMP         : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Rdst2Data_FROM_EMP     : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr_FROM_EMP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr_FROM_EMP     : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-- HANDLING STACK POINTER OUTPUT
	SIGNAL STACK_USE              : STD_LOGIC;
	SIGNAL SP_FROM_STACK          : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- HANDLING DATA ENTRY
	SIGNAL ADDRESS_INTO_MEMORY    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DATA_INTO_MEMORY       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- MEMORY OUTPUTS
	SIGNAL DATA_FROM_MEMORY       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL EXCEPTION_FROM_MEM     : STD_LOGIC;
	-------------------------------------------------------------------------------------------------

	----------------------------------------- WRITEBACK SIGNALS -------------------------------------
	-- M/W REGISTER OUTPUTS
	SIGNAL SIGNALS_FROM_MWP   : STD_LOGIC_VECTOR(19 DOWNTO 0);
	SIGNAL FLAGS_FROM_MWP     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL Rdst1Data_FROM_MWP : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst2Data_FROM_MWP : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rdst1Addr_FROM_MWP : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Rdst2Addr_FROM_MWP : STD_LOGIC_VECTOR(2 DOWNTO 0);
	-------------------------------------------------------------------------------------------------

	--------------------------------------- OUT OF BUFFER SIGNALS -----------------------------------
	-- STALLED FORWARD UNIT
	SIGNAL FORCE_BOTH_FROM_SFU         : STD_LOGIC;
	SIGNAL FORCE_Rsrc1_FROM_SFU        : STD_LOGIC;
	SIGNAL FORCE_Rsrc2_FROM_SFU        : STD_LOGIC;
	-- DATA FORWARD UNIT OUTPUTS
	SIGNAL Rsrc1Data_FROM_DFU          : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Rsrc2Data_FROM_DFU          : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- MEM USE UNIT OUTPUTS
	SIGNAL STALL_AND_FLUSH_FROM_MEMUSE : STD_LOGIC;
	-- JUMPING OUTPUTS
	SIGNAL JUMP_STALLED_FROM_JFU       : STD_LOGIC;
	SIGNAL CHANGE_PC_FROM_EXECUTE      : STD_LOGIC;
	SIGNAL ZERO_JUMP_FROM_MEMORY       : STD_LOGIC;
	-- EXCEPTION OUTPUT
	SIGNAL FULL_EXCEPTION              : STD_LOGIC;
	-------------------------------------------------------------------------------------------------

	BEGIN	
		------------------------------------------ FETCH STAGE ------------------------------------------
		PC_PAUSER <= STALL_AND_FLUSH_FROM_MEMUSE or STOP_FETCHING_FROM_OI;
		u00: PCount PORT MAP(CLK, RST, RESET_ADDRESS, INT, INTERRUPT_ADDRESS,
			FULL_EXCEPTION, EXCEPTION_ADDRESS, PC_PAUSER, CHANGE_PC_FROM_EXECUTE,
			Rsrc1Data_FROM_DFU, SIGNALS_FROM_EMP(21), DATA_FROM_MEMORY, '0', NewPC, PC);

		u01: InstrCache PORT MAP(CLK, PC(11 DOWNTO 0), RESET_ADDRESS, INTERRUPT_ADDRESS,
				EXCEPTION_ADDRESS, CurrInstr_FROM_IC);

		u02: OperationInsertion PORT MAP(CLK, RST, INT, PC, STOP_FETCHING_FROM_OI,
				FETCH_FORCE_FROM_OI, OPERATION_FROM_OI, PC_FROM_OI);

		NewPC <= std_logic_vector(unsigned(PC) + 1);
		-------------------------------------------------------------------------------------------------

		------------------------------------ FETCH / DECODE PIPELINE ------------------------------------
		FETCH_DECODE_FLUSHER <= CHANGE_PC_FROM_EXECUTE or SIGNALS_FROM_CONTROL(8)
					or FULL_EXCEPTION or SIGNALS_FROM_EMP(21);
		FETCH_DECODE_PAUSER  <= STALL_AND_FLUSH_FROM_MEMUSE;
		u10: FetchDecode PORT MAP(CLK, RST, FETCH_DECODE_FLUSHER, FETCH_DECODE_PAUSER,
				FETCH_FORCE_FROM_OI, OPERATION_FROM_OI, PC_FROM_OI,
				CurrInstr_FROM_IC, CurrentInstr_FROM_FDP, PC, NextPC_FROM_FDP);
		-------------------------------------------------------------------------------------------------

		------------------------------------------ DECODE STAGE -----------------------------------------
		OpCode_DIV_CurrInstr    <= CurrentInstr_FROM_FDP(15 DOWNTO 11);
		RdstAddr_DIV_CurrInstr  <= CurrentInstr_FROM_FDP(10 DOWNTO  8);
		Rsrc1Addr_DIV_CurrInstr <= CurrentInstr_FROM_FDP(7  DOWNTO  5);
		Rsrc2Addr_DIV_CurrInstr <= CurrentInstr_FROM_FDP(4  DOWNTO  2);

		u20: registerfile PORT MAP(CLK, RST, Rsrc1Addr_DIV_CurrInstr, Rsrc2Addr_DIV_CurrInstr,
					Rsrc1Data_FROM_RF, Rsrc2Data_FROM_RF,
						SIGNALS_FROM_MWP(0), Rdst1Addr_FROM_MWP, Rdst1Data_FROM_MWP,
						SIGNALS_FROM_MWP(1), Rdst2Addr_FROM_MWP, Rdst2Data_FROM_MWP,
						R0, R1, R2, R3, R4, R5, R6, R7);

		u21: ControlUnit PORT MAP(OpCode_DIV_CurrInstr, SIGNALS_FROM_CONTROL, ALUopCode_FROM_CONTROL);

		Rdst1Addr_FROM_MUXING <= RdstAddr_DIV_CurrInstr WHEN (SIGNALS_FROM_CONTROL(1) = '0')
		ELSE                     Rsrc2Addr_DIV_CurrInstr;

		u23: SignExtender PORT MAP(CurrInstr_FROM_IC, ImmediateVal_FROM_EXTEND_SIGN);
		ImmediateVal_FROM_EXTEND_ZEROS <= x"0000" & CurrInstr_FROM_IC;

		ImmediateVal_FROM_MUXING <= ImmediateVal_FROM_EXTEND_ZEROS WHEN (SIGNALS_FROM_CONTROL(17) = '1')
		ELSE                        ImmediateVal_FROM_EXTEND_SIGN;
		-------------------------------------------------------------------------------------------------

		----------------------------------- DECODE / EXECUTE PIPELINE -----------------------------------
		DECODE_EXECUTE_FLUSHER <= CHANGE_PC_FROM_EXECUTE or FULL_EXCEPTION or SIGNALS_FROM_EMP(21);
		DECODE_EXECUTE_PAUSER  <= STALL_AND_FLUSH_FROM_MEMUSE;

		u31: DecodeExecute PORT MAP(CLK, RST, DECODE_EXECUTE_FLUSHER, DECODE_EXECUTE_PAUSER,
			FORCE_BOTH_FROM_SFU, FORCE_Rsrc1_FROM_SFU, FORCE_Rsrc2_FROM_SFU,
			Rdst1Data_FROM_MWP, Rdst1Data_FROM_MWP, NextPC_FROM_FDP, NextPC_FROM_DEP,
			SIGNALS_FROM_CONTROL, SIGNALS_FROM_DEP, ALUopCode_FROM_CONTROL,
			ALUopCode_FROM_DEP, Rsrc1Addr_DIV_CurrInstr, Rsrc1Addr_FROM_DEP,
			Rsrc1Data_FROM_RF, Rsrc1Data_FROM_DEP, Rsrc2Addr_DIV_CurrInstr,
			Rsrc2Addr_FROM_DEP, Rsrc2Data_FROM_RF, Rsrc2Data_FROM_DEP,
			ImmediateVal_FROM_MUXING, ImmediateVal_FROM_DEP, Rdst1Addr_FROM_MUXING,
			Rdst1Addr_FROM_DEP, Rsrc1Addr_DIV_CurrInstr, Rdst2Addr_FROM_DEP);
		-------------------------------------------------------------------------------------------------

		----------------------------------------- EXECUTE STAGE -----------------------------------------
		Rsrc2Data_FROM_MUXING <= ImmediateVal_FROM_DEP WHEN (SIGNALS_FROM_DEP(8) = '1')
		ELSE                     Rsrc2Data_FROM_DFU;

		u40: OurALU PORT MAP(ALUopCode_FROM_DEP, Rsrc1Data_FROM_DFU,
			Rsrc2Data_FROM_MUXING, ALUresult_FROM_ALU, ALUflag_FROM_ALU);

		FLAGS_INTO_CCR <= ALUflag_FROM_ALU WHEN (SIGNALS_FROM_EMP(22) = '0')
		ELSE              DATA_FROM_MEMORY(3 DOWNTO 0);

		u41: CCR PORT MAP(CLK, RST, SIGNALS_FROM_DEP(2), SIGNALS_FROM_DEP(3),
						FLAGS_INTO_CCR, FLAGS_FROM_CCR);

		ALU_OR_IN_FROM_MUXING <= ALUresult_FROM_ALU WHEN (SIGNALS_FROM_DEP(14) = '0') ELSE INPORT;
		-------------------------------------------------------------------------------------------------
	
		----------------------------------- EXECUTE / MEMORY PIPELINE -----------------------------------
		EXECUTE_MEMORY_FLUSHER <= STALL_AND_FLUSH_FROM_MEMUSE or SIGNALS_FROM_EMP(21);
		u50: ExecuteMemory PORT MAP(CLK, RST, EXECUTE_MEMORY_FLUSHER, NextPC_FROM_DEP,
			NextPC_FROM_EMP, SIGNALS_FROM_DEP, SIGNALS_FROM_EMP, ALU_OR_IN_FROM_MUXING,
			ALUresult_FROM_EMP, FLAGS_FROM_CCR, FLAGS_FROM_EMP, Rsrc2Data_FROM_DFU,
			Rdst2Data_FROM_EMP, Rdst1Addr_FROM_DEP, Rdst1Addr_FROM_EMP,
					Rdst2Addr_FROM_DEP, Rdst2Addr_FROM_EMP);
		-------------------------------------------------------------------------------------------------

		------------------------------------------ MEMORY STAGE -----------------------------------------
		u60: StackPointer PORT MAP(CLK, RST, SIGNALS_FROM_EMP(12), SIGNALS_FROM_EMP(11), SP_FROM_STACK);

		DATA_INTO_MEMORY <= Rdst2Data_FROM_EMP WHEN (SIGNALS_FROM_EMP(15) = '1')
		ELSE                NextPC_FROM_EMP    WHEN (SIGNALS_FROM_EMP(16) = '1')
		ELSE                ALUresult_FROM_EMP WHEN (SIGNALS_FROM_EMP(20) = '0')
		ELSE                x"0000000" & FLAGS_FROM_EMP;

		STACK_USE <= SIGNALS_FROM_EMP(11) or SIGNALS_FROM_EMP(12);

		ADDRESS_INTO_MEMORY <= SP_FROM_STACK WHEN (STACK_USE = '1')
		ELSE                   ALUresult_FROM_EMP;

		u61: memor PORT MAP(CLK, RST, ADDRESS_INTO_MEMORY(11 DOWNTO 0), SIGNALS_FROM_EMP(4),
			DATA_FROM_MEMORY, SIGNALS_FROM_EMP(5), DATA_INTO_MEMORY,
			SIGNALS_FROM_EMP(6), SIGNALS_FROM_EMP(7), EXCEPTION_FROM_MEM);
		-------------------------------------------------------------------------------------------------

		---------------------------------- MEMORY / WRITEBACK PIPELINE ----------------------------------
		u70: MemoryWriteback PORT MAP(CLK, RST, SIGNALS_FROM_EMP(19 DOWNTO 0), SIGNALS_FROM_MWP,
			FLAGS_FROM_EMP, FLAGS_FROM_MWP, DATA_FROM_MEMORY, Rdst1Data_FROM_MWP,
			Rdst2Data_FROM_EMP, Rdst2Data_FROM_MWP, Rdst1Addr_FROM_EMP,
			Rdst1Addr_FROM_MWP, Rdst2Addr_FROM_EMP, Rdst2Addr_FROM_MWP);
		-------------------------------------------------------------------------------------------------

		----------------------------------------- WRITEBACK STAGE ---------------------------------------
		u80: OutReg PORT MAP(CLK, RST, SIGNALS_FROM_MWP(13), Rdst1Data_FROM_MWP, OUTPORT);
		-------------------------------------------------------------------------------------------------

		-------------------------------------- OUT OF BUFFER UNITS --------------------------------------
		-------------------------------- HANDLING JUMPS --------------------------------
		u90: JumpForwardUnit PORT MAP(Rsrc1Addr_FROM_DEP, Rdst1Addr_FROM_MWP,
			FLAGS_FROM_MWP(0), SIGNALS_FROM_MWP(4), JUMP_STALLED_FROM_JFU);

		ZERO_JUMP_FROM_MEMORY <= SIGNALS_FROM_DEP(10) and FLAGS_FROM_EMP(0);
		CHANGE_PC_FROM_EXECUTE <= (ZERO_JUMP_FROM_MEMORY or SIGNALS_FROM_DEP(9)
			or JUMP_STALLED_FROM_JFU) and (not STALL_AND_FLUSH_FROM_MEMUSE);
		--------------------------------------------------------------------------------
		------------------------------- DATA FORWARD UNIT ------------------------------
		u91: DataForwardUnit PORT MAP(Rsrc1Addr_FROM_DEP, Rsrc1Data_FROM_DEP, Rsrc2Addr_FROM_DEP,
			Rsrc2Data_FROM_DEP, Rdst1Addr_FROM_EMP, ALUresult_FROM_EMP, SIGNALS_FROM_EMP(0),
                        Rdst2Addr_FROM_EMP, Rdst2Data_FROM_EMP, SIGNALS_FROM_EMP(1), Rdst1Addr_FROM_MWP,
			Rdst1Data_FROM_MWP, SIGNALS_FROM_MWP(0), Rdst2Addr_FROM_MWP, Rdst2Data_FROM_MWP,
			SIGNALS_FROM_MWP(1), Rsrc1Data_FROM_DFU, Rsrc2Data_FROM_DFU);
		--------------------------------------------------------------------------------
		-------------------------------- MEMORY USE UNIT -------------------------------
		u92: MemUseUnit PORT MAP(Rsrc1Addr_FROM_DEP, Rsrc2Addr_FROM_DEP,
			Rdst1Addr_FROM_EMP, SIGNALS_FROM_EMP(4), SIGNALS_FROM_DEP(18),
				SIGNALS_FROM_DEP(19), STALL_AND_FLUSH_FROM_MEMUSE);
		--------------------------------------------------------------------------------
		----------------------------- STALLED FORWARD UNIT -----------------------------
		u93: StalledForwardUnit PORT MAP(STALL_AND_FLUSH_FROM_MEMUSE, Rsrc1Addr_FROM_DEP,
			Rsrc2Addr_FROM_DEP, Rdst1Addr_FROM_MWP, Rdst2Addr_FROM_MWP,
			SIGNALS_FROM_MWP(0), SIGNALS_FROM_MWP(1), FORCE_Rsrc1_FROM_SFU,
						FORCE_Rsrc2_FROM_SFU);
		FORCE_BOTH_FROM_SFU <= FORCE_Rsrc1_FROM_SFU AND FORCE_Rsrc2_FROM_SFU;
		--------------------------------------------------------------------------------
		----------------------------------- EXCEPTION ----------------------------------
		FULL_EXCEPTION <= EXCEPTION_FROM_MEM OR FLAGS_FROM_CCR(3);
		--------------------------------------------------------------------------------
		-------------------------------- SYSTEM OUTPUTS --------------------------------
		EXCP <= FULL_EXCEPTION; FLAGS <= FLAGS_FROM_CCR;
		--------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------------

END a_MIPS_Processor;