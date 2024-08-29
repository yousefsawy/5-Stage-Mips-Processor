library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BranchPredictor is
    Port (
        clk : in STD_LOGIC;
        branch_taken : in STD_LOGIC;
        prev_miss : in std_logic;
        is_jump : in STD_LOGIC;
	true_branch_value : in STD_LOGIC; 		--if equal to branch taken then correct prediction else misprediction
        pc_current : in STD_LOGIC_VECTOR (31 downto 0);
        branch_target : in STD_LOGIC_VECTOR (31 downto 0);
	prev2_dest_reg : in STD_LOGIC_VECTOR (2 downto 0);
        prev_dest_reg : in STD_LOGIC_VECTOR (2 downto 0);
        curr_src_reg : in STD_LOGIC_VECTOR (2 downto 0);
        prediction : out STD_LOGIC;
        mispredict : out STD_LOGIC;
        ist_taken  : out std_logic;
        PC_OUT : OUT STD_LOGIC_VECTOR (31 downto 0);
        PC_old : OUT STD_LOGIC_VECTOR (31 downto 0)
    );
end BranchPredictor;

architecture Behavioral of BranchPredictor is
    signal last_branch : STD_LOGIC := '0';  -- Last branch result
    signal internal_mispredict : STD_LOGIC; 
begin
    mispredict <= prev_miss;
    prediction <= branch_taken;
    process(clk, is_jump, true_branch_value, branch_taken)
    begin
        if rising_edge(clk) then
            -- Check if current instruction is a jump and not dependent
            if is_jump = '1' and prev_dest_reg /= curr_src_reg and prev2_dest_reg /= curr_src_reg then
                -- Output prediction
                prediction <= last_branch;
                internal_mispredict <= not (true_branch_value xor branch_taken);
                -- Output misprediction
                mispredict <= internal_mispredict;
                -- Update PC if misprediction occurred
                if true_branch_value = '1' then
		    if branch_taken = '1' then
                        PC_OUT <= pc_current ;  -- Branch was taken, update PC to old pc
                        mispredict <= '0';
                    else
                        PC_OUT <= branch_target ;  -- Branch was not taken, update PC to next instruction
                        mispredict <= '1';
                    end if;
                end if;
                ist_taken <= last_branch;
	        end if;
        else
            -- If not a jump instruction or is dependent, maintain the state of the signals
            PC_OUT <= branch_target;
	    PC_OLD <= pc_current;
        end if;
    end process;
end Behavioral;


