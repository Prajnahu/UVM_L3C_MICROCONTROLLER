class imem_ctrl_transaction extends imem_transaction;

  `uvm_object_utils( imem_ctrl_transaction )

  constraint control_heavy_c {
    opcode dist { OP_BR := 5, OP_JMP := 2, OP_ADD := 1, OP_AND := 1, OP_NOT := 1,
                  OP_LD := 1, OP_LEA := 1, OP_ST := 1 };
  }

  constraint branch_offset_corners_c {
    ( opcode == OP_BR ) -> {
      operands[8:0] dist { 9'd0 := 2, 9'd255 := 2, 9'd256 := 2, 9'd511 := 2, [9'd1:9'd254] :/ 3, [9'd257:9'd510] :/ 3 };
    }
  }

  function new( string name = "" );
    super.new( name );
  endfunction : new

endclass : imem_ctrl_transaction
