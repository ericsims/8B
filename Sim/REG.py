class REG:
    def __init__(self):
        self.value = 0
        
    def dump(self):
        return self.value

    def get(self):
        return self.value & 0xFF

    def set(self,V):
        self.value = V & 0xFF
