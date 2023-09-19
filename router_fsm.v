module router_fsm(input clock,resetn,pkt_valid ,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,
 input[1:0] data_in,
 output	write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

parameter DECODE_ADDRESS=8'd1,
	 LOAD_FIRST_DATA=8'd2,
	 LOAD_DATA=8'd4, 
	 FIF0_FULL_STATE=8'd8,
 	 LOAD_AFTER_FULL=8'd16,
	 WAIT_TILL_EMPTY=8'd32,
 	 LOAD_PARITY=8'd64, 
	 CHECK_PARITY_ERROR=8'd128;



reg[7:0] state,ns;
reg[1:0] temp;

always@(posedge clock)
 begin 
	if(detect_add)
	begin
	temp<=data_in;
	end 
	else 
	temp<=temp;
 end 


always@(posedge clock)
 begin 
	if(~resetn)
	state<=DECODE_ADDRESS;
	
	else if (soft_reset_0 && temp==2'd0   || soft_reset_1 && temp==2'd1  || soft_reset_2 && temp==2'd2 )
 	state<=DECODE_ADDRESS;

	else 
	state<=ns;
 end 

always@(*)
 begin 
	ns=DECODE_ADDRESS;
 	case(state)
 DECODE_ADDRESS: begin 

		   if((pkt_valid  && (data_in==0 )    && fifo_empty_0)|| 
		    (pkt_valid  && (data_in==1)  && fifo_empty_1) ||
		    (pkt_valid  && (data_in==2) && fifo_empty_2 ))
	                ns=LOAD_FIRST_DATA; 
	
		 if((pkt_valid  && (data_in==00)    && (~fifo_empty_0))|| 
	           (pkt_valid  && (data_in==1) && (~fifo_empty_1)) ||
	           (pkt_valid  && (data_in==2) && (~fifo_empty_2) ))
	                ns=WAIT_TILL_EMPTY;

 	        	end

        LOAD_FIRST_DATA:
	              ns=LOAD_DATA;
	
	LOAD_DATA:
	             if(fifo_full)
	               ns=FIF0_FULL_STATE;

	            else if(pkt_valid ==0)
	               ns=LOAD_PARITY;
			
		    else 
			ns=LOAD_DATA; 
	    
	   	
	FIF0_FULL_STATE: if(~fifo_full)
	                ns=LOAD_AFTER_FULL;
	                else 
	               ns=FIF0_FULL_STATE;

       LOAD_AFTER_FULL:begin
		
		if (~parity_done && low_packet_valid)
	                ns=LOAD_PARITY;
	   if(~parity_done && ~low_packet_valid)
	                ns=LOAD_DATA;
 	   if(parity_done)
	                ns=DECODE_ADDRESS;
			end

       WAIT_TILL_EMPTY:begin
		if(fifo_empty_0 && temp==2'd0 || fifo_empty_1 && temp==2'd1  || fifo_empty_2 && temp==2'd2 )
	   ns=LOAD_FIRST_DATA;
	   if(~fifo_empty_0 || ~fifo_empty_1 || ~fifo_empty_2)
	   ns=WAIT_TILL_EMPTY;
		end
	
       LOAD_PARITY:
	   ns=CHECK_PARITY_ERROR;
	
  	CHECK_PARITY_ERROR:if(~fifo_full) 
	   		   ns=DECODE_ADDRESS;
  	    		  else 
	   		  ns=FIF0_FULL_STATE;
	default:
	   ns=DECODE_ADDRESS;
	endcase

 end  

assign detect_add=(state==DECODE_ADDRESS)?1'b1:1'b0;

assign lfd_state=(state==LOAD_FIRST_DATA)?1'b1:1'b0;
assign busy=((state==DECODE_ADDRESS) | (state==LOAD_DATA))? 1'b0:1'b1;

assign ld_state=(state==LOAD_DATA);
assign write_enb_reg=(state==LOAD_DATA)|(state==LOAD_PARITY) |(state==LOAD_AFTER_FULL) ;

assign full_state=(state==FIF0_FULL_STATE);

assign laf_state=(state==LOAD_AFTER_FULL);
assign rst_int_reg=(state==CHECK_PARITY_ERROR);
endmodule 

		
	
	   	
	
