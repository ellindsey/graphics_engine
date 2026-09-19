library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity address_decode is
    Port (
        ADDRESS_IN          : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        
        SEL_SYS_REG         : OUT STD_LOGIC;
        SEL_AUDIO_RAW       : OUT STD_LOGIC;
        SEL_AFFINE          : OUT STD_LOGIC;
        SEL_PALETTE         : OUT STD_LOGIC;
        SEL_COL_FLAGS       : OUT STD_LOGIC;
        SEL_PAL_RED         : OUT STD_LOGIC;
        SEL_PAL_GREEN       : OUT STD_LOGIC;
        SEL_PAL_BLUE        : OUT STD_LOGIC;
        SEL_SPRITE_DATA     : OUT STD_LOGIC;
        SEL_AUDIO_DATA      : OUT STD_LOGIC;
        SEL_SAMPLE_TABLE    : OUT STD_LOGIC;
        SEL_COPPER_LIST     : OUT STD_LOGIC;
        SEL_FONT            : OUT STD_LOGIC;
        SEL_BANK_1          : OUT STD_LOGIC;
        SEL_BANK_2          : OUT STD_LOGIC;
        SEL_BANK_3          : OUT STD_LOGIC;
        SEL_BANK_4          : OUT STD_LOGIC;
        SEL_BANK_5          : OUT STD_LOGIC;
        SEL_BANK_6          : OUT STD_LOGIC;
        SEL_BANK_7          : OUT STD_LOGIC
        );
end address_decode;

architecture Behavioral of address_decode is

begin
    PROCESS(ADDRESS_IN)
    
    BEGIN
        CASE ADDRESS_IN(15 downto 13) IS
            WHEN "000" =>
                IF ADDRESS_IN(12 DOWNTO 6) = "0000000" THEN
                    SEL_SYS_REG <= '1';
                ELSE
                    SEL_SYS_REG <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 5) = "00000010" THEN
                    SEL_AUDIO_RAW <= '1';
                ELSE
                    SEL_AUDIO_RAW <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 4) = "000000110" THEN
                    SEL_AFFINE <= '1';
                ELSE
                    SEL_AFFINE <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 4) = "000000111" THEN
                    SEL_PALETTE <= '1';
                ELSE
                    SEL_PALETTE <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 7) = "000001" THEN
                    SEL_COL_FLAGS <= '1';
                ELSE
                    SEL_COL_FLAGS <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 8) = "00001" THEN
                    SEL_PAL_RED <= '1';
                ELSE
                    SEL_PAL_RED <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 8) = "00010" THEN
                    SEL_PAL_GREEN <= '1';
                ELSE
                    SEL_PAL_GREEN <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 8) = "00011" THEN
                    SEL_PAL_BLUE <= '1';
                ELSE
                    SEL_PAL_BLUE <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 10) = "001" THEN
                    SEL_SPRITE_DATA <= '1';
                ELSE
                    SEL_SPRITE_DATA <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 9) = "0100" THEN
                    SEL_AUDIO_DATA <= '1';
                ELSE
                    SEL_AUDIO_DATA <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 10) = "011" THEN
                    SEL_SAMPLE_TABLE <= '1';
                ELSE
                    SEL_SAMPLE_TABLE <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 11) = "10" THEN
                    SEL_COPPER_LIST <= '1';
                ELSE
                    SEL_COPPER_LIST <= '0';
                END IF;
                
                IF ADDRESS_IN(12 DOWNTO 11) = "11" THEN
                    SEL_FONT <= '1';
                ELSE
                    SEL_FONT <= '0';
                END IF;
                
                SEL_BANK_1 <= '0';
                SEL_BANK_2 <= '0';
                SEL_BANK_3 <= '0';
                SEL_BANK_4 <= '0';
                SEL_BANK_5 <= '0';
                SEL_BANK_6 <= '0';
                SEL_BANK_7 <= '0';
            WHEN "001" =>
                SEL_SYS_REG <= '0';
                SEL_AUDIO_RAW <= '0';
                SEL_AFFINE <= '0';
                SEL_PALETTE <= '0';
                SEL_COL_FLAGS <= '0';
                SEL_PAL_RED <= '0';
                SEL_PAL_GREEN <= '0';
                SEL_PAL_BLUE <= '0';
                SEL_AUDIO_DATA <= '0';
                SEL_SPRITE_DATA <= '0';
                SEL_SAMPLE_TABLE <= '0';
                SEL_COPPER_LIST <= '0';
                SEL_FONT <= '0';
                
                SEL_BANK_1 <= '1';
                SEL_BANK_2 <= '0';
                SEL_BANK_3 <= '0';
                SEL_BANK_4 <= '0';
                SEL_BANK_5 <= '0';
                SEL_BANK_6 <= '0';
                SEL_BANK_7 <= '0';
            WHEN "010" =>
                SEL_SYS_REG <= '0';
                SEL_AUDIO_RAW <= '0';
                SEL_AFFINE <= '0';
                SEL_PALETTE <= '0';
                SEL_COL_FLAGS <= '0';
                SEL_PAL_RED <= '0';
                SEL_PAL_GREEN <= '0';
                SEL_PAL_BLUE <= '0';
                SEL_AUDIO_DATA <= '0';
                SEL_SPRITE_DATA <= '0';
                SEL_SAMPLE_TABLE <= '0';
                SEL_COPPER_LIST <= '0';
                SEL_FONT <= '0';
                
                SEL_BANK_1 <= '0';
                SEL_BANK_2 <= '1';
                SEL_BANK_3 <= '0';
                SEL_BANK_4 <= '0';
                SEL_BANK_5 <= '0';
                SEL_BANK_6 <= '0';
                SEL_BANK_7 <= '0';
            WHEN "011" =>
                SEL_SYS_REG <= '0';
                SEL_AUDIO_RAW <= '0';
                SEL_AFFINE <= '0';
                SEL_PALETTE <= '0';
                SEL_COL_FLAGS <= '0';
                SEL_PAL_RED <= '0';
                SEL_PAL_GREEN <= '0';
                SEL_PAL_BLUE <= '0';
                SEL_AUDIO_DATA <= '0';
                SEL_SPRITE_DATA <= '0';
                SEL_SAMPLE_TABLE <= '0';
                SEL_COPPER_LIST <= '0';
                SEL_FONT <= '0';
                
                SEL_BANK_1 <= '0';
                SEL_BANK_2 <= '0';
                SEL_BANK_3 <= '1';
                SEL_BANK_4 <= '0';
                SEL_BANK_5 <= '0';
                SEL_BANK_6 <= '0';
                SEL_BANK_7 <= '0';
            WHEN "100" =>
                SEL_SYS_REG <= '0';
                SEL_AUDIO_RAW <= '0';
                SEL_AFFINE <= '0';
                SEL_PALETTE <= '0';
                SEL_COL_FLAGS <= '0';
                SEL_PAL_RED <= '0';
                SEL_PAL_GREEN <= '0';
                SEL_PAL_BLUE <= '0';
                SEL_AUDIO_DATA <= '0';
                SEL_SPRITE_DATA <= '0';
                SEL_SAMPLE_TABLE <= '0';
                SEL_COPPER_LIST <= '0';
                SEL_FONT <= '0';
                
                SEL_BANK_1 <= '0';
                SEL_BANK_2 <= '0';
                SEL_BANK_3 <= '0';
                SEL_BANK_4 <= '1';
                SEL_BANK_5 <= '0';
                SEL_BANK_6 <= '0';
                SEL_BANK_7 <= '0';
            WHEN "101" =>
                SEL_SYS_REG <= '0';
                SEL_AUDIO_RAW <= '0';
                SEL_AFFINE <= '0';
                SEL_PALETTE <= '0';
                SEL_COL_FLAGS <= '0';
                SEL_PAL_RED <= '0';
                SEL_PAL_GREEN <= '0';
                SEL_PAL_BLUE <= '0';
                SEL_AUDIO_DATA <= '0';
                SEL_SPRITE_DATA <= '0';
                SEL_SAMPLE_TABLE <= '0';
                SEL_COPPER_LIST <= '0';
                SEL_FONT <= '0';
                
                SEL_BANK_1 <= '0';
                SEL_BANK_2 <= '0';
                SEL_BANK_3 <= '0';
                SEL_BANK_4 <= '0';
                SEL_BANK_5 <= '1';
                SEL_BANK_6 <= '0';
                SEL_BANK_7 <= '0';
            WHEN "110" =>
                SEL_SYS_REG <= '0';
                SEL_AUDIO_RAW <= '0';
                SEL_AFFINE <= '0';
                SEL_PALETTE <= '0';
                SEL_COL_FLAGS <= '0';
                SEL_PAL_RED <= '0';
                SEL_PAL_GREEN <= '0';
                SEL_PAL_BLUE <= '0';
                SEL_AUDIO_DATA <= '0';
                SEL_SPRITE_DATA <= '0';
                SEL_SAMPLE_TABLE <= '0';
                SEL_COPPER_LIST <= '0';
                SEL_FONT <= '0';
                
                SEL_BANK_1 <= '0';
                SEL_BANK_2 <= '0';
                SEL_BANK_3 <= '0';
                SEL_BANK_4 <= '0';
                SEL_BANK_5 <= '0';
                SEL_BANK_6 <= '1';
                SEL_BANK_7 <= '0';
            WHEN "111" =>
                SEL_SYS_REG <= '0';
                SEL_AUDIO_RAW <= '0';
                SEL_AFFINE <= '0';
                SEL_PALETTE <= '0';
                SEL_COL_FLAGS <= '0';
                SEL_PAL_RED <= '0';
                SEL_PAL_GREEN <= '0';
                SEL_PAL_BLUE <= '0';
                SEL_AUDIO_DATA <= '0';
                SEL_SPRITE_DATA <= '0';
                SEL_SAMPLE_TABLE <= '0';
                SEL_COPPER_LIST <= '0';
                SEL_FONT <= '0';
                
                SEL_BANK_1 <= '0';
                SEL_BANK_2 <= '0';
                SEL_BANK_3 <= '0';
                SEL_BANK_4 <= '0';
                SEL_BANK_5 <= '0';
                SEL_BANK_6 <= '0';
                SEL_BANK_7 <= '1';
            WHEN OTHERS =>
                SEL_SYS_REG <= '0';
                SEL_AUDIO_RAW <= '0';
                SEL_AFFINE <= '0';
                SEL_PALETTE <= '0';
                SEL_COL_FLAGS <= '0';
                SEL_PAL_RED <= '0';
                SEL_PAL_GREEN <= '0';
                SEL_PAL_BLUE <= '0';
                SEL_AUDIO_DATA <= '0';
                SEL_SPRITE_DATA <= '0';
                SEL_SAMPLE_TABLE <= '0';
                SEL_COPPER_LIST <= '0';
                SEL_FONT <= '0';
                
                SEL_BANK_1 <= '0';
                SEL_BANK_2 <= '0';
                SEL_BANK_3 <= '0';
                SEL_BANK_4 <= '0';
                SEL_BANK_5 <= '0';
                SEL_BANK_6 <= '0';
                SEL_BANK_7 <= '0';
        END CASE;
    END PROCESS;
end Behavioral;