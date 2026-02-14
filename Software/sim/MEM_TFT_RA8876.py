from enum import Enum
from PIL import Image, ImageTk
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

    # # ==========================================
    # # Active Window Setup Registers
    # # ==========================================
    # AWUL_X0 = 0x30 # Active Window Upper-Left X 0
    # AWUL_X1 = 0x31 # Active Window Upper-Left X 1
    # AWUL_Y0 = 0x32 # Active Window Upper-Left Y 0
    # AWUL_Y1 = 0x33 # Active Window Upper-Left Y 1
    # AWLR_X0 = 0x34 # Active Window Lower-Right X 0
    # AWLR_X1 = 0x35 # Active Window Lower-Right X 1
    # AWLR_Y0 = 0x36 # Active Window Lower-Right Y 0
    # AWLR_Y1 = 0x37 # Active Window Lower-Right Y 1
    
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

    # # ==========================================
    # # Canvas and Main Window
    # # ==========================================
    # CVSSA0 = 0x50 # Canvas Start Address 0
    # CVSSA1 = 0x51 # Canvas Start Address 1
    # CVSSA2 = 0x52 # Canvas Start Address 2
    # CVSSA3 = 0x53 # Canvas Start Address 3
    # CVS_CGW0 = 0x54 # Canvas Image Width 0
    # CVS_CGW1 = 0x55 # Canvas Image Width 1
    # AW_X0 = 0x56 # Active Window Start X 0
    # AW_X1 = 0x57 # Active Window Start X 1
    # AW_Y0 = 0x58 # Active Window Start Y 0
    # AW_Y1 = 0x59 # Active Window Start Y 1
    # AW_W0 = 0x5A # Active Window Width 0
    # AW_W1 = 0x5B # Active Window Width 1
    # AW_H0 = 0x5C # Active Window Height 0
    # AW_H1 = 0x5D # Active Window Height 1
    # AW_COLOR = 0x5E # Active Window Color Depth

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
    # CCR0 = 0xCC # Character Control Register 0
    # CCR1 = 0xCD # Character Control Register 1
    # FLDR = 0xCE # Font Line Distance Register
    # FSSR = 0xCF # Font Spacing Register
    # CGROMCR = 0xD0 # CGROM Control Register
    # CGROMCR1 = 0xD1 # CGROM Control Register 1
    # ROMCR2 = 0xD2 # CGROM Control Register 2
    # ROMCR3 = 0xD3 # CGROM Control Register 3

    # # ==========================================
    # # Foreground and Background Colors
    # # ==========================================
    # FGCR0 = 0xD4 # Foreground Color Register 0 (Blue)
    # FGCR1 = 0xD5 # Foreground Color Register 1 (Green)
    # FGCR2 = 0xD6 # Foreground Color Register 2 (Red)
    # BGCR0 = 0xD7 # Background Color Register 0 (Blue)
    # BGCR1 = 0xD8 # Background Color Register 1 (Green)
    # BGCR2 = 0xD9 # Background Color Register 2 (Red)
    # FGTCR0 = 0xDA # Foreground Transparent Color 0
    # FGTCR1 = 0xDB # Foreground Transparent Color 1
    # FGTCR2 = 0xDC # Foreground Transparent Color 2
    # BGTCR0 = 0xDD # Background Transparent Color 0
    # BGTCR1 = 0xDE # Background Transparent Color 1
    # BGTCR2 = 0xDF # Background Transparent Color 2

    # # ==========================================
    # # System Control & SDRAM Status
    # # ==========================================
    # SDRST = 0xE0 # SDRAM Status Register
    # SYSRST = 0xE4 # System Reset & Operation Register 

    # # ==========================================
    # # Geometric Drawing Engine Registers
    # # ==========================================
    # DCR0 = 0x76 # Draw Line/Triangle Control Register 0
    # DCR1 = 0x77 # Draw Line/Triangle Control Register 1
    # DLHSR0 = 0x68 # Draw Line/Triangle Start X 0
    # DLHSR1 = 0x69 # Draw Line/Triangle Start X 1
    # DLVSR0 = 0x6A # Draw Line/Triangle Start Y 0
    # DLVSR1 = 0x6B # Draw Line/Triangle Start Y 1
    # DLHER0 = 0x6C # Draw Line/Triangle End X 0
    # DLHER1 = 0x6D # Draw Line/Triangle End X 1
    # DLVER0 = 0x6E # Draw Line/Triangle End Y 0
    # DLVER1 = 0x6F # Draw Line/Triangle End Y 1
    # DTPH0 = 0x70 # Draw Triangle Point 3 X 0
    # DTPH1 = 0x71 # Draw Triangle Point 3 X 1
    # DTPV0 = 0x72 # Draw Triangle Point 3 Y 0
    # DTPV1 = 0x73 # Draw Triangle Point 3 Y 1
    
    # # Circle / Ellipse Drawing
    # CECR0 = 0x7D # Circle/Ellipse Control Register
    # CENX0 = 0x7E # Circle/Ellipse Center X 0
    # CENX1 = 0x7F # Circle/Ellipse Center X 1
    # CENY0 = 0x80 # Circle/Ellipse Center Y 0
    # CENY1 = 0x81 # Circle/Ellipse Center Y 1
    # CRAD0 = 0x82 # Circle Radius / Ellipse Semi-Major Axis 0
    # CRAD1 = 0x83 # Circle Radius / Ellipse Semi-Major Axis 1
    # ERAD0 = 0x84 # Ellipse Semi-Minor Axis 0
    # ERAD1 = 0x85 # Ellipse Semi-Minor Axis 1

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
        if(self.regs[RA8876_REG.ICR] & RA8876_REG.ICR_TEXT_MODE_EN_POS):
            # Text Mode
            pass
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


        # drawing
        # mp_pixels = mp.load()

        # for row in range(self.resolution[1]):
        #   for col in range(self.resolution[0]):
        #     dr_addr = int(col/4)+row*int(128/4)
        #     v = 100
        #     if sram.value[(dr_addr+0xA000)&(sram.size-1)] is not None:
        #       v = ((sram.value[(dr_addr+0xA000)&(sram.size-1)] >> (6-((col%4)*2)) ) & 0b11) * 85
        #       #print(row,col,dr_addr,(col%4)*2,v)
        #     mp_pixels[col,row] = v
        self.window["_SCREEN_"].update(data=ImageTk.PhotoImage(image=self.img))

    @staticmethod
    def rgb565_to_color(x):
        r = ((((x >> 11) & 0x1F) * 527) + 23) >> 6
        g = ((((x >> 5) & 0x3F) * 259) + 33) >> 6
        b = (((x & 0x1F) * 527) + 23) >> 6
        return (r,g,b)