class imem_alu_transaction extends imem_transaction;

  `uvm_object_utils( imem_alu_transaction )

  constraint alu_only_c {
    opcode inside { OP_ADD, OP_AND, OP_NOT };
  }

  constraint immediate_corners_c {
    ( opcode != OP_NOT && operands[5] == 1'b1 ) -> {
      operands[4:0] dist { 5'd0 := 2, 5'd15 := 2, 5'd16 := 2, 5'd31 := 2,
                           [5'd1:5'd14] :/ 3, [5'd17:5'd30] :/ 3 };
    }
  }

  function new( string name = "" );
    super.new( name );
  endfunction : new

endclass : imem_alu_transaction
