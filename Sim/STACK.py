class STACK:
    def __init__(self, len_):
        self.len = len_
        self.value = [0]*self.len
        self.pointer = 0
        
    def dump(self):
        return self.value

    def push(self,V):
        if self.pointer >= self.len:
            raise Exception("tried to push to stack when full")
        self.value[self.pointer] = V & 0xFF
        self.pointer += 1


    def pop(self):
        if self.pointer <= 0:
            raise Exception("pop from stack when empty")
        self.pointer -= 1
        return self.value[self.pointer]
        
