module erosion_detector 
#
(
    parameter [9:0] IMG_HDISP = 10'd640 ,
    parameter [9:0] IMG_VDISP = 10'd480
)
(
    
    input   wire            sys_clk          ,
    input   wire            sys_rst_n        ,

    //Image data prepred to be processd
    input	wire			per_frame_vsync  ,	//Prepared Image data vsync valid signal
    input	wire			per_frame_href   ,	//Prepared Image data href vaild  signal
    input	wire			per_frame_clken  ,	//Prepared Image data output/capture enable clock
    input	wire		    per_img_Bit      ,	//Prepared Image Bit flag outout(1: Value, 0:inValid)

    //Image data has been processd
    output  wire			post_frame_vsync ,	//Processed Image data vsync valid signal
    output  wire			post_frame_href  ,	//Processed Image data href vaild  signal
    output  wire			post_frame_clken ,	//Processed Image data output/capture enable clock
    output  wire	    	post_img_Bit		//Processed Image Bit flag outout(1: Value, 0:inValid)
);

//wire defination
wire			matrix_frame_vsync; //Prepared Image data vsync valid signal
wire			matrix_frame_href ; //Prepared Image data href vaild  signal	
wire			matrix_frame_clken; //Prepared Image data output/capture enable clock	
wire            matrix_p11; //matrix row1
wire            matrix_p12; 
wire            matrix_p13;
wire            matrix_p21; //matrix row2
wire            matrix_p22; 
wire            matrix_p23;
wire            matrix_p31; //matrix row3 
wire            matrix_p32; 
wire            matrix_p33; 

//reg defination
reg post_img_Bit1;
reg post_img_Bit2;
reg post_img_Bit3;
reg post_img_Bit4;
reg	[1:0]	per_frame_vsync_r;
reg	[1:0]	per_frame_href_r;	
reg	[1:0]	per_frame_clken_r;

//********************************************************************************************//
//*********************************main code**************************************************//
//********************************************************************************************//

//Step1
always@(posedge sys_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		begin
		post_img_Bit1 <= 1'b0;
		post_img_Bit2 <= 1'b0;
		post_img_Bit3 <= 1'b0;
		end
	else
		begin
		post_img_Bit1 <= matrix_p11 & matrix_p12 & matrix_p13;
		post_img_Bit2 <= matrix_p21 & matrix_p22 & matrix_p23;
		post_img_Bit3 <= matrix_p21 & matrix_p32 & matrix_p33;
		end
end

//Step2
always@(posedge sys_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		post_img_Bit4 <= 1'b0;
	else
		post_img_Bit4 <= post_img_Bit1 & post_img_Bit2 & post_img_Bit3;
end

//lag 2 clocks signal sync  
always@(posedge sys_clk or negedge sys_rst_n)
begin
	if(sys_rst_n == 1'b0)
		begin
		per_frame_vsync_r <= 0;
		per_frame_href_r <= 0;
		per_frame_clken_r <= 0;
		end
	else
		begin
		per_frame_vsync_r 	<= 	{per_frame_vsync_r[0], 	matrix_frame_vsync};
		per_frame_href_r 	<= 	{per_frame_href_r[0], 	matrix_frame_href};
		per_frame_clken_r 	<= 	{per_frame_clken_r[0], 	matrix_frame_clken};
		end
end
assign	post_frame_vsync 	= 	per_frame_vsync_r[1];
assign	post_frame_href 	= 	per_frame_href_r[1];
assign	post_frame_clken 	= 	per_frame_clken_r[1];
assign	post_img_Bit		=	post_frame_href ? post_img_Bit4 : 1'b0;

Matrix_Generate_3X3_1Bit 
#
(
    .IMG_HDISP  		 (10'd640) ,
    .IMG_VDISP  		 (10'd480)
) Matrix_Generate_3X3_1Bit_inst
(
    // system port
    .sys_clk             (sys_clk  ),
    .sys_rst_n           (sys_rst_n),

    //image input port  
    .per_frame_vsync     (per_frame_vsync ),
    .per_frame_href      (per_frame_href  ),
    .per_frame_clken     (per_frame_clken ),
    .per_img_Bit         (per_img_Bit     ),

    //image output port
    .matrix_frame_vsync  (matrix_frame_vsync),
    .matrix_frame_href   (matrix_frame_href ),
    .matrix_frame_clken  (matrix_frame_clken),
    .matrix_p11          (matrix_p11),
    .matrix_p12          (matrix_p12),
    .matrix_p13          (matrix_p13),
    .matrix_p21          (matrix_p21),
    .matrix_p22          (matrix_p22),
    .matrix_p23          (matrix_p23),
    .matrix_p31          (matrix_p31),
    .matrix_p32          (matrix_p32),
    .matrix_p33          (matrix_p33)
);

endmodule