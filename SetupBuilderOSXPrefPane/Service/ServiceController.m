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

-(id) initWithService:(Service *)theService {
    
    NSLog(@"%@%@", @"Initializing service ", theService.identifier);
    
    self = [super init];
    
    self.service = theService;
    if ([self isStarted]) {
        self.status = 2;
    }

    [self updateStatusIndicator];
    return self;
}

-(BOOL) isStarted {
    
    Process *p = [[Process alloc] init];
    
    NSString *output;
    NSMutableString *launchCtlCommand = [[NSMutableString alloc] initWithString:@"/bin/launchctl list | grep "];
    [launchCtlCommand appendString:self.service.identifier];
    [launchCtlCommand appendString:@"$"];
    
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
    if (self.service.useSudo) {
        NSString *tmpPlist = [NSString stringWithFormat:@"/tmp/%@.plist", self.service.identifier];
        NSString *copyCommand = [NSString stringWithFormat:@"cp %s %@", [self.service.plist fileSystemRepresentation], tmpPlist];
        NSString *runCommand = [NSString stringWithFormat:@"/bin/launchctl unload %@", tmpPlist];
        NSString *cleanupCommand = [NSString stringWithFormat:@"rm %@", tmpPlist];
        [p executeSudo:copyCommand];
        [p executeSudo:runCommand];
        [p executeSudo:cleanupCommand];
    } else {
        NSString *command = [NSString stringWithFormat:@"/bin/launchctl unload %s", [self.service.plist fileSystemRepresentation]];
        [p execute:command];
    }
    
    [self isStarted];
    [self updateStatusIndicator];

}

-(void) start {
    self.status = 1;
    [self updateStatusIndicator];
    
    Process *p = [[Process alloc] init];
    if (self.service.useSudo) {
        NSString *tmpPlist = [NSString stringWithFormat:@"/tmp/%@.plist", self.service.identifier];
        NSString *copyCommand = [NSString stringWithFormat:@"cp %s %@", [self.service.plist fileSystemRepresentation], tmpPlist];
        NSString *runCommand = [NSString stringWithFormat:@"/bin/launchctl load %@", tmpPlist];
        NSString *cleanupCommand = [NSString stringWithFormat:@"rm %@", tmpPlist];
        [p executeSudo:copyCommand];
        [p executeSudo:runCommand];
        [p executeSudo:cleanupCommand];
    } else {
        NSString *command = [NSString stringWithFormat:@"/bin/launchctl load %s", [self.service.plist fileSystemRepresentation]];
        [p execute:command];
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

    NSLog(@"Status: %d; runAsRoot: %d, runAtLogin: %d", self.status, self.service.useSudo, self.service.runAtLogin);
    [onOffSwitch setState:self.status != 0 ? 1 : 0];
    [runAsRoot setState:self.service.useSudo ? 1 : 0];
    [runtAtBoot setState:self.service.runAtLogin ? 1 : 0];
    
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

- (void)handleSudoClick:(OnOffSwitchControl *)onOff
{
    [self stop];

    if (onOff.state == NSOnState) {
        self.service.useSudo = YES;
    } else {
        self.service.useSudo = NO;
    }
//    [self.serviceManager saveService:self.service];
    [self start];
    [self isStarted];
    [self updateStatusIndicator];
}

-(void) handleRunAtLoginClick:(OnOffSwitchControl *)onOff
{
    if (onOff.state == NSOnState) {
        self.service.runAtLogin = YES;
    } else {
        self.service.runAtLogin = NO;
    }
//    [self.serviceManager saveService:self.service];
    
    if (self.service.runAtLogin) {
        NSString *newPlist;
        if (self.service.useSudo) {
            newPlist = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@.plist", self.service.identifier];
        } else {
            newPlist = [NSString stringWithFormat:@"%@/Library/LaunchAgents/%@.plist", NSHomeDirectory(), self.service.identifier];
        }
        NSString *copyCommand = [NSString stringWithFormat:@"cp %s %@", [self.service.plist fileSystemRepresentation], newPlist];
        NSLog(@"Executing for at-login run: %@", copyCommand);
        Process *p = [[Process alloc] init];
        if (self.service.useSudo) {
            [p executeSudo:copyCommand];
        } else {
            [p execute:copyCommand];
        }
    } else {
        NSString *plistToDelete;
        if (self.service.useSudo) {
            plistToDelete = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@.plist", self.service.identifier];
        } else {
            plistToDelete = [NSString stringWithFormat:@"%@/Library/LaunchAgents/%@.plist", NSHomeDirectory(), self.service.identifier];
        }
        NSString *deleteCommand = [NSString stringWithFormat:@"rm -f %@", plistToDelete];
        NSLog(@"Cleaning up: %@", deleteCommand);
        Process *p = [[Process alloc] init];
        if (self.service.useSudo) {
            [p executeSudo:deleteCommand];
        } else {
            [p execute:deleteCommand];
        }
    }
}

-(void) handleRemoveClick:(id)sender {
    [self stop];
//    [self.serviceManager removeService:self.service];
}

@end
