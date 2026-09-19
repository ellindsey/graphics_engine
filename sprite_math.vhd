LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY sprite_math IS
    PORT(
        CLK25M                  : IN  STD_LOGIC;
        CLK100M                 : IN  STD_LOGIC;
        LINE_TO_DRAW            : IN  integer range 0 to 239;
        ANIM_CYCLE              : IN  integer range 0 to 65535;
        SPRITE_DATA_IN          : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
        SPRITE_INDEX            : IN  integer range 0 to 127;
        SPRITE_SCROLL_X         : IN  integer range 0 to 511;
        SPRITE_SCROLL_Y         : IN  integer range 0 to 255;
        DRAW_SPRITE             : OUT STD_LOGIC;
        FIFO_DATA_OUT           : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
    );
END sprite_math;

ARCHITECTURE behavioral OF sprite_math IS

    SIGNAL spriteImage              : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL spriteYposition          : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL spriteXposition          : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL spriteLayer              : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL spriteBgColor            : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL spriteFlipAndRotate      : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL spriteSize               : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL spriteCollEnable         : STD_LOGIC;
    SIGNAL spriteCollBits           : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL spriteAlive              : STD_LOGIC;
    SIGNAL spriteAnimSpeed          : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL spriteAnimlength         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL spriteColorDepth         : STD_LOGIC;
    SIGNAL spritePalette            : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    SIGNAL spriteYposInt            : integer range 0 to 511;
    SIGNAL spriteXposInt            : integer range 0 to 1023;
    SIGNAL spriteXposIntAdjusted    : integer range 0 to 1023;
    
    SIGNAL lineAdjusted             : integer range 0 to 511;
    
    SIGNAL adjustedSpriteImage      : STD_LOGIC_VECTOR(9 DOWNTO 0);
    
    SIGNAL spriteSizeInt            : integer range 0 to 63;
    SIGNAL spriteSizeBits           : STD_LOGIC_VECTOR(5 DOWNTO 0);
    
    --SIGNAL spriteMaxYposInt         : integer range 0 to 511;
    
    SIGNAL screenYInSpriteInt       : integer range 0 to 63;
    SIGNAL screenYInSprite          : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL sourceYInSprite          : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL sourceXStartInt          : integer range 0 to 63;
    SIGNAL sourceXStartBits         : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL sourceIncrement          : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL sourceIncrementDirection : STD_LOGIC; 
    
    SIGNAL screenYInSpriteIntFlip   : integer range 0 to 63;
    SIGNAL screenYInSpriteFlip      : STD_LOGIC_VECTOR(5 DOWNTO 0);
    
    --SIGNAL sourceStartAddress       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL sourceStartAddress       : STD_LOGIC_VECTOR(16 DOWNTO 0);
    
    SIGNAL drawSpriteInt            : STD_LOGIC; 
    
BEGIN

    --decompose the data from the sprite data memory
    --PROCESS(SPRITE_DATA_IN,CLK100M)
    --BEGIN
        --IF RISING_EDGE(CLK100M) THEN
            --byte 0: x position bits 0-7
            spriteXposition(7 downto 0)     <= SPRITE_DATA_IN(7 downto 0);
            
            --byte 1: y position bits 0-7
            spriteYposition(7 downto 0)     <= SPRITE_DATA_IN(15 downto 8);
            
            --byte 2:
                --bit 0: y position bit 8
                --bits 1-2: x position bits 8-9
                --bits 3: color depth (1 = 8 bit, 0 = 4 bit)
                --bits 4-7: sprite palette
            spriteYposition(8)              <= SPRITE_DATA_IN(16);
            spriteXposition(9 downto 8)     <= SPRITE_DATA_IN(18 downto 17);
            spriteColorDepth                <= SPRITE_DATA_IN(19);
            spritePalette                   <= SPRITE_DATA_IN(23 downto 20);
                
            --byte 3: image select bits 0-7
            spriteImage(7 downto 0)         <= SPRITE_DATA_IN(31 downto 24);
            
            --byte 4: transparency color
            spriteBgColor                   <= SPRITE_DATA_IN(39 downto 32);
            
            --byte 5:
                --bit 0: flip x
                --bit 1: flip y
                --bit 2: swap x/y
                --bits 3-4: sprite size
                --bits 5-6: image select bits 8-9
                --bit 7: collision check enable
            spriteFlipAndRotate             <= SPRITE_DATA_IN(42 downto 40);
            spriteSize                      <= SPRITE_DATA_IN(44 downto 43);
            spriteImage(9 downto 8)         <= SPRITE_DATA_IN(46 downto 45);
            spriteCollEnable                <= SPRITE_DATA_IN(47);
            
            --byte 6: collision bits
            spriteCollBits                  <= SPRITE_DATA_IN(55 downto 48);
            
            --byte 7:
                --bit 0: sprite alive flag
                --bits 1-3: animation speed
                --bits 4-5: animation length
                --bits 6-7: layer priority
            spriteAlive                     <= SPRITE_DATA_IN(56);
            spriteAnimSpeed                 <= SPRITE_DATA_IN(59 downto 57);
            spriteAnimlength                <= SPRITE_DATA_IN(61 downto 60);
            spriteLayer                     <= SPRITE_DATA_IN(63 downto 62);
        --END IF;
    --END PROCESS;
    
    spriteYposInt <= to_integer(unsigned(spriteYposition));
    spriteXposInt <= to_integer(unsigned(spriteXposition));
    
    spriteXposIntAdjusted <= spriteXposInt - SPRITE_SCROLL_X;
    
    --PROCESS(LINE_TO_DRAW,SPRITE_SCROLL_Y,CLK25M)
    --BEGIN
        --IF RISING_EDGE(CLK25M) THEN
            lineAdjusted <= LINE_TO_DRAW + SPRITE_SCROLL_Y;
        --END IF;
    --END PROCESS;

    --Update the sprite image ID with the animation state
    
    PROCESS(spriteAnimSpeed,ANIM_CYCLE,spriteImage,spriteAnimlength)
        VARIABLE animTemp                 : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE animState                : STD_LOGIC_VECTOR(2 DOWNTO 0);
        VARIABLE animTemp2                : integer range 0 to 7;
        VARIABLE animState2               : STD_LOGIC_VECTOR(2 DOWNTO 0);
    BEGIN
        animTemp := std_logic_vector(to_unsigned(ANIM_CYCLE, 16));
        
        CASE spriteAnimSpeed IS
            WHEN "000" =>
                animState := animTemp(2 downto 0);
            WHEN "001" =>
                animState := animTemp(3 downto 1);
            WHEN "010" =>
                animState := animTemp(4 downto 2);
            WHEN "011" =>
                animState := animTemp(5 downto 3);
            WHEN "100" =>
                animState := animTemp(6 downto 4);
            WHEN "101" =>
                animState := animTemp(7 downto 5);
            WHEN "110" =>
                animState := animTemp(8 downto 6);
            WHEN "111" =>
                animState := animTemp(9 downto 7);
            WHEN others =>
                animState := "000";
        END CASE;
        
        animTemp2 := to_integer(unsigned(animState)) + to_integer(unsigned(spriteImage));
        animState2 := std_logic_vector(to_unsigned(animTemp2, 3));
        
        CASE spriteAnimlength IS
            WHEN "00" =>
                adjustedSpriteImage <= spriteImage;
            WHEN "01" =>
                adjustedSpriteImage <= spriteImage(9 downto 1) & animState2(0);
            WHEN "10" =>
                adjustedSpriteImage <= spriteImage(9 downto 2) & animState2(1 downto 0);
            WHEN "11" =>
                adjustedSpriteImage <= spriteImage(9 downto 3) & animState2(2 downto 0);
            WHEN others =>
                adjustedSpriteImage <= spriteImage;
        END CASE;
    END PROCESS;
    
    --Generate the sprite size value, used elsewhere.
    
    PROCESS(spriteSize)
    BEGIN
        CASE spriteSize IS
            WHEN "00" =>    --8x8
                spriteSizeInt <= 7;
            WHEN "01" =>    --16x16
                spriteSizeInt <= 15;
            WHEN "10" =>    --32x32
                spriteSizeInt <= 31;
            WHEN "11" =>    --64x64
                spriteSizeInt <= 63;
            WHEN others =>
                spriteSizeInt <= 7;
        END CASE;
    END PROCESS;
    
    spriteSizeBits <= std_logic_vector(to_unsigned(spriteSizeInt, 6));
    
    --spriteMaxYposInt <= spriteYposInt + spriteSizeInt;
    
    --Calculate the Y position in the sprite and its inverse
    
    screenYInSpriteInt <= lineAdjusted - spriteYposInt;
    
    --screenYInSpriteIntFlip <= spriteMaxYposInt - lineAdjusted;
    
    screenYInSpriteIntFlip <= spriteSizeInt - screenYInSpriteInt;
    
    screenYInSprite <= std_logic_vector(to_unsigned(screenYInSpriteInt, 6));
    
    screenYInSpriteFlip <= std_logic_vector(to_unsigned(screenYInSpriteIntFlip, 6));
    
    --Determine if we need to draw this sprite at all.
    
    PROCESS(spriteSizeInt,spriteYposInt,lineAdjusted,spriteAlive)
    BEGIN
        IF spriteAlive THEN
            IF spriteYposInt <= lineAdjusted THEN
                --IF lineAdjusted <= spriteMaxYposInt THEN
                IF lineAdjusted <= (spriteYposInt + spriteSizeInt) THEN
                    drawSpriteInt <= '1';
                ELSE
                    drawSpriteInt <= '0';
                END IF;
            ELSE
                drawSpriteInt <= '0';
            END IF;
        ELSE
            drawSpriteInt <= '0';
        END IF;
    END PROCESS;
    
    --Generate the source X and Y and increment based on flip and rotate
    
    PROCESS(screenYInSprite,screenYInSpriteInt,screenYInSpriteFlip,screenYInSpriteIntFlip,spriteFlipAndRotate,spriteSize,spriteSizeBits,spriteSizeInt,screenYInSpriteFlip)
    BEGIN
        CASE spriteFlipAndRotate is
            WHEN "000" => --no flip or rotate - start at X=0, Y=Y, increment = +1
                sourceYInSprite <= screenYInSprite;
                sourceIncrementDirection <= '1';
                sourceXStartInt <= 0;
                sourceIncrement <= "100";
            WHEN "001" => --flip X - start at X=size, Y=Y, increment = -1
                sourceYInSprite <= screenYInSprite;
                sourceIncrementDirection <= '0';
                sourceXStartInt <= spriteSizeInt;
                sourceIncrement <= "100";
            WHEN "010" => --flip Y - start at X=0, Y=inverted Y, increment = +1
                sourceYInSprite <= screenYInSpriteFlip;
                sourceIncrementDirection <= '1';
                sourceXStartInt <= 0;
                sourceIncrement <= "100";
            WHEN "011" => --flip X and Y - start at X=size, Y=inverted Y, increment = -1
                sourceYInSprite <= screenYInSpriteFlip;
                sourceIncrementDirection <= '0';
                sourceXStartInt <= spriteSizeInt;
                sourceIncrement <= "100";
            WHEN "100" => --swap X/Y - start at X=Y, Y=0, increment = +size
                sourceYInSprite <= "000000";
                sourceXStartInt <= screenYInSpriteInt;
                sourceIncrementDirection <= '1';
                sourceIncrement <= "0" & spriteSize;
            WHEN "101" => --swap X/Y, flip X - start at X=Y, Y=size, increment = -size
                sourceYInSprite <= spriteSizeBits;
                sourceXStartInt <= screenYInSpriteInt;
                sourceIncrementDirection <= '0';
                sourceIncrement <= "0" & spriteSize;
            WHEN "110" => --swap X/Y, flip Y - start at X=inverted Y, Y=0, increment = +size
                sourceYInSprite <= "000000";
                sourceXStartInt <= screenYInSpriteIntFlip;
                sourceIncrementDirection <= '1';
                sourceIncrement <= "0" & spriteSize;
            WHEN "111" => --swap X/Y, flip X and Y - start at X=inverted Y, Y=size, increment = -size
                sourceYInSprite <= spriteSizeBits;
                sourceXStartInt <= screenYInSpriteIntFlip;
                sourceIncrementDirection <= '0';
                sourceIncrement <= "0" & spriteSize;
            WHEN others =>
                sourceYInSprite <= screenYInSprite;
                sourceIncrementDirection <= '1';
                sourceXStartInt <= 0;
                sourceIncrement <= "100";
        END CASE;
    END PROCESS;
    
    --Generate the bitmap start address pointer
    
    sourceXStartBits <= std_logic_vector(to_unsigned(sourceXStartInt, 6));
    
    PROCESS(spriteSize,adjustedSpriteImage,sourceYInSprite,sourceXStartBits)
    BEGIN
        CASE spriteSize IS
            WHEN "00" =>    --8x8
                sourceStartAddress <= '0' & adjustedSpriteImage(9 downto 0) & sourceYInSprite(2 downto 0) & sourceXStartBits(2 downto 0);
            WHEN "01" =>    --16x16
                sourceStartAddress <= adjustedSpriteImage(8 downto 0) & sourceYInSprite(3 downto 0) & sourceXStartBits(3 downto 0);
            WHEN "10" =>    --32x32
                sourceStartAddress <= adjustedSpriteImage(6 downto 0) & sourceYInSprite(4 downto 0) & sourceXStartBits(4 downto 0);
            WHEN "11" =>    --64x64
                sourceStartAddress <= adjustedSpriteImage(4 downto 0) & sourceYInSprite(5 downto 0) & sourceXStartBits(5 downto 0);
            WHEN others =>
                sourceStartAddress <= '0' & adjustedSpriteImage(9 downto 0) & sourceYInSprite(2 downto 0) & sourceXStartBits(2 downto 0);
        END CASE;
    END PROCESS;
    
    --PROCESS(CLK100M)
    --BEGIN
        --IF RISING_EDGE(CLK100M) THEN
            --Write data to the FIFO:
            
            --Bitmap source address: 17 bits
            FIFO_DATA_OUT(16 downto 0) <= sourceStartAddress;
            
            --Source increment and direction: 4 bits
            FIFO_DATA_OUT(17) <= sourceIncrementDirection;
            FIFO_DATA_OUT(20 downto 18) <= sourceIncrement;
            
            --Target address: 10 bits
            FIFO_DATA_OUT(30 downto 21) <= std_logic_vector(to_unsigned(spriteXposIntAdjusted, 10));
            
            --Transparency color: 8 bits
            FIFO_DATA_OUT(38 downto 31) <= spriteBgColor;
            
            --Priority: 2 bits
            FIFO_DATA_OUT(40 downto 39) <= spriteLayer;
            
            --Length of transfer: 2 bits
            FIFO_DATA_OUT(42 downto 41) <= spriteSize;
            
            --sprite palette (for 4 bit sprites)
            FIFO_DATA_OUT(46 downto 43) <= spritePalette;
            
            --Collision flags: 8 bits
            FIFO_DATA_OUT(54 downto 47) <= spriteCollBits;
            
            --Sprite ID: 7 bits
            FIFO_DATA_OUT(61 downto 55) <= std_logic_vector(to_unsigned(SPRITE_INDEX, 7));
            
            --Sprite collision enable flag
            FIFO_DATA_OUT(62) <= spriteCollEnable;
            
            --Sprite color depth bit (0 = 8 bit, 1 = 4 bit)
            FIFO_DATA_OUT(63) <= spriteColorDepth;
           
            DRAW_SPRITE <= drawSpriteInt;
        --END IF;
    --END PROCESS;
    
END behavioral;