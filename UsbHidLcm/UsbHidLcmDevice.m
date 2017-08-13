//
//  UsbHidLcmDevice.m
//  UsbHidLcm
//
//  Created by YuansMacMini on 17/8/11.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdint.h>
#import "UsbHidLcmDevice.h"



@implementation UsbHidLcmDevice


- (void)usbhidDidRemove
{
    devConnStatus=false;
    [[self delegate]deviceDidRemove];
}

- (void)usbhidDidMatch
{
    devConnStatus=true;
    [[self delegate]deviceDidMatch];
}

-(void)printString:(NSString*)str{
    char* rawString=[str UTF8String];
    char* wrtiePtr=rawString;
    int len=strlen(rawString);
    if(len>(sizeX*sizeY))
    {
        len=sizeX*sizeY;
    }
    int i;
    for(i=0;i<len/sizeX;i++)
    {
        [self setCurosrWithX:0 withY:i];
        [self writeLcdWith:wrtiePtr withLength:sizeX];
        wrtiePtr+=sizeX;
        
    }
    
    if(len%sizeX)
    {
        [self setCurosrWithX:0 withY:i];
        [self writeLcdWith:wrtiePtr withLength:len%sizeX];
    }
}


-(id)initWithVid:(uint16_t)vid withPid:(uint16_t)pid{
    self = [super init];
    if (self) {
        devConnStatus=false;
        sizeX=16;
        sizeY=2;
    dev=[[UsbHID alloc]initWithVID:vid withPID:pid];
        dev.delegate=self;
    }
    return self;
}


-(void)initLcdWithX:(uint8_t)x withY:(uint8_t)y{
    cmdBuf[0]=CMD_LCD_INIT;
    cmdBuf[1]=x;
    cmdBuf[2]=y;
    
    sizeX=x;
    sizeY=y;
    
    [self sendCmdData];
}

-(void)setCurosrWithX:(uint8_t)x withY:(uint8_t)y{
    cmdBuf[0]=CMD_LCD_SETCURSOR;
    cmdBuf[1]=x;
    cmdBuf[2]=y;
    
    [self sendCmdData];
}

-(void)writeLcdWith:(char* )x withLength:(uint8_t)len{
    cmdBuf[0]=CMD_LCD_WRITEDATA;
    if(len>(sizeof(cmdBuf)-1))
        len=sizeof(cmdBuf)-1;
    cmdBuf[1]=len;
    memcpy(&cmdBuf[2],x,len);
    [self sendCmdData];
}

-(void)sendCmdData{
    if(devConnStatus)
       {
           [dev sendData:cmdBuf withLength:64 withReportId:0];
           
       }
}


@end
