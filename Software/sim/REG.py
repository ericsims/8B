class REG:
    def __init__(self, width=8):
        self.value = 0
        self.width = width
        
    def dump(self):
        return self.value

    def get(self,L=0):
        if L < 0 or L > 1:
            raise Exception("invalid PC byte")
        return (self.value >> (L*8)) & 0xFF

    def set(self,V,L=0):
        if L == 0:
            self.value = ((self.value & 0xFF00) | V) & (2**self.width-1)
        elif L == 1:
            self.value = ((self.value & 0x00FF) | (V<<8)) & (2**self.width-1)
        else:
            raise Exception("invalid PC byte")
        # self.value = ((V << (L*8)) | ( self.value & (0xFF << ((1-L)*8)) )) & (2**self.width-1)
