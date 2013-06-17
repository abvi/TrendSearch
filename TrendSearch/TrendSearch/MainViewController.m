//
//  MainViewController.m
//  TrendSearch
//
//  Created by Abhijeet Vijayakar on 3/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"

#import "TouchXML.h"

// JSON parsing library from http://mobile.tutsplus.com/tutorials/iphone/iphone-json-twitter-api/
#import "JSON.h"

@implementation MainViewController

@synthesize countrySelection;
@synthesize countryNames;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    countrySelection.delegate = self;
    countrySelection.dataSource = self;
    
    countryNames = [self getCountryNames];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onSearchButtonPressed:(id)sender
{    
    // print the selected values
    int selectedCountryRow = [countrySelection selectedRowInComponent:0];
    NSString *selectedCountry = [countryNames objectAtIndex:selectedCountryRow];
    NSString *numTopics = [numTopicsControl 
                           titleForSegmentAtIndex:numTopicsControl.selectedSegmentIndex];
    NSLog(@"Country: %@, num topics:%@", selectedCountry, numTopics);
    ////////////////////////////////
                                 
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    controller.delegate = self;
    
    // initialize the flip side controller with the selected number of trending topics for the
    // selected country
    // the returned array contains 2 arrays, one for the topics and the other for the corresponding URLs
    NSArray *topicsAndURLs = [self getTrendingTopics:selectedCountry numTopics:numTopics.intValue];
    [controller setTopicsArr:[topicsAndURLs objectAtIndex:0] urls:[topicsAndURLs objectAtIndex:1]];
    
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
    
    [controller release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

///////////////////////////////////////////////////////
// data source methods
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [countryNames count];
}

///////////////////////////////////////////////////////
// delegate methods
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [countryNames objectAtIndex:row];
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Let's print in the console what the user had chosen;
    //NSLog(@"Chosen item: %@", [countryNames objectAtIndex:row]);
}

/////////////////////////////////////////////////////////
// private methods

// This returns an array of arrays: [0] contains the names of the topics (which are displayed); 
// [1] contains the URLs of the corresponding Twitter searches to invoke when the item is clicked on
- (NSArray *)getTrendingTopics:(NSString *)country numTopics:(int)numTopics
{
    NSString *woeId = [self getWOEIDForCountry:country];
    NSLog(@"WOEID response=%@", woeId);
    
    // now get the trending topics for this location
    NSString *twitterURL = [self getTwitterTrendsURL:woeId];
    //NSLog(@"Twitter URL=%@", twitterURL);
    NSString *jsonResponse = [self makeRestCall:twitterURL];
    NSLog(@"Twitter response=%@", jsonResponse);
    
    NSMutableArray *trendsArr = [[NSMutableArray alloc] init];  // this is the list of trends displayed
    NSMutableArray *urlsArr = [[NSMutableArray alloc] init];  // the urls corresponding to the trends    
    
    if ([[jsonResponse JSONValue] isKindOfClass:[NSArray class]])
    {
        NSArray *topLevelStructure = [jsonResponse JSONValue];
        NSDictionary *dict = [topLevelStructure objectAtIndex:0];    
        
        NSArray *trendsElts = [dict objectForKey:@"trends"];
        NSDictionary *trendEntry;
        for (trendEntry in trendsElts)
        {
            [trendsArr addObject:[trendEntry objectForKey:@"name"]];
            [urlsArr addObject:[trendEntry objectForKey:@"url"]];
            if ([trendsArr count] >= numTopics)
            {
                // inelegant
                break;
            }
        }
    }
    
    // construct the combined array containing the trends and the URLs they go to
    NSMutableArray *combinedArr = [[NSMutableArray alloc] init];
    [combinedArr addObject:trendsArr];
    [combinedArr addObject:urlsArr];
    return combinedArr;
}

// returns the WOEID from Yahoo given the name of a country
- (NSString *)getWOEIDForCountry:(NSString *)country
{
    // URL format from http://stackoverflow.com/questions/1822650/yahoo-weather-api-woeid-retrieval
    NSString *urlToCall = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=select%%20*%%20from%%20geo.places%%20where%%20text%%3D'%@'&format=xml", 
        [country  stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];  
    // we escape the country name so that spaces are replaced with %20
    
    //NSLog(@"urlToCall=%@", urlToCall);
    
    // get the XML back
    NSString *xmlResponse = [self makeRestCall:urlToCall];
    //NSLog(@"xmlResponse=%@", xmlResponse);
    
    ////////////////////////
    // TouchXML parsing
    CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString:xmlResponse options:0 error:nil] autorelease];
    
    // TouchXML parsing code from http://stackoverflow.com/questions/526887/getting-the-value-of-an-element-in-cocoa-using-touchxml
    // the elements returned by the Yahoo API are within a namespace
    NSDictionary *mappings = [NSDictionary dictionaryWithObject:@"http://where.yahooapis.com/v1/schema.rng" forKey:@"yahoons"];
    NSArray *nodes = [doc nodesForXPath:@"//yahoons:woeid" namespaceMappings:mappings error:nil];
    
    if ([nodes count] > 0)
    {
        // take the first woeid
        CXMLElement *node = [nodes objectAtIndex:0];
        NSString *woeId = [node stringValue];
        return woeId;
    }
    
    // global woeid is 1
    NSLog(@"WARNING: Could not find WOEId for country %@", country);
    return @"1";
}

/////////////////////////////////////////////////////////////
// from http://blog.hardikr.com/tech/rest-objc/
- (NSString*)makeRestCall : (NSString*) reqURL
{
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:reqURL]];
    NSURLResponse *resp = nil;
    NSError *error = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &resp error: &error];
    NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]; 
    
    //NSLog(@"URLResponse=%@", resp);
    //NSLog(@"Result from call=%@",responseString);
    //NSLog(@"Response string length=%@", [responseString length]);
    return responseString;
}

- (NSString *)getTwitterTrendsURL:(NSString*)woeId
{
    // NOTE: We are using the DEPRECATED v1 API since that allows us to make unauthenticated requests.
    // v1.1 requires authenticated requests which are a lot more work to set up and not worth it for this test app.
    return [NSString stringWithFormat:@"https://api.twitter.com/1/trends/%@.json", woeId];
}

// gets country names from geoNames service
- (NSArray *)getCountryNames
{
    NSString *countryJson = [self makeRestCall:@"http://api.geonames.org/countryInfoJSON?username=abhijeetvijayakar"];
    NSDictionary *dict = [countryJson JSONValue];
    NSArray *countryEntries = [dict objectForKey:@"geonames"];
    
    // put some common countries at the top
    NSMutableArray *countryList = [[NSMutableArray alloc] 
        initWithObjects:@"United States", @"India", @"United Kingdom", @"Australia", @"Indonesia", @"Russia", @"Canada", nil];
    for (NSDictionary *countryEntry in countryEntries)
    {
        [countryList addObject:[countryEntry objectForKey:@"countryName"]];
    }
    return countryList;
}

@end
