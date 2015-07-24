//
//  Service.m
//  LaunchRocket
//
//  Created by Josh Butts on 3/26/13.
//  Copyright (c) 2013 Josh Butts. All rights reserved.
//

#import "Service.h"

@implementation Service

@synthesize plist;
@synthesize identifier;
@synthesize name;
@synthesize useSudo;
@synthesize runAtBoot;
@synthesize description;

- (id) initWithPlistURL:(NSURL *)plistURL
{
    self = [super init];
    self.plist = plistURL;
      
    NSDictionary *plistData = [[NSDictionary alloc] initWithContentsOfURL:self.plist];
    self.identifier = [plistData objectForKey:@"Label"];
    self.name = [plistData objectForKey:@"Name"];
    
    NSNumber *shouldUseSudo = [plistData objectForKey:@"RunAsRoot"];
    if (shouldUseSudo == nil) {
        self.useSudo = NO;
    } else {
        self.useSudo = [shouldUseSudo boolValue];
    }
    
    NSNumber *shouldRunAtLogin = [plistData objectForKey:@"RunAtBoot"];
    if (shouldRunAtLogin == nil) {
        self.runAtBoot = NO;
    } else {
        self.runAtBoot = [shouldRunAtLogin boolValue];
    }

    description = [plistData objectForKey:@"Description"];
    return self;
}

- (NSString *)pathForService {
    
    NSString *plistFile = [NSString stringWithFormat:@"/tmp/%@.plist", self.identifier];
    if (self.runAtBoot) {
        if (self.useSudo) {
            plistFile = [NSString stringWithFormat:@"/Library/LaunchDaemons/%@.plist", self.identifier];
        } else {
            plistFile = [NSString stringWithFormat:@"%@/Library/LaunchAgents/%@.plist", NSHomeDirectory(), self.identifier];
        }
        plistFile =[NSString stringWithFormat:@"/Library/LaunchDaemons/%@.plist", self.identifier];
    }
    
    NSLog(@"Path for service: %@", plistFile);
    return plistFile;
}

@end
