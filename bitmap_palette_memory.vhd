LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY bitmap_palette_memory IS
    PORT(
        CLK                         : IN  STD_LOGIC;
        ADDR_1                      : IN  integer range 0 to 15;
        WRITE_DATA_1                : IN  STD_LOGIC_VECTOR(7 downto 0);
        WRITE_STROBE_1              : IN  STD_LOGIC;
        READ_DATA_1                 : OUT STD_LOGIC_VECTOR(7 downto 0);
        
        ADDR_2                      : IN  integer range 0 to 7;
        WRITE_DATA_2                : IN  STD_LOGIC_VECTOR(15 downto 0);
        WRITE_STROBE_2              : IN  STD_LOGIC;
        BYTE_FLAGS_2                : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        READ_DATA_2                 : OUT STD_LOGIC_VECTOR(15 downto 0);
        
        C0                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C1                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C2                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C3                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C4                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C5                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C6                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C7                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C8                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C9                          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C10                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C11                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C12                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C13                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C14                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        C15                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
END bitmap_palette_memory;

ARCHITECTURE behavioral OF bitmap_palette_memory IS

    SIGNAL color0                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; --0 (Black)
    SIGNAL color1                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001111"; --15 (White)
    SIGNAL color2                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001101"; --13 (Fuchsia)
    SIGNAL color3                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001110"; --14 (Aqua)
    SIGNAL color4                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001001"; --9 (Red)
    SIGNAL color5                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001010"; --10 (Lime)
    SIGNAL color6                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001011"; --11 (Yellow)
    SIGNAL color7                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001100"; --12 (Blue)
    SIGNAL color8                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000001"; --1 (Maroon)
    SIGNAL color9                   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000010"; --2 (Green)
    SIGNAL color10                  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000011"; --3 (Olive)
    SIGNAL color11                  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000100"; --4 (Navy)
    SIGNAL color12                  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000101"; --5 (Purple)
    SIGNAL color13                  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000110"; --6 (Teal)
    SIGNAL color14                  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000111"; --7 (Silver)
    SIGNAL color15                  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001000"; --8 (Grey)
    
BEGIN

    -- write process
    PROCESS(CLK,ADDR_1,ADDR_2,WRITE_DATA_1,WRITE_DATA_2,WRITE_STROBE_1,WRITE_STROBE_2,BYTE_FLAGS_2)     
        VARIABLE ADDR_1_BITS : STD_LOGIC_VECTOR(3 downto 0);
        VARIABLE ADDR   : INTEGER range 0 to 7;
        VARIABLE WDATA  : STD_LOGIC_VECTOR(15 downto 0);
        VARIABLE WE     : STD_LOGIC;
        VARIABLE BF     : STD_LOGIC_VECTOR(1 downto 0);
    BEGIN
        ADDR_1_BITS := std_logic_vector(to_unsigned(ADDR_1, 4));
        
        IF (WRITE_STROBE_1) THEN
            ADDR := to_integer(unsigned(ADDR_1_BITS(3 downto 1)));
            WDATA := WRITE_DATA_1 & WRITE_DATA_1;
            BF := (NOT ADDR_1_BITS(0)) & ADDR_1_BITS(0);
        ELSE
            ADDR := ADDR_2;
            WDATA := WRITE_DATA_2;
            BF := BYTE_FLAGS_2;
        END IF;
        
        WE := WRITE_STROBE_1 OR WRITE_STROBE_2;
        
        IF RISING_EDGE(CLK) AND (WE = '1') THEN
            CASE ADDR IS
                WHEN 0 =>
                    IF BF(0) = '1' THEN
                        color0 <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        color1 <= WDATA(7 downto 0);
                    END IF;
                WHEN 1 =>
                    IF BF(0) = '1' THEN
                        color2 <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        color3 <= WDATA(7 downto 0);
                    END IF;
                WHEN 2 =>
                    IF BF(0) = '1' THEN
                        color4 <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        color5 <= WDATA(7 downto 0);
                    END IF;
                WHEN 3 =>
                    IF BF(0) = '1' THEN
                        color6 <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        color7 <= WDATA(7 downto 0);
                    END IF;
                WHEN 4 =>
                    IF BF(0) = '1' THEN
                        color8 <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        color9 <= WDATA(7 downto 0);
                    END IF;
                WHEN 5 =>
                    IF BF(0) = '1' THEN
                        color10 <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        color11 <= WDATA(7 downto 0);
                    END IF;
                WHEN 6 =>
                    IF BF(0) = '1' THEN
                        color12 <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        color13 <= WDATA(7 downto 0);
                    END IF;
                WHEN 7 =>
                    IF BF(0) = '1' THEN
                        color14 <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        color15 <= WDATA(7 downto 0);
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
    
    --read process 1
    PROCESS(ADDR_1,color0,color1,color2,color3,color4,color5,color6,color7,
                   color8,color9,color10,color11,color12,color13,color14,color15)
    BEGIN
        CASE ADDR_1 IS
            WHEN 0 =>
                READ_DATA_1 <= color0;
            WHEN 1 =>
                READ_DATA_1 <= color1;
            WHEN 2 =>
                READ_DATA_1 <= color2;
            WHEN 3 =>
                READ_DATA_1 <= color3;
            WHEN 4 =>
                READ_DATA_1 <= color4;
            WHEN 5 =>
                READ_DATA_1 <= color5;
            WHEN 6 =>
                READ_DATA_1 <= color6;
            WHEN 7 =>
                READ_DATA_1 <= color7;
            WHEN 8 =>
                READ_DATA_1 <= color8;
            WHEN 9 =>
                READ_DATA_1 <= color9;
            WHEN 10 =>
                READ_DATA_1 <= color10;
            WHEN 11 =>
                READ_DATA_1 <= color11;
            WHEN 12 =>
                READ_DATA_1 <= color12;
            WHEN 13 =>
                READ_DATA_1 <= color13;
            WHEN 14 =>
                READ_DATA_1 <= color14;
            WHEN 15 =>
                READ_DATA_1 <= color15;
        END CASE;
    END PROCESS;
    
    --read process 2
    PROCESS(ADDR_2,color0,color1,color2,color3,color4,color5,color6,color7,
                   color8,color9,color10,color11,color12,color13,color14,color15)
    BEGIN
        CASE ADDR_2 IS
            WHEN 0 =>
                READ_DATA_2 <= color0 & color1;
            WHEN 1 =>
                READ_DATA_2 <= color2 & color3;
            WHEN 2 =>
                READ_DATA_2 <= color4 & color5;
            WHEN 3 =>
                READ_DATA_2 <= color6 & color7;
            WHEN 4 =>
                READ_DATA_2 <= color8 & color9;
            WHEN 5 =>
                READ_DATA_2 <= color10 & color11;
            WHEN 6 =>
                READ_DATA_2 <= color12 & color13;
            WHEN 7 =>
                READ_DATA_2 <= color14 & color15;
        END CASE;
    END PROCESS;
    
    C0 <= color0;
    C1 <= color1;
    C2 <= color2;
    C3 <= color3;
    C4 <= color4;
    C5 <= color5;
    C6 <= color6;
    C7 <= color7;
    C8 <= color8;
    C9 <= color9;
    C10 <= color10;
    C11 <= color11;
    C12 <= color12;
    C13 <= color13;
    C14 <= color14;
    C15 <= color15;
    
END behavioral;