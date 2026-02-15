; ###
; lib_ra8876.asm begin
; ###
#once

RA8876_STATUS = RA8876+0 ; status is read only
RA8876_ADDR = RA8876+0 ; address is write only
RA8876_DATA = RA8876+1 ; data is read/write

TFT_SCREEN_WIDTH = 1024
TFT_SCREEN_HEIGHT = 600

; ==========================================
; System and Configuration Registers
; ==========================================
RA8876_SRR = 0x00 ; Software Reset Register
    RA8876_SRR_RST_POS = 0 ; Software Reset. WO
    RA8876_SRR_WARNING_POS = 0 ; Warning condition flag. RO

RA8876_CCR = 0x01 ; Chip Configuration Register
    RA8876_CCR_PLL_EN_POS = 7 ; Reconfigure PLL frequency. R/W. Default = 1
    RA8876_CCR_WAIT_MASK_EN_POS = 6 ; Mask XnWAIT on XnCS deassert. R/W
    RA8876_CCR_KEY_SCAN_EN_POS = 5 ; Key-Scan Enable/Disable. R/W
    RA8876_CCR_TFT_MODE_POS = 3 ; 2 bit TFT Panel I/F Output pin Setting. R/W. Default = 0b01
        RA8876_CCR_TFT_MODE_OUTPUT24 = 0b00
        RA8876_CCR_TFT_MODE_OUTPUT18 = 0b01 ; default
        RA8876_CCR_TFT_MODE_OUTPUT16 = 0b10
        RA8876_CCR_TFT_MODE_NONE = 0b11
    RA8876_CCR_I2C_MASTER_EN_POS = 2 ; I2C master Interface Enable/Disable. R/W
    RA8876_CCR_SERIAL_IF_EN_POS = 1 ; Serial Flash or SPI Interface Enable/Disable. R/W
    RA8876_CCR_HOST_DATA_BUS_MODE_POS = 0 ; Host Data Bus Width Selection. R/W
        RA8876_CCR_HOST_DATA_BUS_MODE_8BIT = 0 ; default
        RA8876_CCR_HOST_DATA_BUS_MODE_16BIT = 1

RA8876_MACR = 0x02 ; Memory Access Control Register
    RA8876_MACR_HOST_FMT_POS = 6 ; 2 bit Host Read/Write image Data Format. RW
        RA8876_MACR_HOST_FMT_DIRECT_WRITE = 0b00 ; default (for all 8 bits MPU I/F, 16 bits MPU I/F with 8bpp data mode 1 & 2, 16 bits MPU I/F with 16/24-bpp data mode 1 & serial host interface)
        RA8876_MACR_HOST_FMT_MASK_HIGH_BYTE = 0b10 ; (ex. 16 bit MPU I/F with 8-bpp data mode 1)
        RA8876_MACR_HOST_FMT_MASK_HIGH_BYTE_EVEN_DATA = 0b11 ; (ex. 16 bit MPU I/F with 24-bpp data mode 2)
    RA8876_MACR_HOST_READ_MEMORY_POS = 4 ; 2 bit Host Read Memory Direction (Only for Graphic Mode). RW
        RA8876_MACR_HOST_READ_MEMORY_LRTB = 0 ; default
        RA8876_MACR_HOST_READ_MEMORY_RLTB = 1
        RA8876_MACR_HOST_READ_MEMORY_TBLR = 2
        RA8876_MACR_HOST_READ_MEMORY_BTLR = 3
    RA8876_MACR_HOST_WRITE_MEMORY_POS = 1 ; 2 bit Host Write Memory Direction (Only for Graphic Mode). RW
        RA8876_MACR_HOST_WRITE_MEMORY_LRTB = 0 ; default
        RA8876_MACR_HOST_WRITE_MEMORY_RLTB = 1
        RA8876_MACR_HOST_WRITE_MEMORY_TBLR = 2
        RA8876_MACR_HOST_WRITE_MEMORY_BTLR = 3

RA8876_ICR = 0x03 ; Input Control Register
    RA8876_ICR_OUTPUT_INV_EN_POS = 7 ; Output to MPU Interrupt pin’s set active high. RW
    RA8876_ICR_EXT_INT_DEBOUNCE_EN_POS = 6 ; External interrupt input (XPS[0] pin) de-bounce. RW
    RA8876_ICR_EXT_INT_TRIGGER_POS = 4 ; 2 bit External interrupt input (XPS[0] pin) trigger type. RW
        RA8876_ICR_EXT_INT_TRIGGER_LOW_LEVEL = 0
        RA8876_ICR_EXT_INT_TRIGGER_FALLING_EDGE = 1
        RA8876_ICR_EXT_INT_TRIGGER_HIGH_LEVEL = 2
        RA8876_ICR_EXT_INT_TRIGGER_RISING_EDGE = 3
    RA8876_ICR_TEXT_MODE_EN_POS = 2 ; Text Mode Enable, otherwise Graphic mode. Before toggle this bit user must make sure core task busy bit in status register is done or idle. RW
    RA8876_ICR_MEMORY_SELECT_POS = 0 ; 2 bit Memory port Read/Write Destination Selection. RW
        RA8876_ICR_MEMORY_SELECT_IMAGE = 0
        RA8876_ICR_MEMORY_SELECT_GAMMA = 1
        RA8876_ICR_MEMORY_SELECT_CURSOR_RAM = 2
        RA8876_ICR_MEMORY_SELECT_PALETTE_RAM = 3

RA8876_MRWDP = 0x04 ; Memory Read/Write Data Port

; ==========================================
; PLL Setting Registers
; ==========================================
RA8876_PPLLC1 = 0x05 ; SCLK PLL Control Register 1
RA8876_PPLLC2 = 0x06 ; SCLK PLL Control Register 2
RA8876_MPLLC1 = 0x07 ; MCLK PLL Control Register 1
RA8876_MPLLC2 = 0x08 ; MCLK PLL Control Register 2
RA8876_SPLLC1 = 0x09 ; CCLK PLL Control Register 1
RA8876_SPLLC2 = 0x0A ; CCLK PLL Control Register 2

; ==========================================
; Interrupt Control Registers
; ==========================================
RA8876_INTEN = 0x0B ; Interrupt Enable Register 
RA8876_INTF = 0x0C ; Interrupt Event Flag Register
RA8876_MINTFR = 0x0D ; Mask Interrupt Flag Register 
RA8876_PUENR = 0x0E ; Pull- high control Register
RA8876_PSFSR = 0x0F ; PDAT for PIO/Key Function Select Register

; ==========================================
; Cursor Setting Registers
; ==========================================
RA8876_GTCCR = 0x3C ; Graphic / Text Cursor Control Register
RA8876_BTCR = 0x3D ; Blink Time Control Register
RA8876_CURHS = 0x3E ; Text Cursor Horizontal Size Register. Default = 0x07
RA8876_CURVS = 0x3F ; Text Cursor Vertical Size Register
RA8876_GCHP0 = 0x40 ; Graphic Cursor Horizontal Position Register 0 (LSB)
RA8876_GCHP1 = 0x41 ; Graphic Cursor Horizontal Position Register 1 (MSB)
RA8876_GCVP0 = 0x42 ; Graphic Cursor Vertical Position Register 0 (LSB)
RA8876_GCVP1 = 0x43 ; Graphic Cursor Vertical Position Register 1 (MSB)
RA8876_GCC0 = 0x44 ; Graphic Cursor Color 0
RA8876_GCC1 = 0x44 ; Graphic Cursor Color 1

; ==========================================
; Canvas and Main Window
; ==========================================
RA8876_CVSSA0 = 0x50 ; Canvas Start Address 0 (LSB)
RA8876_CVSSA1 = 0x51 ; Canvas Start Address 1
RA8876_CVSSA2 = 0x52 ; Canvas Start Address 2
RA8876_CVSSA3 = 0x53 ; Canvas Start Address 3 (MSB)
RA8876_CVS_IMWTH0 = 0x54 ; Canvas Image Width 0 (LSB)
RA8876_CVS_IMWTH1 = 0x55 ; Canvas Image Width 1 (MSB)
RA8876_AWUL_X0 = 0x56 ; Active Window Start X 0 (LSB)
RA8876_AWUL_X1 = 0x57 ; Active Window Start X 1 (MSB)
RA8876_AWUL_Y0 = 0x58 ; Active Window Start Y 0 (LSB)
RA8876_AWUL_Y1 = 0x59 ; Active Window Start Y 1 (MSB)
RA8876_AW_WTH0 = 0x5A ; Active Window Width 0 (LSB)
RA8876_AW_WTH1 = 0x5B ; Active Window Width 1 (MSB)
RA8876_AW_HT0 = 0x5C ; Active Window Height 0 (LSB)
RA8876_AW_HT1 = 0x5D ; Active Window Height 1 (MSB)
RA8876_AW_COLOR = 0x5E ; Active Window Color Depth

; ==========================================
; Geometric Drawing Engine Registers
; ==========================================
RA8876_DCR0 = 0x67 ; Draw Line / Triangle Control Register 0
    RA8876_DCR0_DRAW_EN_POS = 7 ; Draw Line / Triangle Start Signal. WO Start/Stop Drawing function. RO is Drawing function complete
    RA8876_DCR0_FILL_EN_POS = 5 ; RW. Enable fill of triangle
    RA8876_DCR0_DRAW_MODE_POS = 1 ; RW
        RA8876_DCR0_DRAW_MODE_LINE = 0 ; Draw Line
        RA8876_DCR0_DRAW_MODE_TRIANGLE = 1 ; Draw Triangle
RA8876_DLHSR0 = 0x68 ; Draw Line/Square/Triangle Point 1 X-coordinates Register0 (LSB) RW
RA8876_DLHSR1 = 0x69 ; Draw Line/Square/Triangle Point 1 X-coordinates Register1 (MSB) RW
RA8876_DLVSR0 = 0x6A ; Draw Line/Square/Triangle Point 1 Y-coordinates Register0 (LSB) RW
RA8876_DLVSR1 = 0x6B ; Draw Line/Square/Triangle Point 1 Y-coordinates Register1 (MSB) RW
RA8876_DLHER0 = 0x6C ; Draw Line/Square/Triangle Point 2 X-coordinates Register0 (LSB) RW
RA8876_DLHER1 = 0x6D ; Draw Line/Square/Triangle Point 2 X-coordinates Register1 (MSB) RW
RA8876_DLVER0 = 0x6E ; Draw Line/Square/Triangle Point 2 Y-coordinates Register0 (LSB) RW
RA8876_DLVER1 = 0x6F ; Draw Line/Square/Triangle Point 2 Y-coordinates Register1 (MSB) RW
RA8876_DTPH0 = 0x70 ; Draw Triangle Point 3 X-coordinates Register 0 (LSB) RW
RA8876_DTPH1 = 0x71 ; Draw Triangle Point 3 X-coordinates Register 1 (MSB) RW
RA8876_DTPV0 = 0x72 ; Draw Triangle Point 3 Y-coordinates Register 0 (LSB) RW
RA8876_DTPV1 = 0x73 ; Draw Triangle Point 3 Y-coordinates Register 1 (MSB) RW

RA8876_DCR1 = 0x76 ; Draw Circle/Ellipse/Ellipse Curve/Circle Square Control Register 1 
    RA8876_DCR1_DRAW_EN_POS = 7 ; Draw Circle / Ellipse / Square /Circle Square Start Signal. WO Start/Stop Drawing function. RO is Drawing function complete
    RA8876_DCR1_FILL_EN_POS = 6 ; Enable Fill the Circle / Ellipse / Square / Circle Square. RW
    RA8876_DCR1_DRAW_MODE_POS = 4 ; 2 bit Draw Circle / Ellipse / Square / Ellipse Curve / Circle Square Select. RW
        RA8876_DCR1_DRAW_MODE_ELLIPSE = 0b00 ; Draw Circle / Ellipse
        RA8876_DCR1_DRAW_MODE_CURVE = 0b01 ; Draw Circle / Ellipse Curve
        RA8876_DCR1_DRAW_MODE_SQUARE = 0b10 ; Draw Square
        RA8876_DCR1_DRAW_MODE_CIRCLE_SQUARE = 0b01 ; Draw Circle Square
    RA8876_DCR1_DECP_POS = 0 ; 2 bit Draw Circle / Ellipse Curve Part Select(DECP). RW
        RA8876_DCR1_DECP_BL = 0b00 ; bottom-left Ellipse Curve
        RA8876_DCR1_DECP_UL = 0b01 ; upper-left Ellipse Curve
        RA8876_DCR1_DECP_UR = 0b10 ; upper-right Ellipse Curve
        RA8876_DCR1_DECP_BR = 0b11 ; bottom-right Ellipse Curve


; ==========================================
; Foreground and Background Colors
; ==========================================
RA8876_FGCR = 0xD2 ; Foreground Color Register - Red. RW. Default = 0xFF
RA8876_FGCG = 0xD3 ; Foreground Color Register - Green. RW. Default = 0xFF
RA8876_FGCB = 0xD4 ; Foreground Color Register - Blue. RW. Default = 0xFF



; TODO: the rest of the regs

; ==========================================
; Colors
; ==========================================
COLOR65K_BLACK          = 0x0000
COLOR65K_WHITE          = 0xffff
COLOR65K_RED            = 0xf800
COLOR65K_LIGHTRED       = 0xfc10
COLOR65K_DARKRED        = 0x8000
COLOR65K_GREEN          = 0x07e0
COLOR65K_LIGHTGREEN     = 0x87f0
COLOR65K_DARKGREEN      = 0x0400
COLOR65K_BLUE           = 0x001f
COLOR65K_BLUE2          = 0x051f
COLOR65K_LIGHTBLUE      = 0x841f
COLOR65K_DARKBLUE       = 0x0010
COLOR65K_YELLOW         = 0xffe0
COLOR65K_LIGHTYELLOW    = 0xfff0
COLOR65K_DARKYELLOW     = 0x8400
COLOR65K_CYAN           = 0x07ff
COLOR65K_LIGHTCYAN      = 0x87ff
COLOR65K_DARKCYAN       = 0x0410
COLOR65K_MAGENTA        = 0xf81f
COLOR65K_LIGHTMAGENTA   = 0xfc1f
COLOR65K_DARKMAGENTA    = 0x8010
COLOR65K_BROWN          = 0xA145

COLOR65K_GRAYSCALE1     = 2113
COLOR65K_GRAYSCALE2     = 2113*2
COLOR65K_GRAYSCALE3     = 2113*3
COLOR65K_GRAYSCALE4     = 2113*4
COLOR65K_GRAYSCALE5     = 2113*5
COLOR65K_GRAYSCALE6     = 2113*6
COLOR65K_GRAYSCALE7     = 2113*7
COLOR65K_GRAYSCALE8     = 2113*8
COLOR65K_GRAYSCALE9     = 2113*9
COLOR65K_GRAYSCALE10    = 2113*10
COLOR65K_GRAYSCALE11    = 2113*11
COLOR65K_GRAYSCALE12    = 2113*12
COLOR65K_GRAYSCALE13    = 2113*13
COLOR65K_GRAYSCALE14    = 2113*14
COLOR65K_GRAYSCALE15    = 2113*15
COLOR65K_GRAYSCALE16    = 2113*16
COLOR65K_GRAYSCALE17    = 2113*17
COLOR65K_GRAYSCALE18    = 2113*18
COLOR65K_GRAYSCALE19    = 2113*19
COLOR65K_GRAYSCALE20    = 2113*20
COLOR65K_GRAYSCALE21    = 2113*21
COLOR65K_GRAYSCALE22    = 2113*22
COLOR65K_GRAYSCALE23    = 2113*23
COLOR65K_GRAYSCALE24    = 2113*24
COLOR65K_GRAYSCALE25    = 2113*25
COLOR65K_GRAYSCALE26    = 2113*26
COLOR65K_GRAYSCALE27    = 2113*27
COLOR65K_GRAYSCALE28    = 2113*28
COLOR65K_GRAYSCALE29    = 2113*29
COLOR65K_GRAYSCALE30    = 2113*30

;;
; @function
; @brief ra8876_init
; @section description
;      _______________________
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
; @return returns 0 for sucess
;;
#bank rom
ra8876_init:
    .init:
        __prologue
    
    load b, #0
    .done:
        __epilogue
        ret

;;
; @function
; @brief set graphic cursor x,y position
; @section description
;      _______________________
;  -8 |   .param16_cursor_x   |
;  -7 |_______________________|
;  -6 |   .param16_cursor_y   |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
;;
#bank rom
ra8876_set_graphic_cursor_pos:
    .param16_cursor_x = -8
    .param16_cursor_y = -6
    .init:
        __prologue

    .set_pos:
        load a, (BP), .param16_cursor_x
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_GCHP1 ; Graphic Cursor Horizontal Position Register 1 (MSB)
        load a, (BP), .param16_cursor_x+1
        __store a, RA8876, RA8876_GCHP0 ; Graphic Cursor Horizontal Position Register 0 (LSB)

        load a, (BP), .param16_cursor_y
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_GCVP1 ; Graphic Cursor Vertical Position Register 1 (MSB)
        load a, (BP), .param16_cursor_y+1
        __store a, RA8876, RA8876_GCVP0 ; Graphic Cursor Vertical Position Register 0 (LSB)
    
    .done:
        __epilogue
        ret
    
;;
; @function
; @brief set active window width and height
; @section description
;      _______________________
; -12 |      .param16_x       |
; -11 |_______________________|
; -10 |      .param16_y       |
;  -9 |_______________________|
;  -8 |    .param16_width     |
;  -7 |_______________________|
;  -6 |    .param16_height    |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
;;
#bank rom
ra8876_set_active_window_xywh:
    .param16_x = -2
    .param16_y = -10
    .param16_width = -8
    .param16_height = -6
    .init:
        __prologue

    .set_window:
        load a, (BP), .param16_x
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_AWUL_X1 ; Active Window X 1 (MSB)
        load a, (BP), .param16_x + 1
        __store a, RA8876, RA8876_AWUL_X0 ; Active Window X 0 (LSB)

        load a, (BP), .param16_y
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_AWUL_Y1 ; Active Window Y 1 (MSB)
        load a, (BP), .param16_y + 1
        __store a, RA8876, RA8876_AWUL_Y0 ; Active Window Y 0 (LSB)

        load a, (BP), .param16_width
        and a, #0x1F ; width is only 13 bits
        __store a, RA8876, RA8876_AW_WTH1 ; Active Window Width 1 (MSB)
        load a, (BP), .param16_width + 1
        __store a, RA8876, RA8876_AW_WTH0 ; Active Window Width 0 (LSB)

        load a, (BP), .param16_height
        and a, #0x1F ; height is only 13 bits
        __store a, RA8876, RA8876_AW_HT1 ; Active Window Height 1 (MSB)
        load a, (BP), .param16_height + 1
        __store a, RA8876, RA8876_AW_HT0 ; Active Window Height 0 (LSB)
    
    .done:
        __epilogue
        ret


;;
; @function
; @brief set graphic cursor x,y position
; @section description
;      _______________________
; -10 |      .param16_x       |
;  -9 |_______________________|
;  -8 |      .param16_y       |
;  -7 |_______________________|
;  -6 |    .param16_color     |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
;;
#bank rom
ra8876_put_pixel_16bpp:
    .param16_x = -10
    .param16_y = -8
    .param16_color = -6
    .init:
        __prologue

    .set_cursor_pos:
        load a, (BP), .param16_x
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_GCHP1 ; Graphic Cursor Horizontal Position Register 1 (MSB)
        load a, (BP), .param16_x + 1
        __store a, RA8876, RA8876_GCHP0 ; Graphic Cursor Horizontal Position Register 0 (LSB)

        load a, (BP), .param16_y
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_GCVP1 ; Graphic Cursor Vertical Position Register 1 (MSB)
        load a, (BP), .param16_y + 1
        __store a, RA8876, RA8876_GCVP0 ; Graphic Cursor Vertical Position Register 0 (LSB)
    
    .set_color:
        store #RA8876_MRWDP, RA8876_ADDR ; ram access
        load a, (BP), .param16_color
        store a, RA8876_DATA ; MSB
        load a, (BP), .param16_color + 1
        store a, RA8876_DATA ; LSB

    .done:
        __epilogue
        ret


;;
; @function
; @brief set graphic cursor x,y position
; @section description
;      _______________________
; -14 |      .param16_x       |
; -13 |_______________________|
; -12 |      .param16_y       |
; -11 |_______________________|
; -10 |    .param16_width     |
;  -9 |_______________________|
;  -8 |    .param16_height    |
;  -7 |_______________________|
;  -6 |   .param16_img_ptr    |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;   0 |      .local16_x       |
;   1 |_______________________|
;
;;
#bank rom
ra8876_put_image_16bpp:
    .param16_x = -14
    .param16_y = -12
    .param16_width = -10
    .param16_height = -8
    .param16_img_ptr = -6
    .local16_x = 0
    .init:
        __prologue
        alloc 2

    .init_active_window:
        load a, (BP), .param16_x
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_AWUL_X1 ; Active Window X 1 (MSB)
        load a, (BP), .param16_x + 1
        __store a, RA8876, RA8876_AWUL_X0 ; Active Window X 0 (LSB)

        load a, (BP), .param16_y
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_AWUL_Y1 ; Active Window Y 1 (MSB)
        load a, (BP), .param16_y + 1
        __store a, RA8876, RA8876_AWUL_Y0 ; Active Window Y 0 (LSB)

        load a, (BP), .param16_width
        and a, #0x1F ; width is only 13 bits
        __store a, RA8876, RA8876_AW_WTH1 ; Active Window Width 1 (MSB)
        load a, (BP), .param16_width + 1
        __store a, RA8876, RA8876_AW_WTH0 ; Active Window Width 0 (LSB)

        load a, (BP), .param16_height
        and a, #0x1F ; height is only 13 bits
        __store a, RA8876, RA8876_AW_HT1 ; Active Window Height 1 (MSB)
        load a, (BP), .param16_height + 1
        __store a, RA8876, RA8876_AW_HT0 ; Active Window Height 0 (LSB)

    .init_cursor_pos:
        load a, (BP), .param16_x
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_GCHP1 ; Graphic Cursor Horizontal Position Register 1 (MSB)
        load a, (BP), .param16_x + 1
        __store a, RA8876, RA8876_GCHP0 ; Graphic Cursor Horizontal Position Register 0 (LSB)

        load a, (BP), .param16_y
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_GCVP1 ; Graphic Cursor Vertical Position Register 1 (MSB)
        load a, (BP), .param16_y + 1
        __store a, RA8876, RA8876_GCVP0 ; Graphic Cursor Vertical Position Register 0 (LSB)
    
    .load_img:
        store #RA8876_MRWDP, RA8876_ADDR ; ram access
        ..next_row:
            loadw hl, (BP), .param16_height
            subw hl, #1
            jmc .done
            storew hl, (BP), .param16_height
        
            loadw hl, (BP), .param16_width
            storew hl, (BP), .local16_x ; reset x position
        ..next_col:
            loadw hl, (BP), .local16_x
            subw hl, #1
            jmc ..next_row ; reached end of row
            storew hl, (BP), .local16_x

        ..load_pixel:
            loadw hl, (BP), .param16_img_ptr
            load a, (hl)
            store a, RA8876_DATA ; MSB

            addw hl, #1
            load a, (hl)
            store a, RA8876_DATA ; LSB

            addw hl, #1
            storew hl, (BP), .param16_img_ptr

            jmp ..next_col

    .done:
        dealloc 2
        __epilogue
        ret


;;
; @function
; @brief set foreground color
; @section description
;      _______________________
;  -6 |     .param16_color    |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
;;
#bank rom
ra8876_set_foreground_color_16bpp:
    .param16_color = -6
    .init:
        __prologue

    ; ref: https://gist.github.com/companje/11deb82e807f2cf927b3a0da1646e795
    ; r = (color >> 8) & 0xF8. i.e, MSB & 0xF8
    ; g = (color >> 3) & 0xFC. i.e. ((LSB >> 3) | (MSB << 5)) & 0xF
    ; b = (color << 3) & 0xF8. i.e, LSB << 3

    .r:
        load a, (BP), .param16_color
        and a, #0xF8
        __store a, RA8876, RA8876_FGCR ; Foreground Color Register - Red
    .g:
        load a, (BP), .param16_color
        lshift a
        lshift a
        lshift a
        lshift a
        lshift a
        load b, (BP), .param16_color + 1
        rshift b
        rshift b
        rshift b
        or a, b
        and a, #0xFC
        __store a, RA8876, RA8876_FGCG ; Foreground Color Register - Green
    .b:
        load a, (BP), .param16_color + 1
        lshift a
        lshift a
        lshift a
        __store a, RA8876, RA8876_FGCB ; Foreground Color Register - Blue
    
    .done:
        __epilogue
        ret


;;
; @function
; @brief draw square with fill
; @section description
;      _______________________
; -14 |      .param16_x0      |
; -13 |_______________________|
; -12 |      .param16_y1      |
; -11 |_______________________|
; -10 |      .param16_x1      |
;  -9 |_______________________|
;  -8 |      .param16_y1      |
;  -7 |_______________________|
;  -6 |     .param16_color    |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
;;
#bank rom
ra8876_draw_sqaure_fill:
    .param16_x0 = -14
    .param16_y0 = -12
    .param16_x1 = -10
    .param16_y1 = -8
    .param16_color = -6
    .init:
        __prologue

    .set_foreground_color:
        loadw hl, (BP), .param16_color
        pushw hl
        call ra8876_set_foreground_color_16bpp
        popw hl
    
    .set_x0_coord:
        load a, (BP), .param16_x0
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_DLHSR1 ; MSB
        load a, (BP), .param16_x0 + 1
        __store a, RA8876, RA8876_DLHSR0 ; LSB
    
    .set_y0_coord:
        load a, (BP), .param16_y0
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_DLVSR1 ; MSB
        load a, (BP), .param16_y0 + 1
        __store a, RA8876, RA8876_DLVSR0 ; LSB

    .set_x1_coord:
        load a, (BP), .param16_x1
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_DLHER1 ; MSB
        load a, (BP), .param16_x1 + 1
        __store a, RA8876, RA8876_DLHER0 ; LSB
    
    .set_y1_coord:
        load a, (BP), .param16_y1
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_DLVER1 ; MSB
        load a, (BP), .param16_y1 + 1
        __store a, RA8876, RA8876_DLVER0 ; LSB

    .draw:
        __store #((1 << RA8876_DCR1_DRAW_EN_POS)|(1 << RA8876_DCR1_FILL_EN_POS)|(RA8876_DCR1_DRAW_MODE_SQUARE << RA8876_DCR1_DRAW_MODE_POS)), RA8876, RA8876_DCR1
    
    .done:
        __epilogue
        ret


;;
; @function
; @brief draw square with no fill
; @section description
;      _______________________
; -14 |      .param16_x0      |
; -13 |_______________________|
; -12 |      .param16_y1      |
; -11 |_______________________|
; -10 |      .param16_x1      |
;  -9 |_______________________|
;  -8 |      .param16_y1      |
;  -7 |_______________________|
;  -6 |     .param16_color    |
;  -5 |_______________________|
;  -4 |___________?___________| RESERVED
;  -3 |___________?___________|    .
;  -2 |___________?___________|    .
;  -1 |___________?___________| RESERVED
;
;;
#bank rom
ra8876_draw_sqaure:
    .param16_x0 = -14
    .param16_y0 = -12
    .param16_x1 = -10
    .param16_y1 = -8
    .param16_color = -6
    .init:
        __prologue

    .set_foreground_color:
        loadw hl, (BP), .param16_color
        pushw hl
        call ra8876_set_foreground_color_16bpp
        popw hl
    
    .set_x0_coord:
        load a, (BP), .param16_x0
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_DLHSR1 ; MSB
        load a, (BP), .param16_x0 + 1
        __store a, RA8876, RA8876_DLHSR0 ; LSB
    
    .set_y0_coord:
        load a, (BP), .param16_y0
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_DLVSR1 ; MSB
        load a, (BP), .param16_y0 + 1
        __store a, RA8876, RA8876_DLVSR0 ; LSB

    .set_x1_coord:
        load a, (BP), .param16_x1
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_DLHER1 ; MSB
        load a, (BP), .param16_x1 + 1
        __store a, RA8876, RA8876_DLHER0 ; LSB
    
    .set_y1_coord:
        load a, (BP), .param16_y1
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_DLVER1 ; MSB
        load a, (BP), .param16_y1 + 1
        __store a, RA8876, RA8876_DLVER0 ; LSB

    .draw:
        __store #((1 << RA8876_DCR1_DRAW_EN_POS)|(RA8876_DCR1_DRAW_MODE_SQUARE << RA8876_DCR1_DRAW_MODE_POS)), RA8876, RA8876_DCR1
    
    .done:
        __epilogue
        ret

; macros for storing or loading data from registers
#ruledef
{

    __load a, RA8876, RA8876_STSR => asm ; status register is special
        {
            load a, RA8876_STATUS
        }

    __load b, RA8876, RA8876_STSR => asm ; status register is special
        {
            load b, RA8876_STATUS
        }

    __load a, RA8876, {regaddr: i8} => asm
        {
            store #{regaddr}, RA8876_ADDR
            load a, RA8876_DATA
        }

    __load b, RA8876, {regaddr: i8} => asm    
        {
            store #{regaddr}, RA8876_ADDR
            load b, RA8876_DATA
        }

    __store #{imm: i8}, RA8876, {regaddr: i8} => asm
        {
            store #{regaddr}, RA8876_ADDR
            store #{imm}, RA8876_DATA
        }

    __store a, RA8876, {regaddr: i8} => asm
        {
            store #{regaddr}, RA8876_ADDR
            store a, RA8876_DATA
        }

    __store b, RA8876, {regaddr: i8} => asm
        {
            store #{regaddr}, RA8876_ADDR
            store b, RA8876_DATA
        }
}