LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY affine_memory IS
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
        
        C0                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        C1                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        C2                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        C3                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        C4                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        C5                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        C6                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        C7                          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END affine_memory;

ARCHITECTURE behavioral OF affine_memory IS

    SIGNAL coeff0                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000"; --X offset (10.6 fixed point signed) default 0.0
    SIGNAL coeff1                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000"; --Y offset (10.6 fixed point signed) default 0.0
    SIGNAL coeff2                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000100000000"; --matrix A (8.8 fixed point signed)  default 1.0
    SIGNAL coeff3                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000"; --matrix B (8.8 fixed point signed)  default 0.0
    SIGNAL coeff4                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000"; --matrix C (8.8 fixed point signed)  default 0.0
    SIGNAL coeff5                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000100000000"; --matrix D (8.8 fixed point signed)  default 1.0
    SIGNAL coeff6                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0010011111000000"; --XC (10.6 fixed point unsigned)     default 159.0
    SIGNAL coeff7                   : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0001110111000000"; --YC (10.6 fixed point unsigned)     default 119.0
    
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
                        coeff0(15 downto 8) <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        coeff0(7 downto 0) <= WDATA(7 downto 0);
                    END IF;
                WHEN 1 =>
                    IF BF(0) = '1' THEN
                        coeff1(15 downto 8) <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        coeff1(7 downto 0) <= WDATA(7 downto 0);
                    END IF;
                WHEN 2 =>
                    IF BF(0) = '1' THEN
                        coeff2(15 downto 8) <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        coeff2(7 downto 0) <= WDATA(7 downto 0);
                    END IF;
                WHEN 3 =>
                    IF BF(0) = '1' THEN
                        coeff3(15 downto 8) <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        coeff3(7 downto 0) <= WDATA(7 downto 0);
                    END IF;
                WHEN 4 =>
                    IF BF(0) = '1' THEN
                        coeff4(15 downto 8) <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        coeff4(7 downto 0) <= WDATA(7 downto 0);
                    END IF;
                WHEN 5 =>
                    IF BF(0) = '1' THEN
                        coeff5(15 downto 8) <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        coeff5(7 downto 0) <= WDATA(7 downto 0);
                    END IF;
                WHEN 6 =>
                    IF BF(0) = '1' THEN
                        coeff6(15 downto 8) <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        coeff6(7 downto 0) <= WDATA(7 downto 0);
                    END IF;
                WHEN 7 =>
                    IF BF(0) = '1' THEN
                        coeff7(15 downto 8) <= WDATA(15 downto 8);
                    END IF;
                    IF BF(1) = '1' THEN
                        coeff7(7 downto 0) <= WDATA(7 downto 0);
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
    
    --read process 1
    PROCESS(ADDR_1,coeff0,coeff1,coeff2,coeff3,coeff4,coeff5,coeff6,coeff7)
    BEGIN
        CASE ADDR_1 IS
            WHEN 0 =>
                READ_DATA_1 <= coeff0(15 downto 8);
            WHEN 1 =>
                READ_DATA_1 <= coeff0(7 downto 0);
            WHEN 2 =>
                READ_DATA_1 <= coeff1(15 downto 8);
            WHEN 3 =>
                READ_DATA_1 <= coeff1(7 downto 0);
            WHEN 4 =>
                READ_DATA_1 <= coeff2(15 downto 8);
            WHEN 5 =>
                READ_DATA_1 <= coeff2(7 downto 0);
            WHEN 6 =>
                READ_DATA_1 <= coeff3(15 downto 8);
            WHEN 7 =>
                READ_DATA_1 <= coeff3(7 downto 0);
            WHEN 8 =>
                READ_DATA_1 <= coeff4(15 downto 8);
            WHEN 9 =>
                READ_DATA_1 <= coeff4(7 downto 0);
            WHEN 10 =>
                READ_DATA_1 <= coeff5(15 downto 8);
            WHEN 11 =>
                READ_DATA_1 <= coeff5(7 downto 0);
            WHEN 12 =>
                READ_DATA_1 <= coeff6(15 downto 8);
            WHEN 13 =>
                READ_DATA_1 <= coeff6(7 downto 0);
            WHEN 14 =>
                READ_DATA_1 <= coeff7(15 downto 8);
            WHEN 15 =>
                READ_DATA_1 <= coeff7(7 downto 0);
        END CASE;
    END PROCESS;
    
    --read process 2
    PROCESS(ADDR_2,coeff0,coeff1,coeff2,coeff3,coeff4,coeff5,coeff6,coeff7)
    BEGIN
        CASE ADDR_2 IS
            WHEN 0 =>
                READ_DATA_2 <= coeff0;
            WHEN 1 =>
                READ_DATA_2 <= coeff1;
            WHEN 2 =>
                READ_DATA_2 <= coeff2;
            WHEN 3 =>
                READ_DATA_2 <= coeff3;
            WHEN 4 =>
                READ_DATA_2 <= coeff4;
            WHEN 5 =>
                READ_DATA_2 <= coeff5;
            WHEN 6 =>
                READ_DATA_2 <= coeff6;
            WHEN 7 =>
                READ_DATA_2 <= coeff7;
        END CASE;
    END PROCESS;
    
    C0 <= coeff0;
    C1 <= coeff1;
    C2 <= coeff2;
    C3 <= coeff3;
    C4 <= coeff4;
    C5 <= coeff5;
    C6 <= coeff6;
    C7 <= coeff7;
    
END behavioral;