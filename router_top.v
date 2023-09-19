module router_top(input [7:0] data_in, 
	input pkt_valid, clock, resetn, read_enb_0, read_enb_1, read_enb_2,
	output[7:0] data_out_0, data_out_1, data_out_2,
	output vld_out_0, vld_out_1, vld_out_2,
	output err,busy);


wire[2:0] write_enb;
wire[7:0] dout;
//FSM INSTAN.
router_fsm FSM(clock,resetn,pkt_valid ,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,data_in[1:0],write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

//SYNCHRONIZER 
	
router_sync SYNC(clock,resetn,detect_add,full_0,full_1,full_2,fifo_empty_0,fifo_empty_1,fifo_empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,data_in[1:0],write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2, soft_reset_0,soft_reset_1,soft_reset_2);



//REGISTER 

router_reg REG(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);



//FIFO	

router_fifo FIFO1(clock,resetn,write_enb[0],read_enb_0,dout,lfd_state,soft_reset_0,full_0,fifo_empty_0,data_out_0);
router_fifo FIFO2(clock,resetn,write_enb[1],read_enb_1,dout,lfd_state,soft_reset_1,full_1,fifo_empty_1,data_out_1);
router_fifo FIFO3(clock,resetn,write_enb[2],read_enb_2,dout,lfd_state,soft_reset_2,full_2,fifo_empty_2,data_out_2);


endmodule 
