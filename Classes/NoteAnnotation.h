//
//  NoteAnnotation.h
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/30/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DocuWalkNote.h"

@interface NoteAnnotation : NSObject <MKAnnotation> {
	DocuWalkNote *note;
}

- (id)initWithNote:(DocuWalkNote *)aNote;

@end
