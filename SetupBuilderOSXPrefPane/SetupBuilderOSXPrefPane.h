//
//  SetupBuilderOSXPrefPane.h
//  SetupBuilderOSXPrefPane
//
//  Created by Gerry Weißbach on 23/07/2015.
//  Copyright (c) 2015 i-net software. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>

@class ServiceController;
@interface SetupBuilderOSXPrefPane : NSPreferencePane
{
    IBOutlet ServiceController *serviceController;
}

- (void)mainViewDidLoad;
- (void)didUnselect;

@end
