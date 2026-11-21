// Data words for the closure stream, one per data memory read, in order
// (the loads, LDI pointers and values the closure stream relies on).
// Afterwards the class falls back to plain random.
localparam int unsigned DMEM_CLOSURE_LENGTH = 83;

localparam bit [15:0] DMEM_CLOSURE_ROM [0:DMEM_CLOSURE_LENGTH-1] = '{
  16'h7fff, 16'h8000, 16'h0000, 16'hffff, 16'h1234, 16'h0010, 16'h8001, 16'h0000,
  16'h0042, 16'h0000, 16'h0001, 16'h0000, 16'h0005, 16'hffff, 16'h0005, 16'h3050,
  16'h0005, 16'h0000, 16'hffff, 16'h3050, 16'h0007, 16'h3000, 16'h0003, 16'h3000,
  16'h0011, 16'h0012, 16'h0013, 16'h3000, 16'h0015, 16'h0016, 16'h0017, 16'h0018,
  16'h0019, 16'h001a, 16'h3001, 16'h001b, 16'h001c, 16'h3100, 16'h0000, 16'h0100,
  16'h0001, 16'h8001, 16'h0000, 16'h0100, 16'h0001, 16'h8001, 16'h0000, 16'h0100,
  16'h0001, 16'h8001, 16'h0000, 16'h0100, 16'h0001, 16'h8001, 16'h0000, 16'h0100,
  16'h0001, 16'h8001, 16'h0000, 16'h0100, 16'h0001, 16'h8001, 16'h0000, 16'h0100,
  16'h0001, 16'h8001, 16'h0000, 16'h0100, 16'h0001, 16'h8001, 16'h0000, 16'h0100,
  16'h0001, 16'h8001, 16'h0000, 16'h0100, 16'h0001, 16'h8001, 16'h0000, 16'h0100,
  16'h0001, 16'h8001, 16'h0000
};

class dmem_closure_transaction extends dmem_transaction;

  `uvm_object_utils( dmem_closure_transaction )

  static int unsigned next_index;

  bit [15:0] target;
  bit        use_target;

  constraint closure_c {
    use_target -> ( data == target );
  }

  function new( string name = "" );
    super.new( name );
  endfunction : new

  function void pre_randomize();
    use_target = ( next_index < DMEM_CLOSURE_LENGTH );
    if ( use_target ) target = DMEM_CLOSURE_ROM[next_index];
    next_index++;
  endfunction : pre_randomize

endclass : dmem_closure_transaction
