LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY audioMod IS
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
END audioMod;

ARCHITECTURE behavior OF audioMod IS

BEGIN
    PROCESS(FMChanRaw,FMamplitude,FMEnable,AMChanRaw,AMamplitude,AMEnable,WMChanRaw,WMamplitude,WMEnable)
        VARIABLE AMMUL : signed(33 downto 0);
        VARIABLE AMMULU : unsigned(33 downto 0);
        VARIABLE FMMUL : signed(33 downto 0);
        VARIABLE WMMUL : signed(33 downto 0);
        
    BEGIN
        FMMUL := signed(resize(FMChanRaw,17)) * signed(resize(FMamplitude,17));
        AMMUL := signed(resize(AMChanRaw,17)) * signed(resize(AMamplitude,17));
        AMMULU := unsigned(AMMUL);
        WMMUL := signed(resize(WMChanRaw,17)) * signed(resize(WMamplitude,17));
    
        IF FMEnable = '0' THEN
            FMvalue <= to_signed(0,24);
        ELSE
            FMvalue <= FMMUL(31 downto 8);
        END IF;
        
        IF AMEnable = '0' THEN
            AMvalue <= to_unsigned(32768,16);
        ELSE
            AMvalue <= AMMULU(31 downto 16) + 32768;
        END IF;
        
        IF WMEnable = '0' THEN
            WMvalue <= to_signed(0,8);
        ELSE
            WMvalue <= WMMUL(31 downto 24);
        END IF;
    END PROCESS;
END behavior;