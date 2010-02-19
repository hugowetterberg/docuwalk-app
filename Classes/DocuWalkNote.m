//
//  DocuWalkNote.m
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/30/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import "DocuWalkNote.h"


@implementation DocuWalkNote

@synthesize nid, coordinate, time, text, solution;

- (NSString *)wktCoordinate {
	return [NSString stringWithFormat:@"%f %f", coordinate.latitude, coordinate.longitude];
}

@end
