//
//  Walk.h
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/29/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "WalkDelegate.h"

@interface Walk : NSObject <CLLocationManagerDelegate> {
	id<WalkDelegate> delegate;
	NSDictionary *task;
	NSDictionary *solution;
	CLLocationManager *locationManager;
	CLLocation *location;
}

+ (void)setCurrentWalk:(Walk *)aWalk;
+ (Walk *)currentWalk;

@property (readonly) NSDictionary *task;
@property (readonly) NSDictionary *solution;
@property (readonly) CLLocation *location;
@property (retain) id<WalkDelegate> delegate;

- (id)initWithTask:(NSDictionary *)aTask;
- (void)saveNote:(NSString *)note;

@end
