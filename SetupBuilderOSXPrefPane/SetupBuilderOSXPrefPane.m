//
//  SetupBuilderOSXPrefPane.m
//  SetupBuilderOSXPrefPane
//
//  Created by Gerry Weißbach on 23/07/2015.
//  Copyright (c) 2015 i-net software. All rights reserved.
//

#import "SetupBuilderOSXPrefPane.h"

#import "OnOffSwitchControl.h"
#import "OnOffSwitchControlCell.h"
#import "ServiceController.h"
#import "Service.h"
#import "Process.h"

@implementation SetupBuilderOSXPrefPane

- (void)mainViewDidLoad
{
}

- (void)didUnselect {
    [Process killSudoHelper];
}

- (void)didSelect {
    NSURL *plist = [[NSBundle bundleForClass:[self class]] URLForResource:@"com.inet.pdfc.PDFCServer" withExtension:@"plist"];
    Service *service = [[Service alloc] initWithOptions:@{
                                                          @"plist":plist,
                                                          @"useSudo":@YES,
                                                          @"runAtLogin":@YES
                                                          }];
    
    [serviceController setService:service];
    [serviceController isStarted];
    [serviceController updateStatusIndicator];
}

@end
