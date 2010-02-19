//
//  Walk.m
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/29/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import "Walk.h"
#import "DocuWalkAppDelegate.h"

static Walk* currentWalk;

@implementation Walk

@synthesize task, solution, location, delegate;

+ (void)setCurrentWalk:(Walk *)aWalk {
	[currentWalk release];
	currentWalk = [aWalk retain];
}

+ (Walk *)currentWalk {
	return currentWalk;
}

- (id)initWithTask:(NSDictionary *)aTask {
	if (self = [super init]) {
		task = [aTask retain];
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
		
		// Create a solution entry
		RESTClient *client = [RESTClient sharedClient];
		RESTClientRequest *request = [[RESTClientRequest alloc] initWithUrl:[DocuWalkAppDelegate apiURL:@"docuwalk-solution"] method:@"POST"];
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		[dict setValue:[task objectForKey:@"title"] forKey:@"title"];
		[dict setValue:@"" forKey:@"body"];
		[dict setValue:[task objectForKey:@"nid"] forKey:@"task"];
		[request setJSONBody:[dict autorelease]];
		[client performRequestAsync:[request autorelease] target:self selector:@selector(restClient:solutionCreated:) failSelector:@selector(restClient:failedToCreateSolution:)];
	}
	return self;
}

- (void)restClient:(id)request solutionCreated:(NSDictionary *)result {
	NSLog(@"%@", result);
	solution = [result retain];
}

- (void)restClient:(id)request failedToCreateSolution:(NSError *)error {
	NSLog(@"%@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	[location release];
	location = [newLocation retain];
	
	// Submit the waypoint to the server
	RESTClient *client = [RESTClient sharedClient];
	NSURL *actionUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/add-waypoint", [solution objectForKey:@"uri"]]];
	RESTClientRequest *request = [[RESTClientRequest alloc] initWithUrl:actionUrl method:@"POST"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setValue:[NSString stringWithFormat:@"%f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude] forKey:@"position"];
	[request setJSONBody:[dict autorelease]];
	[client performRequestAsync:[request autorelease] target:self selector:@selector(restClient:waypointRecorded:) failSelector:@selector(restClient:failedToRecordWaypoint:)];
}

- (void)restClient:(id)request waypointRecorded:(NSDictionary *)result {
	NSLog(@"%@", result);
}

- (void)restClient:(id)request failedToRecordWaypoint:(NSError *)error {
	NSLog(@"%@", [error localizedDescription]);
}

- (void)saveNote:(NSString *)noteText {
	DocuWalkNote *note = [[DocuWalkNote alloc] init];
	note.coordinate = location.coordinate;
	note.solution = [solution objectForKey:@"nid"];
	note.text = noteText;
	
	RESTClient *client = [RESTClient sharedClient];
	RESTClientRequest *request = [[RESTClientRequest alloc] initWithUrl:[DocuWalkAppDelegate apiURL:@"docuwalk-text"] method:@"POST"];
	request.infoObject = note;
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setValue:note.text forKey:@"body"];
	[dict setValue:note.solution forKey:@"solution"];
	[dict setValue:[note wktCoordinate] forKey:@"position"];
	[request setJSONBody:[dict autorelease]];
	[client performRequestAsync:[request autorelease] target:self selector:@selector(restClient:noteCreated:) failSelector:@selector(restClient:failedToCreateNote:)];
}

- (void)restClient:(RESTClientAsyncRequest *)request noteCreated:(NSDictionary *)result {
	NSLog(@"Saved note: %@", result);
	
	DocuWalkNote *note = request.restRequest.infoObject;
	note.nid = [result objectForKey:@"nid"];
	[delegate noteAdded:note];
}

- (void)restClient:(id)request failedToCreateNote:(NSError *)error {
	NSLog(@"Failed to save note: %@", [error localizedDescription]);
}

- (void)dealloc {
	[locationManager stopUpdatingLocation];
	[locationManager release];
	[task release];
	[solution release];
	[super dealloc];
}

@end
