// Directed stream that hits every coverage bin, worked out by the generator
// from the covergroup definitions: first a block that makes every branch
// outcome, psr value, bypass path, overflow, operand corner and LDI/STI
// pointer happen in the pipeline, then a stream that fills the remaining
// instruction-stream bins. Delivered after the 9 register clears;
// afterwards the class falls back to plain random. The data words the
// stream relies on are in dmem_closure_transaction.
localparam int unsigned IMEM_CLOSURE_LENGTH = 244;

localparam bit [15:0] IMEM_CLOSURE_ROM [0:IMEM_CLOSURE_LENGTH-1] = '{
  16'h2200, 16'h2400, 16'h2600, 16'h2800, 16'h2a00, 16'h2c00, 16'h5020, 16'h5fe0,
  16'h1061, 16'h10bf, 16'h10e0, 16'h50ff, 16'h5125, 16'h513f, 16'h90ff, 16'h913f,
  16'h90bf, 16'h2000, 16'h2000, 16'h2000, 16'he001, 16'h917f, 16'h0800, 16'h0400,
  16'h0200, 16'h0c00, 16'h0a00, 16'h0600, 16'h0e00, 16'h2000, 16'h0200, 16'h0800,
  16'h0400, 16'h0c00, 16'h0a00, 16'h0600, 16'h0e00, 16'he001, 16'h0200, 16'h0800,
  16'h0400, 16'h0c00, 16'h0a00, 16'h0600, 16'h0e00, 16'h5160, 16'h0200, 16'h2000,
  16'h0200, 16'he001, 16'h0800, 16'h3000, 16'h0200, 16'h3000, 16'h0800, 16'ha000,
  16'ha000, 16'ha000, 16'hb000, 16'hb000, 16'hb000, 16'hc180, 16'he1ef, 16'hc080,
  16'he000, 16'h1221, 16'h1461, 16'h56a7, 16'h98ff, 16'h1c20, 16'h7f80, 16'h1c20,
  16'h6b80, 16'h1221, 16'h1401, 16'h5602, 16'h3600, 16'h1221, 16'hb200, 16'h1221,
  16'h7200, 16'h1221, 16'h1441, 16'he200, 16'h1460, 16'he200, 16'h5461, 16'he200,
  16'h947f, 16'he200, 16'h6440, 16'he200, 16'h7040, 16'he200, 16'h1401, 16'he200,
  16'h5401, 16'he200, 16'h3200, 16'he200, 16'hb200, 16'he200, 16'h7200, 16'h2200,
  16'h1460, 16'h2200, 16'h5461, 16'h2200, 16'h947f, 16'h2200, 16'h6440, 16'h16a0,
  16'h2200, 16'h7040, 16'h2200, 16'h1401, 16'h2200, 16'h5401, 16'h2200, 16'h3200,
  16'h2200, 16'hb200, 16'h2200, 16'h7200, 16'h2200, 16'h1441, 16'h1c20, 16'hc180,
  16'he200, 16'hc040, 16'h2200, 16'hc040, 16'h1840, 16'h1b02, 16'h791f, 16'h1f45,
  16'h34ff, 16'h601f, 16'h62a0, 16'h7420, 16'h66ff, 16'h2eff, 16'h1183, 16'h6903,
  16'h3900, 16'h76bf, 16'h7ac3, 16'h3bff, 16'h3c03, 16'h6d65, 16'h7d65, 16'h02ff,
  16'h11c4, 16'h923f, 16'h3f05, 16'h97bf, 16'h6fc0, 16'h9bff, 16'ha2ff, 16'hc140,
  16'ha500, 16'he4ff, 16'ha7ff, 16'h1082, 16'ha803, 16'h0300, 16'hb4ff, 16'hab05,
  16'h2100, 16'hac00, 16'h5000, 16'hb700, 16'h03ff, 16'h71c0, 16'hb9ff, 16'h5003,
  16'hae00, 16'h9c3f, 16'hba03, 16'h9e3f, 16'h5004, 16'hbd05, 16'he700, 16'he9ff,
  16'h21ff, 16'hc100, 16'hc000, 16'h0203, 16'hc0c0, 16'h5005, 16'hc1c0, 16'h1006,
  16'h0305, 16'h1007, 16'h102f, 16'h1030, 16'h1035, 16'h2003, 16'h2105, 16'h5006,
  16'h5007, 16'h502f, 16'h5030, 16'h5035, 16'h6000, 16'hbe00, 16'h3000, 16'h5000,
  16'h7000, 16'h5000, 16'hea00, 16'hec00, 16'h6140, 16'h0200, 16'h6000, 16'h5000,
  16'hee00, 16'h0200, 16'h903f, 16'h7000, 16'h903f, 16'hc000, 16'h3000, 16'ha000,
  16'h3000, 16'h0200, 16'hc000, 16'h6000, 16'ha000, 16'h6000, 16'hc000, 16'h7000,
  16'ha000, 16'h7000, 16'hc000, 16'h903f, 16'hc000, 16'hb000, 16'h6000, 16'h3000,
  16'hb000, 16'h7000, 16'h3000, 16'hc000
};

class imem_closure_transaction extends imem_transaction;

  `uvm_object_utils( imem_closure_transaction )

  static int unsigned next_index;

  bit [15:0] target;
  bit        use_target;

  constraint closure_c {
    use_target -> ( opcode == target[15:12] && operands == target[11:0] );
  }

  function new( string name = "" );
    super.new( name );
  endfunction : new

  function void pre_randomize();
    use_target = ( next_index < IMEM_CLOSURE_LENGTH );
    if ( use_target ) target = IMEM_CLOSURE_ROM[next_index];
    next_index++;
  endfunction : pre_randomize

endclass : imem_closure_transaction
