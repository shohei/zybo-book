unsigned int hls_block(unsigned char da_r_i,
		               unsigned char da_g_i,
		               unsigned char da_b_i){
	unsigned char da_r;
    unsigned char da_g;
	unsigned char da_b;
	unsigned int ans;
	unsigned short da_gray;
	     //�����ϊ�
		da_gray = (77*da_r_i + 150*da_g_i + 29*da_b_i )>>8;
		//�ϊ����ʂ��O�F�ɑ��
		da_r = da_gray;
		da_g = da_gray;
		da_b = da_gray;
		//�r�b�g�ʒu�̒���
		ans = (da_b<<16)+ (da_g<<8) + (da_r);
		return ans;
}
