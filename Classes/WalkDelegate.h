//
//  WalkDelegate.h
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/30/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocuWalkNote.h"

@protocol WalkDelegate <NSObject>
-(void)noteAdded:(DocuWalkNote *)note;
@end
