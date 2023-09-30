class II:
    def __init__(self):
        self.value = 0
        
    def dump(self):
        return self.value


    def set(self,V):
        self.value = V & 0xFF
