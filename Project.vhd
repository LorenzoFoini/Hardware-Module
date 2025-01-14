-- FOINI LORENZO
-- PROVA FINALE RETI LOGICHE A.A. 2023/2024

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- top project entity 
entity project_reti_logiche is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);
        
        o_done  : out std_logic;
        
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we   : out std_logic;
        o_mem_en   : out std_logic
    );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is
    -- Declare an instance of fsm
    component fsm is
        port(
            fsm_i_clk      : in std_logic;
            fsm_i_rst      : in std_logic;
            fsm_i_start    : in std_logic;
            fsm_i_add      : in std_logic_vector(15 downto 0);
            fsm_i_k        : in std_logic_vector(9 downto 0);
            fsm_i_mem_data : in std_logic_vector(7 downto 0);
            
            fsm_o_done     : out std_logic;
            fsm_o_mem_addr : out std_logic_vector(15 downto 0);
            fsm_o_mem_data : out std_logic_vector(7 downto 0);
            fsm_o_mem_we   : out std_logic;
            fsm_o_mem_en   : out std_logic
        );
    end component fsm;

begin
    -- Instantiate fsm => Port map
    fsm_instance : fsm
    port map (fsm_i_clk => i_clk,
              fsm_i_rst => i_rst,
              fsm_i_start => i_start,
              fsm_i_add => i_add,
              fsm_i_k => i_k,
              fsm_i_mem_data => i_mem_data,
              fsm_o_done => o_done,
              fsm_o_mem_addr => o_mem_addr,
              fsm_o_mem_data => o_mem_data,
              fsm_o_mem_we => o_mem_we,
              fsm_o_mem_en => o_mem_en
    );
end project_reti_logiche_arch;


-- fsm entity: MOORE fsm
-- It is responsible for setting the signals and handles all steps in the processing of the input and output sequence

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    port(
        fsm_i_clk      : in std_logic;
        fsm_i_rst      : in std_logic;
        fsm_i_start    : in std_logic;
        fsm_i_add      : in std_logic_vector(15 downto 0);
        fsm_i_k        : in std_logic_vector(9 downto 0);
        fsm_i_mem_data : in std_logic_vector(7 downto 0);
        
        fsm_o_done     : out std_logic;
        fsm_o_mem_addr : out std_logic_vector(15 downto 0);
        fsm_o_mem_data : out std_logic_vector(7 downto 0);
        fsm_o_mem_we   : out std_logic;
        fsm_o_mem_en   : out std_logic
    );
end fsm;

architecture fsm_arch of fsm is
    -- List of fsm's possibile states
    type state_type is (INITIAL, CHECK_ELABORATION, READ_VALUE_MEM, CHECK_VALUE_MEM, WRITE_VALUE_MEM,
                        WRITE_CREDIBILITY_MEM, INCREASE_ADDRESS, FINISH_ELABORATION);
    
    -- Signal representing fsm's current state
    signal CURRENT_STATE: state_type;
           
begin
    -- Process for managing the progress of fsm's current state
    -- It also change the value of the variable and signals
    process(fsm_i_clk, fsm_i_rst) -- Asynchronous reset, synchronous clock
    variable last_value  : std_logic_vector (7 downto 0); -- Variable to save the last valid value read from memory
    variable credibility : std_logic_vector (7 downto 0); -- Variable to save the credibility value
    variable curr_addr   : std_logic_vector(15 downto 0); -- Variable representing the current address
    variable done        : std_logic; -- Variable representing if the elaboration is finish or not
    
    begin
        if fsm_i_rst = '1' then -- Asynchronous reset
            -- Inizialise the signals
            fsm_o_mem_addr <= (others => '0');
            fsm_o_mem_data <= (others => '0');
            fsm_o_mem_we   <= '0';
            fsm_o_mem_en   <= '0';
            fsm_o_done     <= '0';
            
            -- Inizialise the variables
            -- curr_addr will be inizialise in the next state 
            last_value  := (others => '0'); -- Last value is set to 0
            credibility := (others => '0'); -- Credibility level is set to 0
            done        := '0'; -- Set done to 0
            
            -- Fsm's current state
            CURRENT_STATE <= INITIAL;
            
        elsif (fsm_i_clk'event and fsm_i_clk = '1') then -- Clock rising edge
            case CURRENT_STATE is
                when INITIAL =>
                    if fsm_i_start = '1' then
                        -- Inizialise curr_addr variable to the initial address, which is fsm_i_add
                        curr_addr := fsm_i_add;
                                                
                        -- Next state
                        CURRENT_STATE <= CHECK_ELABORATION;
                    end if;
                    
                when CHECK_ELABORATION =>
                    -- Check if the elaboration is finished or not
                    -- If finished => Set done to 1 and finish elaboration
                    -- If not finished => Change the value of the signals responsible for reading from memory
                    
                    if fsm_i_k = "0000000000" or unsigned(curr_addr) > (unsigned(fsm_i_add) + 2 * (unsigned(fsm_i_k) - 1))  then
                        -- k is 0 or current address is not valid => Set done and fsm_o_done to 1
                        done := '1';
                        fsm_o_done <= '1';
                        
                        -- Next state
                        CURRENT_STATE <= FINISH_ELABORATION;
                    else
                        -- Current address is valid => Change the value of signals for reading from memory
                        fsm_o_mem_addr <= curr_addr;
                        fsm_o_mem_en   <= '1';
                        
                        -- Next state
                        CURRENT_STATE <= READ_VALUE_MEM;
                    end if;
                        
                when READ_VALUE_MEM =>
                    -- Reading the value for the memory at curr_addr
                    
                    -- Next state
                    CURRENT_STATE <= CHECK_VALUE_MEM;
                 
                when CHECK_VALUE_MEM =>
                    -- Check the value return by memory
                    -- If the value is valid => Modify the values of variables last_value and credibility 
                    -- if the value is not valid => Modify the value of variable credibility, if necessary 
                    
                    if fsm_i_mem_data /= "00000000" then
                        -- Value is valid <=> NOT 0
                        last_value  := fsm_i_mem_data;
                        credibility := "00011111"; -- 31
                    elsif credibility /= "00000000" then
                        -- Value not valid and crebility not equals 0
                        credibility := std_logic_vector(unsigned(credibility) - 1);
                    end if;
                                        
                    -- Change the value of signals for writing last valid value in memory
                    -- Changes of signals are visible in the next clock rising edge
                    fsm_o_mem_data <= last_value;
                    fsm_o_mem_we   <= '1';

                    -- Next state
                    CURRENT_STATE <= WRITE_VALUE_MEM;
                                    
                when WRITE_VALUE_MEM =>
                    -- At start of this state: Writing last valid value in memory
                    -- Increment current address
                    curr_addr := std_logic_vector(unsigned(curr_addr) + 1);

                    -- Change the value of signals for writing credibility in memory
                    -- Changes of signals are visible in the next clock rising edge
                    fsm_o_mem_addr <= curr_addr;
                    fsm_o_mem_data <= credibility;

                    -- Next state
                    CURRENT_STATE <= WRITE_CREDIBILITY_MEM;
                                            
                when WRITE_CREDIBILITY_MEM =>
                    -- At start of this state: Writing credibility level in memory
                    -- Change the values of the signals => Do not read from memory
                    -- Changes of signals are visible in the next clock rising edge
                    fsm_o_mem_en   <= '0';
                    fsm_o_mem_we   <= '0';
                    
                    -- Next state
                    CURRENT_STATE <= INCREASE_ADDRESS;
                                                
                when INCREASE_ADDRESS =>
                    -- Increment current address
                    curr_addr := std_logic_vector(unsigned(curr_addr) + 1);
                    
                    -- Next state
                    CURRENT_STATE <= CHECK_ELABORATION;
                                                        
                when FINISH_ELABORATION =>
                    -- if start = 0 then I can set done and fsm_o_done to 0
                    if fsm_i_start = '0' then
                        -- Change of the signal is visible in the next clock rising edge
                        done := '0';
                        fsm_o_done <= '0';

                        -- Reset the signals for the next elaboration
                        -- ATTENTION: fsm_o_mem_en and fsm_o_mem_we already 0
                        fsm_o_mem_addr <= (others => '0');
                        fsm_o_mem_data <= (others => '0');
    
                        -- Reset the variables for the next elaboration
                        last_value  := (others => '0');
                        credibility := (others => '0');
                    
                        -- Next state
                        CURRENT_STATE <= INITIAL;
                    end if;                    
            end case;
        end if;
    end process;
end fsm_arch;