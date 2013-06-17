//
//  MainViewController.h
//  TrendSearch
//
//  Created by Abhijeet Vijayakar on 3/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController 
<FlipsideViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate> 
{
    IBOutlet UISegmentedControl *numTopicsControl;
    IBOutlet UIPickerView *countrySelection;
    NSArray *countryNames;
}

@property (nonatomic, retain) IBOutlet UIPickerView *countrySelection;
@property (nonatomic, retain) NSArray *countryNames;

- (IBAction)onSearchButtonPressed:(id)sender;

//////////////////////////////////////////////////////////
//private methods

- (NSArray *)getTrendingTopics:(NSString *)country numTopics:(int)numTopics;
- (NSString *)getWOEIDForCountry:(NSString *)country;
- (NSString*)makeRestCall : (NSString*)reqURL;
- (NSString *)getTwitterTrendsURL:(NSString*)woeId;
- (NSArray *)getCountryNames;

@end
