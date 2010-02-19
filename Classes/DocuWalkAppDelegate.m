//
//  DocuWalkAppDelegate.m
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/28/09.
//  Copyright Good Old 2009. All rights reserved.
//

#import "DocuWalkAppDelegate.h"
#import "OAConsumer.h"
#import "AuthorizationManager.h"
#import "AuthorizationViewController.h"
#import "TaskListViewController.h"
#import "OAuthRESTClientDelegate.h"

static NSString *baseUrl;

@implementation DocuWalkAppDelegate

@synthesize window;
@synthesize restClient;
@synthesize tabBarController;

+ (NSURL *)apiURL:(NSString *)fragment {
	return [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/api/%@", baseUrl, fragment]] autorelease];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"dist" ofType:@"plist"];
	NSDictionary *dist = [NSDictionary dictionaryWithContentsOfFile:path];
	
	// Create a shared authorization manager
	baseUrl = [[dist objectForKey:@"base_url"] retain];
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:[dist objectForKey:@"oauth_consumer_key"] secret:[dist objectForKey:@"oauth_consumer_secret"]];
	AuthorizationManager *manager = [[[AuthorizationManager alloc] initWithConsumer:consumer baseUrl:[NSURL URLWithString:baseUrl]] autorelease];
	[AuthorizationManager setSharedManager:manager];
	
	// Create a shared rest client
	RESTClient *client = [[RESTClient alloc] init];
    OAuthRESTClientDelegate *oauthDelegate = [[OAuthRESTClientDelegate alloc] initWithAuthorizationManager:manager];
    client.delegate = [oauthDelegate autorelease];
	[RESTClient setSharedClient:[client autorelease]];
	
	// Create a authorization and a task list view
	AuthorizationViewController *authController = [[AuthorizationViewController alloc] initWithNibName:@"AuthorizationView" bundle:nil];
	TaskListViewController *taskList = [[TaskListViewController alloc] initWithNibName:@"TaskListView" bundle:nil];
	
	// Wrap our list in a nav controller
	UINavigationController *navController = [[[UINavigationController alloc] init] autorelease];
	[navController pushViewController:taskList animated:FALSE];
	
	NSArray *controllers = [[NSArray alloc] initWithObjects:navController, authController, nil];
	[tabBarController setViewControllers:[controllers autorelease]];
	
	if (![manager hasAccess]) {
		tabBarController.selectedIndex = [controllers indexOfObject:authController];
	}

	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
