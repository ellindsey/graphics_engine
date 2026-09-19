LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY timing_control IS
   PORT(
      clk               : IN  STD_LOGIC;
      xpos              : OUT integer range 0 to 1023;
      ypos              : OUT integer range 0 to 1023;
      
      screen_area       : OUT STD_LOGIC;
      hsync             : OUT STD_LOGIC;
      vsync             : OUT STD_LOGIC;
      
      line_reset        : OUT STD_LOGIC;
      screen_reset      : OUT STD_LOGIC;
      engine_run        : OUT STD_LOGIC;
      buffer_swap       : OUT STD_LOGIC;
      line_to_draw      : OUT integer range 0 to 239;
      
      screen_state      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
END timing_control;

--  Basic 640x480 HDMI timing:

--  Pixel Clock           25 MHz
--  Pixel Time            40 ns
--  Horizontal Freq.  31.250 kHz
--  Line Time             32 μs
--  Vertical Freq.    59.523 Hz     (close enough to 60hz)
--  Frame Time          16.8 ms

--  Horizontal Timings
--  Active Pixels        640    (25.6 us)
--  Front Porch           16    (0.64 us)
--  Sync Width            96    (3.84 us)
--  Back Porch            48    (1.92 us)
--  Blanking Total       160    (6.4 us)
--  Total Pixels         800    (32 us)

--  Vertical Timings
--  Active Lines         480    (15.360 ms)
--  Front Porch           10    (0.320 ms)
--  Sync Width             2    (0.064 ms)
--  Back Porch            33    (1.056 ms)
--  Blanking Total        45    (1.44 ms)
--  Total Lines          525    (16.8 ms)

--  Active Pixels    307,200

--  We use pixel doubling as our functional resolution is 320x240.

--  Actual (doubled) line time is 64us (15.625 hz)
--  Actual (doubled) pixel time is 80ns (12.5mhz)


ARCHITECTURE behavior OF timing_control IS

    type state_type is (state_screenarea, 
                        state_screenarea_hblank, 
                        state_screen_evenline_lastpixel,
                        state_screen_oddline_lastpixel,
                        state_screen_lastlines,
                        state_screen_lastlines_hblank,
                        state_vfp,
                        state_vsync,
                        state_vbp,
                        state_setup_next_screen,
                        state_last_blanking_lines,
                        state_final_blanking_pixel);
   
    --SIGNAL count_4              : INTEGER RANGE 0 TO 3 := 0;
    --SIGNAL next_count_4         : INTEGER RANGE 0 TO 3;
                        
    SIGNAL xcount               : INTEGER RANGE 0 TO 1023 := 0;
    SIGNAL ycount               : INTEGER RANGE 0 TO 1023 := 0;
    
    SIGNAL next_xcount          : INTEGER RANGE 0 TO 1023 := 0;
    SIGNAL next_ycount          : INTEGER RANGE 0 TO 1023 := 0;
    
    SIGNAL step                 : state_type := state_screenarea;
    SIGNAL next_step            : state_type := state_screenarea;
    
    SIGNAL int_line_to_draw     : integer range 0 to 239 := 1;
    SIGNAL int_buffer_swap      : STD_LOGIC := '0';
    
    SIGNAL next_screen_area     : STD_LOGIC := '0';
    SIGNAL next_hsync           : STD_LOGIC := '0';
    SIGNAL next_vsync           : STD_LOGIC := '0';
    SIGNAL next_line_reset      : STD_LOGIC := '0';
    SIGNAL next_screen_reset    : STD_LOGIC := '0';
    SIGNAL next_buffer_swap     : STD_LOGIC := '0';
    SIGNAL next_engine_run      : STD_LOGIC := '0';
    SIGNAL next_line_to_draw    : integer range 0 to 239 := 0;
    
    SIGNAL x_last_pixel         : STD_LOGIC := '0';
    SIGNAL x_prep_next_line     : STD_LOGIC := '0';
    SIGNAL x_line_end           : STD_LOGIC := '0';
    SIGNAL y_last_screen_line   : STD_LOGIC := '0';
    SIGNAL y_next_line_start_vsync : STD_LOGIC := '0';
    SIGNAL y_next_line_end_vsync   : STD_LOGIC := '0';
    SIGNAL y_prep_next_screen   : STD_LOGIC := '0';
    SIGNAL y_next_to_last_line  : STD_LOGIC := '0';
    SIGNAL y_last_line          : STD_LOGIC := '0';
    SIGNAL y_odd_line           : STD_LOGIC := '0';
    
    SIGNAL next_vblank          : STD_LOGIC := '0';
    SIGNAl next_hblank          : STD_LOGIC := '0';
    
    SIGNAL vblank               : STD_LOGIC := '0';
    SIGNAl hblank               : STD_LOGIC := '0';
    
BEGIN

--TODO:
--Recode this to have the CLK edge checking only in the clocked state at the end.
--Recode to run off the 100mhz clock like most of the other system logic
--(will need a count to 4 counter to handle the counting at 25mhz increments)
    
    --PROCESS(count_4)    --X and Y count increment
    --BEGIN
    --    next_count_4 <= count_4 + 1;
    --END PROCESS;

    PROCESS(CLK,xcount,ycount)    --X and Y count increment
    BEGIN
        IF FALLING_EDGE(CLK) THEN --do we need this? logic should be static.
        --IF (count_4 = 0) THEN --increment on 25mhz
            IF (xcount = 799) THEN
                next_xcount <= 0;
                IF (ycount = 524) THEN
                    next_ycount <= 0;
                ELSE
                    next_ycount <= ycount + 1;
                END IF;
            ELSE
                next_xcount <= xcount + 1;
                next_ycount <= ycount;
            END IF;
        --ELSE
        --    next_xcount <= xcount;
        --    next_ycount <= ycount;
        END IF;
    END PROCESS;
        
    PROCESS(CLK,ycount,next_hsync) --latches for final line flag
    BEGIN
        IF RISING_EDGE(CLK) THEN --do we need this? logic should be static.
            IF (ycount = 479) THEN
                IF (next_hsync = '1') THEN   --check if this is needed
                    y_last_screen_line <= '1';
                END IF;
            ELSE
                y_last_screen_line <= '0';
            END IF;
            
            IF (ycount = 524) THEN
                IF (next_hsync = '1') THEN    --check if this is needed
                    y_last_line <= '1';
                END IF;
            ELSE
                y_last_line <= '0';
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(CLK,xcount,hsync) --horizontal sync generation
    BEGIN
        IF RISING_EDGE(CLK) THEN --do we need this? logic should be static.
            --IF (next_xcount = 655) THEN
            IF (xcount = 655) THEN
                next_hsync <= '1';
            END IF;
            
            --ELSIF (next_xcount = 751) THEN
            IF (xcount = 751) THEN
                next_hsync <= '0';
            --ELSE
            --    next_hsync <= hsync;
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(xcount,ycount)  --miscellaneous timing flags
    BEGIN
        IF (xcount = 639) THEN
            x_last_pixel <= '1';
        ELSE
            x_last_pixel <= '0';
        END IF;
        
        IF (xcount = 798) THEN
            x_prep_next_line <= '1';
        ELSE
            x_prep_next_line <= '0';
        END IF;
        
        IF (xcount = 799) THEN
            x_line_end <= '1';
        ELSE
            x_line_end <= '0';
        END IF;
        
        IF (ycount = 478) THEN
            y_next_to_last_line <= '1';
        ELSE
            y_next_to_last_line <= '0';
        END IF;
        
        IF (ycount = 488) THEN
            y_next_line_start_vsync <= '1';
        ELSE
            y_next_line_start_vsync <= '0';
        END IF;
        
        IF (ycount = 490) THEN
            y_next_line_end_vsync <= '1';
        ELSE
            y_next_line_end_vsync <= '0';
        END IF;
        
        IF (ycount = 522) THEN
            y_prep_next_screen <= '1';
        ELSE
            y_prep_next_screen <= '0';
        END IF;
        
        IF (ycount mod 2 = 0) THEN
            y_odd_line <= '0';
        ELSE
            y_odd_line <= '1';
        END IF;
    END PROCESS;
    
    --Main state engine
    
    PROCESS(step,
            x_last_pixel,x_prep_next_line,x_line_end,
            y_last_line,y_next_line_start_vsync,y_next_line_end_vsync,
            y_prep_next_screen,y_odd_line,y_last_screen_line,
            int_line_to_draw,int_buffer_swap,y_next_to_last_line)
    BEGIN
        CASE step IS
            WHEN state_screenarea =>   --screen area horizontal line
                next_screen_area <= '1';
                next_vsync <= '0';
                next_line_reset <= '0';
                next_screen_reset <= '0';
                next_engine_run <= '1';
                next_line_to_draw <= int_line_to_draw;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '0';
                next_vblank <= '0';
                
                IF x_last_pixel = '1' THEN
                    next_step <= state_screenarea_hblank;
                ELSE
                    next_step <= state_screenarea;
                END IF;
              
              WHEN state_screenarea_hblank => --screen area horizontal blank
                next_screen_area <= '0';
                next_vsync <= '0';
                next_line_reset <= '0';
                next_screen_reset <= '0';
                next_engine_run <= '1';
                next_line_to_draw <= int_line_to_draw;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '1';
                next_vblank <= '0';
                
                IF x_prep_next_line = '1' THEN
                    IF y_next_to_last_line = '1' THEN
                        next_step <= state_screen_lastlines;
                    ELSIF y_odd_line = '1' THEN
                        next_step <= state_screen_oddline_lastpixel;
                    ELSE
                        next_step <= state_screen_evenline_lastpixel;
                    END IF;
                ELSE
                    next_step <= state_screenarea_hblank;
                END IF;
                
            WHEN state_screen_evenline_lastpixel =>   --just before next line, even line, nothing to do here
                next_screen_area <= '0';
                next_vsync <= '0';
                next_line_reset <= '0';
                next_screen_reset <= '0';
                next_engine_run <= '1';
                next_line_to_draw <= int_line_to_draw;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '1';
                next_vblank <= '0';
                
                IF x_line_end = '1' THEN
                    next_step <= state_screenarea;
                ELSE
                    next_step <= state_screen_evenline_lastpixel;
                END IF;
                
            WHEN state_screen_oddline_lastpixel =>   --just before next line, odd line, reset engines and select next line
                next_screen_area <= '0';
                next_vsync <= '0';
                next_line_reset <= '1';
                next_screen_reset <= '0';
                next_engine_run <= '1';
                next_line_to_draw <= int_line_to_draw + 1;
                next_buffer_swap <= NOT int_buffer_swap;
                next_hblank <= '1';
                next_vblank <= '0';
                
                IF x_line_end = '1' THEN
                    next_step <= state_screenarea;
                ELSE
                    next_step <= state_screen_oddline_lastpixel;
                END IF;
                
            WHEN state_screen_lastlines =>   --screen area horizontal line, last 2 lines on screen
                next_screen_area <= '1';
                next_vsync <= '0';
                next_line_reset <= '0';
                next_screen_reset <= '0';
                next_engine_run <= '0';
                next_line_to_draw <= 0;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '0';
                next_vblank <= '0';
                
                IF x_last_pixel = '1' THEN
                    next_step <= state_screen_lastlines_hblank;
                ELSE
                    next_step <= state_screen_lastlines;
                END IF;
                
              WHEN state_screen_lastlines_hblank => --last two lines, horizontal blanking period
                next_screen_area <= '0';
                next_vsync <= '0';
                next_line_reset <= '0';
                next_screen_reset <= '0';
                next_engine_run <= '0';
                next_line_to_draw <= 0;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '1';
                next_vblank <= '0';
                
                IF x_line_end = '1' THEN
                    if y_last_screen_line = '1' THEN
                        next_step <= state_vfp;
                    ELSE
                        next_step <= state_screen_lastlines;
                    END IF;
                ELSE
                    next_step <= state_screen_lastlines_hblank;
                END IF;

            WHEN state_vfp =>   --vertical front porch
                next_screen_area <= '0';
                next_vsync <= '0';
                next_line_reset <= '0';
                next_screen_reset <= '0';
                next_engine_run <= '0';
                next_line_to_draw <= 0;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '0';
                next_vblank <= '1';
                
                IF x_line_end = '1' THEN 
                    IF y_next_line_start_vsync = '1' THEN
                        next_step <= state_vsync;
                    ELSE
                        next_step <= state_vfp;
                    END IF;
                ELSE
                    next_step <= state_vfp;
                END IF;

            WHEN state_vsync =>   --vertical sync
                next_screen_area <= '0';
                next_vsync <= '1';
                next_line_reset <= '0';
                next_screen_reset <= '0';
                next_engine_run <= '0';
                next_line_to_draw <= 0;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '0';
                next_vblank <= '1';

                IF x_line_end = '1' THEN 
                    IF y_next_line_end_vsync = '1' THEN
                        next_step <= state_vbp;
                    ELSE
                        next_step <= state_vsync;
                    END IF;
                ELSE
                    next_step <= state_vsync;
                END IF;

            WHEN state_vbp =>   --vertical back porch
                next_screen_area <= '0';
                next_vsync <= '0';
                next_line_reset <= '0';
                next_screen_reset <= '0';
                next_engine_run <= '0';
                next_line_to_draw <= 0;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '0';
                next_vblank <= '1';

                IF y_prep_next_screen = '1' AND x_prep_next_line = '1' THEN
                    next_step <= state_setup_next_screen;
                ELSE
                    next_step <= state_vbp;
                END IF;

            WHEN state_setup_next_screen =>   --start to set up for next screen
                next_screen_area <= '0';
                next_vsync <= '0';
                next_line_reset <= '1';
                next_screen_reset <= '1';
                next_engine_run <= '1';
                next_line_to_draw <= 0;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '0';
                next_vblank <= '1';
                
                IF x_line_end = '1' THEN 
                    next_step <= state_last_blanking_lines;
                ELSE
                    next_step <= state_setup_next_screen;
                END IF;
                
            WHEN state_last_blanking_lines =>   --last two lines of blanking inverval
                next_screen_area <= '0';
                next_vsync <= '0';
                next_line_reset <= '0';
                next_screen_reset <= '0';
                next_engine_run <= '1';
                next_line_to_draw <= 0;
                next_buffer_swap <= int_buffer_swap;
                next_hblank <= '0';
                next_vblank <= '1';
                                
                IF x_prep_next_line = '1' AND y_last_line = '1' THEN
                    next_step <= state_final_blanking_pixel;
                ELSE
                    next_step <= state_last_blanking_lines;
                END IF;

            WHEN state_final_blanking_pixel =>   --final pixel before new screen
                next_screen_area <= '0';
                next_vsync <= '0';
                next_line_reset <= '1';
                next_screen_reset <= '0';
                next_engine_run <= '1';
                next_line_to_draw <= 1;
                next_buffer_swap <= NOT int_buffer_swap;
                next_hblank <= '0';
                next_vblank <= '1';
                
                IF x_line_end = '1' THEN 
                    next_step <= state_screenarea;
                ELSE
                    next_step <= state_final_blanking_pixel;
                END IF;
                
            --WHEN OTHERS =>
            --    next_screen_area <= '0';
            --    next_vsync <= '0';
            --    next_line_reset <= '0';
            --    next_screen_reset <= '0';
            --    next_engine_run <= '0';
            --    next_line_to_draw <= 0;
            --    next_buffer_swap <= '0';
            --    next_hblank <= '0';
            --    next_vblank <= '0';
                
            --    next_step <= state_screenarea;
        END CASE;
    END PROCESS;
            
    --state and output flags updates on clock edges
            
    PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            step <= next_step;
            
            xcount <= next_xcount;
            ycount <= next_ycount;
            screen_area <= next_screen_area;
            hsync <= next_hsync;
            vsync <= next_vsync;
            line_reset <= next_line_reset;
            screen_reset <= next_screen_reset;
            buffer_swap <= next_buffer_swap;
            int_buffer_swap <= next_buffer_swap;
            engine_run <= next_engine_run;
            line_to_draw <= next_line_to_draw;
            int_line_to_draw <= next_line_to_draw;
            
            vblank <= next_vblank;
            hblank <= next_hblank;
            
            if (next_screen_area = '1') THEN
                xpos <= xcount;
                ypos <= ycount;
            ELSE
                xpos <= 0;
                ypos <= 0;
            END IF;
            
            --count_4 <= next_count_4;
            
            screen_state <= (not screen_area) & (not hblank) & (not vblank) & screen_area & hblank & vblank & hsync & vsync;
        END IF;
    END PROCESS;
    
    
END behavior;