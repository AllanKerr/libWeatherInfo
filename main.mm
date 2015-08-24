//
//  main.mm
//  WeatherBoard
//
//  Created by Allan Kerr on 2015-01-17.
//
//

#import "WBInfoService.h"
#import "NSXPCListener.h"
#import "IOKit.h"
#import <signal.h>
#import <substrate.h>

// these don't need to be static because main never returns
io_connect_t  root_port;
WBInfoService *infoService = nil;

void SystemPowerDidChange(void *refCon, io_service_t service, natural_t messageType, void *messageArgument) {
    
    switch (messageType) {
        case kIOMessageSystemWillSleep:
            [infoService systemWillSleep];
        case kIOMessageCanSystemSleep:
            // IOAllowPowerChange must be called or the device will not go to sleep
            IOAllowPowerChange( root_port, (long)messageArgument );
            break;
            
        case kIOMessageSystemWillPowerOn:
            [infoService systemWillPowerOn];
            break;
    }
}

int main(int argc, char *argv[]) {
    
    @autoreleasepool {
        
        IONotificationPortRef notifyPortRef;
        io_object_t notifierObject;
        void *refCon = NULL;

        // register for system power notifications
        // this allows the daemon to sleep and wake based on when the device is asleep and awake
        root_port = IORegisterForSystemPower(refCon, &notifyPortRef, SystemPowerDidChange, &notifierObject);
        
        // listens for conenctions from WBWeatherInfoManager
        NSString *serviceName = [NSString stringWithUTF8String:argv[1]];
        NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:serviceName];
        infoService = [[WBInfoService alloc] initWithServiceName:serviceName];
        listener.delegate = infoService;
        [listener resume];
        
        // start the run loop preventing main from returning
        // in order to gracefully stop the daemon all that is required is stopping the run loop
        CFRunLoopAddSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(notifyPortRef), kCFRunLoopCommonModes);
        CFRunLoopRun();
        
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(notifyPortRef), kCFRunLoopCommonModes);
        IODeregisterForSystemPower( &notifierObject );
        IOServiceClose(root_port);
        IONotificationPortDestroy(notifyPortRef);

        [infoService release];
        [listener invalidate];
        [listener release];
    }
    return 0;
}
