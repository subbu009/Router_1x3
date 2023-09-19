interface router_if(input bit clock);




logic [7:0] data_in;
logic pkt_valid,resetn, read_enb;
    
logic [7:0] data_out;
logic vld_out;
logic err,busy;

//bit clk;

//clock

//---------duv modport-------





//------tb modports and cb------------

 


//write DRIVER CB

clocking wdr_cb @(posedge clock);
default input #1 output #0;

input busy;
input err;

output data_in;
output pkt_valid;
output resetn;


endclocking


//write monitor cb

clocking wmon_cb @(posedge clock);

input data_in;
input pkt_valid;
input resetn;
input busy;

endclocking

//rd driver cb

clocking rdr_cb @(posedge clock);
 default input #1 output #0;
 
output read_enb;
input vld_out;

endclocking





//rd monitor

clocking rmon_cb @(posedge clock);
 default input #1 output #0;
 
 input  read_enb;
 input data_out;

endclocking


modport WDR_MP (clocking wdr_cb);
modport RDR_MP (clocking rdr_cb);

modport WMON_MP(clocking wmon_cb);
modport RMON_MP(clocking rmon_cb);


endinterface 
