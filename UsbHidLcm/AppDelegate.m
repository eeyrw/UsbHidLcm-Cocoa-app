//
//  AppDelegate.m
//  UsbHidLcm
//
//  Created by YuansMacMini on 17/8/11.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import "AppDelegate.h"




@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSScrollView *mainTextField;
@property (unsafe_unretained) IBOutlet NSTextView *mainTextView;
@property (weak) IBOutlet NSButton *sendButton;


@end

@implementation AppDelegate

UsbHidLcmDevice *udev;


-(void)textDidChange:(NSNotification *)notification {
    [udev printString:[[_mainTextView textStorage]string]];
}
- (IBAction)send:(id)sender {
    
    [udev printString:[[_mainTextView textStorage]string]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    udev=[UsbHidLcmDevice alloc];
    [udev initWithVid:0x0483 withPid:0x5750];
    udev.delegate=self;
    _mainTextView.textStorage.delegate = self;
}

-(void)deviceDidMatch{
    NSLog(@"dev attached");
    [udev initLcdWithX:24 withY:2];
    [udev setCurosrWithX:0 withY:0];
    [udev printString:@"LALALA!"];
    
}

-(void)deviceDidRemove{
    NSLog(@"dev detached");
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
