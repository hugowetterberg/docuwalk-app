//
//  TaskListViewController.h
//  DocuWalk
//
//  Created by Hugo Wetterberg on 10/29/09.
//  Copyright 2009 Good Old. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *tasks;
	UITableView *tableView;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
