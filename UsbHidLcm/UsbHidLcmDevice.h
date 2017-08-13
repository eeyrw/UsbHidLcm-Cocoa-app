//
//  UsbHidLcmDevice.h
//  UsbHidLcm
//
//  Created by YuansMacMini on 17/8/11.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#ifndef UsbHidLcmDevice_h
#define UsbHidLcmDevice_h
#import <Cocoa/Cocoa.h>
#import "usbhid.h"

#define CMD_LCD_INIT 0x01
#define CMD_LCD_SETBACKLGIHT 0x02
#define CMD_LCD_SETCONTRAST 0x03
#define CMD_LCD_SETBRIGHTNESS 0x04
#define CMD_LCD_WRITEDATA 0x05
#define CMD_LCD_SETCURSOR 0x06
#define CMD_LCD_CUSTOMCHAR 0x07
#define CMD_LCD_WRITECMD 0x08
#define CMD_ENTER_BOOT 0x19

@protocol UsbHidLcmDeviceDelegate <NSObject>
@optional
- (void)deviceDidMatch;
- (void)deviceDidRemove;
@end




@interface UsbHidLcmDevice : NSObject <NSApplicationDelegate,UsbHIDDelegate>
{
    UsbHID* dev;
    Boolean devConnStatus;
    char cmdBuf[64];
    uint8_t sizeX;
    uint8_t sizeY;
}
@property(nonatomic,strong)id<UsbHidLcmDeviceDelegate> delegate;

-(id)initWithVid:(uint16_t)vid withPid:(uint16_t)pid;

-(void)initLcdWithX:(uint8_t)x withY:(uint8_t)y;
-(void)setCurosrWithX:(uint8_t)x withY:(uint8_t)y;
-(void)writeLcdWith:(char* )x withLength:(uint8_t)len;
-(void)printString:(NSString*)str;
@end
#endif /* UsbHidLcmDevice_h */
