LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY audioVolMath IS
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
END audioVolMath;

ARCHITECTURE behavior OF audioVolMath IS

--TODO: add pipelining for the volume calculation

BEGIN
    PROCESS(RawValue,Envelope,AMvalue,MasterVolume,LeftVolume,RightVolume)
        VARIABLE P1 : unsigned(31 downto 0);
        VARIABLE P2 : unsigned(23 downto 0);
        VARIABLE LV : unsigned(23 downto 0);
        VARIABLE RV : unsigned(23 downto 0);
        VARIABLE RO : signed(32 downto 0);
        VARIABLE LO : signed(32 downto 0);
    BEGIN
        P1 := Envelope * AMvalue;
        P2 := P1(31 downto 16) * MasterVolume;
        LV := P2(23 downto 8) * LeftVolume;
        RV := P2(23 downto 8) * RightVolume;
        
        RO := RawValue * signed ('0' & RV(23 downto 8));
        
        LO := RawValue * signed ('0' & LV(23 downto 8));
        
        --IF RISING_EDGE(CLK) THEN
            LeftOut <= LO(32 downto 17);
            RightOut <= RO(32 downto 17);
        --END IF;
    END PROCESS;
END behavior;