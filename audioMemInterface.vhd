LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY audioMemInterface IS
    PORT(
        CLK25            : IN  STD_LOGIC;
        CLK100           : IN  STD_LOGIC;
        
        loadStart        : IN  STD_LOGIC;
        loadDone         : OUT STD_LOGIC;
        saveStart        : IN  STD_LOGIC;
        saveDone         : OUT STD_LOGIC;
        
        AddressOut       : OUT integer range 0 to 31;
        DataIn           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        DataOut          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        WriteStrobe      : OUT STD_LOGIC;
        
        Gate             : OUT STD_LOGIC;
        ADSREnable       : OUT STD_LOGIC;
        DurationEnable   : OUT STD_LOGIC;
        WaveSel          : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        Duration         : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
        AttackVal        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        DecayVal         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        SustainVal       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ReleaseVal       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        Frequency        : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
        WaveShape        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        FMEnable         : OUT STD_LOGIC;
        AMEnable         : OUT STD_LOGIC;
        WMEnable         : OUT STD_LOGIC;
        SyncEnable       : OUT STD_LOGIC;
        InvSyncEnable    : OUT STD_LOGIC;
        FMAmplitude      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        AMAmplitude      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        WMAmplitude      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        LeftVolume       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        RightVolume      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ADSRState        : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        DurRemain        : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
        ADSRCounter      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Phase            : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
        
        endGateIn        : IN  STD_LOGIC;
        newADSRStateIn   : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        newDurRemainIn   : IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
        newADSRCounterIn : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        newPhaseIn       : IN  STD_LOGIC_VECTOR(23 DOWNTO 0);
        
        priorRaw         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        newRaw           : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        ChannelIn        : IN  integer range 0 to 15;
        
        RAW_VALUE_ADDRESS_OUT   : OUT integer range 0 to 31;
        RAW_VALUE_DATA_IN       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        RAW_VALUE_DATA_OUT      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        RAW_VALUE_WRITE_OUT     : OUT STD_LOGIC;
        
        FMChanRaw        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        AMChanRaw        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        WMChanRaw        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        notePlaying      : IN  STD_LOGIC;
        syncOut          : OUT STD_LOGIC
        
        --debug            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
END audioMemInterface;

ARCHITECTURE behavior OF audioMemInterface IS

type state_type is (state_idle,
                    state_load_1,
                    state_load_2,
                    state_load_3,
                    state_load_done,
                    state_save_endgate_1,
                    state_save_endgate_2,
                    state_prep_for_save,
                    state_save_1,
                    state_save_2,
                    state_save_3,
                    state_save_done
                    );
                    
                    
type rawAddrMux_action is (rawAddrMux_zero,
                           rawAddrMux_keep,
                           rawAddrMux_inc);
             
type address_action is (address_zero,
                        address_load,
                        address_keep,
                        address_inc);
        
SIGNAl step                 : state_type := state_idle;
SIGNAl next_step            : state_type := state_idle;

SIGNAl address              : integer range 0 to 31 := 0;
SIGNAl next_address         : integer range 0 to 31 := 0;

SIGNAL rawAddrMux           : integer range 0 to 7;
SIGNAL next_rawAddrMux      : integer range 0 to 7;

SIGNAl readStrobe           : STD_LOGIC;

SIGNAL next_readStrobe      : STD_LOGIC;
SIGNAL next_writeStrobe     : STD_LOGIC;
SIGNAL next_loadDone        : STD_LOGIC;
SIGNAL next_saveDone        : STD_LOGIC;

SIGNAl readRaw0             : STD_LOGIC;
SIGNAl readRaw1             : STD_LOGIC;
SIGNAl readRaw2             : STD_LOGIC;
SIGNAl readRaw3             : STD_LOGIC;
SIGNAl readRaw4             : STD_LOGIC;
SIGNAl readRaw5             : STD_LOGIC;
SIGNAl readRaw6             : STD_LOGIC;
SIGNAl readRaw7             : STD_LOGIC;

SIGNAl read0                : STD_LOGIC;
SIGNAl read1                : STD_LOGIC;
SIGNAl read2                : STD_LOGIC;
SIGNAl read3                : STD_LOGIC;
SIGNAl read4                : STD_LOGIC;
SIGNAl read5                : STD_LOGIC;
SIGNAl read6                : STD_LOGIC;
SIGNAl read7                : STD_LOGIC;
SIGNAl read8                : STD_LOGIC;
SIGNAl read9                : STD_LOGIC;
SIGNAl read10               : STD_LOGIC;
SIGNAl read11               : STD_LOGIC;
SIGNAl read12               : STD_LOGIC;
SIGNAl read13               : STD_LOGIC;
SIGNAl read14               : STD_LOGIC;
SIGNAl read15               : STD_LOGIC;
SIGNAl read16               : STD_LOGIC;
SIGNAl read17               : STD_LOGIC;
SIGNAl read18               : STD_LOGIC;
SIGNAl read19               : STD_LOGIC;
SIGNAl read20               : STD_LOGIC;
SIGNAl read21               : STD_LOGIC;
SIGNAl read22               : STD_LOGIC;
SIGNAl read23               : STD_LOGIC;
SIGNAl read24               : STD_LOGIC;
SIGNAl read25               : STD_LOGIC;
SIGNAl read26               : STD_LOGIC;
SIGNAl read27               : STD_LOGIC;
SIGNAl read28               : STD_LOGIC;
SIGNAl read29               : STD_LOGIC;
SIGNAl read30               : STD_LOGIC;
SIGNAl read31               : STD_LOGIC;

SIGNAl FMChanSel            : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAl AMChanSel            : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAl WMChanSel            : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAl SyncChanSel          : STD_LOGIC_VECTOR(3 DOWNTO 0);
        
TYPE runFlagMem IS ARRAY (0 TO 15) OF STD_LOGIC;
SIGNAL channelRun : runFlagMem;
    
SIGNAL endGate              : STD_LOGIC;
SIGNAL newADSRState         : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL newDurRemain         : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL newADSRCounter       : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL newPhase             : STD_LOGIC_VECTOR(23 DOWNTO 0);
        
BEGIN
    
    --synchronize inputs to clock
    PROCESS(CLK25)
    BEGIN
        IF RISING_EDGE(CLK25) THEN
            endGate <= endGateIn;
            newADSRState <= newADSRStateIn;
            newDurRemain <= newDurRemainIn;
            newADSRCounter <= newADSRCounterIn;
            newPhase <= newPhaseIn;
        END IF;
    END PROCESS;
    
    --save the note playing flag
    PROCESS(CLK25)
    BEGIN
        IF RISING_EDGE(CLK25) THEN
            IF saveStart = '1' THEN
                channelRun(ChannelIn) <= notePlaying;
            END IF;
        END IF;
    END PROCESS;
    
    --load/save state engine
    PROCESS(CLK100,loadStart,saveStart,endGate,address,step,rawAddrMux)
        VARIABLE next_rawAddrMux_action : rawAddrMux_action;
        VARIABLE next_address_action    : address_action;
        VARIABLE readWriteDone          : STD_LOGIC;
    BEGIN
        IF address = 31 THEN
            readWriteDone := '1';
        ELSE
            readWriteDone := '0';
        END IF;
    
        CASE step IS
            WHEN state_idle => 
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_zero;
                next_rawAddrMux_action := rawAddrMux_zero;
                
                IF loadStart THEN
                    next_step <= state_load_1;
                ELSIF saveStart THEN
                    IF endGate THEN
                        next_step <= state_save_endgate_1;
                    ELSE
                        next_step <= state_prep_for_save;
                    END IF;
                ELSE
                    next_step <= state_idle;
                END IF;
                
            WHEN state_load_1 => 
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_keep;
                next_rawAddrMux_action := rawAddrMux_keep;
                
                --debug(2 downto 0) <= "001";
                
                next_step <= state_load_2;
                
            WHEN state_load_2 => 
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '1';
                
                next_address_action := address_keep;
                next_rawAddrMux_action := rawAddrMux_keep;
                
                --debug(2 downto 0) <= "010";
                
                next_step <= state_load_3;
                
            WHEN state_load_3 => 
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_inc;
                next_rawAddrMux_action := rawAddrMux_inc;
                
                --debug(2 downto 0) <= "011";
                
                IF readWriteDone THEN
                    next_step <= state_load_done;
                ELSE
                    next_step <= state_load_1;
                END IF;
                
            WHEN state_load_done => 
                next_loadDone <= '1';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_keep;
                next_rawAddrMux_action := rawAddrMux_keep;
                
                --debug(2 downto 0) <= "100";
                
                IF loadStart THEN
                    next_step <= state_load_done;
                ELSE
                    next_step <= state_idle;
                END IF;
                
            WHEN state_save_endgate_1 =>
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_zero;
                next_rawAddrMux_action := rawAddrMux_zero;
                
                --debug(2 downto 0) <= "101";
                
                next_step <= state_save_endgate_2;
                
            WHEN state_save_endgate_2 => 
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '1';
                next_readStrobe <= '0';
                
                next_address_action := address_zero;
                next_rawAddrMux_action := rawAddrMux_zero;
                
                --debug(2 downto 0) <= "101";
                
                next_step <= state_prep_for_save;
                
            WHEN state_prep_for_save => 
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_load;
                next_rawAddrMux_action := rawAddrMux_zero;
                
                --debug(2 downto 0) <= "110";
                
                next_step <= state_save_1;
                
            WHEN state_save_1 => 
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_keep;
                next_rawAddrMux_action := rawAddrMux_keep;
                
                --debug(2 downto 0) <= "101";
                
                next_step <= state_save_2;
                
            WHEN state_save_2 => 
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '1';
                next_readStrobe <= '0';
                
                next_address_action := address_keep;
                next_rawAddrMux_action := rawAddrMux_keep;
                
                --debug(2 downto 0) <= "101";
                
                next_step <= state_save_3;
                
            WHEN state_save_3 => 
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_inc;
                next_rawAddrMux_action := rawAddrMux_inc;
                
                --debug(2 downto 0) <= "110";
                
                IF readWriteDone THEN
                    next_step <= state_save_done;
                ELSE
                    next_step <= state_save_1;
                END IF;
                
            WHEN state_save_done => 
                next_loadDone <= '0';
                next_saveDone <= '1';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_keep;
                next_rawAddrMux_action := rawAddrMux_keep;
                
                --debug(2 downto 0) <= "111";
                
                IF saveStart = '1' THEN
                    next_step <= state_save_done;
                ELSE
                    next_step <= state_idle;
                END IF;
                
            WHEN OTHERS =>
                next_loadDone <= '0';
                next_saveDone <= '0';
                next_writeStrobe <= '0';
                next_readStrobe <= '0';
                
                next_address_action := address_zero;
                next_rawAddrMux_action := rawAddrMux_zero;
                
                --debug(2 downto 0) <= "000";
                
                next_step <= state_idle;
        END CASE;
        
        CASE next_rawAddrMux_action IS
            WHEN rawAddrMux_zero =>
                next_rawAddrMux <= 0;
            WHEN rawAddrMux_keep =>
                next_rawAddrMux <= rawAddrMux;
            WHEN rawAddrMux_inc =>
                next_rawAddrMux <= rawAddrMux+1;
            WHEN OTHERS =>
                next_rawAddrMux <= 0;
        END CASE;
        
        CASE next_address_action IS
            WHEN address_zero =>
                next_address <= 0;
            WHEN address_load =>
                next_address <= 23;
            WHEN address_keep =>
                next_address <= address;
            WHEN address_inc =>
                next_address <= address+1;
            WHEN OTHERS =>
                next_address <= 0;
        END CASE;
        
        IF RISING_EDGE(CLK100) THEN
            step                <= next_step;
            address             <= next_address;
            WriteStrobe         <= next_writeStrobe;
            loadDone            <= next_loadDone;
            saveDone            <= next_saveDone;
            readStrobe          <= next_readStrobe;
            rawAddrMux          <= next_rawAddrMux;
            
            IF next_rawAddrMux = 0 or next_rawAddrMux = 1 THEN
                RAW_VALUE_WRITE_OUT <= next_writeStrobe;
            ELSE
                RAW_VALUE_WRITE_OUT <= '0';
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(rawAddrMux,FMChanSel,AMChanSel,WMChanSel,ChannelIn)
        VARIABLE chanID : STD_LOGIC_VECTOR(3 downto 0);
    BEGIN
        chanID := STD_LOGIC_VECTOR(to_unsigned(ChannelIn,4));
        
        --lookup for prior raw and cross-channel modulation values
        CASE rawAddrMux IS
            WHEN 0 =>
                RAW_VALUE_ADDRESS_OUT <= to_integer(unsigned(chanID & '0'));
            WHEN 1 =>
                RAW_VALUE_ADDRESS_OUT <= to_integer(unsigned(chanID & '1'));
            WHEN 2 =>
                RAW_VALUE_ADDRESS_OUT <= to_integer(unsigned(FMChanSel & '0'));
            WHEN 3 =>
                RAW_VALUE_ADDRESS_OUT <= to_integer(unsigned(FMChanSel & '1'));
            WHEN 4 =>
                RAW_VALUE_ADDRESS_OUT <= to_integer(unsigned(AMChanSel & '0'));
            WHEN 5 =>
                RAW_VALUE_ADDRESS_OUT <= to_integer(unsigned(AMChanSel & '1'));
            WHEN 6 =>
                RAW_VALUE_ADDRESS_OUT <= to_integer(unsigned(WMChanSel & '0'));
            WHEN 7 =>
                RAW_VALUE_ADDRESS_OUT <= to_integer(unsigned(WMChanSel & '1'));
            WHEN OTHERS =>
                RAW_VALUE_ADDRESS_OUT <= 0;
        END CASE;
    END PROCESS;
    
    --debug(3) <= readStrobe;
    
    PROCESS(readStrobe,rawAddrMux)
    BEGIN
        IF rawAddrMux = 0 THEN
            readRaw0 <= readStrobe;
        ELSE
            readRaw0 <= '0';
        END IF;
        
        IF rawAddrMux = 1 THEN
            readRaw1 <= readStrobe;
        ELSE
            readRaw1 <= '0';
        END IF;
        
        IF rawAddrMux = 2 THEN
            readRaw2 <= readStrobe;
        ELSE
            readRaw2 <= '0';
        END IF;
        
        IF rawAddrMux = 3 THEN
            readRaw3 <= readStrobe;
        ELSE
            readRaw3 <= '0';
        END IF;
        
        IF rawAddrMux = 4 THEN
            readRaw4 <= readStrobe;
        ELSE
            readRaw4 <= '0';
        END IF;
        
        IF rawAddrMux = 5 THEN
            readRaw5 <= readStrobe;
        ELSE
            readRaw5 <= '0';
        END IF;
        
        IF rawAddrMux = 6 THEN
            readRaw6 <= readStrobe;
        ELSE
            readRaw6 <= '0';
        END IF;
        
        IF rawAddrMux = 7 THEN
            readRaw7 <= readStrobe;
        ELSE
            readRaw7 <= '0';
        END IF;
    END PROCESS;
    
    PROCESS(readStrobe,address)
    BEGIN
        IF address = 0 THEN
            read0 <= readStrobe;
        ELSE
            read0 <= '0';
        END IF;
        
        IF address = 1 THEN
            read1 <= readStrobe;
        ELSE
            read1 <= '0';
        END IF;
        
        IF address = 2 THEN
            read2 <= readStrobe;
        ELSE
            read2 <= '0';
        END IF;
        
        IF address = 3 THEN
            read3 <= readStrobe;
        ELSE
            read3 <= '0';
        END IF;
        
        IF address = 4 THEN
            read4 <= readStrobe;
        ELSE
            read4 <= '0';
        END IF;
        
        IF address = 5 THEN
            read5 <= readStrobe;
        ELSE
            read5 <= '0';
        END IF;
        
        IF address = 6 THEN
            read6 <= readStrobe;
        ELSE
            read6 <= '0';
        END IF;
        
        IF address = 7 THEN
            read7 <= readStrobe;
        ELSE
            read7 <= '0';
        END IF;
        
        IF address = 8 THEN
            read8 <= readStrobe;
        ELSE
            read8 <= '0';
        END IF;
        
        IF address = 9 THEN
            read9 <= readStrobe;
        ELSE
            read9 <= '0';
        END IF;
        
        IF address = 10 THEN
            read10 <= readStrobe;
        ELSE
            read10 <= '0';
        END IF;
        
        IF address = 11 THEN
            read11 <= readStrobe;
        ELSE
            read11 <= '0';
        END IF;
        
        IF address = 12 THEN
            read12 <= readStrobe;
        ELSE
            read12 <= '0';
        END IF;
        
        IF address = 13 THEN
            read13 <= readStrobe;
        ELSE
            read13 <= '0';
        END IF;
        
        IF address = 14 THEN
            read14 <= readStrobe;
        ELSE
            read14 <= '0';
        END IF;
        
        IF address = 15 THEN
            read15 <= readStrobe;
        ELSE
            read15 <= '0';
        END IF;
        
        IF address = 16 THEN
            read16 <= readStrobe;
        ELSE
            read16 <= '0';
        END IF;
        
        IF address = 17 THEN
            read17 <= readStrobe;
        ELSE
            read17 <= '0';
        END IF;
        
        IF address = 18 THEN
            read18 <= readStrobe;
        ELSE
            read18 <= '0';
        END IF;
        
        IF address = 19 THEN
            read19 <= readStrobe;
        ELSE
            read19 <= '0';
        END IF;
            
        IF address = 20 THEN
            read20 <= readStrobe;
        ELSE
            read20 <= '0';
        END IF;
        
        IF address = 21 THEN
            read21 <= readStrobe;
        ELSE
            read21 <= '0';
        END IF;
        
        IF address = 22 THEN
            read22 <= readStrobe;
        ELSE
            read22 <= '0';
        END IF;
        
        IF address = 23 THEN
            read23 <= readStrobe;
        ELSE
            read23 <= '0';
        END IF;
        
        IF address = 24 THEN
            read24 <= readStrobe;
        ELSE
            read24 <= '0';
        END IF;
        
        IF address = 25 THEN
            read25 <= readStrobe;
        ELSE
            read25 <= '0';
        END IF;
        
        IF address = 26 THEN
            read26 <= readStrobe;
        ELSE
            read26 <= '0';
        END IF;
        
        IF address = 27 THEN
            read27 <= readStrobe;
        ELSE
            read27 <= '0';
        END IF;
        
        IF address = 28 THEN
            read28 <= readStrobe;
        ELSE
            read28 <= '0';
        END IF;
        
        IF address = 29 THEN
            read29 <= readStrobe;
        ELSE
            read29 <= '0';
        END IF;
            
        IF address = 30 THEN
            read30 <= readStrobe;
        ELSE
            read30 <= '0';
        END IF;
        
        IF address = 31 THEN
            read31 <= readStrobe;
        ELSE
            read31 <= '0';
        END IF;
    END PROCESS;
    
    PROCESS(CLK100,RAW_VALUE_DATA_IN)
    BEGIN
        --read data steering for prior raw and cross-channel raw values
        
        IF RISING_EDGE(CLK100) THEN
            IF readRaw0 = '1' THEN
                priorRaw(15 downto 8)       <= RAW_VALUE_DATA_IN; 
            END IF;
        
            IF readRaw1 = '1' THEN
                priorRaw(7 downto 0)        <= RAW_VALUE_DATA_IN; 
            END IF;
        
            IF readRaw2 = '1' THEN
                FMChanRaw(15 downto 8)      <= RAW_VALUE_DATA_IN; 
            END IF;
        
            IF readRaw3 = '1' THEN
                FMChanRaw(7 downto 0)       <= RAW_VALUE_DATA_IN; 
            END IF;
        
            IF readRaw4 = '1' THEN
                AMChanRaw(15 downto 8)      <= RAW_VALUE_DATA_IN; 
            END IF;
        
            IF readRaw5 = '1' THEN
                AMChanRaw(7 downto 0)       <= RAW_VALUE_DATA_IN; 
            END IF;
        
            IF readRaw6 = '1' THEN
                WMChanRaw(15 downto 8)      <= RAW_VALUE_DATA_IN; 
            END IF;
        
            IF readRaw7 = '1' THEN
                WMChanRaw(7 downto 0)       <= RAW_VALUE_DATA_IN; 
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(ALL)
    BEGIN
        --read data steering
        
        IF RISING_EDGE(CLK100) THEN
            --Byte 0:	    Control byte
            IF read0 = '1' THEN
                Gate                        <= DataIn(0);
                ADSREnable                  <= DataIn(1);
                DurationEnable              <= DataIn(2);
                WaveSel                     <= DataIn(5 downto 3);
            END IF;
        
            --Byte 1:	    Duration high byte
            IF read1 = '1' THEN
                Duration(23 downto 16)      <= DataIn;
            END IF;
        
            --Byte 2:       Duration mid byte
            IF read2 = '1' THEN
                Duration(15 downto 8)       <= DataIn;
            END IF;
        
            --Byte 3:       Duration low byte
            IF read3 = '1' THEN
                Duration(7 downto 0)        <= DataIn;
            END IF;
        
            --Byte 4:       Attack
            IF read4 = '1' THEN
                AttackVal                   <= DataIn;
            END IF;
        
            --Byte 5:	    Decay
            IF read5 = '1' THEN
                DecayVal                    <= DataIn;
            END IF;
        
            --Byte 6:	    Sustain
            IF read6 = '1' THEN
                SustainVal                  <= DataIn;
            END IF;
        
            --Byte 7:	    Release
            IF read7 = '1' THEN
                ReleaseVal                  <= DataIn;
            END IF;
        
            --Byte 8:	    Frequency high byte
            IF read8 = '1' THEN
                Frequency(23 downto 16)     <= DataIn;
            END IF;
        
            --Byte 9:	    Frequency mid byte
            IF read9 = '1' THEN
                Frequency(15 downto 8)      <= DataIn;
            END IF;
            
            --Byte 10:	    Frequency low byte
            IF read10 = '1' THEN
                Frequency(7 downto 0)       <= DataIn;
            END IF;
        
            --Byte 11:	    Wave shaper
            IF read11 = '1' THEN
                WaveShape                   <= DataIn;
            END IF;
        
            --Byte 12:	    Cross-channel function enable bits
            IF read12 = '1' THEN
                FMEnable                    <= DataIn(0);
                AMEnable                    <= DataIn(1);
                WMEnable                    <= DataIn(2);
                SyncEnable                  <= DataIn(3);
                InvSyncEnable               <= DataIn(4);
            END IF;
        
            --Byte 13:	    Cross channel function source select 1
            IF read13 = '1' THEN
                FMChanSel                   <= DataIn(3 downto 0);
                AMChanSel                   <= DataIn(7 downto 4);
            END IF;
        
            --Byte 14:	    Cross channel function source select 2
            IF read14 = '1' THEN
                WMChanSel                   <= DataIn(3 downto 0);
                SyncChanSel                 <= DataIn(7 downto 4);
            END IF;
        
            --Byte 15:	    FM amplitude high byte
            IF read15 = '1' THEN
                FMAmplitude(15 downto 8)    <= DataIn;
            END IF;
        
            --Byte 16:	    FM amplitude low byte
            IF read16 = '1' THEN
                FMAmplitude(7 downto 0)     <= DataIn;
            END IF;
        
            --Byte 17:	    AM amplitude high byte
            IF read17 = '1' THEN
                AMAmplitude(15 downto 8)    <= DataIn;
            END IF;
        
            --Byte 18:	    AM amplitude low byte
            IF read18 = '1' THEN
                AMAmplitude(7 downto 0)     <= DataIn;
            END IF;
        
            --Byte 19:	    WM amplitude high byte
            IF read19 = '1' THEN
                WMAmplitude(15 downto 8)    <= DataIn;
            END IF;
            
            --Byte 20:	    WM amplitude low byte
            IF read20 = '1' THEN
                WMAmplitude(7 downto 0)     <= DataIn;
            END IF;
        
            --Byte 21:	    Left volume
            IF read21 = '1' THEN
                LeftVolume                  <= DataIn;
            END IF;
        
            --Byte 22:	    Right volume
            IF read22 = '1' THEN
                RightVolume                 <= DataIn;
            END IF;
        
            --Byte 23:	    ADSR mode 
            IF read23 = '1' THEN
                ADSRState                   <= DataIn(4 downto 0);
            END IF;
        
            --Byte 24:	    Duration remaining high byte 
            IF read24 = '1' THEN
                DurRemain(23 downto 16)     <= DataIn;
            END IF;
        
            --Byte 25:	    Duration remaining mid byte 
            IF read25 = '1' THEN
                DurRemain(15 downto 8)      <= DataIn;
            END IF;
        
            --Byte 26:	    Duration remaining low byte 
            IF read26 = '1' THEN
                DurRemain(7 downto 0)       <= DataIn;
            END IF;
        
            --Byte 27:	    ADSR counter high byte 
            IF read27 = '1' THEN
                ADSRCounter(15 downto 8)    <= DataIn;
            END IF;
        
            --Byte 28:	    ADSR counter low byte 
            IF read28 = '1' THEN
                ADSRCounter(7 downto 0)     <= DataIn;
            END IF;
        
            --Byte 29:	    Phase register high byte 
            IF read29 = '1' THEN
                Phase(23 downto 16)         <= DataIn;
            END IF;
            
            --Byte 30:	    Phase register mid byte 
            IF read30 = '1' THEN
                Phase(15 downto 8)          <= DataIn;
            END IF;
        
            --Byte 31:	    Phase register low byte 
            IF read31 = '1' THEN
                Phase(7 downto 0)           <= DataIn;
            END IF;
        END IF;
            
        --IF RISING_EDGE(CLK) THEN
            --write data steering
            CASE address is
                WHEN 0 => --Byte 0:	control mode with gate = 0
                    DataOut <= "00" & WaveSel & DurationEnable & ADSREnable & "0";        
                WHEN 23 => --Byte 23:	ADSR mode 
                    DataOut <= "000" & newADSRState;
                WHEN 24 => --Byte 24:	Duration remaining high byte 
                    DataOut <= newDurRemain(23 downto 16);
                WHEN 25 => --Byte 25:	Duration remaining mid byte 
                    DataOut <= newDurRemain(15 downto 8);
                WHEN 26 => --Byte 26:	Duration remaining low byte 
                    DataOut <= newDurRemain(7 downto 0);
                WHEN 27 => --Byte 27:	ADSR counter high byte 
                    DataOut <= newADSRCounter(15 downto 8);
                WHEN 28 => --Byte 28:	ADSR counter low byte 
                    DataOut <= newADSRCounter(7 downto 0);
                WHEN 29 => --Byte 29:	Phase register high byte 
                    DataOut <= newPhase(23 downto 16);
                WHEN 30 => --Byte 30:	Phase register mid byte 
                    DataOut <= newPhase(15 downto 8);
                WHEN 31 => --Byte 31:	Phase register low byte 
                    DataOut <= newPhase(7 downto 0);
                WHEN OTHERS =>
                    DataOut <= "00000000";
            END CASE;
        --END IF;
        
        --IF RISING_EDGE(CLK) THEN
            --raw value data steering
            CASE rawAddrMux IS
                WHEN 0 =>
                    RAW_VALUE_DATA_OUT <= newRaw(15 downto 8);
                WHEN 1 =>
                    RAW_VALUE_DATA_OUT <= newRaw(7 downto 0);
                WHEN OTHERS =>
                    RAW_VALUE_DATA_OUT <= "00000000";
            END CASE;
        --END IF;
        
    END PROCESS;
    
    --output for cross-channel sync
    syncOut <= channelRun(to_integer(unsigned(SyncChanSel)));
    
    AddressOut <= address;
    
END behavior;