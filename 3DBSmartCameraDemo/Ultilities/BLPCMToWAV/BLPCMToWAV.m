//
//  BLPCMToWAV.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/12/10.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "BLPCMToWAV.h"

typedef struct{
    unsigned char  RIFF[4];				//00h, 'RIFF'
    unsigned int   FileLength;			//04h, FileTotalLength-8
    unsigned char  WAVEfmt[8];			//08h, 'WAVEfmt '
    unsigned char  PcmWaveFormatSize[4];//10h, PCMWaveFormatSize = 0x10, after 'WAVEfme ' and before 'data'
    unsigned short FormatTag;			//14h, 0x01
    unsigned short Channels;			//16h, 1-Single 2-Dual
    unsigned int   SamplesPerSec;       //18h, such as 24K/s
    unsigned int   AvgBytesPerSec;		//1Ch, such as 24KB/s = 1chanx24K/sx16bit/8
    unsigned short BlockAlign;			//20h, BytesPerSample on all channels, such as 2 = 1chanx16bit/8
    unsigned short BitsPerSample;		//22h, BitsPerSample on each channel, 8bit-0x08, 16bit-0x10
    unsigned char  data[4];				//24h, 'data'
    unsigned int   dataLength;			//28h, SampleDataLength = FileTotalLength-44
} WaveFileHeader_44Bytes;

@implementation BLPCMToWAV

+ (NSMutableData *)convertPCMToWavWith:(NSData *)data withSample:(int)sample channel:(int)channel bps:(int)bps;
{
    // 开始准备WAV的文件头
    NSLog(@"wav Head info length : %lu", sizeof(WaveFileHeader_44Bytes));
    WaveFileHeader_44Bytes DestionFileHeader;
    DestionFileHeader.RIFF[0] = 'R';
    DestionFileHeader.RIFF[1] = 'I';
    DestionFileHeader.RIFF[2] = 'F';
    DestionFileHeader.RIFF[3] = 'F';
    
    DestionFileHeader.FileLength = (unsigned int)([data length] - 8);
    
    DestionFileHeader.WAVEfmt[0] = 'W';
    DestionFileHeader.WAVEfmt[1] = 'A';
    DestionFileHeader.WAVEfmt[2] = 'V';
    DestionFileHeader.WAVEfmt[3] = 'E';
    
    DestionFileHeader.WAVEfmt[4] = 'f';
    DestionFileHeader.WAVEfmt[5] = 'm';
    DestionFileHeader.WAVEfmt[6] = 't';
    DestionFileHeader.WAVEfmt[7] = 0x20;
    
    DestionFileHeader.PcmWaveFormatSize[0] = 0x10;  //  表示 FMT 的长度      //
    DestionFileHeader.PcmWaveFormatSize[1] = 0;     //  表示 FMT 的长度      //
    DestionFileHeader.PcmWaveFormatSize[2] = 0;     //  表示 FMT 的长度      //
    DestionFileHeader.PcmWaveFormatSize[3] = 0;     //  表示 FMT 的长度      //
    
    DestionFileHeader.FormatTag            = 0x01;  //这个表示a law PCM
    DestionFileHeader.Channels             = channel;
    DestionFileHeader.SamplesPerSec        = sample;
    DestionFileHeader.AvgBytesPerSec       = channel * sample * bps / 8 ;
    DestionFileHeader.BlockAlign           = channel * bps / 8;
    DestionFileHeader.BitsPerSample        = bps;
    
    DestionFileHeader.data[0] = 'd';
    DestionFileHeader.data[1] = 'a';
    DestionFileHeader.data[2] = 't';
    DestionFileHeader.data[3] = 'a';
    
    DestionFileHeader.dataLength = (unsigned int)([data length] - 44);

    //Save this headdata as .wav file, then it is taget wav audio file
    NSMutableData *headData = [[NSMutableData alloc] initWithBytes:&DestionFileHeader length:sizeof(DestionFileHeader)];
    [headData appendData:data];
    return headData;
}

@end


