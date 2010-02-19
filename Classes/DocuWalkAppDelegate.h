//
//  DocuWalkAppDelegate.h
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/28/09.
//  Copyright Good Old 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESTClient.h"

@class DocuWalkViewController;

@interface DocuWalkAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	RESTClient *restClient;
}

@property (readonly) RESTClient *restClient;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController* tabBarController;

+ (NSURL *)apiURL:(NSString *)fragment;

@end

