class lc3_closure_test extends test_top;

  `uvm_component_utils( lc3_closure_test )

  function new( string name = "", uvm_component parent = null );
    super.new( name, parent );
  endfunction : new

  virtual function void build_phase( uvm_phase phase );
    imem_transaction::type_id::set_type_override( imem_closure_transaction::get_type() );
    dmem_transaction::type_id::set_type_override( dmem_closure_transaction::get_type() );
    lc3_bench_sequence_base::num_instructions = IMEM_CLOSURE_LENGTH;
    super.build_phase( phase );
  endfunction : build_phase

endclass : lc3_closure_test
