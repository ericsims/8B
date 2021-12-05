class STACK:
    def __init__(self, ram):
        self.starting_addr=0x3FFF
        self.pointer = 0
        self.max_used = 0
        self.ram = ram.value
        
    def dump(self):
        return self.value

    def push(self,V):
        #self.value[self.pointer] = V & 0xFF
        self.ram[self.starting_addr-self.pointer] = V & 0xFF
        self.pointer += 1
        if self.pointer > self.max_used:
            self.max_used = self.pointer


    def pop(self):
        if self.pointer <= 0:
            raise Exception("pop from stack when empty")
        self.pointer -= 1
        v = self.ram[self.starting_addr-self.pointer]
        self.ram[self.starting_addr-self.pointer] = 0
        #return self.value[self.pointer]
        return v
        
