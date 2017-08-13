//
//  AppDelegate.h
//  UsbHidLcm
//
//  Created by YuansMacMini on 17/8/11.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UsbHidLcmDevice.h"
#import "GCDAsyncSocket.h" // for TCP
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDDispatchQueueLogFormatter.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,UsbHidLcmDeviceDelegate,NSTextViewDelegate>
{
    GCDAsyncSocket *asyncSocket;
}


@end

