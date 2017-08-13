//
//  AppDelegate.m
//  UsbHidLcm
//
//  Created by YuansMacMini on 17/8/11.
//  Copyright © 2017年 Yuan. All rights reserved.
//

#import "AppDelegate.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

#define  WWW_PORT 2400 // 0 => automatic
#define  WWW_HOST @"192.168.1.134"


#define READ_HEADER_LINE_BY_LINE 0



@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSScrollView *mainTextField;
@property (unsafe_unretained) IBOutlet NSTextView *mainTextView;
@property (weak) IBOutlet NSButton *sendButton;


@end

@implementation AppDelegate

UsbHidLcmDevice *udev;

-(void)networkInit{
    // AsyncSocket optionally uses the Lumberjack logging framework.
    //
    // Lumberjack is a professional logging framework. It's extremely fast and flexible.
    // It also uses GCD, making it a great fit for GCDAsyncSocket.
    //
    // As mentioned earlier, enabling logging in GCDAsyncSocket is entirely optional.
    // Doing so simply helps give you a deeper understanding of the inner workings of the library (if you care).
    // You can do so at the top of GCDAsyncSocket.m,
    // where you can also control things such as the log level,
    // and whether or not logging should be asynchronous (helps to improve speed, and
    // perfect for reducing interference with those pesky timing bugs in your code).
    //
    // There is a massive amount of documentation on the Lumberjack project page:
    // http://code.google.com/p/cocoalumberjack/
    //
    // But this one line is all you need to instruct Lumberjack to spit out log statements to the Xcode console.
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // We're going to take advantage of some of Lumberjack's advanced features.
    //
    // Format log statements such that it outputs the queue/thread name.
    // As opposed to the not-so-helpful mach thread id.
    //
    // Old : 2011-12-05 19:54:08:161 [17894:f803] Connecting...
    //       2011-12-05 19:54:08:161 [17894:11f03] GCDAsyncSocket: Dispatching DNS lookup...
    //       2011-12-05 19:54:08:161 [17894:13303] GCDAsyncSocket: Creating IPv4 socket
    //
    // New : 2011-12-05 19:54:08:161 [main] Connecting...
    //       2011-12-05 19:54:08:161 [socket] GCDAsyncSocket: Dispatching DNS lookup...
    //       2011-12-05 19:54:08:161 [socket] GCDAsyncSocket: Creating IPv4 socket
    
    DDDispatchQueueLogFormatter *formatter = [[DDDispatchQueueLogFormatter alloc] init];
    [formatter setReplacementString:@"socket" forQueueLabel:GCDAsyncSocketQueueName];
    [formatter setReplacementString:@"socket-cf" forQueueLabel:GCDAsyncSocketThreadName];
    
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    
    // Start the socket stuff
    
    [self startSocket];
}

- (void)startSocket
{
    // Create our GCDAsyncSocket instance.
    //
    // Notice that we give it the normal delegate AND a delegate queue.
    // The socket will do all of its operations in a background queue,
    // and you can tell it which thread/queue to invoke your delegate on.
    // In this case, we're just saying invoke us on the main thread.
    // But you can see how trivial it would be to create your own queue,
    // and parallelize your networking processing code by having your
    // delegate methods invoked and run on background queues.
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Now we tell the ASYNCHRONOUS socket to connect.
    //
    // Recall that GCDAsyncSocket is ... asynchronous.
    // This means when you tell the socket to connect, it will do so ... asynchronously.
    // After all, do you want your main thread to block on a slow network connection?
    //
    // So what's with the BOOL return value, and error pointer?
    // These are for early detection of obvious problems, such as:
    //
    // - The socket is already connected.
    // - You passed in an invalid parameter.
    // - The socket isn't configured properly.
    //
    // The error message might be something like "Attempting to connect without a delegate. Set a delegate first."
    //
    // When the asynchronous sockets connects, it will invoke the socket:didConnectToHost:port: delegate method.
    
    NSError *error = nil;
    
    uint16_t port = WWW_PORT;
    
    if (![asyncSocket connectToHost:WWW_HOST onPort:port error:&error])
    {
        DDLogError(@"Unable to connect to due to invalid configuration: %@", error);
    }
    else
    {
        DDLogVerbose(@"Connecting to \"%@\" on port %hu...", WWW_HOST, port);
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    DDLogVerbose(@"socket:didConnectToHost:%@ port:%hu", host, port);
    
    //Byte数组－> NSData
    
    Byte byte[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23};
    
    NSData *adata = [[NSData alloc] initWithBytes:byte length:24];
    [asyncSocket writeData:adata withTimeout:-1.0 tag:0];
    
}



- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    DDLogVerbose(@"socket:didWriteDataWithTag:");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    DDLogVerbose(@"socket:didReadData:withTag:");
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    // Since we requested HTTP/1.0, we expect the server to close the connection as soon as it has sent the response.
    
    DDLogVerbose(@"socketDidDisconnect:%p withError:%@", sock, err);
}

- (NSString *)getLocalIPAddress
{
    NSArray *ipAddresses = [[NSHost currentHost] addresses];
    NSArray *sortedIPAddresses = [ipAddresses sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.allowsFloats = NO;
    
    for (NSString *potentialIPAddress in sortedIPAddresses)
    {
        if ([potentialIPAddress isEqualToString:@"127.0.0.1"]) {
            continue;
        }
        
        NSArray *ipParts = [potentialIPAddress componentsSeparatedByString:@"."];
        
        BOOL isMatch = YES;
        
        for (NSString *ipPart in ipParts) {
            if (![numberFormatter numberFromString:ipPart]) {
                isMatch = NO;
                break;
            }
        }
        if (isMatch) {
            return potentialIPAddress;
        }
    }
    
    // No IP found
    return @"?.?.?.?";
}

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
    
    [self networkInit];
}

-(void)deviceDidMatch{
    NSLog(@"dev attached");
    [udev initLcdWithX:24 withY:2];
    [udev setCurosrWithX:0 withY:0];
    NSString *str=[self getLocalIPAddress];
    char* rawString=(char*)[str UTF8String];
    unsigned long len=strlen(rawString);
    [udev writeLcdWith: rawString withLength:len];
    
}

-(void)deviceDidRemove{
    NSLog(@"dev detached");
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
