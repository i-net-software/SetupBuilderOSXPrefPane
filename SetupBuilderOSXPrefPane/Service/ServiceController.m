//
//  ServiceController.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "ServiceController.h"
#import "OnOffSwitchControl.h"
#import "Process.h"
#import "Service.h"

@implementation ServiceController

@synthesize service = _service;
@synthesize status;

NSTimer *timer;

- (void)setService:(Service *)service
{
    _service = service;
    description.stringValue = service.description;
    productName.stringValue = service.name;
    productVersion.stringValue = [NSString stringWithFormat:@"v: %@", service.version];
    uninstall.title = @"Uninstall";
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(pollStatus) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
}

-(BOOL) serviceStatusChanged {

    SERVICE_STATUS currentState = self.status;
    BOOL isRunning = [self.service isServiceRunning];
    switch (self.status) {
        case SERVICE_STOPPED:
        case SERVICE_RUNNING:
            self.status = isRunning ? SERVICE_RUNNING : SERVICE_STOPPED;
            break;
        case SERVICE_STARTING:
            self.status = isRunning ? SERVICE_RUNNING : self.status;
        case SERVICE_STOPPING:
            self.status = isRunning ? self.status : SERVICE_STOPPED;
    }
//*
    // Nothing
/*/
    if ( self.status != SERVICE_RUNNING ) {
        Process *p = [[Process alloc] init];
        
        NSString *output;
        NSString *launchCtlCommand = [NSString stringWithFormat:@"/bin/launchctl list | grep %@$", self.service.identifier];
        if (self.service.useSudo) {
            output = [p executeSudo:launchCtlCommand];
        } else {
            output = [p execute:launchCtlCommand];
        }
        
        if ([output length] > 0) {
            self.status = SERVICE_RUNNING;
        }
    }
//*/
    return self.status != currentState;
    
}

-(void) stop {
    self.status = SERVICE_STOPPING;
    [self updateStatusIndicator];
    
    Process *p = [[Process alloc] init];
    NSString *runCommand = [NSString stringWithFormat:@"/bin/launchctl unload %@", [self.service pathForService]];
    NSString *cleanupCommand = [NSString stringWithFormat:@"rm %@", [self.service pathForService]];

    if (self.service.useSudo) {
        [p executeSudo:runCommand];
        [p executeSudo:cleanupCommand];
    } else {
        [p execute:runCommand];
        [p executeSudo:cleanupCommand];
    }
}

-(void) start {
    self.status = SERVICE_STARTING;
    [self updateStatusIndicator];
    
    Process *p = [[Process alloc] init];
    NSString *copyCommand = [NSString stringWithFormat:@"cp %s %@", [self.service.plist fileSystemRepresentation], [self.service pathForService]];
    NSString *runCommand = [NSString stringWithFormat:@"/bin/launchctl load %@", [self.service pathForService]];

    if (self.service.useSudo) {
        [p executeSudo:copyCommand];
        [p executeSudo:runCommand];
    } else {
        [p execute:copyCommand];
        [p execute:runCommand];
    }
}

-(void)pollStatus {
    if ( [self serviceStatusChanged] ) {
        [self updateStatusIndicator];
    }
}

-(void) updateStatusIndicator {
    
    NSString *statusImageName;
    NSString *statusImageAccessibilityDescription;
    switch (self.status) {
        case SERVICE_STARTING:
        case SERVICE_STOPPING:
            statusImageName = @"yellow";
            statusImageAccessibilityDescription = NSLocalizedString(@"Starting or stopping", nil);
            break;
        case SERVICE_STOPPED:
            statusImageName = @"red";
            statusImageAccessibilityDescription = NSLocalizedString(@"Not running", nil);
            break;
        case SERVICE_RUNNING:
            statusImageName = @"green";
            statusImageAccessibilityDescription = NSLocalizedString(@"Running", nil);
            break;
    }

    [onOffSwitch setState:self.status == SERVICE_RUNNING || self.status == SERVICE_STARTING ? 1 : 0];
    NSLog(@"Status: %d; runAsRoot: %d, runAtLogin: %d", self.status, self.service.useSudo, self.service.runAtBoot);
    
    [statusIndicator setImage:[[NSImage alloc] initByReferencingFile:[[NSBundle bundleForClass:[self class]] pathForResource:statusImageName ofType:@"png"]]];
    [statusIndicator.cell accessibilitySetOverrideValue:statusImageAccessibilityDescription forAttribute:NSAccessibilityDescriptionAttribute];
    [statusIndicator setNeedsDisplay:YES];
}

- (IBAction) handleStartStopClick:(OnOffSwitchControl *)onOff
{
    if (onOff.state == NSOnState) {
        [self start];
    } else {
        [self stop];
    }
}

- (IBAction) handleUninstallClick:(NSButton *)button {
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Do you realy want to remove THE PRODUCT?" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:NULL informativeTextWithFormat:@"This will remove THE PRODUCT and the preferecene pane"];
    
    if ( [alert runModal] == NSAlertDefaultReturn ) {

        [self stop];
        
        // Uninstall
    }
}

- (void)handleStartPageClick:(NSButton *)button {
    
}
@end




