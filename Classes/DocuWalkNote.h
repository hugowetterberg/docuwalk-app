//
//  DocuWalkNote.h
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/30/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DocuWalkNote : NSObject {
	NSString *nid;
	CLLocationCoordinate2D coordinate;
	NSDate *time;
	NSString *text;
	NSString *solution;
}

@property (retain, nonatomic) NSString *nid;
@property (assign) CLLocationCoordinate2D coordinate;
@property (retain, nonatomic) NSDate *time;
@property (retain, nonatomic) NSString *text;
@property (retain, nonatomic) NSString *solution;

- (NSString *)wktCoordinate;

@end
