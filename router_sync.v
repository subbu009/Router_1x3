module router_sync(input clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,
write_enb_reg,read_enb_0,read_enb_1,read_enb_2,
input [1:0] data_in,

output reg [2:0]write_enb,
output reg fifo_full,
output vld_out_0,vld_out_1,vld_out_2,
output reg soft_reset_0,soft_reset_1,soft_reset_2);


//wire read_enb, vld_out;

reg[4:0] count_0,count_1,count_2;
reg [1:0] temp;


always@(posedge clock)
 begin 
	if(detect_add)
	begin
	temp<=data_in;
	end 
	else 
	temp<=temp;
 end 


always@(*)
  begin
	case(temp)
	  2'b00: fifo_full=full_0;
	  2'b01: fifo_full=full_1;
          2'b10: fifo_full=full_2;
	  default :fifo_full=0;
	endcase
  end 

always@(*)
begin 	
    if(write_enb_reg)
	begin
		case(temp)
		2'b00:write_enb=3'b001;
		2'b01:write_enb=3'b010;
		2'b10:write_enb=3'b100;
		default : write_enb=3'd0;
	endcase
  end
	else
		write_enb=3'b000;
end 


always@(posedge clock)
  begin

    if(~resetn)
      begin
	count_0<=0;
      end

	else if(vld_out_0)
		begin
		   if(read_enb_0!=1'b1)
 		      begin
			
			count_0<=count_0+1'b1;
			 
 			  if(count_0==30)
                            begin 

			    soft_reset_0<=1'b1;			     
			    count_0<=0;
			
			     end
			    
			   else
			  soft_reset_0<=1'b0;	
	
		       end
		  else 
			count_0<=0;
		end
	else
		soft_reset_0<=1'b0;

  end

always@(posedge clock)
  begin

    if(~resetn)
      begin
	count_1<=0;
      end

	else if(vld_out_1)
		begin
		   if(~read_enb_1)
 		      begin
			count_1<=count_1+1'b1;
			 
 			  if(count_1==30)
                            begin			     
			    soft_reset_1<=1'b1;
			    count_1<=0;
			     end
						    
			   else
			  soft_reset_1<=1'b0;	
		       end
		  else 
			count_1<=0;
		end
	else
		soft_reset_1<=1'b0;
  end                             

always@(posedge clock)
  begin

    if(~resetn)
      begin
	count_2<=0;
      end

	else if(vld_out_2)
		begin
		   if(read_enb_2!=1'b1)
 		      begin
			
			count_2<=count_2+1'b1;
			 
 			  if(count_2==30)
                            begin
			     soft_reset_2<=1'b1;
			      count_2<=0;
			
			     end
				
						    
			   else
			  soft_reset_2<=1'b0;	
		       end
		  else 
			count_2<=0;
		end
	else
		soft_reset_2<=1'b0;

  end


assign vld_out_0=~empty_0;
assign vld_out_1=~empty_1;
assign vld_out_2=~empty_2;

	  
endmodule
