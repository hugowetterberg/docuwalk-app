//
//  TaskViewController.h
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/29/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskViewController : UIViewController {
	NSDictionary *task;
	UIScrollView *descriptionScroll;
	UILabel *author;
	UILabel *description;
	UIImageView *background;
}

- (id)initWithTask:(NSDictionary *)aTask;

@property (retain, nonatomic) IBOutlet UILabel *author;
@property (retain, nonatomic) IBOutlet UILabel *description;
@property (retain, nonatomic) IBOutlet UIScrollView *descriptionScroll;
@property (retain, nonatomic) IBOutlet UIImageView *background;

@end
