//
//  usbhid.h
//  SmartThermoMeter
//
//  Created by YuansMacMini on 15/6/11.
//  Copyright (c) 2015年 Yuan. All rights reserved.
//

#ifndef SmartThermoMeter_usbhid_h
#define SmartThermoMeter_usbhid_h

#import <Foundation/Foundation.h>
#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDKeys.h>

#define USB_HID_DEBUG

@protocol UsbHIDDelegate <NSObject>
@optional
- (void)usbhidDidRecvData:(uint8_t*)recvData length:(CFIndex)reportLength reportId:(CFIndex)reportId;
- (void)usbhidDidMatch;
- (void)usbhidDidRemove;
@end

@interface UsbHID : NSObject {
    IOHIDManagerRef managerRef;
    IOHIDDeviceRef deviceRef;
}

@property(nonatomic,strong)id<UsbHIDDelegate> delegate;

+ (UsbHID *)sharedManager;
- (id)initWithVID:(long)vid withPID:(long)pid;
- (void)connectHID;
- (void)sendData:(char*)outbuffer withLength:(int)length withReportId:(CFIndex)reportId;
- (IOHIDManagerRef)getManageRef;
- (void)setManageRef:(IOHIDManagerRef)ref;
- (IOHIDDeviceRef)getDeviceRef;
- (void)setDeviceRef:(IOHIDDeviceRef)ref;

@end

#endif
