class STACK:
    def __init__(self, ram):
        self.starting_addr=0x3FFF
        self.pointer = 0
        self.max_used = 0
        self.ram = ram.value
        
    def dump(self):
        return self.value

    def push(self,V):
        self.ram[self.starting_addr-self.pointer] = V & 0xFF
        self.pointer += 1
        if self.pointer > self.max_used:
            self.max_used = self.pointer

    def inc(self):
        if self.pointer <= 0:
            raise Exception("inc from stack ptr when empty")
        self.pointer -= 1

    def dec(self):
        self.pointer += 1


    def pop(self):
        if self.pointer <= 0:
            raise Exception("pop from stack when empty")
        v = self.ram[self.starting_addr-self.pointer]
        self.ram[self.starting_addr-self.pointer] = 0
        return v
        
