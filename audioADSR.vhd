LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY audioADSR IS
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
END audioADSR;

ARCHITECTURE behavior OF audioADSR IS

SIGNAL notePlaying      : STD_LOGIC;
SIGNAL noteHold         : STD_LOGIC;

SIGNAL newADSRState     : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL newADSRCounter   : UNSIGNED(15 DOWNTO 0);
SIGNAL newDurRemain     : UNSIGNED(23 DOWNTO 0);
SIGNAL endGate          : STD_LOGIC;
        
BEGIN
    --gate and duration countdown
    
    PROCESS(ADSRState,Gate,DurationEnable,Duration,DurRemain)
    BEGIN
        IF ADSRState = "00000" THEN
            IF Gate = '1' THEN
                noteHold <= '1';
                IF DurationEnable = '1' THEN
                    newDurRemain <= Duration;
                ELSE
                    newDurRemain <= "000000000000000000000000";
                END IF;
            ELSE
                noteHold <= '0';
                newDurRemain <= "000000000000000000000000";
            END IF;
            endGate <= '0';
        ELSE
            IF DurationEnable = '1' THEN
                IF DurRemain = 0 THEN
                    noteHold <= '0';
                    newDurRemain <= DurRemain;
                    endGate <= Gate;
                ELSE
                    noteHold <= '1';
                    newDurRemain <= DurRemain - 1;
                    endGate <= '0';
                END IF;
            ELSE
                noteHold <= Gate;
                newDurRemain <= "000000000000000000000000";
                endGate <= '0';
            END IF;
        END IF;
    END PROCESS;
    
    --main ADSR state engine
    PROCESS(Gate,ADSRCounter,ADSREnable,ADSRState,AttackVal,DecayVal,ReleaseVal,SustainVal,noteHold)
        VARIABLE tempA : UNSIGNED(16 downto 0);
        VARIABLE tempD : UNSIGNED(16 downto 0);
        VARIABLE tempR : UNSIGNED(16 downto 0);
    BEGIN
        tempA := resize(ADSRCounter,17) + resize(AttackVal,17);
        tempD := resize(ADSRCounter,17) - resize(DecayVal,17);
        tempR := resize(ADSRCounter,17) - resize(ReleaseVal,17);
        
        CASE ADSRState(2 downto 0) IS
            WHEN "000" =>   --OFF
                IF noteHold = '1' THEN
                    IF ADSREnable = '1' THEN
                        newADSRState <= "00010"; --go to state ATTACK
                    ELSE
                        newADSRState <= "00001"; --go to state ON
                    END IF;
                ELSE
                    newADSRState <= "00000"; --stay in state OFF
                END IF;
                newADSRCounter <= "0000000000000000";
                notePlaying <= '0';
                
            WHEN "001" =>   --ON
                IF noteHold = '0' THEN
                    newADSRstate <= "00110"; --go to state WAITOFF
                ELSE
                    newADSRstate <= "00001"; --stay in state ON
                END IF;
                newADSRCounter <= "1111111111111111";
                notePlaying <= '1';
                
            WHEN "010" =>   --ATTACK
                IF tempA(16) = '1' THEN --overflow, hit max
                    newADSRstate <= "00011"; --go to state DECAY
                    newADSRCounter <= "1111111111111111";
                ELSE
                    IF noteHold = '0' THEN
                        newADSRstate <= "00101"; --go to state RELEASE
                    ELSE
                        newADSRstate <= "00010"; --stay in state ATTACK
                    END IF;
                    newADSRCounter <= tempA(15 downto 0);
                END IF;
                notePlaying <= '1';
                
            WHEN "011" =>   --DECAY
                IF ADSRState(4 downto 3) = "11" THEN
                    IF tempD(16) = '1' or tempD(15 downto 8) < SustainVal THEN
                        newADSRstate <= "00100"; --go to state SUSTAIN
                        newADSRCounter <= SustainVal & "00000000";
                    ELSE
                        IF noteHold = '0' THEN
                            newADSRstate <= "00101"; --go to state RELEASE
                        ELSE
                            newADSRstate <= "00011"; --stay in state DECAY
                        END IF;
                        newADSRCounter <= tempD(15 downto 0);
                    END IF;
                ELSE
                    --count to 4
                    newADSRstate <= STD_LOGIC_VECTOR(UNSIGNED(ADSRState(4 downto 3))+1) & "011";
                    newADSRCounter <= ADSRCounter;
                END IF;
                notePlaying <= '1';
                
            WHEN "100" =>   --SUSTAIN
                IF noteHold = '0' THEN
                    newADSRstate <= "00101"; --go to state RELEASE
                ELSE
                    newADSRstate <= "00100"; --stay in state SUSTAIN
                END IF;
                newADSRCounter <= SustainVal & "00000000";
                notePlaying <= '1';
                
            WHEN "101" =>   --RELEASE
                IF noteHold = '1' THEN
                    IF ADSREnable = '1' THEN
                        newADSRState <= "00010"; --go to state ATTACK
                    ELSE
                        newADSRState <= "00001"; --go to state ON
                    END IF;
                    newADSRCounter <= ADSRCounter;
                ELSIF ADSRState(4 downto 3) = "11" THEN
                    IF tempR(16) = '1' THEN --hit zero and wrapped around
                        newADSRstate <= "00110"; --go to state WAITOFF
                        newADSRCounter <= "0000000000000000";
                    ELSE
                        newADSRState <= "00101"; --stay in state RELEASE
                        newADSRCounter <= tempR(15 downto 0);
                    END IF;
                ELSE
                    --count to 4
                    newADSRstate <= STD_LOGIC_VECTOR(UNSIGNED(ADSRState(4 downto 3))+1) & "101";
                    newADSRCounter <= ADSRCounter;
                END IF;
                notePlaying <= '1';
                
            WHEN "110" =>   --WAITOFF
                IF gate = '1' THEN
                    newADSRState <= "00110"; --WAITOFF
                ELSE
                    newADSRState <= "00000"; --OFF
                END IF;
                newADSRCounter <= "0000000000000000";
                notePlaying <= '0';
                
            WHEN others =>  --should never get here
                newADSRState <= "00000";
                newADSRCounter <= "0000000000000000";
                notePlaying <= '0';
        END CASE;
        
    END PROCESS;
    
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            notePlayingOut      <= notePlaying;
            newADSRStateOut     <= newADSRState;
            newADSRCounterOut   <= newADSRCounter;
            newDurRemainOut     <= newDurRemain;
            endGateOut          <= endGate;
        END IF;
    END PROCESS;
END behavior;