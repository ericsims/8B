class PC:
    def __init__(self):
        self.value = 0
        
    def dump(self):
        return self.value
        
    def get(self,L):
        if L < 0 or L > 1:
            raise Exception("invalid PC byte")
        return (self.value >> (L*8)) & 0xFF
    
    def inc(self):
        self.value = (self.value + 1) & 0xFFFF

    def set(self,L,V):
        if L < 0 or L > 1:
            raise Exception("invalid PC byte")
        self.value = (V << (L*8)) | ( self.value & (0xFF << ((1-L)*8)) )
