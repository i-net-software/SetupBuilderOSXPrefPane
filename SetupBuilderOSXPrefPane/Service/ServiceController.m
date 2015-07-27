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

@synthesize service;
@synthesize status;
@synthesize description;

-(BOOL) isStarted {
    
    Process *p = [[Process alloc] init];
    
    NSString *output;
    NSString *launchCtlCommand = [NSString stringWithFormat:@"/bin/launchctl list | grep %@$", self.service.identifier];
    if (self.service.useSudo) {
        output = [p executeSudo:launchCtlCommand];
    } else {
        output = [p execute:launchCtlCommand];
    }
    
    if ([output length] > 0) {
        self.status = 2;
        return YES;
    }
    self.status = 0;
    return NO;
    
}

-(void) stop {
    self.status = 1;
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
    
    [self isStarted];
    [self updateStatusIndicator];
}

-(void) start {
    self.status = 1;
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
    
    [self isStarted];
    [self updateStatusIndicator];
}

-(void) updateStatusIndicator {
    NSString *statusImageName;
    NSString *statusImageAccessibilityDescription;

    switch (self.status) {
        case 0:
            statusImageName = @"red.png";
            statusImageAccessibilityDescription = NSLocalizedString(@"Not running", nil);
            break;
        case 1:
            statusImageName = @"yellow.png";
            statusImageAccessibilityDescription = NSLocalizedString(@"Starting or stopping", nil);
            break;
        case 2:
            statusImageName = @"green.png";
            statusImageAccessibilityDescription = NSLocalizedString(@"Running", nil);
            break;
    }

    NSLog(@"Status: %d; runAsRoot: %d, runAtLogin: %d", self.status, self.service.useSudo, self.service.runAtBoot);
    [onOffSwitch setState:self.status != 0 ? 1 : 0];
    
    [statusIndicator setImage:[NSImage imageNamed:statusImageName]];
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

@end
