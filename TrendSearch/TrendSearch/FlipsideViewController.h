//
//  FlipsideViewController.h
//  TrendSearch
//
//  Created by Abhijeet Vijayakar on 3/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;

@property (nonatomic, assign) IBOutlet UITableView *topicsTableView; 

@property (nonatomic, assign) NSArray *topicsArr;
@property (nonatomic, assign) NSArray *urlsArr;

- (void)setTopicsArr:(NSArray *)topicsToFill urls:(NSArray*)urls;

- (IBAction)done:(id)sender;

@end
