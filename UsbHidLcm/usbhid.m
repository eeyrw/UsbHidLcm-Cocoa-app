//
//  usbhid.m
//  SmartThermoMeter
//
//  Created by YuansMacMini on 15/6/11.
//  Copyright (c) 2015年 Yuan. All rights reserved.
//

#import "UsbHID.h"
#import <Cocoa/Cocoa.h>

@implementation UsbHID

static UsbHID *_sharedManager = nil;

@synthesize delegate;

static void RawInputCallback(void* context, IOReturn result, void* sender, IOHIDReportType type, uint32_t reportID, uint8_t *report,CFIndex reportLength){
    [[[UsbHID sharedManager] delegate] usbhidDidRecvData:report length:reportLength reportId:reportID];
}

static void RawDeviceMatchingCallback(void *inContext,IOReturn inResult,void *inSender,IOHIDDeviceRef inIOHIDDeviceRef) {
    [[UsbHID sharedManager] setDeviceRef:inIOHIDDeviceRef];
    char *inputbuffer = malloc(64);
    IOHIDDeviceRegisterInputReportCallback([[UsbHID sharedManager]getDeviceRef], (uint8_t*)inputbuffer, 64, RawInputCallback, NULL);
#ifdef USB_HID_DEBUG
    NSLog(@"%p设备插入,现在usb设备数量:%ld",(void *)inIOHIDDeviceRef,GetUsbHidDeviceCount(inSender));
#endif
    [[[UsbHID sharedManager] delegate] usbhidDidMatch];
}

static void RawDeviceRemovalCallback(void *inContext,IOReturn inResult,void *inSender,IOHIDDeviceRef inIOHIDDeviceRef) {
    [[UsbHID sharedManager] setDeviceRef:nil];
#ifdef USB_HID_DEBUG
    NSLog(@"%p设备拔出,现在usb设备数量:%ld",(void *)inIOHIDDeviceRef,GetUsbHidDeviceCount(inSender));
#endif
    [[[UsbHID sharedManager] delegate] usbhidDidRemove];
}

#ifdef USB_HID_DEBUG
static long GetUsbHidDeviceCount(IOHIDManagerRef HIDManager){
    CFSetRef devSet = IOHIDManagerCopyDevices(HIDManager);
    if(devSet)
        return CFSetGetCount(devSet);
    return 0;
}
#endif

+(UsbHID *)sharedManager {
    @synchronized( [UsbHID class] ){
        if(!_sharedManager)
            _sharedManager = [[self alloc] init];
        return _sharedManager;
    }
    return nil;
}

+(id)alloc {
    @synchronized ([UsbHID class]){
        NSAssert(_sharedManager == nil,
                 @"Attempted to allocated a second instance");
        _sharedManager = [super alloc];
        return _sharedManager;
    }
    return nil;
}

- (id)initWithVID:(long)vid withPID:(long)pid {
    self = [super init];
    if (self) {
        managerRef = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
        IOHIDManagerScheduleWithRunLoop(managerRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
        IOReturn ret = IOHIDManagerOpen(managerRef, kIOHIDOptionsTypeNone);
        if (ret != kIOReturnSuccess) {
#ifdef USB_HID_DEBUG
            NSLog(@"Fail to open device");
#endif
            return self;
        }
        const long vendorID = vid;
        const long productID = pid;
        NSMutableDictionary* dict= [NSMutableDictionary dictionary];
        [dict setValue:[NSNumber numberWithLong:productID] forKey:[NSString stringWithCString:kIOHIDProductIDKey encoding:NSUTF8StringEncoding]];
        [dict setValue:[NSNumber numberWithLong:vendorID] forKey:[NSString stringWithCString:kIOHIDVendorIDKey encoding:NSUTF8StringEncoding]];
        IOHIDManagerSetDeviceMatching(managerRef, (__bridge CFMutableDictionaryRef)dict);
        
        IOHIDManagerRegisterDeviceMatchingCallback(managerRef, &RawDeviceMatchingCallback, NULL);
        IOHIDManagerRegisterDeviceRemovalCallback(managerRef, &RawDeviceRemovalCallback, NULL);
        
        NSSet* allDevices = (__bridge NSSet*)(IOHIDManagerCopyDevices(managerRef));
        NSArray* deviceRefs = [allDevices allObjects];
        if (deviceRefs.count==0) {
            
        }
    }
    return self;
}

- (void)dealloc {
    IOReturn ret = IOHIDDeviceClose(deviceRef, 0L);
    if (ret == kIOReturnSuccess) {
        deviceRef = nil;
    }
    ret = IOHIDManagerClose(managerRef, 0L);
    if (ret == kIOReturnSuccess) {
        managerRef = nil;
    }
}

- (void)connectHID {
    NSSet* allDevices = (__bridge NSSet*)(IOHIDManagerCopyDevices(managerRef));
    NSArray* deviceRefs = [allDevices allObjects];
    deviceRef = (deviceRefs.count)?(__bridge IOHIDDeviceRef)[deviceRefs objectAtIndex:0]:nil;
}

- (void)sendData:(char*)outbuffer withLength:(int)length withReportId:(CFIndex)reportId {
    if (!deviceRef) {
        return ;
    }
    IOReturn ret = IOHIDDeviceSetReport(deviceRef, kIOHIDReportTypeOutput, reportId, (uint8_t*)outbuffer, length);
    if (ret != kIOReturnSuccess) {
#ifdef USB_HID_DEBUG
        NSLog(@"Fail to send data.");
#endif
    }
}

- (IOHIDManagerRef)getManageRef {
    return managerRef;
}

- (void)setManageRef:(IOHIDManagerRef)ref {
    managerRef = ref;
}

- (IOHIDDeviceRef)getDeviceRef {
    return deviceRef;
}

- (void)setDeviceRef:(IOHIDDeviceRef)ref {
    deviceRef = ref;
}
@end
