class lc3_alu_test extends test_top;

  `uvm_component_utils( lc3_alu_test )

  function new( string name = "", uvm_component parent = null );
    super.new( name, parent );
  endfunction : new

  virtual function void build_phase( uvm_phase phase );
    imem_transaction::type_id::set_type_override( imem_alu_transaction::get_type() );
    super.build_phase( phase );
  endfunction : build_phase

endclass : lc3_alu_test
