LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY audioState IS
   PORT(
        clk             : IN  STD_LOGIC;
        latched         : IN  STD_LOGIC;
        waveGenDone     : IN  STD_LOGIC;
        
        channel         : OUT integer range 0 to 15 := 0;
        waveHold        : OUT STD_LOGIC;
        clearTotals     : OUT STD_LOGIC;
        addTotals       : OUT STD_LOGIC;
        latchTotals     : OUT STD_LOGIC;
        
        loadStart       : OUT STD_LOGIC;
        loadDone        : IN  STD_LOGIC;
        saveStart       : OUT STD_LOGIC;
        saveDone        : IN  STD_LOGIC
        );
END audioState;

ARCHITECTURE behavior OF audioState IS

type state_type is (state_init,
                    state_load_start,
                    state_load_wait,
                    state_main_gen_start,
                    state_main_gen_wait,
                    state_main_gen_process,
                    state_save_start,
                    state_save_wait,
                    state_channel_done,
                    state_all_done);
                        
type channelSelect_action is (channelSelect_zero,
                              channelSelect_keep,
                              channelSelect_inc);
                              
SIGNAl step             : state_type := state_init;
SIGNAl next_step        : state_type := state_init;

SIGNAL channelSelect    : integer range 0 to 15;

SIGNAL next_loadStart       : STD_LOGIC;
SIGNAl next_saveStart       : STD_LOGIC;

SIGNAL next_waveHold        : STD_LOGIC;
SIGNAL next_clearTotals     : STD_LOGIC;
SIGNAL next_addTotals       : STD_LOGIC;
SIGNAL next_latchTotals     : STD_LOGIC;
SIGNAL next_channelSelect   : integer range 0 to 15 := 0;
SIGNAL lastLatched          : STD_LOGIC := '0';

--TODO: additional processing step for volume math pilelining?

BEGIN
    PROCESS(clk,channelSelect,step,loadDone,waveGenDone,saveDone,latched,lastLatched)
        VARIABLE next_channelSelect_action : channelSelect_action;
        VARIABLE final_channel : STD_LOGIC;
    BEGIN
        IF channelSelect = 15 THEN
            final_channel := '1';
        ELSE
            final_channel := '0';
        END IF;
    
        CASE step IS
            WHEN state_init => 
                next_waveHold <= '1';
                next_clearTotals <= '1';
                next_addTotals <= '0';
                next_loadStart <= '0';
                next_saveStart <= '0';
                next_latchTotals <= '0';
                
                next_channelSelect_action := channelSelect_zero;
                
                next_step <= state_load_start;
                
            WHEN state_load_start => 
                next_waveHold <= '1';
                next_clearTotals <= '0';
                next_addTotals <= '0';
                next_loadStart <= '1';
                next_saveStart <= '0';
                next_latchTotals <= '0';
                
                next_channelSelect_action := channelSelect_keep;
                
                next_step <= state_load_wait;
                
            WHEN state_load_wait => 
                next_waveHold <= '1';
                next_clearTotals <= '0';
                next_addTotals <= '0';
                next_loadStart <= '1';
                next_saveStart <= '0';
                next_latchTotals <= '0';
                
                next_channelSelect_action := channelSelect_keep;
                
                IF loadDone THEN
                    next_step <= state_main_gen_start;
                ELSE
                    next_step <= state_load_wait;
                END IF;
                
            WHEN state_main_gen_start => 
                next_clearTotals <= '0';
                next_addTotals <= '0';
                next_waveHold <= '0';
                next_loadStart <= '0';
                next_saveStart <= '0';
                next_latchTotals <= '0';
                
                next_channelSelect_action := channelSelect_keep;
                
                next_step <= state_main_gen_wait;
                
            WHEN state_main_gen_wait => 
                next_clearTotals <= '0';
                next_addTotals <= '0';
                next_waveHold <= '0';
                next_loadStart <= '0';
                next_saveStart <= '0';
                next_latchTotals <= '0';
                
                next_channelSelect_action := channelSelect_keep;
                
                IF waveGenDone THEN
                    next_step <= state_main_gen_process;
                ELSE
                    next_step <= state_main_gen_wait;
                END IF;
                
            WHEN state_main_gen_process => 
                next_waveHold <= '0';
                next_clearTotals <= '0';
                next_addTotals <= '1';
                next_loadStart <= '0';
                next_saveStart <= '0';
                next_latchTotals <= '0';
                
                next_channelSelect_action := channelSelect_keep;
                
                next_step <= state_save_start;
                
            WHEN state_save_start => 
                next_waveHold <= '0';
                next_clearTotals <= '0';
                next_addTotals <= '0';
                next_loadStart <= '0';
                next_saveStart <= '1';
                next_latchTotals <= '0';
                
                next_channelSelect_action := channelSelect_keep;
                
                next_step <= state_save_wait;
                
            WHEN state_save_wait => 
                next_waveHold <= '0';
                next_clearTotals <= '0';
                next_addTotals <= '0';
                next_loadStart <= '0';
                next_saveStart <= '1';
                next_latchTotals <= '0';
                
                next_channelSelect_action := channelSelect_keep;
                
                IF saveDone THEN
                    next_step <= state_channel_done;
                ELSE
                    next_step <= state_save_wait;
                END IF;
                
            WHEN state_channel_done => 
                next_waveHold <= '1';
                next_clearTotals <= '0';
                next_addTotals <= '0';
                next_loadStart <= '0';
                next_saveStart <= '0';
                next_latchTotals <= '0';
                
                next_channelSelect_action := channelSelect_inc;
                
                IF final_channel THEN
                    next_step <= state_all_done;
                ELSE
                    next_step <= state_load_start;
                END IF;
                
            WHEN state_all_done => 
                next_waveHold <= '1';
                next_clearTotals <= '0';
                next_addTotals <= '0';
                next_loadStart <= '0';
                next_saveStart <= '0';
                next_latchTotals <= '1';
                
                next_channelSelect_action := channelSelect_zero;
                
                IF latched AND NOT lastLatched THEN
                    next_step <= state_init;
                ELSE
                    next_step <= state_all_done;
                END IF;
                
            --WHEN others =>
            --    next_waveHold <= '1';
            --    next_clearTotals <= '0';
            --    next_addTotals <= '0';
            --    next_loadStart <= '0';
            --    next_saveStart <= '0';
            --    next_latchTotals <= '0';
                
            --    next_channelSelect_action := channelSelect_zero;
                
            --    next_step <= state_all_done;
        END CASE;
         
        CASE next_channelSelect_action IS
            WHEN channelSelect_zero =>
                next_channelSelect <= 0;
            WHEN channelSelect_keep =>
                next_channelSelect <= channelSelect;
            WHEN channelSelect_inc =>
                next_channelSelect <= channelSelect + 1;
            --WHEN OTHERS =>
            --    next_channelSelect <= 0;
        END CASE;
        
        IF RISING_EDGE(CLK) THEN
            lastLatched         <= latched;
            channelSelect       <= next_channelSelect;
            waveHold            <= next_waveHold;
            clearTotals         <= next_clearTotals;
            addTotals           <= next_addTotals;
            latchTotals         <= next_latchTotals;
            loadStart           <= next_loadStart;
            saveStart           <= next_saveStart;
            
            step                <= next_step;
        END IF;
    END PROCESS;
    
    channel <= channelSelect;
    
END behavior;