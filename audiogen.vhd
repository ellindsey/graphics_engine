LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY audiogen IS
   PORT(
        CLK25                   : IN  STD_LOGIC;
        CLK100                  : IN  STD_LOGIC;
        MCLK                    : IN  STD_LOGIC;
        
        AUDIO_DAT_ADDRESS_OUT   : OUT integer range 0 to 511;
        AUDIO_DAT_DATA_IN       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        AUDIO_DAT_DATA_OUT      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        AUDIO_DAT_WRITE_OUT     : OUT STD_LOGIC;
        
        RNG16                   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        SINE_TABLE_ADDRESS_OUT  : OUT integer range 0 to 255;
        SINE_TABLE_DATA_IN      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        INV_TABLE_ADDRESS_OUT   : OUT integer range 0 to 255;
        INV_TABLE_DATA_IN       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        SAMPLE_TABLE_ADDRESS_OUT: OUT integer range 0 to 1023;
        SAMPLE_TABLE_DATA_IN    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        RAW_VALUE_ADDRESS_OUT   : OUT integer range 0 to 31;
        RAW_VALUE_DATA_IN       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        RAW_VALUE_DATA_OUT      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        RAW_VALUE_WRITE_OUT     : OUT STD_LOGIC;
        
        --CPU_ADDR                : IN  integer range 0 to 31;
        --CPU_RDATA               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        masterVolumeIn          : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        loadOkPulse             : OUT STD_LOGIC;
        
        sclk                    : OUT STD_LOGIC;
        lrclk                   : OUT STD_LOGIC;
        sdata                   : OUT STD_LOGIC;
        
        debug                   : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
        );
END audiogen;

ARCHITECTURE behavior OF audiogen IS

COMPONENT i2s IS
   PORT(
        clk         : IN  STD_LOGIC;
        
        rdata       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        ldata       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        sclk        : OUT STD_LOGIC;
        lrclk       : OUT STD_LOGIC;
        sdata       : OUT STD_LOGIC;
        
        latched     : OUT STD_LOGIC
        );
END COMPONENT i2s;

COMPONENT waveGen IS
   PORT(
        clk                     : IN  STD_LOGIC;
        hold                    : IN  STD_LOGIC;
        done                    : OUT STD_LOGIC;
        
        phase                   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        wavesel                 : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        shaper                  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        priorHighBit            : IN  STD_LOGIC;
        random                  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        valueIn                 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        valueOut                : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        SINE_TABLE_ADDRESS_OUT  : OUT integer range 0 to 255;
        SINE_TABLE_DATA_IN      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        INV_TABLE_ADDRESS_OUT   : OUT integer range 0 to 255;
        INV_TABLE_DATA_IN       : IN  STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END COMPONENT waveGen;

COMPONENT audioADSR IS
   PORT(
        CLK              : IN STD_LOGIC;
        Gate             : IN STD_LOGIC;
        DurationEnable   : IN STD_LOGIC;
        ADSREnable       : IN STD_LOGIC;
        Duration         : IN UNSIGNED(23 DOWNTO 0);
        DurRemain        : IN UNSIGNED(23 DOWNTO 0);
        AttackVal        : IN UNSIGNED(7 DOWNTO 0);
        DecayVal         : IN UNSIGNED(7 DOWNTO 0);
        SustainVal       : IN UNSIGNED(7 DOWNTO 0);
        ReleaseVal       : IN UNSIGNED(7 DOWNTO 0);
        ADSRState        : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        ADSRCounter      : IN UNSIGNED(15 DOWNTO 0);
        
        notePlayingOut   : OUT STD_LOGIC;
        newADSRStateOut  : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        newADSRCounterOut: OUT UNSIGNED(15 DOWNTO 0);
        newDurRemainOut  : OUT UNSIGNED(23 DOWNTO 0);
        endGateOut       : OUT STD_LOGIC
        );
END COMPONENT audioADSR;

COMPONENT audioVolMath IS
   PORT(
        CLK             : IN  STD_LOGIC;
        RawValue        : IN  SIGNED(15 DOWNTO 0);
        Envelope        : IN  UNSIGNED(15 DOWNTO 0);
        AMvalue         : IN  UNSIGNED(15 DOWNTO 0);
        MasterVolume    : IN  UNSIGNED(7 DOWNTO 0);
        LeftVolume      : IN  UNSIGNED(7 DOWNTO 0);
        RightVolume     : IN  UNSIGNED(7 DOWNTO 0);
        
        LeftOut         : OUT SIGNED(15 DOWNTO 0);
        RightOut        : OUT SIGNED(15 DOWNTO 0)
        );
END COMPONENT audioVolMath;

COMPONENT audioMod IS
   PORT(
        FMChanRaw       : IN  SIGNED(15 DOWNTO 0);
        AMChanRaw       : IN  SIGNED(15 DOWNTO 0);
        WMChanRaw       : IN  SIGNED(15 DOWNTO 0);
        
        FMamplitude     : IN  UNSIGNED(15 DOWNTO 0);
        AMamplitude     : IN  UNSIGNED(15 DOWNTO 0);
        WMamplitude     : IN  UNSIGNED(15 DOWNTO 0);
        
        AMEnable        : IN  STD_LOGIC;
        FMEnable        : IN  STD_LOGIC;
        WMEnable        : IN  STD_LOGIC;
        
        FMvalue         : OUT SIGNED(23 DOWNTO 0);
        AMvalue         : OUT UNSIGNED(15 DOWNTO 0);
        WMvalue         : OUT SIGNED(7 DOWNTO 0)
        );
END COMPONENT audioMod;

COMPONENT audioState IS
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
END COMPONENT audioState;

COMPONENT audioSum IS
   PORT(
        clk     : IN  STD_LOGIC;
        clear   : IN  STD_LOGIC;
        add     : IN  STD_LOGIC;
        
        audio   : IN  SIGNED(15 DOWNTO 0);
        total   : OUT SIGNED(15 DOWNTO 0)
        );
END COMPONENT audioSum;

COMPONENT audioMemInterface
   PORT(
        CLK25                   : IN  STD_LOGIC;
        CLK100                  : IN  STD_LOGIC;
        
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
END COMPONENT audioMemInterface;
    
SIGNAL latched              : STD_LOGIC;

SIGNAL channelSelect        : integer range 0 to 15;
SIGNAl addressInChannel     : integer range 0 to 31;

SIGNAL Rtotal               : SIGNED (15 downto 0);
SIGNAL Ltotal               : SIGNED (15 downto 0);

SIGNAL RtotalLatchedOut     : SIGNED (15 downto 0);
SIGNAL LtotalLatchedOut     : SIGNED (15 downto 0);

SIGNAL masterVolume         : STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL GateIn             : STD_LOGIC;
SIGNAL ADSREnableIn       : STD_LOGIC;
SIGNAL DurationEnableIn   : STD_LOGIC;
SIGNAL WaveSelIn          : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL DurationIn         : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL AttackValIn        : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL DecayValIn         : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL SustainValIn       : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ReleaseValIn       : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL FrequencyIn        : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL WaveShapeIn        : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL FMEnableIn         : STD_LOGIC;
SIGNAL AMEnableIn         : STD_LOGIC;
SIGNAL WMEnableIn         : STD_LOGIC;
SIGNAL SyncEnableIn       : STD_LOGIC;
SIGNAL InvSyncEnableIn    : STD_LOGIC;
SIGNAL FMAmplitudeIn      : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL AMAmplitudeIn      : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL WMAmplitudeIn      : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL LeftVolumeIn       : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL RightVolumeIn      : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ADSRStateIn        : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL DurRemainIn        : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL ADSRCounterIn      : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL PhaseIn            : STD_LOGIC_VECTOR(23 DOWNTO 0);

SIGNAL Gate             : STD_LOGIC;
SIGNAL ADSREnable       : STD_LOGIC;
SIGNAL DurationEnable   : STD_LOGIC;
SIGNAL WaveSel          : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL Duration         : UNSIGNED(23 DOWNTO 0);
SIGNAL AttackVal        : UNSIGNED(7 DOWNTO 0);
SIGNAL DecayVal         : UNSIGNED(7 DOWNTO 0);
SIGNAL SustainVal       : UNSIGNED(7 DOWNTO 0);
SIGNAL ReleaseVal       : UNSIGNED(7 DOWNTO 0);
SIGNAL Frequency        : UNSIGNED(23 DOWNTO 0);
SIGNAL WaveShape        : UNSIGNED(7 DOWNTO 0);
SIGNAL FMEnable         : STD_LOGIC;
SIGNAL AMEnable         : STD_LOGIC;
SIGNAL WMEnable         : STD_LOGIC;
SIGNAL SyncEnable       : STD_LOGIC;
SIGNAL InvSyncEnable    : STD_LOGIC;
SIGNAL FMAmplitude      : UNSIGNED(15 DOWNTO 0);
SIGNAL AMAmplitude      : UNSIGNED(15 DOWNTO 0);
SIGNAL WMAmplitude      : UNSIGNED(15 DOWNTO 0);
SIGNAL LeftVolume       : UNSIGNED(7 DOWNTO 0);
SIGNAL RightVolume      : UNSIGNED(7 DOWNTO 0);
SIGNAL ADSRState        : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL DurRemain        : UNSIGNED(23 DOWNTO 0);
SIGNAL ADSRCounter      : UNSIGNED(15 DOWNTO 0);
SIGNAL Phase            : UNSIGNED(23 DOWNTO 0);
SIGNAL SamSel           : STD_LOGIC_VECTOR(1 DOWNTO 0);

SIGNAL EndGate          : STD_LOGIC;
SIGNAL newADSRState     : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL newDurRemain     : UNSIGNED(23 DOWNTO 0);
SIGNAL newADSRCounter   : UNSIGNED(15 DOWNTO 0);
SIGNAL newPhase         : UNSIGNED(23 DOWNTO 0);
        
SIGNAL lastRawValue     : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL newRawValue      : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL lastRawValueIn   : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL FMChanRaw        : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL AMChanRaw        : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL WMChanRaw        : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL FMChanRawIn      : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL AMChanRawIn      : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL WMChanRawIn      : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL notePlaying      : STD_LOGIC;

SIGNAL loadStart        : STD_LOGIC;
SIGNAL loadDone         : STD_LOGIC;
SIGNAL saveStart        : STD_LOGIC;
SIGNAL saveDone         : STD_LOGIC;

SIGNAL FMvalue          : SIGNED(23 DOWNTO 0);
SIGNAL AMvalue          : UNSIGNED(15 DOWNTO 0);
SIGNAL WMvalue          : SIGNED(7 DOWNTO 0);

SIGNAL waveHold         : STD_LOGIC;
SIGNAL waveGenDone      : STD_LOGIC;

SIGNAL clearTotals      : STD_LOGIC;
SIGNAL addTotals        : STD_LOGIC;
SIGNAL latchTotals      : STD_LOGIC;

SIGNAl intLRclk         : STD_LOGIC;

SIGNAL channelLeftOut   : SIGNED(15 DOWNTO 0);
SIGNAL channelRightOut  : SIGNED(15 DOWNTO 0);

SIGNAL tableLookupAddr  : integer range 0 to 255;
SIGNAL tableData        : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL invTableLookupAddr  : integer range 0 to 255;

SIGNAL WaveShapeModded  : UNSIGNED(7 DOWNTO 0);

SIGNAL sync             : STD_LOGIC;
SIGNAL syncIn           : STD_LOGIC;
SIGNAL syncedGate       : STD_LOGIC;

SIGNAL invTableData     : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL DataOut          : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL WriteStrobe      : STD_LOGIC;

BEGIN
    --instantiate the memory interface
    memint: audioMemInterface
        PORT MAP(
            CLK25            => CLK25,
            CLK100           => CLK100,
            loadStart        => loadStart,
            loadDone         => loadDone,
            saveStart        => saveStart,
            saveDone         => saveDone,
            AddressOut       => addressInChannel,
            DataIn           => AUDIO_DAT_DATA_IN,
            DataOut          => DataOut,
            WriteStrobe      => WriteStrobe,
            Gate             => GateIn,
            ADSREnable       => ADSREnableIn,
            DurationEnable   => DurationEnableIn,
            WaveSel          => WaveSelIn,
            Duration         => DurationIn,
            AttackVal        => AttackValIn,
            DecayVal         => DecayValIn,
            SustainVal       => SustainValIn,
            ReleaseVal       => ReleaseValIn,
            Frequency        => FrequencyIn,
            WaveShape        => WaveShapeIn,
            FMEnable         => FMEnableIn,
            AMEnable         => AMEnableIn,
            WMEnable         => WMEnableIn,
            SyncEnable       => SyncEnableIn,
            InvSyncEnable    => InvSyncEnableIn,
            FMAmplitude      => FMAmplitudeIn,
            AMAmplitude      => AMAmplitudeIn,
            WMAmplitude      => WMAmplitudeIn,
            LeftVolume       => LeftVolumeIn,
            RightVolume      => RightVolumeIn,
            ADSRState        => ADSRStateIn,
            DurRemain        => DurRemainIn,
            ADSRCounter      => ADSRCounterIn,
            Phase            => PhaseIn,
            endGateIn        => EndGate,
            newADSRStateIn   => newADSRState,
            newDurRemainIn   => STD_LOGIC_VECTOR(newDurRemain),
            newADSRCounterIn => STD_LOGIC_VECTOR(newADSRCounter),
            newPhaseIn       => STD_LOGIC_VECTOR(newPhase),
            priorRaw         => lastRawValueIn,
            newRaw           => newRawValue,
            ChannelIn        => channelSelect,
            RAW_VALUE_ADDRESS_OUT   => RAW_VALUE_ADDRESS_OUT,
            RAW_VALUE_DATA_IN       => RAW_VALUE_DATA_IN,
            RAW_VALUE_DATA_OUT      => RAW_VALUE_DATA_OUT,
            RAW_VALUE_WRITE_OUT     => RAW_VALUE_WRITE_OUT,
            FMChanRaw        => FMChanRawIn,
            AMChanRaw        => AMChanRawIn,
            WMChanRaw        => WMChanRawIn,
            notePlaying      => notePlaying,
            syncOut          => syncIn
            --debug            => debug(3 downto 0)
            );
    
    AUDIO_DAT_DATA_OUT <= DataOut;
    AUDIO_DAT_WRITE_OUT <= WriteStrobe;
    AUDIO_DAT_ADDRESS_OUT <= to_integer(unsigned(STD_LOGIC_VECTOR(to_unsigned(channelSelect,4)) & STD_LOGIC_VECTOR(to_unsigned(addressInChannel,5))));

    --latch data in to the 25M clock
    PROCESS(CLK25)
    BEGIN
        IF RISING_EDGE(CLK25) THEN
            Gate             <= GateIn;
            ADSREnable       <= ADSREnableIn;
            DurationEnable   <= DurationEnableIn;
            Duration         <= UNSIGNED(DurationIn);
            AttackVal        <= UNSIGNED(AttackValIn);
            DecayVal         <= UNSIGNED(DecayValIn);
            SustainVal       <= UNSIGNED(SustainValIn);
            ReleaseVal       <= UNSIGNED(ReleaseValIn);
            Frequency        <= UNSIGNED(FrequencyIn);
            WaveShape        <= UNSIGNED(WaveShapeIn);
            FMEnable         <= FMEnableIn;
            AMEnable         <= AMEnableIn;
            WMEnable         <= WMEnableIn;
            SyncEnable       <= SyncEnableIn;
            InvSyncEnable    <= InvSyncEnableIn;
            FMAmplitude      <= UNSIGNED(FMAmplitudeIn);
            AMAmplitude      <= UNSIGNED(AMAmplitudeIn);
            WMAmplitude      <= UNSIGNED(WMAmplitudeIn);
            LeftVolume       <= UNSIGNED(LeftVolumeIn);
            RightVolume      <= UNSIGNED(RightVolumeIn);
            ADSRState        <= ADSRStateIn;
            DurRemain        <= UNSIGNED(DurRemainIn);
            ADSRCounter      <= UNSIGNED(ADSRCounterIn);
            Phase            <= UNSIGNED(PhaseIn);
            lastRawValue     <= lastRawValueIn;
            FMChanRaw        <= FMChanRawIn;
            AMChanRaw        <= AMChanRawIn;
            WMChanRaw        <= WMChanRawIn;
            sync             <= syncIn;
            
            masterVolume     <= masterVolumeIn;
            invTableData     <= INV_TABLE_DATA_IN;
            
            CASE WaveSelIn(2) IS
                WHEN '1' => 
                    tableData  <= SAMPLE_TABLE_DATA_IN & "00000000";
                    WaveSel <= "10";
                WHEN OTHERS => 
                    tableData  <= SINE_TABLE_DATA_IN;
                    WaveSel <= WaveSelIn(1 downto 0);
            END CASE;
            
            SamSel <= WaveSelIn(1 downto 0);
        END IF;
    END PROCESS;
    
    loadOkPulse <= intLRclk;
    
    --cross-channel sync logic
    syncedGate <= GATE AND ((InvSyncEnable XOR sync) OR NOT SyncEnable);
    
    --ADSR calculator
    adsr: audioADSR
        PORT MAP (
            CLK              => CLK25,
            Gate             => syncedGate,
            DurationEnable   => DurationEnable,
            ADSREnable       => ADSREnable,
            Duration         => Duration,
            DurRemain        => DurRemain,
            AttackVal        => AttackVal,
            DecayVal         => DecayVal,
            SustainVal       => SustainVal,
            ReleaseVal       => ReleaseVal,
            ADSRState        => ADSRState,
            ADSRCounter      => ADSRCounter,
            
            notePlayingOut   => notePlaying,
            newADSRStateOut  => newADSRState,
            newADSRCounterOut=> newADSRCounter,
            newDurRemainOut  => newDurRemain,
            endGateOut       => EndGate
        );
    
    --phase clock
    PROCESS(CLK25,notePlaying,Frequency,Phase)
    BEGIN
        IF RISING_EDGE(CLK25) THEN
            IF notePlaying = '1' THEN
                newPhase <= Phase + Frequency + unsigned(FMvalue);
            ELSE
                newPhase <= to_unsigned(0,24);
            END IF;
        END IF;
    END PROCESS;
    
    --modulation values calculation
    modulation: audioMod
        PORT MAP (
            FMChanRaw       => SIGNED(FMChanRaw),
            AMChanRaw       => SIGNED(AMChanRaw),
            WMChanRaw       => SIGNED(WMChanRaw),
            
            FMamplitude     => UNSIGNED(FMAmplitude),
            AMamplitude     => UNSIGNED(AMAmplitude),
            WMamplitude     => UNSIGNED(WMAmplitude),
            
            AMEnable        => AMEnable,
            FMEnable        => FMEnable,
            WMEnable        => WMEnable,
            
            FMvalue         => FMvalue,
            AMvalue         => AMvalue,
            WMvalue         => WMvalue
        );
        
    --wave shape value modulation with clipping
    PROCESS(WaveShape,WMvalue)
        VARIABLE WM : SIGNED(9 downto 0);
    BEGIN
        WM := SIGNED(resize(WaveShape,10)) + SIGNED(resize(WMvalue,10));
        
        IF WM(9 downto 8) = "01" THEN
            WaveShapeModded <= "11111111";
        ELSIF WM(9 downto 8) = "11" THEN
            WaveShapeModded <= "00000000";
        ELSE
            WaveShapeModded <= UNSIGNED(WM(7 downto 0));
        END IF;
    END PROCESS;
        
    --waveform generator
    waveformGenerator: waveGen
        PORT MAP (
            clk                     => CLK25,
            hold                    => waveHold,
            done                    => waveGenDone,
            
            phase                   => STD_LOGIC_VECTOR(newPhase(23 downto 8)),
            wavesel                 => waveSel,
            shaper                  => STD_LOGIC_VECTOR(WaveShapeModded),
            priorHighBit            => Phase(23),
            random                  => RNG16,
            valueIn                 => lastRawValue,
            valueOut                => newRawValue,
            
            SINE_TABLE_ADDRESS_OUT  => tableLookupAddr,
            SINE_TABLE_DATA_IN      => tableData,
            INV_TABLE_ADDRESS_OUT   => invTableLookupAddr,
            INV_TABLE_DATA_IN       => invTableData
        );
        
    --latch addresses out to the 25M clock
    PROCESS(CLK25,SamSel,tableLookupAddr)
        VARIABLE tableLookupAddrVec : STD_LOGIC_VECTOR(9 downto 0);
        VARIABLE tableLookupAddrAdj : integer range 0 to 1023;
    BEGIN
        tableLookupAddrVec := SamSel & STD_LOGIC_VECTOR(to_unsigned(tableLookupAddr,8));
        tableLookupAddrAdj := to_integer(unsigned(tableLookupAddrVec));
        IF RISING_EDGE(CLK25) THEN
            SINE_TABLE_ADDRESS_OUT <= tableLookupAddr;
            SAMPLE_TABLE_ADDRESS_OUT <= tableLookupAddrAdj;
            INV_TABLE_ADDRESS_OUT <= invTableLookupAddr;
        END IF;
    END PROCESS;
    
    --volume math
    vol: audioVolMath
        PORT MAP (
            CLK             => CLK25,
            RawValue        => signed(newRawValue),
            Envelope        => newADSRCounter,
            AMvalue         => AMvalue,
            MasterVolume    => unsigned(masterVolume),
            LeftVolume      => LeftVolume,
            RightVolume     => RightVolume,
            
            LeftOut         => channelLeftOut,
            RightOut        => channelRightOut
        );
        
    --main state engine
    engine: audioState
        PORT MAP (
            clk             => CLK25,
            latched         => latched,
            waveGenDone     => waveGenDone,
            channel         => channelSelect,
            waveHold        => waveHold,
            clearTotals     => clearTotals,
            addTotals       => addTotals,
            latchTotals     => latchTotals,
            loadStart       => loadStart,
            loadDone        => loadDone,
            saveStart       => saveStart,
            saveDone        => saveDone
        );
    
    --left channel sum with limiter
    Lsum: audioSum
        PORT MAP (
            clk         => CLK25,
            clear       => clearTotals,
            add         => addTotals,
            audio       => channelLeftOut,
            total       => Ltotal
        );
        
    --right channel sum with limiter
    Rsum: audioSum
        PORT MAP (
            clk         => CLK25,
            clear       => clearTotals,
            add         => addTotals,
            audio       => channelRightOut,
            total       => Rtotal
        );
        
    PROCESS(CLK25,latchTotals)
    BEGIN
        IF RISING_EDGE(CLK25) THEN
            IF latchTotals = '1' THEN
               LtotalLatchedOut <= Ltotal;
               RtotalLatchedOut <= Rtotal;
            END IF;
        END IF;
    END PROCESS;
    
    --i2s output
    audioout: i2s
       PORT MAP (
            clk         => MCLK,
            
            rdata       => std_logic_vector(RtotalLatchedOut),
            ldata       => std_logic_vector(LtotalLatchedOut),
            
            sclk        => SCLK,
            lrclk       => intLRclk,
            sdata       => SDATA,
            
            latched     => latched
            );
    
    LRCLK <= intLRclk;
    
    --debug(5) <= saveDone;
    debug(5) <= loadStart;
    debug(4) <= notePlaying;
    
    debug(3 downto 0) <= std_logic_vector(to_unsigned(channelSelect,4));
END behavior;