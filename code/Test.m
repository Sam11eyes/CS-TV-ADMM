a = 1 ;b = 1 ;c = 1 ;d = 2 ;%%四维维cat映射的参数

x01 =0.759; x02 =0.581;  %两个混沌矩阵的参数
mu1 = 6.372; mu2 = 7.687; 
    
    filename = 'lena';
    imname = [filename '.png'];
    grayImg = imread(imname);

   figure(1);
   
   imshow(grayImg,'Border','tight');


   [hash,yfinal] = GetFinal(x01,x02,mu1,mu2,grayImg );


   reconstructed_image = uint8(EncodeFinal(yfinal,x01,x02,mu1,mu2));
   peaksnr = psnr(reconstructed_image, grayImg);

   figure(2);
   
   imshow(uint8(reconstructed_image),'Border','tight');

     figure(3);
   
   imshow(uint8(yfinal),'Border','tight');





   