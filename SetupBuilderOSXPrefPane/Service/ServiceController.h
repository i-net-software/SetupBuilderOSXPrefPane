//
//  ServiceController.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "Service.h"

@class OnOffSwitchControl;
@interface ServiceController : NSObject {
    
    IBOutlet OnOffSwitchControl *onOffSwitch;
    IBOutlet NSImageView *statusIndicator;
    IBOutlet NSTextField *description;
    IBOutlet NSTextField *productName;
    IBOutlet NSTextField *productVersion;
    IBOutlet NSButton *uninstall;
}

@property (strong, nonatomic) Service *service;
@property (strong) NSFileManager *fm;

@property int status;

-(BOOL) isStarted;
-(void) start;
-(void) stop;
-(void) updateStatusIndicator;

- (IBAction) handleStartStopClick:(OnOffSwitchControl *)onOff;
- (IBAction) handleUninstallClick:(NSButton *)button;

@end
