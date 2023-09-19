module router_fifo #(parameter width =9,depth=16,addr=5)(input clk,resetn,we_n,re_n,

input [width-2:0]data_in,
input lfd_state,soft_reset,

output full,empty,
output reg [width-2:0]dout);


 
reg [width-1:0] ram [depth -1:0];
reg [addr-1:0]rd_ptr,wr_ptr;
reg[5:0] count;

reg temp;

always@(posedge clk)
 begin 
	if(lfd_state)
	temp<=1'b1;
	else 
	temp<=1'b0; 
 end 
//reset and soft reset 
always@(posedge clk)

begin :B1

 integer i;
	if(~resetn)
		begin
			
			for(i=0;i<depth;i=i+1)
			ram[i]<=0;
		end
	 	
	else if(soft_reset)
		begin 
			
			for(i=0;i<depth;i=i+1)
			ram[i]<=0;
		end 
//write logic 
	else
		begin
   		 if(temp && we_n && ~full)
			
			{ram[wr_ptr[3:0]][8],ram[wr_ptr[3:0]][7:0]}<={temp,data_in};

    	         else if(we_n && ~full)
 			
		{ram[wr_ptr[3:0]][8],ram[wr_ptr[3:0]][7:0]}<={temp,data_in};    
    	        end 		  
end 	 

//read logic   
always@(posedge clk)
 begin	
	if(~resetn)
	begin 
	count<=0;	  
	dout<=0;
	end 

	else if(soft_reset)
	begin 
	count<=0;
	dout<=8'bz;
	end 

	else 
	begin 
	if((re_n && ~empty) && ram[rd_ptr[3:0]][8]==1 )
		begin
		count<=(ram[rd_ptr[3:0]][7:2])+1'b1;
		dout<=ram[rd_ptr[3:0]];

		end
	
	else if(count==0)
		begin 
		dout<=8'bz;
		end 

	else if((re_n && ~empty) && ram[rd_ptr[3:0]][8]==0 )
		begin
		count<=count-1'b1;
		dout<=ram[rd_ptr[3:0]]; 
 		end  
	end 
end 
//address logic
//

always@(posedge clk)
	begin
	if (~resetn)
	begin
		rd_ptr<=0;wr_ptr<=0;
	end

	else if(soft_reset)
	begin 
		rd_ptr<=0;wr_ptr<=0;
	end 
   else

	begin 
	if(we_n && ~full) 
		 wr_ptr<=wr_ptr + 1'b1;
	if(re_n && ~empty) rd_ptr<=rd_ptr + 1'b1;
	end
end


    assign full=(wr_ptr[4] != rd_ptr[4] && wr_ptr[3:0] == rd_ptr[3:0])?1'b1:1'b0;
    assign empty=(wr_ptr == rd_ptr)?1'b1:1'b0;

endmodule 









