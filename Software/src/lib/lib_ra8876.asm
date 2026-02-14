; ###
; lib_ra8876.asm begin
; ###
#once

RA8876_STATUS = RA8876+0 ; status is read only
RA8876_ADDR = RA8876+0 ; address is write only
RA8876_DATA = RA8876+1 ; data is read/write

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
; @return returns 0 for sucess
;;
#bank rom
ra8876_set_graphic_cursor_pos:
    .param16_cursor_x = -8
    .param16_cursor_y = -6
    .init:
        __prologue

    .set_pos:
        ; RA8876_GCHP0 Graphic Cursor Horizontal Position Register 0 (LSB)
        ; RA8876_GCHP1 Graphic Cursor Horizontal Position Register 1 (MSB)
        ; RA8876_GCVP0 Graphic Cursor Vertical Position Register 0 (LSB)
        ; RA8876_GCVP1 Graphic Cursor Vertical Position Register 1 (MSB)

        load a, (BP), .param16_cursor_x
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_GCHP1
        load a, (BP), .param16_cursor_x+1
        __store a, RA8876, RA8876_GCHP0

        load a, (BP), .param16_cursor_y
        and a, #0x1F ; postition is only 13 bits
        __store a, RA8876, RA8876_GCVP1
        load a, (BP), .param16_cursor_y+1
        __store a, RA8876, RA8876_GCVP0
    
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
; @return returns 0 for sucess
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