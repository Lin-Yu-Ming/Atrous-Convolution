`timescale 1ns/10ps
module  ATCONV(clk,reset,busy,ready,iaddr,idata,cwr,caddr_wr,cdata_wr,crd,caddr_rd,cdata_rd,csel);
	
// Input signal		
input	clk,reset,ready;		
input signed [12:0]	idata;
input [12:0] cdata_rd;			


// Output signal			
output reg 	csel,busy,crd,cwr;
output reg	[11:0]	caddr_wr;
output reg 	[12:0] 	cdata_wr;
output reg	[11:0]	iaddr;
output reg	[11:0] 	caddr_rd;	


reg [8:0] mem_r,mem_c,state,n_state,m,n, mem_r1,mem_c1,mem_r2,mem_c2,mem_r3,mem_c3;
reg [12:0] img_array [0:63][0:63];
reg [12:0] img_padding[0:67][0:67];
reg signed [12:0] kernel[0:4][0:4];
reg signed [12:0] conv[0:63][0:63];
reg [12:0] relu[0:63][0:63];
reg [12:0]a,b,c,d;
reg signed [12:0] bias;
reg [12:0] max_pooling_array[0:31][0:31];
reg signed [12:0]result,result1;
reg [12:0] position,position1;

wire [12:0] img_relu_0=relu [0][0];
wire [12:0] img_relu_1=relu [0][1];
wire [12:0] img_relu_2=relu [0][2];
wire [12:0] img_relu_61=relu[63][61];
wire [12:0] img_relu_62=relu[63][62];
wire [12:0] img_relu_63=relu[63][63];
wire [12:0] img_conv_0=conv [0][0];
wire [12:0] img_conv_1=conv [0][1];
wire [12:0] img_conv_2=conv [0][2];
wire [12:0] img_conv_3=conv [0][3];
wire [12:0] img_conv_62=conv [63][62];
wire [12:0] img_conv_63=conv[63][63];
wire [12:0] img_padding_0=img_padding[0][0];
wire [12:0] img_padding_1=img_padding[0][0];
wire [12:0] img_padding_2=img_padding[67][66];
wire [12:0] img_padding_3=img_padding[67][67];
wire [12:0] max_pooling_0=max_pooling_array[0][0];
wire [12:0] max_pooling_1=max_pooling_array[0][1];
wire [12:0] max_pooling_2=max_pooling_array[0][2];
wire [12:0] max_pooling_30=max_pooling_array[31][30];
wire [12:0] max_pooling_31=max_pooling_array[31][31];
wire [12:0] img_KERNEL_0=kernel[0][0];
wire [12:0] img_KERNEL_1=kernel[4][4];

parameter INIT=8'd0,IMG_D_READ=8'd1,
          PADDING=8'd2,C_KERNEL=8'd3,
			 CONV=8'd4,RELU=8'd5,MAXPOOLING=8'd6,
			 CHECK=8'd9,LAYER0_MEM=8'd7,LAYER1_MEM=8'd8;
			 
			 


always@(posedge clk  or posedge reset)
begin
   if(reset)
	begin
     state=INIT;   
	 end
	else 
	begin
	  state=n_state;
	end
end


always@(*)
begin
  case(state)  
    INIT:begin
      n_state= IMG_D_READ;		
	 end
	 
	 IMG_D_READ:begin
	   if(b==0)
		  begin
		    n_state=IMG_D_READ;
		  end
		else
		  begin 
	       if(mem_r>6'd63)
		      begin
		        n_state= PADDING; 
		      end
		    else
		      begin
		        n_state= IMG_D_READ;  
		     end	
		  end 
	 end
	  
	  
    PADDING:begin
		  if(mem_r1>6'd63)
		    begin	 
			  n_state= C_KERNEL;				
			 end
		  else
		    begin
		      n_state= PADDING;
			 end	
		end
	
	
	   C_KERNEL:begin
		    n_state= CONV;		
		end
		
		CONV:begin
		  if(mem_r>6'd63)
		    begin
		      n_state=RELU; 				
	       end
	     else
	       begin
	         n_state=CONV;   
	       end		 
		end
		
		RELU:begin
		  if(mem_r1>6'd63)
		    begin
		      n_state=LAYER0_MEM; 				
	       end
	     else
	       begin
	         n_state=RELU;   
	       end		 
		end

		MAXPOOLING:begin
		  if(mem_r>6'd31)
		    begin
		      n_state=LAYER1_MEM; 				
	       end
	     else
	       begin
	         n_state=MAXPOOLING;   
	       end	
		end

		LAYER0_MEM:begin
		      if(mem_r2>6'd63)
		        begin
		          n_state=MAXPOOLING;
			     end
		      else
		        begin
		          n_state=LAYER0_MEM;
			     end	
			  end	  
		 
		
		
		LAYER1_MEM:begin
		      if(mem_r3>6'd31)
		        begin
		          n_state=CHECK;
			     end
		      else
		        begin
		          n_state=LAYER1_MEM;
			     end				
		     end	
		  
		
		CHECK:begin
		  n_state=INIT;
		end
		 
		default:begin
		  n_state = INIT;
		end
	 
	 
  endcase
end



always@(posedge clk)
begin
  case(state)
    INIT:begin
	   
       		
		mem_c<=8'd0;
		mem_r<=8'd0;
		mem_c1<=8'd0;
		mem_r1<=8'd0;
		m<=8'd0;
		n<=8'd0;
		a<=13'd0;
		b<=0;
		c<=0;
		d<=0;
		bias<=-(5'b10000-4'b0100);
      result1<=0;
		busy<=0;
		result<=0;
		mem_c2<=8'd0;
		mem_r2<=8'd0;
	   mem_c3<=8'd0;
		mem_r3<=8'd0;	
		position <= 0;
		position1 <= 0;
	 end    
	 
	 
	 IMG_D_READ:begin	
	
		if(b==0)
		  begin
		    busy<=1;
		    iaddr<=12'd0;
			 b<=b+1;
		  end
		else
		  begin
		    if(mem_r>6'd63)
			   begin
				  mem_c<=0;
				  mem_r<=0;
				end
          else
			   begin
	           if(mem_c>6'd63)
	             begin
		            mem_c<=0;
		            mem_r<=mem_r+6'd1;			 
	             end
	           else
	             begin		   
			         img_array[mem_r][mem_c]<=idata;//[0][n];n=0~63	,idata起始0
						mem_c<=mem_c+6'd1;
				      iaddr<=iaddr+1;
	             end		  
             end
	       end			 
	   end
	  
	  PADDING:begin
	    if(mem_r1>6'd63)
		   begin
			  mem_c1<=0;
			  mem_r1<=0;			  
			end
		 else
		   begin
	        if(mem_c1>6'd63)
	          begin
		         mem_c1<=0;
		         mem_r1<=mem_r1+6'd1;			 
	          end
	        else
	          begin		  
		         mem_c1<=mem_c1+6'd1;
			      img_padding[mem_r1+2][mem_c1+2] <= img_array[mem_r1][mem_c1];//[0][n];n=0~63	,idata起始0
			  
			      img_padding[0][mem_c1+2] <= img_array[0][mem_c1];
			      img_padding[1][mem_c1+2] <= img_array[0][mem_c1];  
			  
			      img_padding[mem_r1+2][0] <= img_array[mem_r1][0];
			      img_padding[mem_r1+2][1] <= img_array[mem_r1][0]; 
			  			 
			      img_padding[66][mem_c1+2] <= img_array[63][mem_c1]; 
			      img_padding[67][mem_c1+2] <= img_array[63][mem_c1]; 
			  
			      img_padding[mem_r1+2][66] <= img_array[mem_r1][63]; 
               img_padding[mem_r1+2][67] <= img_array[mem_r1][63]; 
					
					img_padding[0][0]<=img_array[0][0];
			      img_padding[0][1]<=img_array[0][0];
			      img_padding[1][0]<=img_array[0][0];
			      img_padding[1][1]<=img_array[0][0];			  
			      img_padding[0][66]<=img_array[0][63];
			      img_padding[0][67]<=img_array[0][63];
			      img_padding[1][66]<=img_array[0][63];
			      img_padding[1][67]<=img_array[0][63];			  
			      img_padding[66][0]<=img_array[63][0];
			      img_padding[66][1]<=img_array[63][0];
			      img_padding[67][0]<=img_array[63][0];
			      img_padding[67][1]<=img_array[63][0];			  
			      img_padding[66][66]<=img_array[63][63];
			      img_padding[66][67]<=img_array[63][63];
			      img_padding[67][66]<=img_array[63][63];
			      img_padding[67][67]<=img_array[63][63];	
	          end		  	  
	       end
       end			 

		
	   C_KERNEL:begin
	  	
		      kernel[0][0]<=	-4'b0001;//-0.0625
			   kernel[0][2]<=	-4'b0010;//-0.125
				kernel[0][4]<=	-4'b0001;//-0.0625
				kernel[2][0]<=-4'b0100;//-0.25
		      kernel[2][2]<=5'b10000;	//1
			   kernel[2][4]<=-4'b0100;//-0.25
				kernel[4][0]<=	-4'b0001;//-0.0625
				kernel[4][2]<=	-4'b0010;//-0.125
				kernel[4][4]<=	-4'b0001;//-0.0625
            kernel[0][1]<=	0;
				kernel[0][3]<=	0;
			   kernel[1][0]<=	0;
				kernel[1][1]<=	0;
				kernel[1][2]<=	0;
				kernel[1][3]<=	0;
				kernel[1][4]<=	0;
				kernel[2][1]<=	0;
				kernel[2][3]<=	0;
				kernel[3][0]<=	0;
				kernel[3][1]<=	0;
				kernel[3][2]<=	0;
				kernel[3][3]<=	0;
				kernel[3][4]<=	0;
				kernel[4][1]<=	0;
				kernel[4][3]<=	0;				
      end	
		
		
		CONV:begin
		   if(mem_r>6'd63)
			  begin
			   mem_c<=0;
				mem_r<=0;
			  end
			else
			  begin
			    if(mem_c>6'd63)
				   begin
					  mem_c<=0;
					  mem_r<=mem_r+6'd1;
					end
				 else
				   begin
					  if(m>4)
					    begin
					      conv[mem_r][mem_c]<=result+bias;
							mem_c<=mem_c+1;
							m<=0;	
	                  result<=0;						
					    end
					  else
					    begin
	                  if(n>4)
	                     begin
		                    n<=0;
		                    m<=m+6'd1;			 
	                     end
	                  else
	                    begin		                 							
			                result<=result+(img_padding[mem_r+m][mem_c+n]>>4) * kernel[m][n];
								 n<=n+6'd1;
	                    end		  			 
		              end
					 end
            end									
		  end
		 
		 
	    RELU:begin	
		   if(mem_r1>6'd63)
			  begin
			   mem_c1<=0;
				mem_r1<=0;
				caddr_wr<=12'd0;
			  end
			else
			  begin
	          if(mem_c1>6'd63)
	            begin
		           mem_c1<=0;
		           mem_r1<=mem_r1+6'd1;			 
	            end
	          else
	            begin		  		           
			        relu[mem_r1][mem_c1]<=(conv[mem_r1][mem_c1]>0)?conv[mem_r1][mem_c1]:0;
					  mem_c1<=mem_c1+6'd1; 
	            end		  			 
		      end
			end
		  
		 
		 MAXPOOLING:begin 
		   if(mem_r>6'd31)
			  begin
			   mem_c<=0;
				mem_r<=0;
				caddr_wr<=12'd0;
			  end
			else
			  begin
			    if(mem_c>6'd31)
				   begin
					  mem_c<=0;
					  mem_r<=mem_r+6'd1;
					end
				 else
				   begin
					  if(m>1)
					    begin
						 mem_c<=mem_c+1;
			          m<=0;
						 result1<=0;
							if (result1[3:0] != 0) 
					        begin
                         max_pooling_array[mem_r][mem_c] <= ((result1>>4) + 4'd1)<<4; // if the lower 4 bits are not zero, add 1 to result
                       end 
                     else 
					        begin
                         max_pooling_array[mem_r][mem_c] <= result1; // else assign result directly
                       end	
							  
							  
					    end
					  else
					    begin
	                  if(n>1)
	                     begin
		                    n<=0;
		                    m<=m+6'd1;			 
	                     end
	                  else
	                    begin		  		                   							
			                result1<=(relu[2*mem_r+m][2*mem_c+n]>result1)?relu[2*mem_r+m][2*mem_c+n]:result1;
								 n<=n+6'd1; 
	                    end		  			 
		              end
					 end
			   end		 
	        end
			  
		LAYER0_MEM:begin	
		      if(mem_r2>63)
		        begin
			       cwr<=1'd0;
		          mem_c2<=0;
		          mem_r2<=0;				 
			     end
		      else
		        begin
 	             if(mem_c2>6'd63)
	               begin
		              mem_c2<=0;
		              mem_r2<=mem_r2+1;			 
	               end
	             else
	               begin
						  if(c==0)
						    begin
                        csel<=0;
				            cwr<=1'd1;						
			               cdata_wr<=relu[mem_r2][mem_c2];
						      caddr_wr<=position;
								position<=position+1;
								//caddr_wr<=caddr_wr+12'd1;
						      mem_c2<=mem_c2+1;	
                        c<=c+1;								
							 end
						  else
						    begin						
			               cdata_wr<=relu[mem_r2][mem_c2];
						      caddr_wr<=caddr_wr+12'd1;
						      mem_c2<=mem_c2+1;
							end
	               end	
				  end
           end				
        	
			  
		LAYER1_MEM:begin
		      if(mem_r3>6'd31)
		        begin
			       cwr<=1'd0;
			       csel<=0;
					 mem_c3<=0;
		          mem_r3<=0;
			     end
		      else
		        begin
	             if(mem_c3>6'd31)
	               begin
		              mem_c3<=0;
		              mem_r3<=mem_r3+1;			 
	               end
	             else
	               begin
                    if(d==0)
		                begin
		                  //caddr_wr<=0;
								caddr_wr<=position1;
								position1<=position1+1;
								cdata_wr<=max_pooling_array[mem_r3][mem_c3];
								csel<=1;
				            cwr<=1'd1;
						      mem_c3<=mem_c3+1; 
					         //caddr_wr<=caddr_wr+12'd1;
								d=d+1;
                      end
						  else
						    begin  
			               cdata_wr<=max_pooling_array[mem_r3][mem_c3];
					         mem_c3<=mem_c3+1; 
					         caddr_wr<=caddr_wr+12'd1;

							end
	              end				
			     end
          end
		 	 
		   
		  
		  CHECK:begin
		    busy<=0;		  
		  end
	 
  endcase    
end
endmodule
