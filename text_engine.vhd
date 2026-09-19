LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY text_engine IS
    PORT(
        CLK                     : IN  STD_LOGIC;
        RESET_LINE              : IN  STD_LOGIC;
        RESET_SCREEN            : IN  STD_LOGIC;
        RUN                     : IN  STD_LOGIC;
        LINE_TO_DRAW            : IN  integer range 0 to 239;
        DONE                    : OUT STD_LOGIC;
        
        TEXT_WIDTH              : IN  integer range 0 to 7;
        TEXT_Y_SCROLL           : IN  integer range 0 to 255;
        ANIM_CYCLE              : IN  integer range 0 to 65535;
        
        MAP_READ_ADDRESS        : OUT integer range 0 to 2047;
        MAP_DATA_IN             : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        
        FONT_READ_ADDRESS       : OUT integer range 0 to 2047;
        FONT_DATA_IN            : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        
        BUFFER_WRITE_ADDRESS    : OUT integer range 0 to 319;
        BUFFER_WRITE_DATA       : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        BUFFER_WRITE_STROBE     : OUT STD_LOGIC
    );
END text_engine;

ARCHITECTURE behavioral OF text_engine IS

    type state_type is (state_reset,
                        state_load_line,
                        state_read_map_delay,
                        state_read_map_delay2,
                        state_read_map_delay3,
                        state_set_font_pointer,
                        state_font_read_delay,
                        state_font_read_delay2,
                        state_font_read_delay3,
                        state_font_read,
                        state_pixels_write,
                        state_pixels_write_pause,
                        state_next_character,
                        state_line_done);

    SIGNAL xaddress         : integer range 0 to 319 := 0;
    SIGNAL next_xaddress    : integer range 0 to 319 := 0; 
    
    SIGNAL next_we          : STD_LOGIC := '0';
    
    SIGNAL line_complete    : STD_LOGIC := '0';
    
    SIGNAL local_lineToDraw : STD_LOGIC_VECTOR(7 downto 0);
    
    SIGNAL step             : state_type := state_reset;
    SIGNAL next_step        : state_type := state_reset;
    
    SIGNAL map_read_pointer : integer range 0 to 2047;
    SIGNAL next_map_read_pointer : integer range 0 to 2047;
    
    SIGNAL character_id     : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL fg_color         : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL bg_color         : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL blink_en_text      : STD_LOGIC;
    SIGNAL blink_en_attribute : STD_LOGIC;
    SIGNAL attribute_type   : STD_LOGIC_VECTOR(1 downto 0);
    SIGNAL blink_speed      : STD_LOGIC_VECTOR(1 downto 0);
    SIGNAL layer_priority   : STD_LOGIC_VECTOR(1 downto 0);
    
    SIGNAL pixels           : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL next_pixels      : STD_LOGIC_VECTOR(7 downto 0);
    
    SIGNAL count            : integer range 0 to 7;
    SIGNAL next_count       : integer range 0 to 7;
    
    SIGNAL font_read_pointer        : integer range 0 to 2047;
    SIGNAL next_font_read_pointer   : integer range 0 to 2047;
    
    SIGNAL write_data       : STD_LOGIC_VECTOR(7 downto 0);
    
    SIGNAL blink            : STD_LOGIC;
    SIGNAL blink_text       : STD_LOGIC;
    SIGNAL blink_attribute  : STD_LOGIC;
    SIGNAL attribute_pixel  : STD_LOGIC;
    
    SIGNAL animTemp         : STD_LOGIC_VECTOR(10 downto 0);
    
    SIGNAL next_done        : STD_LOGIC;
    
    type xaddress_action is (xaddress_zero,
                             xaddress_keep,
                             xaddress_step);
                             
    type maddress_action is (maddress_load,
                             maddress_keep,
                             maddress_step);

    type pixels_action is (pixels_load,
                           pixels_keep,
                           pixels_shift);
                           
    type count_action is (count_load,
                          count_keep,
                          count_dec);
                          
    SIGNAL reset                      : STD_LOGIC;
                             
BEGIN
    PROCESS(CLK,LINE_TO_DRAW,TEXT_Y_SCROLL,ANIM_CYCLE,MAP_DATA_IN)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            reset <= (RESET_SCREEN) OR (RESET_LINE) OR (NOT RUN);
        END IF;
    
        --IF RISING_EDGE(CLK) AND (load_line = '1') THEN
            local_lineToDraw <= STD_LOGIC_VECTOR(to_unsigned(LINE_TO_DRAW + TEXT_Y_SCROLL,8));
            --local_lineToDraw <= STD_LOGIC_VECTOR(to_unsigned(LINE_TO_DRAW + TEXT_Y_SCROLL,9));
        --END IF;
            
        --IF RISING_EDGE(CLK) AND (read_map = '1') THEN
                    
            animTemp <= STD_LOGIC_VECTOR(to_unsigned(ANIM_CYCLE,11));
                    
            character_id        <= MAP_DATA_IN(7 downto 0);
            fg_color            <= MAP_DATA_IN(15 downto 8);
            bg_color            <= MAP_DATA_IN(23 downto 16);
            blink_en_text       <= MAP_DATA_IN(31);
            blink_en_attribute  <= MAP_DATA_IN(30);
            attribute_type      <= MAP_DATA_IN(29 downto 28);
            blink_speed         <= MAP_DATA_IN(27 downto 26);
            layer_priority      <= MAP_DATA_IN(25 downto 24);
        --END IF;
    END PROCESS;

    PROCESS(clk,animTemp,blink_speed,blink_en_text,blink_en_attribute,blink)
    BEGIN
        CASE blink_speed IS
            WHEN "00" =>
                blink <= animTemp(3);
            WHEN "01" =>
                blink <= animTemp(4);
            WHEN "10" =>
                blink <= animTemp(5);
            WHEN "11" =>
                blink <= animTemp(6);
            WHEN OTHERS =>
                blink <= animTemp(6);
        END CASE;
        blink_text <= blink_en_text AND blink;
        blink_attribute <= blink_en_attribute AND blink;
    END PROCESS;
    
    PROCESS(attribute_type,local_lineToDraw,count,TEXT_WIDTH,clk)
    BEGIN
        CASE attribute_type IS
            WHEN "00" => -- no attribute
                attribute_pixel <= '0';
            WHEN "01" => -- full cursor
                attribute_pixel <= '1';
            WHEN "10" => -- vertical line cursor
                IF (count = TEXT_WIDTH) THEN
                    attribute_pixel <= '1';
                ELSE
                    attribute_pixel <= '0';
                END IF;
            WHEN "11" => -- underscore cursor
                IF (local_lineToDraw(2 downto 0) = "111") THEN
                    attribute_pixel <= '1';
                ELSE
                    attribute_pixel <= '0';
                END IF;
            WHEN OTHERS =>
                attribute_pixel <= '0';
        END CASE;
    END PROCESS;
    
    PROCESS(fg_color,bg_color,pixels,attribute_pixel,blink_attribute,blink_text,clk)
        VARIABLE invert_pixel     : STD_LOGIC;
        VARIABLE draw_pixel       : STD_LOGIC;
    BEGIN
        invert_pixel := attribute_pixel AND NOT blink_attribute;
        draw_pixel := (pixels(7) AND NOT blink_text) XOR (invert_pixel);
        
        IF draw_pixel = '1' THEN
            write_data <= fg_color;
        ELSE
            write_data <= bg_color;
        END IF;
    END PROCESS;
    
    PROCESS(xaddress,clk)
    BEGIN
        IF xaddress = 319 THEN
            line_complete <= '1';
        ELSE
            line_complete <= '0';
        END IF;
    END PROCESS;
              
    PROCESS(clk,step,reset,count,line_complete,xaddress,local_lineToDraw,map_read_pointer,
            FONT_DATA_IN,TEXT_WIDTH,pixels,character_id,font_read_pointer)
        VARIABLE next_xaddress_action       : xaddress_action; 
        VARIABLE next_maddress_action       : maddress_action; 
        VARIABLE next_pixels_action         : pixels_action;
        VARIABLE next_count_action          : count_action;
        VARIABLE load_font_pointer          : STD_LOGIC;
    BEGIN
        CASE step IS
                WHEN state_reset =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_zero;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    IF (reset) THEN
                        next_step <= state_reset;
                    ELSE
                        next_step <= state_load_line;
                    END IF;
                    
                WHEN state_load_line =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_zero;
                    next_maddress_action := maddress_load;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    next_step <= state_read_map_delay;
                    
                WHEN state_read_map_delay =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    next_step <= state_read_map_delay2;
                    
                WHEN state_read_map_delay2 =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    next_step <= state_read_map_delay3;
                    
                WHEN state_read_map_delay3 =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    next_step <= state_set_font_pointer;
                    
                WHEN state_set_font_pointer =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '1';
                    
                    next_step <= state_font_read_delay;
                    
                WHEN state_font_read_delay =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    next_step <= state_font_read_delay2;
                    
                WHEN state_font_read_delay2 =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    next_step <= state_font_read_delay3;
                    
                WHEN state_font_read_delay3 =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    next_step <= state_font_read;
                    
                WHEN state_font_read =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_load;
                    next_count_action := count_load;
                    load_font_pointer := '0';
                    
                    next_step <= state_pixels_write;
                
                WHEN state_pixels_write =>
                    next_we <= '1';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    next_step <= state_pixels_write_pause;
                    
                WHEN state_pixels_write_pause =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_step;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_shift;
                    next_count_action := count_dec;
                    load_font_pointer := '0';
                    
                    IF count = 0 THEN
                        IF line_complete = '1' THEN
                            next_step <= state_line_done;
                        ELSE
                            next_step <= state_next_character;
                        END IF;
                    ELSE
                        next_step <= state_pixels_write;
                    END IF;
                
                WHEN state_next_character =>
                    next_we <= '0';
                    next_done <= '0';
                    
                    next_xaddress_action := xaddress_keep;
                    next_maddress_action := maddress_step;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    next_step <= state_read_map_delay;
                    
                WHEN state_line_done =>
                    next_we <= '0';
                    next_done <= '1';
                    
                    next_xaddress_action := xaddress_zero;
                    next_maddress_action := maddress_keep;
                    next_pixels_action := pixels_keep;
                    next_count_action := count_keep;
                    load_font_pointer := '0';
                    
                    IF (reset) THEN
                        next_step <= state_reset;
                    ELSE
                        next_step <= state_line_done;
                    END IF;
        END CASE;
            
        CASE next_xaddress_action IS
            WHEN xaddress_zero =>
                next_xaddress <= 0;
            WHEN xaddress_keep =>
                next_xaddress <= xaddress;
            WHEN xaddress_step =>
                next_xaddress <= xaddress + 1;
        END CASE;
        
        CASE next_maddress_action IS
            WHEN maddress_load =>
                next_map_read_pointer <= to_integer(unsigned(local_lineToDraw(7 downto 3) & "000000"));
            WHEN maddress_keep =>
                next_map_read_pointer <= map_read_pointer;
            WHEN maddress_step =>
                next_map_read_pointer <= map_read_pointer + 1;
        END CASE;
        
        CASE next_pixels_action IS
            WHEN pixels_load =>
                next_pixels <= FONT_DATA_IN;
            WHEN pixels_keep =>
                next_pixels <= pixels;
            WHEN pixels_shift =>
                next_pixels <= pixels(6 downto 0) & '0';
        END CASE;
        
        CASE next_count_action IS
            WHEN count_load =>
                next_count <= TEXT_WIDTH;
            WHEN count_keep =>
                next_count <= count;
            WHEN count_dec =>
                next_count <= count - 1;
        END CASE;
        
        IF load_font_pointer THEN
            next_font_read_pointer <= to_integer(unsigned(character_id & local_lineToDraw(2 downto 0)));
        ELSE
            next_font_read_pointer <= font_read_pointer;
        END IF;
        
    END PROCESS;

    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK)THEN
            step <= next_step;
            
            xaddress <= next_xaddress;
            count <= next_count;
            pixels <= next_pixels;
            font_read_pointer <= next_font_read_pointer;
            map_read_pointer <= next_map_read_pointer;
            
            DONE <= next_done;
            
            BUFFER_WRITE_STROBE <= next_we;
        END IF;
    END PROCESS;
    
    PROCESS(clk,layer_priority,write_data)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            BUFFER_WRITE_DATA <= layer_priority & write_data;
        END IF;
    END PROCESS;
    
    MAP_READ_ADDRESS <= map_read_pointer;
    FONT_READ_ADDRESS <= font_read_pointer;
    BUFFER_WRITE_ADDRESS <= xaddress;
    
END behavioral;