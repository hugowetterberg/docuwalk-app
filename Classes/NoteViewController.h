//
//  NoteViewController.h
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/30/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Walk.h"

@interface NoteViewController : UIViewController {
	Walk *walk;
	UIImageView *background;
	UITextView *note;
}

@property (retain, nonatomic) IBOutlet UIImageView *background;
@property (retain, nonatomic) IBOutlet UITextView *note;

- (id)initWithWalk:(Walk *)aWalk;
- (IBAction)saveNote;

@end
