import socket
import FreeSimpleGUI as sg

class W5300_REG:
    # ==========================================
    # Mode and Indirect Registers
    # ==========================================
    MR0 = 0x000 # Mode Register (MSB)
    MR1 = 0x001 # Mode Register (LSB)
    MR1_RST_POS = 7 # S/W Reset
    IDM_AR0 = 0x002 # Indirect Mode Address Registe (MSB)
    IDM_AR1 = 0x003 # Indirect Mode Address Registe (LSB)
    IDM_DR0 = 0x004 # Indirect Mode Data Register (MSB)
    IDM_DR1 = 0x005 # Indirect Mode Data Register (LSB)


    # ==========================================
    # Common Registers
    # ==========================================
    IR0 = 0x002 # Interrupt Register (MSB)
    IR1 = 0x003 # Interrupt Register (LSB)
    IMR0 = 0x004 # Interrupt Mask Register (MSB)
    IMR1 = 0x005 # Interrupt Mask Register (LSB)
    SHAR0 = 0x008 # Source Hardware Address Register byte 0
    SHAR1 = 0x009 # Source Hardware Address Register byte 1
    SHAR2 = 0x00A # Source Hardware Address Register byte 2
    SHAR3 = 0x00B # Source Hardware Address Register byte 3
    SHAR4 = 0x00C # Source Hardware Address Register byte 4
    SHAR5 = 0x00D # Source Hardware Address Register byte 5
    GAR0 = 0x010 # Gateway Address Registe byte 0
    GAR1 = 0x011 # Gateway Address Registe byte 1
    GAR2 = 0x012 # Gateway Address Registe byte 2
    GAR3 = 0x013 # Gateway Address Registe byte 3
    SUBR0 = 0x014 # Subnet Mask Register byte 0
    SUBR1 = 0x015 # Subnet Mask Register byte 1
    SUBR2 = 0x016 # Subnet Mask Register byte 2
    SUBR3 = 0x017 # Subnet Mask Register byte 3
    SIPR0 = 0x018 # Source IP Address Register byte 0
    SIPR1 = 0x019 # Source IP Address Register byte 1
    SIPR2 = 0x01A # Source IP Address Register byte 2
    SIPR3 = 0x01B # Source IP Address Register byte 3
    RTR0 = 0x01C # Retransmission Timeout-value Register (MSB)
    RTR1 = 0x01D # Retransmission Timeout-value Register (LSB)
    RCR1 = 0x01F # Retransmission Retry-count Register
    TMSR0 = 0x020 # Transmit Memory Size Register of SOCKET0
    TMSR1 = 0x021 # Transmit Memory Size Register of SOCKET1
    TMSR2 = 0x022 # Transmit Memory Size Register of SOCKET2
    TMSR3 = 0x023 # Transmit Memory Size Register of SOCKET3
    TMSR4 = 0x024 # Transmit Memory Size Register of SOCKET4
    TMSR5 = 0x025 # Transmit Memory Size Register of SOCKET5
    TMSR6 = 0x026 # Transmit Memory Size Register of SOCKET6
    TMSR7 = 0x027 # Transmit Memory Size Register of SOCKET7
    RMSR0 = 0x028 # Receive Memory Size Register of SOCKET0
    RMSR1 = 0x029 # Receive Memory Size Register of SOCKET1
    RMSR2 = 0x02A # Receive Memory Size Register of SOCKET2
    RMSR3 = 0x02B # Receive Memory Size Register of SOCKET3
    RMSR4 = 0x02C # Receive Memory Size Register of SOCKET4
    RMSR5 = 0x02D # Receive Memory Size Register of SOCKET5
    RMSR6 = 0x02E # Receive Memory Size Register of SOCKET6
    RMSR7 = 0x02F # Receive Memory Size Register of SOCKET7
    MTYPER0 = 0x030 # Memory Block Type Register (MSB)
    MTYPER1 = 0x031 # Memory Block Type Register (LSB)
    PATR0 = 0x032 # PPPoE Authentication Register (MSB)
    PATR1 = 0x033 # PPPoE Authentication Register (LSB)
    
    IDR0 = 0x0FE # W5300 ID Register (MSB)
    IDR1 = 0x0FF # W5300 ID Register (LSB)

    # ==========================================
    # Socket Registers
    # ==========================================
    SOCK0 = 0x200 # SOCKET 0 base address
    SOCK1 = 0x240 # SOCKET 1 base address
    SOCK2 = 0x280 # SOCKET 2 base address
    SOCK3 = 0x2C0 # SOCKET 3 base address
    SOCK4 = 0x300 # SOCKET 4 base address
    SOCK5 = 0x340 # SOCKET 5 base address
    SOCK6 = 0x380 # SOCKET 6 base address
    SOCK7 = 0x3C0 # SOCKET 7 base address
    SOCKETS = [SOCK0, SOCK1, SOCK2, SOCK3, SOCK4, SOCK5, SOCK6, SOCK7]
    # use this offsets with socket addresss. i.e. W5300_SOCK3+Sn_MR0
    Sn_MR0 = 0x000 # SOCKET Mode Register (MSB)
    Sn_MR1 = 0x001 # SOCKET Mode Register (LSB)
    Sn_MR1_CLOSE = 0x0 # Closed
    Sn_MR1_TCP = 0x1 # TCP
    Sn_MR1_UDP = 0x2 # UDP
    Sn_MR1_IPRAW = 0x3 # IP RAW
    Sn_MR1_MACRAW = 0x4 # MAC RAW
    Sn_MR1_PPPoE = 0x5 # PPPoE
    Sn_CR = 0x003 # SOCKET Command Register
    Sn_CR_OPEN = 0x01 # It initializes SOCKETn and opens according to protocol type set in Sn_MR(P3:P0)
    Sn_CR_LISTEN = 0x02 # Only valid in TCP mode. Operates SOCKETn as "TCP SERVER"
    Sn_CR_CONNECT = 0x04 # Only valid in TCP mode. Operates SOCKETn as "TCP CLIENT"
    Sn_CR_DISCON = 0x08 # Only valid in TCP mode. Regardless of "TCP SERVER" or “TCP CLINET”, it performs disconnect-process.
    Sn_CR_CLOSE = 0x10 # closes SOCKETn
    Sn_CR_SEND = 0x20 # It transmits data as big as the size of Sn_TX_WRSR
    Sn_CR_SEND_MAC = 0x21 # Valid only in UDP. The basic operation is same as SEND
    Sn_CR_SEND_KEEP = 0x22 # Valid only in TCP mode. Transmits KEEP ALIVE packet
    Sn_CR_RECV = 0x40 # It notifies that the host received the data packet of SOCKETn
    Sn_IMR1 = 0x005 # SOCKET Interrupt Mask Register
    Sn_IR1 = 0x007 # SOCKET Interrupt Register
    Sn_SSR1 = 0x009 # SOCKET SOCKET Status Register
    Sn_SSR1_SOCK_CLOSED = 0x00 # SOCKETn is released
    Sn_SSR1_SOCK_INIT = 0x13 # SOCKETn is open as TCP mode
    Sn_SSR1_SOCK_LISTEN = 0x14 # SOCKETn operates as "TCP SERVER"
    Sn_SSR1_SOCK_ESTABLISHED = 0x17 # TCP connection is established
    Sn_SSR1_SOCK_CLOSE_WAIT = 0x1C # disconnect-request(FIN packet) is received from the peer
    Sn_SSR1_SOCK_UDP = 0x22 # SOCKETn is open as UDP mode
    Sn_SSR1_SOCK_IPRAW = 0x32 # SOCKETn is open as IPRAW mode
    Sn_SSR1_SOCK_MACRAW = 0x42 # SOCKETn is open as MACRAW mode
    Sn_SSR1_SOCK_PPPoE = 0x4F # SOCKETn is open as PPPoE mode
    Sn_PORTR0 = 0x00A # SOCKET Source Port Register (MSB)
    Sn_PORTR1 = 0x00B # SOCKET Source Port Register (LSB)
    Sn_DHAR0 = 0x00C # SOCKET Destination Hardware Address Register
    Sn_DHAR1 = 0x00D # SOCKET Destination Hardware Address Register
    Sn_DHAR2 = 0x00E # SOCKET Destination Hardware Address Register
    Sn_DHAR3 = 0x00F # SOCKET Destination Hardware Address Register
    Sn_DHAR4 = 0x010 # SOCKET Destination Hardware Address Register
    Sn_DHAR5 = 0x011 # SOCKET Destination Hardware Address Register
    Sn_DPORTR0 = 0x012 # SOCKET Destination Port Register (MSB)
    Sn_DPORTR1 = 0x013 # SOCKET Destination Port Register (LSB)
    Sn_DIPR0 = 0x014 # SOCKET Destination IP 
    Sn_DIPR1 = 0x015 # SOCKET Destination IP 
    Sn_DIPR2 = 0x016 # SOCKET Destination IP 
    Sn_DIPR3 = 0x017 # SOCKET Destination IP 
    Sn_MSSR0 = 0x018 # SOCKET Maximum Segment Size (MSB)
    Sn_MSSR1 = 0x019 # SOCKET Maximum Segment Size (LSB)
    Sn_KPALVTR = 0x01A # SOCKET Keep Alive Time Register
    Sn_PROTOR = 0x01B # SOCKET Protocol Number Register
    Sn_TOSR1 = 0x01D # SOCKET TOS Register
    Sn_TTLR1 = 0x01F # SOCKET TTL Register
    Sn_TX_WRSR1 = 0x021 # SOCKET TX Write Size Register
    Sn_TX_WRSR2 = 0x022 # SOCKET TX Write Size Register
    Sn_TX_WRSR3 = 0x023 # SOCKET TX Write Size Register
    Sn_TX_FSR1 = 0x025 # SOCKET TX Free Size Register
    Sn_TX_FSR2 = 0x026 # SOCKET TX Free Size Register
    Sn_TX_FSR3 = 0x027 # SOCKET TX Free Size Register
    Sn_RX_RSR1 = 0x029 # SOCKET RX Receive Size Register
    Sn_RX_RSR2 = 0x02A # SOCKET RX Receive Size Register
    Sn_RX_RSR3 = 0x02B # SOCKET RX Receive Size Register
    Sn_FRAGR1 = 0x02D # SOCKET FLAG Register
    Sn_TX_FIFOR0 = 0x02E # SOCKET TX FIFO Register (MSB)
    Sn_TX_FIFOR1 = 0x02F # SOCKET TX FIFO Register (LSB)
    Sn_RX_FIFOR0 = 0x030 # SOCKET RX FIFO Register (MSB)
    Sn_RX_FIFOR1 = 0x031 # SOCKET RX FIFO Register (LSB)

class ETH_W5300:
    def __init__(self):
        self.reset_regs()
        self.socks = [None]*8

    def reset_regs(self):
        self.regs = [0] * 0x400

        self.regs[W5300_REG.MR0] = 0b00111000
        self.regs[W5300_REG.IDR0] = 0x53
        for s in W5300_REG.SOCKETS:
            self.regs[s + W5300_REG.Sn_MR1] = 0b00100000
            self.regs[s + W5300_REG.Sn_IMR1] = 0xFF
            self.regs[s + W5300_REG.Sn_PORTR0] = 0x13
            self.regs[s + W5300_REG.Sn_PORTR1] = 0x88
            self.regs[s + W5300_REG.Sn_DHAR0] = 0x00
            self.regs[s + W5300_REG.Sn_DHAR1] = 0x08
            self.regs[s + W5300_REG.Sn_DHAR2] = 0xDC
            self.regs[s + W5300_REG.Sn_DHAR3] = 0x01
            self.regs[s + W5300_REG.Sn_DHAR4] = 0x02
            self.regs[s + W5300_REG.Sn_DHAR5] = 0x10
            self.regs[s + W5300_REG.Sn_DPORTR0] = 0x13
            self.regs[s + W5300_REG.Sn_DPORTR1] = 0x88
            self.regs[s + W5300_REG.Sn_DIPR0] = 192
            self.regs[s + W5300_REG.Sn_DIPR1] = 168
            self.regs[s + W5300_REG.Sn_DIPR2] = 0
            self.regs[s + W5300_REG.Sn_DIPR3] = 11
            self.regs[s + W5300_REG.Sn_KPALVTR] = 10
            self.regs[s + W5300_REG.Sn_PROTOR] = 0x01
            self.regs[s + W5300_REG.Sn_TTLR1] = 0x80
       

    def get(self,addr):
        return self.regs[addr & 0x3FF]

    def set(self, addr, V):
        self.regs[addr & 0x3FF] = V & 0xFF


    def sim(self):
        # simulate the internals of the W5300
        # handle soft reset
        if (self.regs[W5300_REG.MR1] >> W5300_REG.MR1_RST_POS) & 1:
            # soft reset
            print("W5300 soft reset")
            self.reset_regs()

        for n,s in enumerate(W5300_REG.SOCKETS):
            if self.regs[s + W5300_REG.Sn_CR]:
                match self.regs[s + W5300_REG.Sn_CR]:
                    case W5300_REG.Sn_CR_CLOSE:
                        print(f"socket {n} close")
                        if self.socks[n]: self.socks[n].close()
                        self.regs[s + W5300_REG.Sn_SSR1] = W5300_REG.Sn_SSR1_SOCK_CLOSED
                    case W5300_REG.Sn_CR_OPEN:
                        match self.regs[s + W5300_REG.Sn_MR1]&0xF:
                            case W5300_REG.Sn_MR1_TCP:
                                print(f"socket {n} open TCP")
                                self.socks[n] = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                                self.regs[s + W5300_REG.Sn_SSR1] = W5300_REG.Sn_SSR1_SOCK_INIT
                            case W5300_REG.Sn_MR1_UDP:
                                print(f"socket {n} open UDP")
                                self.socks[n] = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                                self.regs[s + W5300_REG.Sn_SSR1] = W5300_REG.Sn_SSR1_SOCK_UDP
                            case _:
                                print(f"socket {n} MR mode 0x{self.regs[s + W5300_REG.Sn_MR1]:2X}???")
                    case W5300_REG.Sn_CR_CONNECT:
                        if self.socks[n]:
                            ip = f'{self.regs[s + W5300_REG.Sn_DIPR0]}.{self.regs[s + W5300_REG.Sn_DIPR1]}.{self.regs[s + W5300_REG.Sn_DIPR2]}.{self.regs[s + W5300_REG.Sn_DIPR3]}'
                            port = (self.regs[s + W5300_REG.Sn_DPORTR0] << 8) | self.regs[s + W5300_REG.Sn_DPORTR1]
                            print(f"socket {n} connecting to '{ip}' on port '{port}'")
                            try:
                                self.socks[n].connect((ip, port))
                                self.regs[s + W5300_REG.Sn_SSR1] = W5300_REG.Sn_SSR1_SOCK_ESTABLISHED
                            except:
                                print("socket {n} FAILED to connect!!!")
                    case W5300_REG.Sn_CR_SEND:
                        if self.socks[n]:
                            print(f"socket {n} sending...")
                    case _:
                        print(f"socket {n} CR mode 0x{self.regs[s + W5300_REG.Sn_CR]:2X}???")
                self.regs[s + W5300_REG.Sn_CR] = 0x00


    def gui_get_layout(self):
        return [[
                    sg.Multiline(
                        size=(15,40),
                        font=('courier new',8),
                        justification='left',
                        text_color='black',
                        background_color='white',
                        key='_W5300_REGS_',
                        expand_y=True,
                        expand_x=True
                    )
                ]]
    
    
    def gui_init(self, window):
        self.window = window
        self.gui_update()

    
    def gui_update(self):
        # set reg values. keep scroll position
        regs_scroll_pos = self.window['_W5300_REGS_'].Widget.yview()[0]
        self.window['_W5300_REGS_'].update("\n".join([f"{i:03X}: {x:02X}" for i,x in enumerate(self.regs)]))
        self.window['_W5300_REGS_'].Widget.yview_moveto(regs_scroll_pos)

