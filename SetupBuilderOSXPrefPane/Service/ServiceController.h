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
    IBOutlet NSButton *startPage;
}

typedef enum {

    SERVICE_STOPPED = 0,
    SERVICE_RUNNING,
    SERVICE_STARTING,
    SERVICE_STOPPING
    
} SERVICE_STATUS;


@property (strong, nonatomic) Service *service;
@property (strong) NSFileManager *fm;

@property SERVICE_STATUS status;

-(void) start;
-(void) stop;
-(BOOL) serviceStatusChanged;
-(void) updateStatusIndicator;
-(void)pollStatus;

- (IBAction) handleStartStopClick:(OnOffSwitchControl *)onOff;
- (IBAction) handleUninstallClick:(NSButton *)button;
- (IBAction) handleStartPageClick:(NSButton *)button;

@end
