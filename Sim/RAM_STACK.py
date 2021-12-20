class STACK:
    def __init__(self, mems):
        self.stack_ptr_initialized=False
        self.starting_addr=0x0000
        self.pointer = 0
        self.max_used = 0
        self.mems = mems

    def get_pointer(self):
        return self.starting_addr-self.pointer

    def push(self,V):
        if self.stack_ptr_initialized:
            self.mems.set(self.starting_addr-self.pointer, V)
        else:
            self.stack_ptr_not_init()

    def inc(self):
        if self.stack_ptr_initialized:
            if self.pointer <= 0:
                raise Exception("inc from stack ptr when empty")
            self.pointer -= 1
        else:
            self.stack_ptr_not_init()

    def dec(self):
        if self.stack_ptr_initialized:
            self.pointer += 1
            if self.pointer > self.max_used:
                self.max_used = self.pointer
        else:
            self.stack_ptr_not_init()


    def pop(self):
        if self.stack_ptr_initialized:
            if self.pointer < 0:
                raise Exception("pop from stack when empty")
            v = self.mems.get(self.starting_addr-self.pointer)
            self.mems.set(self.starting_addr-self.pointer, 0)
            return v
        else:
            self.stack_ptr_not_init()
    
    def get(self,L=0):
        if self.stack_ptr_initialized:
            if L < 0 or L > 1:
                raise Exception("invalid PC byte")
            return ((self.starting_addr-self.pointer) >> (L*8)) & 0xFF
        else:
            self.stack_ptr_not_init()

    def set(self,V,L=0):
        if L < 0 or L > 1:
            raise Exception("invalid PC byte")
        self.starting_addr = ((V << (L*8)) | ( self.starting_addr & (0xFF << ((1-L)*8)) )) & (2**16-1)
        self.pointer = 0
        self.stack_ptr_initialized = True

    def stack_ptr_not_init(self):
        raise Exception("tried to do a stack operation without initializing the SP first")
