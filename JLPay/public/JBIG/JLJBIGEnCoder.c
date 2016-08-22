//
//  JLJBIGEnCoder.c
//  JLPay
//
//  Created by jielian on 16/7/26.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#include "JLJBIGEnCoder.h"

#include "jbig.h"

#include <stdlib.h>
#include <string.h>
#include <assert.h>

/* used for determining output file length */
unsigned long total_length = 0;
unsigned char* pbmJbigEncoded = NULL;



unsigned char* pbmTransferFromBmp(unsigned char* bitmapStr, size_t width, size_t height, size_t totalSize);
void jbigEncode(unsigned char* pbmStr, size_t width, size_t height);


static void data_out(unsigned char *start, size_t len, void *file)
{
    total_length += len;

    if (pbmJbigEncoded == NULL) {
        pbmJbigEncoded = malloc(total_length);
    } else {
        pbmJbigEncoded = realloc(pbmJbigEncoded, total_length);
    }
    memcpy(pbmJbigEncoded + total_length - len, start, len);
    return;
}


/* 对 bmp 进行 jbig 编码
 1. bmp 转为 pbm
 2. 对 pbm 进行编码
 */
unsigned char* JLJBIGEncode(unsigned char* bitmapStr, size_t width, size_t height, size_t totalSize, size_t* encodedLen) {

    printf(" <<<<<<<<<<<<<strlen(bitmapStr)=[%ld],width[%ld],height[%ld],totalSize[%ld]", strlen(bitmapStr),width, height, totalSize );
    total_length = 0;
    pbmJbigEncoded = NULL;
    unsigned char* pbmStr = pbmTransferFromBmp(bitmapStr, width, height, totalSize);
    
    jbigEncode(pbmStr, width, height);
    *encodedLen = total_length;
    return pbmJbigEncoded;
}


/* bmp 转为 pbm */
unsigned char* pbmTransferFromBmp(unsigned char* bitmapStr, size_t width, size_t height, size_t totalSize) {
    
    /* 保存转换后的 pbm 串 */
    unsigned char* pbmStr = (unsigned char*)malloc(totalSize / 4 / 8);
    memset(pbmStr, 0x00, totalSize / 4 / 8);
    
    /* 已转换的字节数 */
    size_t countTransed = 0;
    
    for (int h = 0; h < (int)height; h++) {
        unsigned char pbmChar = 0;
        // 每 4*8 个字节一取,转为 pbm 的一个字节
        for (int w = 0; w < width * 4; w += 4 * 8) {
            pbmChar = 0;
            int start = w;
            // 将 8 个字节转换为 0|1 ，并填充到 pbm 的单字节
            for (int i = 0; i < 8; i++) {
                unsigned char curBmpBitChar = *(bitmapStr + h * width * 4 + start + i * 4);
                int tmp = (curBmpBitChar & 0xc0/*0xc0~0xff*/) ? (0/*0xff*/) : (1/*0x00*/);
                if (tmp) {
                    pbmChar = pbmChar | (0x80 >> i);
                }
            }
            memcpy(pbmStr + countTransed, &pbmChar, 1);
            countTransed ++;
        }
    }
    
    /* 输出 */
//    printf("/ --------begin-打印pbm--------- /");
//    printf("01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f \n");
//    int len = totalSize / 4 / 8;
//    int tSize = 0;
//    while (tSize < len) {
//        int minLen = (len - tSize >= 16) ? (16) : (len - tSize);
//        for (int i = 0; i < minLen; i ++) {
//            printf("%02x ", *(pbmStr + tSize + i));
//        }
//        printf("\n");
//        tSize += 16;
//    }
//    printf("/ --------end-打印pbm--------- /");

    return pbmStr;
}


void jbigEncode(unsigned char* pbmStr, size_t width, size_t height) {
    struct jbg_enc_state s;

    jbg_enc_init(&s, width, height, 1, &pbmStr, data_out, NULL);
    
    jbg_enc_lrlmax(&s, 600, 300);
    
    jbg_enc_lrange(&s, -1, -1);
    
    int options = JBG_TPDON | JBG_TPBON | JBG_DPON;
    int order = JBG_ILEAVE | JBG_SMID;
    jbg_enc_options(&s, order, options, 0, -1, -1);
    
    jbg_enc_out(&s);
    
    jbg_enc_free(&s);
    free(pbmStr);

    return;
}


