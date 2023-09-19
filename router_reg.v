module router_reg (input clock,resetn,
		   input pkt_valid,
		   input [7:0] data_in,
		   input fifo_full,detect_add,ld_state,laf_state,
		   input full_state,lfd_state,rst_int_reg,
		   
		    output reg err,
		    output reg parity_done,low_packet_valid,
		    output reg [7:0] dout);

reg [7:0] header,fifo_full_reg,packet_parity, internal_parity;


//dout 
 always@(posedge clock)
	begin
	if(~resetn)
	  dout<=0;

	else if(detect_add && pkt_valid && (data_in[1:0]!=2'd3))
		header<=data_in;
	
	else if(lfd_state)
		dout<=header;
	 
	else  if(ld_state)
		if(~fifo_full)
		dout<=data_in;
		
		else 
		fifo_full_reg<= data_in;  //dout<= //internal register 
 	
	else if(laf_state)
	 	 dout<=	fifo_full_reg;
	  	
	end 
 

//low packet valid 
 always@(posedge clock)
	begin
	if(~resetn)
	   low_packet_valid<=1'b0;
	
	else if(rst_int_reg)
	    low_packet_valid<=1'b0;

	else if(ld_state && ~pkt_valid)
	    low_packet_valid<=1'b1;
	//else
	  //  low_packet_valid<=1'b0; 
	
	 end 

// parity done
 always@(posedge clock)
 	begin
	if(~resetn)
	   parity_done<=1'b0;
	
	else if(detect_add)
	    parity_done<=1'b0;

	else if((ld_state && ~fifo_full && ~pkt_valid) || (laf_state && low_packet_valid && ~parity_done))
	    parity_done <=1'b1;
/*	else 
	    parity_done <=1'b0;
*/
	end

  
 // err block 
 
//assign err=(packet_parity!=internal_parity);
 

always@(posedge clock)
 begin
	if(~resetn)
	 err<=0;
	else if(parity_done)
	 begin
	  if(packet_parity!=internal_parity)
		err<=1;
	 end 
	else 
		err<=0;
	  end
  

//internal parity 
 always@(posedge clock)
 	begin 
	if(~resetn)
	 internal_parity<=0;
	
	else if(lfd_state)
	  internal_parity <=internal_parity ^ header;
	
	else if(ld_state && pkt_valid && ~full_state)
	  internal_parity<=internal_parity ^ data_in; 
		
	else if(detect_add)
	  internal_parity<=1'b0;
	 
	end 	


//packet parity 
 always@(posedge clock)
	begin 
	if(~resetn)
	 packet_parity<=0;

	else if(ld_state && ~pkt_valid)
	packet_parity <= data_in;
	
	else if(detect_add)
	packet_parity<=0;
	
	
	end 

endmodule 
