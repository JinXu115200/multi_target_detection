module dilation_detector 
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,

    input   wire            per_frame_vsync     ,
    input   wire            per_frame_href      ,
    input   wire            per_frame_clken     ,
    input   wire            per_img_Bit         ,

    output  wire            post_frame_vsync    ,
    output  wire            post_frame_href     ,
    output  wire            post_frame_clken    ,
    output  wire            post_img_Bit
);

//wire defination
//Generate 1Bit 3x3 Matrix for Video Image Processor
wire    matrix_frame_vsync;
wire    matrix_frame_href;
wire    matrix_frame_clken;
wire    matrix_p11;
wire    matrix_p12;
wire    matrix_p13;
wire    matrix_p21;
wire    matrix_p22;
wire    matrix_p23;
wire    matrix_p31;
wire    matrix_p32;
wire    matrix_p33;

//reg definiation
reg     post_img_Bit_1;
reg     post_img_Bit_2;
reg     post_img_Bit_3;
reg     post_img_Bit_4;

reg	[1:0]	per_frame_vsync_r;
reg	[1:0]	per_frame_href_r;	
reg	[1:0]	per_frame_clken_r;
//dilation
//Dilation Parameter
//      Original         Dilation			  Pixel
// [   0  0   0  ]   [   1	1   1 ]     [   P1  P2   P3 ]
// [   0  1   0  ]   [   1  1   1 ]     [   P4  P5   P6 ]
// [   0  0   0  ]   [   1  1	1 ]     [   P7  P8   P9 ]
//P = P1 | P2 | P3 | P4 | P5 | P6 | P7 | 8 | 9;
//---------------------------------------
//Dilation with or operation,1 : White,  0 : Black

always@(posedge sys_clk or negedge sys_rst_n)
begin
    if (sys_rst_n == 1'b0)
        begin
            post_img_Bit_1 <= 1'b0;
            post_img_Bit_2 <= 1'b0;
            post_img_Bit_3 <= 1'b0;
        end
    else
        begin
            post_img_Bit_1 <= (matrix_p11 || matrix_p12 || matrix_p13);
            post_img_Bit_2 <= (matrix_p21 || matrix_p22 || matrix_p23);
            post_img_Bit_3 <= (matrix_p31 || matrix_p32 || matrix_p33);
        end 
end

always@(posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        post_img_Bit_4 <= 1'b0;
    else 
        post_img_Bit_4 <= (post_img_Bit_1 || post_img_Bit_2 || post_img_Bit_3);

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
assign	post_img_Bit		=	post_frame_href ? post_img_Bit_4 : 1'b0;

Matrix_Generate_3X3_1Bit 
#
(
    .IMG_HDISP (10'd640),
    .IMG_VDISP (10'd480)
)Matrix_Generate_3X3_1Bit_inst
(
    .sys_clk             (sys_clk   ),
    .sys_rst_n           (sys_rst_n),

    .per_frame_vsync     (per_frame_vsync  ),                   
    .per_frame_href      (per_frame_href   ), 
    .per_frame_clken     (per_frame_clken  ),
    .per_img_Bit         (per_img_Bit      ), 

    .matrix_frame_vsync  (matrix_frame_vsync),
    .matrix_frame_href   (matrix_frame_href ),
    .matrix_frame_clken  (matrix_frame_clken),
    .matrix_p11          (matrix_p11        ),
    .matrix_p12          (matrix_p12        ),
    .matrix_p13          (matrix_p13        ),
    .matrix_p21          (matrix_p21        ),
    .matrix_p22          (matrix_p22        ),
    .matrix_p23          (matrix_p23        ),
    .matrix_p31          (matrix_p31        ),
    .matrix_p32          (matrix_p32        ),
    .matrix_p33          (matrix_p33        )
);

endmodule