LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tile_engine IS
    PORT(
        CLK25M                  : IN  STD_LOGIC;
        CLK100M                 : IN  STD_LOGIC;
        RESET_LINE              : IN  STD_LOGIC;
        RESET_SCREEN            : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        LINE_TO_DRAW            : IN  integer range 0 to 239;
        DONE                    : OUT STD_LOGIC;
        
        TILE_Y_SCROLL           : IN  integer range 0 to 255;
        TILE_X_SCROLL           : IN  integer range 0 to 511;
        ANIM_CYCLE              : IN  integer range 0 to 65535;
        
        MAP_READ_ADDRESS        : OUT integer range 0 to 2047;
        MAP_DATA_IN             : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        TILE_GFX_READ_ADDRESS   : OUT integer range 0 to 8191;
        TILE_GFX_DATA_IN        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        BUFFER_WRITE_ADDRESS    : OUT integer range 0 to 319;
        BUFFER_WRITE_DATA       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE     : OUT STD_LOGIC;
        
        COLLISION_WRITE_ADDRESS : OUT integer range 0 to 511;
        COLLISION_WRITE_DATA    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        COLLISION_WRITE_STROBE  : OUT STD_LOGIC
        
    );
END tile_engine;

ARCHITECTURE behavioral OF tile_engine IS

    type state_type is (state_reset,
                        state_0,
                        state_1,
                        state_2,
                        state_3,
                        state_line_done);
                        
    SIGNAl step                         : state_type := state_reset;
    SIGNAl next_step                    : state_type := state_reset;
    
    SIGNAL xaddress                     : integer range 0 to 511 := 0;
    SIGNAL xaddress_pipe_1              : integer range 0 to 511 := 0;
    SIGNAL xaddress_pipe_2              : integer range 0 to 511 := 0;
    SIGNAL next_xaddress                : integer range 0 to 511;
    SIGNAL next_xaddress_pipe_1         : integer range 0 to 511;
    SIGNAL next_xaddress_pipe_2         : integer range 0 to 511;
    
    SIGNAL tileX                        : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
    SIGNAL next_tileX                   : STD_LOGIC_VECTOR(5 DOWNTO 0);
    
    SIGNAL tileY                            : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
    SIGNAL next_tileY                   : STD_LOGIC_VECTOR(4 DOWNTO 0);
    
    SIGNAL pixelX                       : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL next_pixelX                  : STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    SIGNAL pixelY                       : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL next_pixelY                  : STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    SIGNAL next_we                      : STD_LOGIC := '0';
    SIGNAL next_col_we                  : STD_LOGIC := '0';
    
    SIGNAL bread_addr                   : STD_LOGIC_VECTOR(13 DOWNTO 0) := "00000000000000";
    SIGNAL next_bread_addr              : STD_LOGIC_VECTOR(13 DOWNTO 0);
    
    SIGNAL tileID                       : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL bgColor                      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL flipAndRotate                : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL layerPriority                : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL transEnable                  : STD_LOGIC;
    SIGNAL animLength                   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL animSpeed                    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL collisionBits                : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL colorDepth                   : STD_LOGIC;
    
    SIGNAL layerPriority_hold           : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL transEnable_hold             : STD_LOGIC;
    SIGNAL bgColor_hold                 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL collisionBits_hold           : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL colorDepth_hold              : STD_LOGIC;
    
    SIGNAL next_layerPriority_hold      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL next_transEnable_hold        : STD_LOGIC;
    SIGNAL next_bgColor_hold            : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL next_collisionBits_hold      : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL next_colorDepth_hold         : STD_LOGIC;
    
    SIGNAL collisionBitsOut             : STD_LOGIC_VECTOR(3 DOWNTO 0);
    
    SIGNAL xdraw                        : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL ydraw                        : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL adjustedPixelX               : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL adjustedPixelY               : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL adjustedtileID               : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL adjustedPixelX0_hold         : STD_LOGIC := '0';
    SIGNAL next_adjustedPixelX0_hold    : STD_LOGIC;
    
    SIGNAL pixelColor                   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    SIGNAL line_complete                : STD_LOGIC := '0'; 
    
    SIGNAL next_done                    : STD_LOGIC := '0'; 
    
    SIGNAL latch_tile                   : STD_LOGIC := '0'; 
    SIGNAL next_latch_tile              : STD_LOGIC; 
    
    SIGNAL latch_pixel                  : STD_LOGIC := '0'; 
    SIGNAL next_latch_pixel             : STD_LOGIC; 
    
    SIGNAL local_anim_cycle             : integer range 0 to 65535;
    

BEGIN

    -- Y scroll math
    PROCESS(CLK25M,LINE_TO_DRAW,TILE_Y_SCROLL,ANIM_CYCLE)
        VARIABLE Y1         : integer range 0 to 255;
    BEGIN
        IF RISING_EDGE(CLK25M) THEN
            Y1 := LINE_TO_DRAW + TILE_Y_SCROLL;
            ydraw <= std_logic_vector(to_unsigned(Y1, 8));
            local_anim_cycle <= ANIM_CYCLE;
        END IF;
    END PROCESS;
    
    -- X scroll math
    PROCESS(CLK100M,xaddress,TILE_X_SCROLL)
        VARIABLE X1         : integer range 0 to 511;
    BEGIN
        IF RISING_EDGE(CLK100M) THEN
            X1 := xaddress + TILE_X_SCROLL;
            xdraw <= std_logic_vector(to_unsigned(X1, 9));
        END IF;
    END PROCESS;
    
    --Map read address calculation
    PROCESS(tileY,tileX)
        VARIABLE readAddressTemp : STD_LOGIC_VECTOR(10 DOWNTO 0);
    BEGIN
        readAddressTemp := tileY & tileX;
        MAP_READ_ADDRESS <= to_integer(unsigned(readAddressTemp));
    END PROCESS;
    
    --Map data input handling
    PROCESS(CLK100M,MAP_DATA_IN,latch_tile)
    BEGIN
        IF RISING_EDGE(CLK100M) AND (latch_tile = '1') THEN
            --byte 0: tile ID
            tileID <= MAP_DATA_IN(7 downto 0);
            
            --byte 1: transparency color
            bgColor <= MAP_DATA_IN(15 downto 8);
            
            --byte 2: attribute 0
                --bits 0-1: animation length
                --bit 2: transparency enable
                --bits 3-4: layer priority
                --bit 5: flip x
                --bit 6: flip y
                --bit 7: swap x/y
            animLength <= MAP_DATA_IN(17 downto 16);
            transEnable <= MAP_DATA_IN(18);
            layerPriority <= MAP_DATA_IN(20 downto 19);
            flipAndRotate <= MAP_DATA_IN(23 downto 21);
            
            --byte 3: attribute 1
                --bits 0-3: collision bits
                --bits 4-6: animation speed
                --bit 7: 8/4 bit color select (0 = 8 bit, 1 = 4 bit)
            collisionBits <= MAP_DATA_IN(27 downto 24);
            animSpeed <= MAP_DATA_IN(30 downto 28);
            colorDepth <= MAP_DATA_IN(31);
        END IF;
    END PROCESS;
    
    --Tile animation logic
    PROCESS(animSpeed,local_anim_cycle,tileID,animLength)
        VARIABLE animTemp         : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE animState        : STD_LOGIC_VECTOR(2 DOWNTO 0);
        VARIABLE animTemp2        : integer range 0 to 7;
        VARIABLE animState2       : STD_LOGIC_VECTOR(2 DOWNTO 0);
    BEGIN
        animTemp := std_logic_vector(to_unsigned(local_anim_cycle, 16));
        
        CASE animSpeed IS
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
        
        animTemp2 := to_integer(unsigned(animState)) + to_integer(unsigned(tileID));
        animState2 := std_logic_vector(to_unsigned(animTemp2, 3));
        
        CASE animLength IS
            WHEN "01" =>
                adjustedtileID <= tileID(7 downto 1) & animState2(0);
            WHEN "10" =>
                adjustedtileID <= tileID(7 downto 2) & animState2(1 downto 0);
            WHEN "11" =>
                adjustedtileID <= tileID(7 downto 3) & animState2(2 downto 0);
            WHEN others =>
                adjustedtileID <= tileID;
        END CASE;
    END PROCESS;
    
    --Tile flip and rotate math
    PROCESS(pixelX,pixelY,flipAndRotate)
    BEGIN
        CASE flipAndRotate is
            WHEN "000" => --no flip or rotate
                adjustedPixelX <= pixelX;
                adjustedPixelY <= pixelY;
            WHEN "001" => --flip X
                adjustedPixelX <= not pixelX;
                adjustedPixelY <= pixelY;
            WHEN "010" => --flip Y
                adjustedPixelX <= pixelX;
                adjustedPixelY <= not pixelY;
            WHEN "011" => --flip X and Y
                adjustedPixelX <= not pixelX;
                adjustedPixelY <= not pixelY;
            WHEN "100" => --swap X/Y
                adjustedPixelX <= pixelY;
                adjustedPixelY <= pixelX;
            WHEN "101" => --swap X/Y, flip X
                adjustedPixelX <= pixelY;
                adjustedPixelY <= not pixelX;
            WHEN "110" => --swap X/Y, flip Y
                adjustedPixelX <= not pixelY;
                adjustedPixelY <= pixelX;
            WHEN "111" => --swap X/Y, flip X and Y
                adjustedPixelX <= not pixelY;
                adjustedPixelY <= not pixelX;
            WHEN others =>
                adjustedPixelX <= pixelX;
                adjustedPixelY <= pixelY;
        END CASE;
    END PROCESS;
    
    --Line complete detection
    PROCESS(xaddress_pipe_2)
    BEGIN
        IF xaddress_pipe_2 = 319 THEN
            line_complete <= '1';
        ELSE
            line_complete <= '0';
        END IF;
    END PROCESS;
    
    --Pixel color select math
    PROCESS(CLK100M,latch_pixel,TILE_GFX_DATA_IN,bgColor_hold,colorDepth_hold,adjustedPixelX0_hold)
    BEGIN
        IF RISING_EDGE(CLK100M) AND (latch_pixel = '1') THEN
            IF colorDepth_hold = '1' THEN --4 bits per pixel
                IF adjustedPixelX0_hold = '0' THEN
                    pixelColor <= bgColor_hold(7 downto 4) & TILE_GFX_DATA_IN(7 downto 4);
                ELSE
                    pixelColor <= bgColor_hold(7 downto 4) & TILE_GFX_DATA_IN(3 downto 0);
                END IF;
            ELSE
                pixelColor <= TILE_GFX_DATA_IN; --8 bits per pixel
            END IF;
        END IF;
    END PROCESS;
    
    --Pixel transparency detection
    PROCESS(layerPriority_hold,transEnable_hold,bgColor_hold,pixelColor,RUN,collisionBits_hold)
        VARIABLE transparentTile  : STD_LOGIC;
        VARIABLE adjustedPriority : STD_LOGIC_VECTOR(1 DOWNTO 0);
    BEGIN
        IF (bgColor_hold = pixelColor) THEN
            transparentTile := transEnable_hold;
        ELSE
            transparentTile := '0';
        END IF;
        
        if (transparentTile) OR (NOT RUN) THEN
            adjustedPriority := "00";
            collisionBitsOut <= "0000";
        ELSE
            adjustedPriority := layerPriority_hold;
            collisionBitsOut <= collisionBits_hold;
        END IF;
        
        BUFFER_WRITE_DATA <= adjustedPriority & pixelColor;
        
    END PROCESS;
    
    --Bitmap read address calculation
    PROCESS(bread_addr,colorDepth)
        VARIABLE bread_addr_out : STD_LOGIC_VECTOR(12 DOWNTO 0);
    BEGIN
        IF colorDepth = '1' THEN
            bread_addr_out := bread_addr(13 downto 1); --4 bits per pixel
        ELSE
            bread_addr_out := bread_addr(12 downto 0); --8 bits per pixel
        END IF;
        TILE_GFX_READ_ADDRESS <= to_integer(unsigned(bread_addr_out));
    END PROCESS;

    --State engine - next state value calculation
    PROCESS(step,RESET_SCREEN,RESET_LINE,line_complete,xdraw,ydraw,tileX,tileY,pixelX,pixelY,
            adjustedtileID,bread_addr,xaddress,xaddress_pipe_1,layerPriority,transEnable,
            bgColor,collisionBits,colorDepth,adjustedPixelX,adjustedPixelY,layerPriority_hold,
            bgColor_hold,transEnable_hold,collisionBits_hold,colorDepth_hold,xaddress_pipe_2,
            adjustedPixelX0_hold)
        VARIABLE loadTAddr : STD_LOGIC;
        VARIABLE loadBAddr : STD_LOGIC;
        VARIABLE zeroXaddr : STD_LOGIC;
        VARIABLE incXaddr : STD_LOGIC;
        VARIABLE reset : STD_LOGIC;
        
    BEGIN
        reset := RESET_SCREEN OR RESET_LINE;
        
        CASE step IS
            WHEN state_reset =>
                next_we <= '0';
                next_col_we <= '0';
                zeroXaddr := '1';
                incXaddr := '0';
                loadTAddr := '0';
                loadBAddr := '0';
                next_done <= '0';
                next_latch_tile <= '0';
                next_latch_pixel <= '0';
                
                IF reset THEN
                    next_step <= state_reset;
                ELSE
                    next_step <= state_0;
                END IF;
                
                -- Interleaved pipelined tile engine
                -- 4 stages, but 3 pixels are being processed at once.
        
            WHEN state_0 =>
            
                -- Step 0:
                --      Calculate the next tile address from line to draw, xaddress, x and y scroll registers
                --      Calculate adjusted tile ID from tile ID and animation flags (from tile data in)
                --      Calculate adjusted pixel x,y from pixel x,y and flip/rotate flags (from tile data in)
                --      Calculate the pixel and priority data output from bitmap data in and pipelined color depth, layer priority, and transparency flags and color
                --          (from bitmap data in, and pipelined tile data in)
                --      Exit from the loop if line complete flag is set. (last pixel will still get written)
            
                next_we <= '1';
                next_col_we <= '1';
                zeroXaddr := '0';
                incXaddr := '0';
                loadTAddr := '1';
                loadBAddr := '1';
                next_done <= '0';
                next_latch_tile <= '0';
                next_latch_pixel <= '0';
                
                IF (line_complete) THEN
                    next_step <= state_line_done;
                ELSE
                    next_step <= state_1;
                END IF;
                
            WHEN state_1 =>
            
                -- Step 1:
                --      Latch the tile address output from the internal calculated tile address
                --      Latch the bitmap address output from the adjusted tile ID and adjusted pixel x,y
                --      Write the data out to the line buffer (address is second pipelined xaddress)
                --      Write the collision data out to the collision buffer (address is second pipelined xaddress)
                
                next_we <= '0';
                next_col_we <= '0';
                zeroXaddr := '0';
                incXaddr := '1';
                loadTAddr := '0';
                loadBAddr := '0';
                next_done <= '0';
                next_latch_tile <= '0';
                next_latch_pixel <= '0';
                
                next_step <= state_2;
            
            WHEN state_2 =>
            
                -- Step 2:
                --      Tile and bitmap memories are reacting to the address changes.
                --      Increment the x address
                --      Save 2 stages of pipelined x address
                --      Save 1 stage of pipelined color depth, collision flags, layer priority, and transparency flag and color.
                --      Also save the bit 0 of the adjusted pixel x
                --      Line complete flag gets updated after xaddress changes
        
                next_we <= '0';
                next_col_we <= '0';
                zeroXaddr := '0';
                incXaddr := '0';
                loadTAddr := '0';
                loadBAddr := '0';
                next_done <= '0';
                next_latch_tile <= '1';
                next_latch_pixel <= '1';
                
                next_step <= state_3;
            
            WHEN state_3 =>
            
                -- Step 3:
                --      Tile and bitmap data should be valid now
                --      Latch the tile data in (including tileid, color depth, collision flags, priority, transparency, animation, and flip/rotate flags)
                --      Latch the bitmap data in
        
                next_we <= '0';
                next_col_we <= '0';
                zeroXaddr := '0';
                incXaddr := '0';
                loadTAddr := '0';
                loadBAddr := '0';
                next_done <= '0';
                next_latch_tile <= '0';
                next_latch_pixel <= '0';
                
                next_step <= state_0;
                
            WHEN state_line_done =>
                next_we <= '0';
                next_col_we <= '0';
                zeroXaddr := '1';
                incXaddr := '0';
                loadTAddr := '0';
                loadBAddr := '0';
                next_done <= '1';
                next_latch_tile <= '0';
                next_latch_pixel <= '0';
                
                IF (reset) THEN
                    next_step <= state_reset;
                ELSE
                    next_step <= state_line_done;
                END IF;
                
            --WHEN OTHERS =>
            --    next_we <= '0';
            --    next_col_we <= '0';
            --    zeroXaddr := '1';
            --    incXaddr := '0';
            --    loadTAddr := '0';
            --    loadBAddr := '0';
            --    next_done <= '0';
            --    next_latch_tile <= '0';
            --    next_latch_pixel <= '0';
                
            --    next_step <= state_reset;
                
        END CASE;
        
        IF (loadTAddr) THEN
            next_tileX <= xdraw(8 downto 3);
            next_tileY <= ydraw(7 downto 3);
            next_pixelX <= xdraw(2 downto 0);
            next_pixelY <= ydraw(2 downto 0);
        ELSE   
            next_tileX <= tileX;
            next_tileY <= tileY;
            next_pixelX <= pixelX;
            next_pixelY <= pixelY;
        END IF;
        
        IF (loadBAddr) THEN
            next_bread_addr <= adjustedtileID & adjustedPixelY & adjustedPixelX;
        ELSE
            next_bread_addr <= bread_addr;
        END IF;
        
        IF (zeroXaddr) THEN
            next_xaddress <= 0;
            next_xaddress_pipe_1 <= 0;
            next_xaddress_pipe_2 <= 0;
            next_layerPriority_hold <= "00";
            next_transEnable_hold <= '0';
            next_bgColor_hold <= "00000000";
            next_collisionBits_hold <= "0000";
            next_colorDepth_hold <= '1';
            next_adjustedPixelX0_hold <= '0';
        ELSIF (incXaddr) THEN
            next_xaddress <= xaddress + 1;
            next_xaddress_pipe_1 <= xaddress;
            next_xaddress_pipe_2 <= xaddress_pipe_1;
            next_layerPriority_hold <= layerPriority;
            next_transEnable_hold <= transEnable;
            next_bgColor_hold <= bgColor;
            next_collisionBits_hold <= collisionBits;
            next_colorDepth_hold <= colorDepth;
            next_adjustedPixelX0_hold <= adjustedPixelX(0);
        ELSE
            next_xaddress <= xaddress;
            next_xaddress_pipe_1 <= xaddress_pipe_1;
            next_xaddress_pipe_2 <= xaddress_pipe_2;
            next_layerPriority_hold <= layerPriority_hold;
            next_transEnable_hold <= transEnable_hold;
            next_bgColor_hold <= bgColor_hold;
            next_collisionBits_hold <= collisionBits_hold;
            next_colorDepth_hold <= colorDepth_hold;
            next_adjustedPixelX0_hold <= adjustedPixelX0_hold;
        END IF;
        
    END PROCESS;

    --State engine - clocked process
    PROCESS(CLK100M)
    BEGIN
        IF RISING_EDGE(CLK100M) THEN
            step <= next_step;
            
            xaddress_pipe_2 <= next_xaddress_pipe_2;
            xaddress_pipe_1 <= next_xaddress_pipe_1;
            xaddress <= next_xaddress;
            
            layerPriority_hold <= next_layerPriority_hold;
            transEnable_hold <= next_transEnable_hold;
            bgColor_hold <= next_bgColor_hold;
            collisionBits_hold <= next_collisionBits_hold;
            colorDepth_hold <= next_colorDepth_hold;
            adjustedPixelX0_hold <= next_adjustedPixelX0_hold;
            
            tileX <= next_tileX;
            tileY <= next_tileY;
            pixelX <= next_pixelX;
            pixelY <= next_pixelY;
            bread_addr <= next_bread_addr;
            latch_tile <= next_latch_tile; 
            latch_pixel <= next_latch_pixel;
            
            BUFFER_WRITE_STROBE <= next_we AND RUN;
            COLLISION_WRITE_STROBE <= next_col_we;
            COLLISION_WRITE_DATA <= collisionBitsOut;
            DONE <= next_done;
        END IF;
    END PROCESS;
    
    BUFFER_WRITE_ADDRESS <= xaddress_pipe_2;
    COLLISION_WRITE_ADDRESS <= xaddress_pipe_2;
    
END behavioral;