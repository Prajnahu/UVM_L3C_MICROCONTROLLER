class imem_mem_transaction extends imem_transaction;

  `uvm_object_utils( imem_mem_transaction )

  constraint memory_only_c {
    opcode inside { OP_LD, OP_LDI, OP_LDR, OP_LEA, OP_ST, OP_STI, OP_STR };
  }

  constraint offset_corners_c {
    ( opcode inside { OP_LD, OP_LDI, OP_LEA, OP_ST, OP_STI } ) -> {
      operands[8:0] dist { 9'd0 := 2, 9'd255 := 2, 9'd256 := 2, 9'd511 := 2, [9'd1:9'd254] :/ 3, [9'd257:9'd510] :/ 3 };
    }
    ( opcode inside { OP_LDR, OP_STR } ) -> {
      operands[5:0] dist { 6'd0 := 2, 6'd31 := 2, 6'd32 := 2, 6'd63 := 2,
                           [6'd1:6'd30] :/ 3, [6'd33:6'd62] :/ 3 };
    }
  }

  function new( string name = "" );
    super.new( name );
  endfunction : new

endclass : imem_mem_transaction
