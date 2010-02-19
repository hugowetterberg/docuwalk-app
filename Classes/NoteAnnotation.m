//
//  NoteAnnotation.m
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/30/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import "NoteAnnotation.h"

@implementation NoteAnnotation

- (id)initWithNote:(DocuWalkNote *)aNote {
	if (self = [super init]) {
		note = [aNote retain];
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate{
	return note.coordinate;
}

- (NSString *)title {
    return note.text;
}

- (NSString *)subtitle {
    return @"";
}

@end
