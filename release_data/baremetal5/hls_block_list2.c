//2015.11.07 k.yokomizo
unsigned int hls_block(unsigned char da_r_i,
		               unsigned char da_g_i,
		               unsigned char da_b_i,
		               unsigned char da_r_d1,
		               unsigned char da_g_d1,
		               unsigned char da_b_d1,
		               unsigned char mode_sw
		               ){
	unsigned int ans;
	unsigned char da_r,da_g,da_b;
	short da_gray;
	switch (mode_sw){
	case 0:{
		da_r = da_r_i;
		da_g = da_g_i;
		da_b = da_b_i;
		break;
	}
	case 1:{
		da_gray = (77*da_r_i + 150*da_g_i + 29*da_b_i )>>8;
		da_r = da_gray;
		da_g = da_gray;
		da_b = da_gray;
		break;
	}
	case 2:{
		da_r = 255-da_r_i;
		da_g = 255-da_g_i;
		da_b = 255-da_b_i;
		break;
	}
	case 3:{
		da_r = abs(da_r_d1-da_r_i);
		da_g = abs(da_g_d1-da_g_i);
		da_b = abs(da_b_d1-da_b_i);
		break;
	}
	}
		ans = (da_b<<16)+ (da_g<<8) + (da_r);
		return ans;

}
