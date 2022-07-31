Procedure GenerateEntireProj;
Begin
     // Backplane
     GenerateOutputFiles('D:\Users\erics\Documents\16B\Backplane\Backplane.PrjPcb');
     GenerateOutputFiles('D:\Users\erics\Documents\16B\Control Logic\Control Logic.PrjPcb');

     // Compute
     GenerateOutputFiles('D:\Users\erics\Documents\16B\ALU_Ctrl\ALU_Ctrl.PrjPcb');
     GenerateOutputFiles('D:\Users\erics\Documents\16B\ALU_Logic\ALU_Logic.PrjPcb');
     GenerateOutputFiles('D:\Users\erics\Documents\16B\Scratch\Scratch.PrjPcb');
     GenerateOutputFiles('D:\Users\erics\Documents\16B\Register\Register.PrjPcb');
     // Memories
     GenerateOutputFiles('D:\Users\erics\Documents\16B\Memory_Proto\Memory_Proto.PrjPcb');
     GenerateOutputFiles('D:\Users\erics\Documents\16B\Memory_SRAM\Memory_SRAM.PrjPcb');
     GenerateOutputFiles('D:\Users\erics\Documents\16B\Memory_EEPROM\Memory_EEPROM.PrjPcb');
End;
