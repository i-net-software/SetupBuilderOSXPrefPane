//
//  ServiceController.h
//  LaunchRocket
//
//  Created by Josh Butts on 3/28/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"

@class OnOffSwitchControl;
@interface ServiceController : NSObject {
    
    IBOutlet OnOffSwitchControl *onOffSwitch;
    IBOutlet OnOffSwitchControl *runtAtBoot;
    IBOutlet OnOffSwitchControl *runAsRoot;

}

@property (strong) Service *service;
@property (strong) NSFileManager *fm;

@property int status;

-(id) initWithService:(Service *) theService;
-(BOOL) isStarted;
-(void) start;
-(void) stop;
-(void) updateStatusIndicator;
-(void) updateStartStopStatus;
-(void) handleRemoveClick:(id)sender;

- (IBAction) handleStartStopClick:(OnOffSwitchControl *)onOff;
- (IBAction) handleSudoClick:(OnOffSwitchControl *)onOff;
- (IBAction) handleRunAtLoginClick:(OnOffSwitchControl *)onOff;

@end
