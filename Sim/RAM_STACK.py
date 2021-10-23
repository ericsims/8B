class STACK:
    def __init__(self, len_, ram):
        self.len = len_
        self.starting_addr=0x03FF
        self.pointer = 0
        self.max_used = 0
        self.ram = ram.value
        
    def dump(self):
        return self.value

    def push(self,V):
        if self.pointer >= self.len:
            raise Exception("tried to push to stack when full")
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
        
