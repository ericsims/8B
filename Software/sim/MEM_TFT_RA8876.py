from enum import Enum
from PIL import Image, ImageTk, ImageDraw, ImageFont
import FreeSimpleGUI as sg


from enum import Enum

class RA8876_REG:
    # ==========================================
    # System and Configuration Registers
    # ==========================================
    SRR = 0x00 # Software Reset Register
    SRR_RST_POS = 0 # Software Reset. WO
    SRR_WARNING_POS = 0 # Warning condition flag. RO
    
    CCR = 0x01 # Chip Configuration Register
    CCR_PLL_EN_POS = 7 # Reconfigure PLL frequency. R/W. Default = 1
    CCR_WAIT_MASK_EN_POS = 6 # Mask XnWAIT on XnCS deassert. R/W
    CCR_KEY_SCAN_EN_POS = 5 # Key-Scan Enable/Disable. R/W
    CCR_TFT_MODE_POS = 3 # 2 bit TFT Panel I/F Output pin Setting. R/W. Default = 0b01
    CCR_TFT_MODE_OUTPUT24 = 0b00
    CCR_TFT_MODE_OUTPUT18 = 0b01 # default
    CCR_TFT_MODE_OUTPUT16 = 0b10
    CCR_TFT_MODE_NONE = 0b11
    CCR_I2C_MASTER_EN_POS = 2 # I2C master Interface Enable/Disable. R/W
    CCR_SERIAL_IF_EN_POS = 1 # Serial Flash or SPI Interface Enable/Disable. R/W
    CCR_HOST_DATA_BUS_MODE_POS = 0 # Host Data Bus Width Selection. R/W
    CCR_HOST_DATA_BUS_MODE_8BIT = 0 # default
    CCR_HOST_DATA_BUS_MODE_16BIT = 1
    
    MACR = 0x02 # Memory Access Control Register
    MACR_HOST_FMT_POS = 6 # 2 bit Host Read/Write image Data Format. RW
    MACR_HOST_FMT_DIRECT_WRITE = 0b00 # default (for all 8 bits MPU I/F, 16 bits MPU I/F with 8bpp data mode 1 & 2, 16 bits MPU I/F with 16/24-bpp data mode 1 & serial host interface)
    MACR_HOST_FMT_MASK_HIGH_BYTE = 0b10 # (ex. 16 bit MPU I/F with 8-bpp data mode 1)
    MACR_HOST_FMT_MASK_HIGH_BYTE_EVEN_DATA = 0b11 # (ex. 16 bit MPU I/F with 24-bpp data mode 2)
    MACR_HOST_READ_MEMORY_POS = 4 # 2 bit Host Read Memory Direction (Only for Graphic Mode). RW
    MACR_HOST_READ_MEMORY_LRTB = 0 # default
    MACR_HOST_READ_MEMORY_RLTB = 1
    MACR_HOST_READ_MEMORY_TBLR = 2
    MACR_HOST_READ_MEMORY_BTLR = 3
    MACR_HOST_WRITE_MEMORY_POS = 1 # 2 bit Host Write Memory Direction (Only for Graphic Mode). RW
    MACR_HOST_WRITE_MEMORY_LRTB = 0 # default
    MACR_HOST_WRITE_MEMORY_RLTB = 1
    MACR_HOST_WRITE_MEMORY_TBLR = 2
    MACR_HOST_WRITE_MEMORY_BTLR = 3
    
    ICR = 0x03 # Input Control Register
    ICR_OUTPUT_INV_EN_POS = 7 # Output to MPU Interrupt pin’s set active high. RW
    ICR_EXT_INT_DEBOUNCE_EN_POS = 6 # External interrupt input (XPS[0] pin) de-bounce. RW
    ICR_EXT_INT_TRIGGER_POS = 4 # 2 bit External interrupt input (XPS[0] pin) trigger type. RW
    ICR_EXT_INT_TRIGGER_LOW_LEVEL = 0
    ICR_EXT_INT_TRIGGER_FALLING_EDGE = 1
    ICR_EXT_INT_TRIGGER_HIGH_LEVEL = 2
    ICR_EXT_INT_TRIGGER_RISING_EDGE = 3
    ICR_TEXT_MODE_EN_POS = 2 # Text Mode Enable, otherwise Graphic mode. Before toggle this bit user must make sure core task busy bit in status register is done or idle. RW
    ICR_MEMORY_SELECT_POS = 0 # 2 bit Memory port Read/Write Destination Selection. RW
    ICR_MEMORY_SELECT_IMAGE = 0
    ICR_MEMORY_SELECT_GAMMA = 1
    ICR_MEMORY_SELECT_CURSOR_RAM = 2
    ICR_MEMORY_SELECT_PALETTE_RAM = 3

    MRWDP = 0x04 # Memory Read/Write Data Port
    # ==========================================
    # PLL Setting Registers
    # ==========================================
    PPLLC1 = 0x05 # SCLK PLL Control Register 1
    PPLLC2 = 0x06 # SCLK PLL Control Register 2
    MPLLC1 = 0x07 # MCLK PLL Control Register 1
    MPLLC2 = 0x08 # MCLK PLL Control Register 2
    SPLLC1 = 0x09 # CCLK PLL Control Register 1
    SPLLC2 = 0x0A # CCLK PLL Control Register 2

    # ==========================================
    # Interrupt Control Registers
    # ==========================================
    INTEN = 0x0B # Interrupt Enable Register 
    INTF = 0x0C # Interrupt Event Flag Register
    MINTFR = 0x0D # Mask Interrupt Flag Register 
    PUENR = 0x0E # Pull- high control Register
    PSFSR = 0x0F # PDAT for PIO/Key Function Select Register

    # # ==========================================
    # # LCD Display Control Registers
    # # ==========================================
    # AWCOLOR = 0x10 # Active Window Color Register
    # DPCR = 0x12 # Display Configuration Register
    # PCSR = 0x13 # Panel Configuration Setting Register
    # HDWR = 0x14 # Horizontal Display Width Register
    # HDWFTR = 0x15 # Horizontal Display Width Fine Tune Register
    # HNDR = 0x16 # Horizontal Non-Display Period Register
    # HNDFTR = 0x17 # Horizontal Non-Display Period Fine Tune Register
    # HSTR = 0x18 # HSYNC Start Position Register
    # HPWR = 0x19 # HSYNC Pulse Width Register
    # VDHR0 = 0x1A # Vertical Display Height Register 0
    # VDHR1 = 0x1B # Vertical Display Height Register 1
    # VNDR0 = 0x1C # Vertical Non-Display Period Register 0
    # VNDR1 = 0x1D # Vertical Non-Display Period Register 1
    # VSTR0 = 0x1E # VSYNC Start Position Register 0
    # VSTR1 = 0x1F # VSYNC Start Position Register 1
    # VPWR = 0x20 # VSYNC Pulse Width Register

    # # ==========================================
    # # Memory and SDRAM Control Registers
    # # ==========================================
    # SDRAR = 0x21 # SDRAM Attribute Register
    # SDRMD = 0x22 # SDRAM Mode Register
    # SDR_REF_L = 0x23 # SDRAM Auto Refresh Interval Register (Low)
    # SDR_REF_H = 0x24 # SDRAM Auto Refresh Interval Register (High)
    # MISA0 = 0x25 # Memory Image Start Address 0
    # MISA1 = 0x26 # Memory Image Start Address 1
    # MISA2 = 0x27 # Memory Image Start Address 2
    # MISA3 = 0x28 # Memory Image Start Address 3
    # MACR1 = 0x29 # Memory Access Control Register 1
    # MIW0 = 0x2A # Memory Image Width 0
    # MIW1 = 0x2B # Memory Image Width 1
    # MWCR1 = 0x2C # Memory Window Control Register 1
    # MWCR2 = 0x2D # Memory Window Control Register 2

    # ==========================================
    # Cursor Setting Registers
    # ==========================================
    GTCCR = 0x3C # Graphic / Text Cursor Control Register
    BTCR = 0x3D # Blink Time Control Register
    CURHS = 0x3E # Text Cursor Horizontal Size Register. Default = 0x07
    CURVS = 0x3F # Text Cursor Vertical Size Register
    GCHP0 = 0x40 # Graphic Cursor Horizontal Position Register 0 (LSB)
    GCHP1 = 0x41 # Graphic Cursor Horizontal Position Register 1 (MSB)
    GCVP0 = 0x42 # Graphic Cursor Vertical Position Register 0 (LSB)
    GCVP1 = 0x43 # Graphic Cursor Vertical Position Register 1 (MSB)
    GCC0 = 0x44 # Graphic Cursor Color 0
    GCC1 = 0x44 # Graphic Cursor Color 1

    # ==========================================
    # Canvas and Main Window
    # ==========================================
    CVSSA0 = 0x50 # Canvas Start Address 0 (LSB)
    CVSSA1 = 0x51 # Canvas Start Address 1
    CVSSA2 = 0x52 # Canvas Start Address 2
    CVSSA3 = 0x53 # Canvas Start Address 3 (MSB)
    CVS_IMWTH0 = 0x54 # Canvas Image Width 0 (LSB)
    CVS_IMWTH1 = 0x55 # Canvas Image Width 1 (MSB)
    AWUL_X0 = 0x56 # Active Window Start X 0 (LSB)
    AWUL_X1 = 0x57 # Active Window Start X 1 (MSB)
    AWUL_Y0 = 0x58 # Active Window Start Y 0 (LSB)
    AWUL_Y1 = 0x59 # Active Window Start Y 1 (MSB)
    AW_WTH0 = 0x5A # Active Window Width 0 (LSB)
    AW_WTH1 = 0x5B # Active Window Width 1 (MSB)
    AW_HT0 = 0x5C # Active Window Height 0 (LSB)
    AW_HT1 = 0x5D # Active Window Height 1 (MSB)
    AW_COLOR = 0x5E # Active Window Color Depth

    # ==========================================
    # Geometric Drawing Engine Registers
    # ==========================================
    DCR0 = 0x67 # Draw Line / Triangle Control Register 0
    DCR0_DRAW_EN_POS = 7 # Draw Line / Triangle Start Signal. WO Start/Stop Drawing function. RO is Drawing function complete
    DCR0_FILL_EN_POS = 5 # RW. Enable fill of triangle
    DCR0_DRAW_MODE_POS = 1 # RW
    DCR0_DRAW_MODE_LINE = 0 # Draw Line
    DCR0_DRAW_MODE_TRIANGLE = 1 # Draw Triangle

    DLHSR0 = 0x68 # Draw Line/Square/Triangle Point 1 X-coordinates Register0 (LSB) RW
    DLHSR1 = 0x69 # Draw Line/Square/Triangle Point 1 X-coordinates Register1 (MSB) RW
    DLVSR0 = 0x6A # Draw Line/Square/Triangle Point 1 Y-coordinates Register0 (LSB) RW
    DLVSR1 = 0x6B # Draw Line/Square/Triangle Point 1 Y-coordinates Register1 (MSB) RW
    DLHER0 = 0x6C # Draw Line/Square/Triangle Point 2 X-coordinates Register0 (LSB) RW
    DLHER1 = 0x6D # Draw Line/Square/Triangle Point 2 X-coordinates Register1 (MSB) RW
    DLVER0 = 0x6E # Draw Line/Square/Triangle Point 2 Y-coordinates Register0 (LSB) RW
    DLVER1 = 0x6F # Draw Line/Square/Triangle Point 2 Y-coordinates Register1 (MSB) RW
    DTPH0 = 0x70 # Draw Triangle Point 3 X-coordinates Register 0 (LSB) RW
    DTPH1 = 0x71 # Draw Triangle Point 3 X-coordinates Register 1 (MSB) RW
    DTPV0 = 0x72 # Draw Triangle Point 3 Y-coordinates Register 0 (LSB) RW
    DTPV1 = 0x73 # Draw Triangle Point 3 Y-coordinates Register 1 (MSB) RW

    DCR1 = 0x76 # Draw Circle/Ellipse/Ellipse Curve/Circle Square Control Register 1 
    DCR1_DRAW_EN_POS = 7 # Draw Circle / Ellipse / Square /Circle Square Start Signal. WO Start/Stop Drawing function. RO is Drawing function complete
    DCR1_FILL_EN_POS = 6 # Enable Fill the Circle / Ellipse / Square / Circle Square. RW
    DCR1_DRAW_MODE_POS = 4 # 2 bit Draw Circle / Ellipse / Square / Ellipse Curve / Circle Square Select. RW
    DCR1_DRAW_MODE_ELLIPSE = 0b00 # Draw Circle / Ellipse
    DCR1_DRAW_MODE_CURVE = 0b01 # Draw Circle / Ellipse Curve
    DCR1_DRAW_MODE_SQUARE = 0b10 # Draw Square
    DCR1_DRAW_MODE_CIRCLE_SQUARE = 0b01 # Draw Circle Square
    DCR1_DECP_POS = 0 # 2 bit Draw Circle / Ellipse Curve Part Select(DECP). RW
    DCR1_DECP_BL = 0b00 # bottom-left Ellipse Curve
    DCR1_DECP_UL = 0b01 # upper-left Ellipse Curve
    DCR1_DECP_UR = 0b10 # upper-right Ellipse Curve
    DCR1_DECP_BR = 0b11 # bottom-right Ellipse Curve


    # ==========================================
    # Foreground and Background Colors
    # ==========================================
    FGCR = 0xD2 # Foreground Color Register - Red. RW. Default = 0xFF
    FGCG = 0xD3 # Foreground Color Register - Green. RW. Default = 0xFF
    FGCB = 0xD4 # Foreground Color Register - Blue. RW. Default = 0xFF

    BGCR = 0xD5 # Background Color Register - Red. RW. Default = 0xFF
    BGCG = 0xD6 # Background Color Register - Green. RW. Default = 0xFF
    BGCB = 0xD7 # Background Color Register - Blue. RW. Default = 0xFF

    # # ==========================================
    # # BTE (Block Transfer Engine) Registers
    # # ==========================================
    # BTE_CTRL0 = 0x90 # BTE Control Register 0
    # BTE_CTRL1 = 0x91 # BTE Control Register 1
    # BTE_COLR = 0x92 # BTE Color Selection Register
    # S0_STR0 = 0x93 # Source 0 Start Address 0
    # S0_STR1 = 0x94 # Source 0 Start Address 1
    # S0_STR2 = 0x95 # Source 0 Start Address 2
    # S0_STR3 = 0x96 # Source 0 Start Address 3
    # S0_W0 = 0x97 # Source 0 Image Width 0
    # S0_W1 = 0x98 # Source 0 Image Width 1
    # S0_X0 = 0x99 # Source 0 X Coordinate 0
    # S0_X1 = 0x9A # Source 0 X Coordinate 1
    # S0_Y0 = 0x9B # Source 0 Y Coordinate 0
    # S0_Y1 = 0x9C # Source 0 Y Coordinate 1
    # S1_STR0 = 0x9D # Source 1 Start Address 0
    # S1_STR1 = 0x9E # Source 1 Start Address 1
    # S1_STR2 = 0x9F # Source 1 Start Address 2
    # S1_STR3 = 0xA0 # Source 1 Start Address 3
    # S1_W0 = 0xA1 # Source 1 Image Width 0
    # S1_W1 = 0xA2 # Source 1 Image Width 1
    # S1_X0 = 0xA3 # Source 1 X Coordinate 0
    # S1_X1 = 0xA4 # Source 1 X Coordinate 1
    # S1_Y0 = 0xA5 # Source 1 Y Coordinate 0
    # S1_Y1 = 0xA6 # Source 1 Y Coordinate 1
    # DT_STR0 = 0xA7 # Destination Start Address 0
    # DT_STR1 = 0xA8 # Destination Start Address 1
    # DT_STR2 = 0xA9 # Destination Start Address 2
    # DT_STR3 = 0xAA # Destination Start Address 3
    # DT_W0 = 0xAB # Destination Image Width 0
    # DT_W1 = 0xAC # Destination Image Width 1
    # DT_X0 = 0xAD # Destination X Coordinate 0
    # DT_X1 = 0xAE # Destination X Coordinate 1
    # DT_Y0 = 0xAF # Destination Y Coordinate 0
    # DT_Y1 = 0xB0 # Destination Y Coordinate 1
    # BTE_W0 = 0xB1 # BTE Window Width 0
    # BTE_W1 = 0xB2 # BTE Window Width 1
    # BTE_H0 = 0xB3 # BTE Window Height 0
    # BTE_H1 = 0xB4 # BTE Window Height 1
    # APB_CTRL = 0xB5 # Alpha Blending Control Register

    # # ==========================================
    # # Text and Font Control Registers
    # # ==========================================
    F_CURX0 = 0x63 # Text Write X-coordinates Register 0 
    F_CURX1 = 0x64 # Text Write X-coordinates Register 1
    F_CURY0 = 0x65 # Text Write Y-coordinates Register 0
    F_CURY1 = 0x66 # Text Write Y-coordinates Register 1


    CCR0 = 0xCC # Character Control Register 0
    CCR0_SOURCE_SELECT_POS = 6 # Character source selection
    CCR0_SOURCE_SELECT_INTERNAL_ROM = 0b00 # Select internal CGROM Character
    CCR0_SOURCE_SELECT_EXTERNAL_ROM = 0b01 # Select external CGROM Character (Genitop serial flash)
    CCR0_SOURCE_SELECT_USER = 0b10 # Select user-defined Character
    CCR0_CHAR_HEIGHT_POS = 4 # Character Height Setting for external CGROM & user-defined Character
    CCR0_CHAR_HEIGHT_16 = 0b00 # ex. 8x16 / 16x16 / variable character width x 16
    CCR0_CHAR_HEIGHT_24 = 0b01 # ex. 12x24 / 24x24 / variable character width x 24
    CCR0_CHAR_HEIGHT_32 = 0b10 # ex. 16x32 / 32x32 / variable character width x 32
    CCR0_INT_CHAR_SELECT_POS = 0 # Character Selection for internal CGROM
    CCR0_INT_CHAR_SELECT_8859_1 = 0b00 # ISO/IEC 8859-1
    CCR0_INT_CHAR_SELECT_8859_2 = 0b01 # ISO/IEC 8859-2
    CCR0_INT_CHAR_SELECT_8859_4 = 0b10 # ISO/IEC 8859-4
    CCR0_INT_CHAR_SELECT_8859_5 = 0b11 # ISO/IEC 8859-5

    CCR1 = 0xCD # Character Control Register 1
    CCR1_FULL_ALIGNMENT_EN_POS = 7 # Full alignment enable
    CCR1_CHROMA_KEY_EN_POS = 6 # Chroma keying enable on Text input Character’s background displayed with original canvas’ background.
    CCR1_CHAR_ROTATE_EN_POS = 4 # Counterclockwise 90 degree & vertical flip
    CCR1_WIDTH_SCALE_POS = 2 # Character width enlargement factor
    CCR1_WIDTH_SCALE_X1 = 0b00
    CCR1_WIDTH_SCALE_X2 = 0b01
    CCR1_WIDTH_SCALE_X3 = 0b10
    CCR1_WIDTH_SCALE_X4 = 0b11
    CCR1_HEIGHT_SCALE_POS = 2 # Character height enlargement factor
    CCR1_HEIGHT_SCALE_X1 = 0b00
    CCR1_HEIGHT_SCALE_X2 = 0b01
    CCR1_HEIGHT_SCALE_X3 = 0b10
    CCR1_HEIGHT_SCALE_X4 = 0b11


    # FLDR = 0xCE # Font Line Distance Register
    # FSSR = 0xCF # Font Spacing Register
    # CGROMCR = 0xD0 # CGROM Control Register
    # CGROMCR1 = 0xD1 # CGROM Control Register 1
    # ROMCR2 = 0xD2 # CGROM Control Register 2
    # ROMCR3 = 0xD3 # CGROM Control Register 3

    # # ==========================================
    # # System Control & SDRAM Status
    # # ==========================================
    # SDRST = 0xE0 # SDRAM Status Register
    # SYSRST = 0xE4 # System Reset & Operation Register 
    

    # # ==========================================
    # # PWM Control Registers
    # # ==========================================
    # PSCLR = 0x8A # PWM Prescaler Register
    # PWM0CTRL = 0x8B # PWM0 Control Register
    # PWM0DUTY = 0x8C # PWM0 Duty Cycle Register
    # PWM1CTRL = 0x8D # PWM1 Control Register
    # PWM1DUTY = 0x8E # PWM1 Duty Cycle Register

class TFT_RA8876:
    def __init__(self,resolution=(1024,600)):
        self.resolution = resolution
        self.reset_regs()
        self.img = Image.new('RGB', list(self.resolution), 0)
        self.ram_writes = []
               
    def reset_regs(self):
        self.reg_status = 0b01010000
        self.reg_addr = 0x00
        self.regs = [0] * 256

        self.regs[RA8876_REG.SRR] = 0b11010110 # addr 0x00
        self.regs[RA8876_REG.CCR] = 0b10001000 # addr 0x01
        self.regs[RA8876_REG.PPLLC1] = 0b00000100 # addr 0x05. Not certain on this default
        self.regs[RA8876_REG.PPLLC2] = 0x17 # addr 0x06
        self.regs[RA8876_REG.MPLLC1] = 0b00000010 # addr 0x07. Not certain on this default
        self.regs[RA8876_REG.MPLLC2] = 0x1D # addr 0x08
        self.regs[RA8876_REG.SPLLC1] = 0b00000100 # addr 0x09. Not certain on this default
        self.regs[RA8876_REG.SPLLC2] = 0x2A # addr 0x0A

        self.regs[RA8876_REG.CURHS] = 0x07 # addr 0x3E
        
        self.regs[RA8876_REG.FGCR] = 0xFF # addr 0xD2
        self.regs[RA8876_REG.FGCG] = 0xFF # addr 0xD3
        self.regs[RA8876_REG.FGCB] = 0xFF # addr 0xD4

        self.regs[RA8876_REG.BGCR] = 0xFF # addr 0xD5
        self.regs[RA8876_REG.BGCG] = 0xFF # addr 0xD6
        self.regs[RA8876_REG.BGCB] = 0xFF # addr 0xD7

        # TODO: the rest of the regs

    def get(self,addr):
        if (addr&0x01) == 0x00:
            # read status reg
            return self.reg_status
        elif (addr&0x01) == 0x01:
            # read data
            return self.regs[self.reg_addr]
        else:
            raise Exception(f"RA8876 byte {addr} not valid")

    def set(self, addr, V):
        if (addr&0x01) == 0x00:
            self.reg_addr = (V & 0xFF)
        elif (addr&0x01) == 0x01:
            # handle the special case for writing the ram port MRWDP
            if self.reg_addr == RA8876_REG.MRWDP:
                self.ram_writes.append(V & 0xFF)
            else:
                self.regs[self.reg_addr] = (V & 0xFF)
        else:
            raise Exception(f"RA8876 byte {addr} not valid")


    def sim(self):
        # simulate the internals of the RA8876
        if (self.regs[RA8876_REG.ICR] & (1<<RA8876_REG.ICR_TEXT_MODE_EN_POS)):
            # Text Mode
            if len(self.ram_writes) >= 1:
                # cursor position
                x = (self.regs[RA8876_REG.F_CURX1] << 8) | self.regs[RA8876_REG.F_CURX0]
                y = (self.regs[RA8876_REG.F_CURY1] << 8) | self.regs[RA8876_REG.F_CURY0]

                # font size
                match (self.regs[RA8876_REG.CCR0] >> RA8876_REG.CCR0_CHAR_HEIGHT_POS) & 0x3:
                    case RA8876_REG.CCR0_CHAR_HEIGHT_16:
                        height = 16
                        width = 8
                    case RA8876_REG.CCR0_CHAR_HEIGHT_24:
                        height = 24
                        width = 12
                    case RA8876_REG.CCR0_CHAR_HEIGHT_32:
                        height = 32
                        width = 16
                    case _:
                        height = 16
                        width = 8


                text_img = Image.new('RGBA', [width, height], (0, 0, 0, 0))
                text_draw = ImageDraw.Draw(text_img)
                font = None

                
                # background and foreground colors
                br, bg, bb = self.regs[RA8876_REG.BGCR], self.regs[RA8876_REG.BGCG], self.regs[RA8876_REG.BGCB]
                fr, fg, fb = self.regs[RA8876_REG.FGCR], self.regs[RA8876_REG.FGCG], self.regs[RA8876_REG.FGCB]

                if not ((self.regs[RA8876_REG.CCR1] >> RA8876_REG.CCR1_CHROMA_KEY_EN_POS) & 0x1):
                    # if chroma keying is disabled, fill with background color
                    text_draw.rectangle(((0, 0), (width, height)), fill=(br, bg, bb, 255)) # fill


                char_data = bytes([self.ram_writes.pop(0)])
                char = '?'
                if (self.regs[RA8876_REG.CCR0] >> RA8876_REG.CCR0_SOURCE_SELECT_POS) & 0x3 == RA8876_REG.CCR0_SOURCE_SELECT_INTERNAL_ROM:
                    font = ImageFont.truetype("sim/AcPlus_ToshibaSat_8x16.ttf", size=height)
                    match (self.regs[RA8876_REG.CCR0] >> RA8876_REG.CCR0_INT_CHAR_SELECT_POS) & 0x3:
                        case RA8876_REG.CCR0_INT_CHAR_SELECT_8859_1:
                            char = char_data.decode('iso-8859-1')
                        case RA8876_REG.CCR0_INT_CHAR_SELECT_8859_2:
                            char = char_data.decode('iso-8859-2')
                        case RA8876_REG.CCR0_INT_CHAR_SELECT_8859_4:
                            char = char_data.decode('iso-8859-4')
                        case RA8876_REG.CCR0_INT_CHAR_SELECT_8859_5:
                            char = char_data.decode('iso-8859-5')
                
                if font:
                    text_draw.text((0, 0), char, fill=(fr, fg, fb, 255), font=font)

                    # copy character image buffer into image
                    self.img.paste(text_img, (x, y), mask=text_img)
                
                # increment cursor
                x += width
                self.regs[RA8876_REG.F_CURX1] = x >> 8
                self.regs[RA8876_REG.F_CURX0] = x & 0xFF
                
        else:
            # Graphics Mode
            if len(self.ram_writes) >= 2:
                # pixel ram was written
                # write pixel
                color_msb = self.ram_writes.pop(0)
                color_lsb = self.ram_writes.pop(0)
                color565 = (color_msb << 8) | color_lsb

                color = TFT_RA8876.rgb565_to_color(color565)
                x = (self.regs[RA8876_REG.GCHP1] << 8) | self.regs[RA8876_REG.GCHP0]
                y = (self.regs[RA8876_REG.GCVP1] << 8) | self.regs[RA8876_REG.GCVP0]
                # print(x,y,color)
                self.img.putpixel((x, y), color)

                # increment cursor in active window
                aw_x = (self.regs[RA8876_REG.AWUL_X1] << 8) | self.regs[RA8876_REG.AWUL_X0]
                aw_y = (self.regs[RA8876_REG.AWUL_Y1] << 8) | self.regs[RA8876_REG.AWUL_Y0]
                aw_wd = (self.regs[RA8876_REG.AW_WTH1] << 8) | self.regs[RA8876_REG.AW_WTH0]
                aw_ht = (self.regs[RA8876_REG.AW_HT1] << 8) | self.regs[RA8876_REG.AW_HT0]

                x += 1
                if x >= (aw_x+aw_wd):
                    # wrap row at edge of active window
                    x = aw_x
                    y += 1
                
                # write back cursor position
                self.regs[RA8876_REG.GCHP1] = (x >> 8) & 0xFF
                self.regs[RA8876_REG.GCHP0] = x & 0xFF
                self.regs[RA8876_REG.GCVP1] = (y >> 8) & 0xFF
                self.regs[RA8876_REG.GCVP0] = y & 0xFF
        
        # Geometric Draw Circle / Ellipse / Square / Circle Square
        if (self.regs[RA8876_REG.DCR1] >> RA8876_REG.DCR1_DRAW_EN_POS) & 1:
            x0 = (self.regs[RA8876_REG.DLHSR1] << 8) | self.regs[RA8876_REG.DLHSR0]
            y0 = (self.regs[RA8876_REG.DLVSR1] << 8) | self.regs[RA8876_REG.DLVSR0]
            x1 = (self.regs[RA8876_REG.DLHER1] << 8) | self.regs[RA8876_REG.DLHER0]
            y1 = (self.regs[RA8876_REG.DLVER1] << 8) | self.regs[RA8876_REG.DLVER0]
            r, g, b = self.regs[RA8876_REG.FGCR], self.regs[RA8876_REG.FGCG], self.regs[RA8876_REG.FGCB]
            if x0 > x1: x0, x1 = x1, x0 # ImageDraw function requires x1 > y0
            if y0 > y1: y0, y1 = y1, y0 # ImageDraw function requires y1 > y0

            draw = ImageDraw.Draw(self.img)

            # check draw mode Circle / Ellipse / Square / Circle Square
            match (self.regs[RA8876_REG.DCR1] >> RA8876_REG.DCR1_DRAW_MODE_POS) & 0b11:
                case RA8876_REG.DCR1_DRAW_MODE_SQUARE:
                    if (self.regs[RA8876_REG.DCR1] >> RA8876_REG.DCR1_FILL_EN_POS) & 1 :
                        draw.rectangle(((x0, y0), (x1, y1)), fill=(r, g, b)) # fill
                    else:
                        draw.rectangle(((x0, y0), (x1, y1)), outline=(r, g, b), width=1)  # no fill
                case RA8876_REG.DCR1_DRAW_MODE_CIRCLE_SQUARE:
                    print("SIM DOES NOT SUPPORT CIRCLE SQUARE YET")
                case RA8876_REG.DCR1_DRAW_MODE_ELLIPSE:
                    print("SIM DOES NOT SUPPORT ELLIPSE YET")
                case RA8876_REG.DCR1_DRAW_MODE_CURVE:
                    print("SIM DOES NOT SUPPORT CURVE YET")

            # drawing complete. clear draw bit
            self.regs[RA8876_REG.DCR1] &= ~(1<<RA8876_REG.DCR1_DRAW_EN_POS)

         # Geometric Draw Line / Triangle
        if (self.regs[RA8876_REG.DCR0] >> RA8876_REG.DCR0_DRAW_EN_POS) & 1:
            print("SIM DOES NOT SUPPORT LINE / TRIANGLE YET")
            # drawing complete. clear draw bit
            self.regs[RA8876_REG.DCR0] &= ~(1<<RA8876_REG.DCR0_DRAW_EN_POS)


    def gui_get_layout(self):
        return   [[
            sg.Column([
                [
                    sg.T('ADDR     '),
                    sg.T(
                    text='',
                    size=(2,1),
                    justification='left',
                    text_color='black',
                    background_color='white',
                    key='_RA8876_ADDR_'
                    )
                ],
                [
                    sg.T('STATUS   '),
                    sg.T(
                    text='',
                    size=(2,1),
                    justification='left',
                    text_color='black',
                    background_color='white',
                    key='_RA8876_STATUS_'
                    )
                ],
                [
                    sg.Multiline(
                        size=(15,40),
                        font=('courier new',8),
                        justification='left',
                        text_color='black',
                        background_color='white',
                        key='_RA8876_REGS_',
                        expand_y=True,
                        expand_x=True
                    ),
                    sg.Frame('',[[sg.Image(key="_SCREEN_", size=self.resolution)]])
                ]
            ], vertical_alignment='t', expand_y=False, expand_x=False),
        ]]
    
    
    def gui_init(self, window):
        self.window = window
        self.gui_update()

    
    def gui_update(self):
        # update register displays
        self.window['_RA8876_ADDR_'].update(f"{self.reg_addr:02X}")
        self.window['_RA8876_STATUS_'].update(f"{self.reg_status:02X}")
        
        # set reg values. keep scroll position
        regs_scroll_pos = self.window['_RA8876_REGS_'].Widget.yview()[0]
        self.window['_RA8876_REGS_'].update("\n".join([f"{i:02X}: {x:02X}" for i,x in enumerate(self.regs)]))
        self.window['_RA8876_REGS_'].Widget.yview_moveto(regs_scroll_pos)

        # display screen image
        self.window["_SCREEN_"].update(data=ImageTk.PhotoImage(image=self.img))

    @staticmethod
    def rgb565_to_color(x):
        r = ((((x >> 11) & 0x1F) * 527) + 23) >> 6
        g = ((((x >> 5) & 0x3F) * 259) + 33) >> 6
        b = (((x & 0x1F) * 527) + 23) >> 6
        return (r,g,b)