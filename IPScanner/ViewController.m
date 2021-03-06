//
//  ViewController.m
//  IPScanner
//
//  Created by pramesh on 2/7/14.
//  Copyright (c) 2014 pramesh. All rights reserved.
//

#import "ViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController{
    NSString *str;
    int rowNumber;
    NSString *myString;
    NSString *ipAddress;
    NSMutableData *readData;
    NSString *actionString;
}
uint16_t port = 5001;

@synthesize myTableView, btnScan, btnScanComputer, btnConnect, btnSend, btnWrist, txtReadData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // check for wifi or internet connection
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == ReachableViaWiFi){
        NSLog(@"connected to WIFI");
    }
    else{
        UIAlertView *wifiAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Device is not connected to WIFI" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [wifiAlert show];
    }
    
	arrBarcode = [[NSMutableArray alloc]init];
    
    // load array for uisegmented control
    NSArray *arrayAction = [[NSArray alloc]initWithObjects:@"Registration",@"Send Ticket", @"Change Tracking",nil];
    
    // Set Title Image
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dfm_slogo.png"]];
    
    // Set background image
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"color_bg.png"]];
    [self.view addSubview:img];
    [self.view sendSubviewToBack:img];

    // Display btnScan
    UIImage * imgScan = [UIImage imageNamed:@"button_active.png"];
    [btnScan setBackgroundImage:imgScan forState:UIControlStateNormal];
    [btnScan setTitle:@"Scan" forState:UIControlStateNormal];
    [btnScan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Display Scan Computer Button
    UIImage *imgScanComputer = [UIImage imageNamed:@"button_active.png"];
    [btnScanComputer setBackgroundImage:imgScanComputer forState:UIControlStateNormal];
    [btnScanComputer setTitle:@"Read Data" forState:UIControlStateNormal];
    [btnScanComputer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Display Connect
    UIImage *imgConnect = [UIImage imageNamed:@"button_selected.png"];
    [btnConnect setBackgroundImage:imgConnect forState:UIControlStateNormal];
    [btnConnect setTitle:@"Connect to RST Scan" forState:UIControlStateNormal];
    [btnConnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Display btnSend
    UIImage *imgSend = [UIImage imageNamed:@"button_active.png"];
    [btnSend setBackgroundImage:imgSend forState:UIControlStateNormal];
    [btnSend setTitle:@"Send Data" forState:UIControlStateNormal];
    [btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSend setHidden:YES];
    
    // Display btnWrist
    UIImage *imgWrist = [UIImage imageNamed:@"button_active.png"];
    [btnWrist setBackgroundImage:imgWrist forState:UIControlStateNormal];
    [btnWrist setTitle:@"Wrist" forState:UIControlStateNormal];
    [btnWrist setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //Display UIsegmented control
    UISegmentedControl *control = [[UISegmentedControl alloc]initWithItems:arrayAction];
    control.frame = CGRectMake(3, 180, 312, 40);
    UIColor *color = [UIColor colorWithRed:0/255.0f green:150/255.0f blue:225/255.0f alpha:1.0f];
    //control.tintColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.7f alpha:1.0f];
    //[control setTintColor:color];
    [[UISegmentedControl appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:color} forState:UIControlStateNormal];
    [control addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:control];

    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    //get ip address of the device
    ipAddress= [self getIPAddress];
    NSLog(@"%@", ipAddress);
}


- (void)valueChanged:(UISegmentedControl *)segment
{
    if (segment.selectedSegmentIndex == 0)
    {
        actionString = [NSString stringWithFormat:@"%i", 0];
        //txtReadData.text = [NSString stringWithFormat:@"%i", 0];
    }
    else if (segment.selectedSegmentIndex == 1)
    {
        actionString = [NSString stringWithFormat:@"%i", 1];
        //txtReadData.text = [NSString stringWithFormat:@"%d", 1];
    }
    else if (segment.selectedSegmentIndex == 2)
    {
        actionString = [NSString stringWithFormat:@"%i", 2];
        //txtReadData.text = [NSString stringWithFormat:@"%i", 2];
    }
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
- (void) viewDidAppear:(BOOL)animated
{
    //host = self.txtServiceUrl.text;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ip = [defaults objectForKey:@"ip"];
    NSString *uniqueId = [defaults objectForKey:@"uniqueId"];
    bool isWristEnabled = [defaults boolForKey:@"isWristEnabled"];
    if (!isWristEnabled){
        [btnWrist setHidden:YES];
    }
    else{
        [btnWrist setHidden:NO];
    }
    host = ip;
    udid = uniqueId;
}

// UITableView Delegate Methods
-(NSInteger)numberOfSectionsInTableView: (UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrBarcode count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *barcode = [arrBarcode objectAtIndex:[indexPath row]];
    // Create custom color
    UIColor *color = [UIColor colorWithRed:0/255.0f green:150/255.0f blue:225/255.0f alpha:1.0f];
    cell.textLabel.textColor = color;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];    [cell.textLabel setText:barcode];
    [cell setBackgroundColor:[UIColor clearColor]];
    //UIButton *btn = [[UIButton alloc]init];
    //btn.frame = CGRectMake(200, 5.0, 50, 30);
    //btn.backgroundColor = [UIColor blackColor];
    //[btn setTitle:@"Send" forState:UIControlStateNormal];
    //[cell addSubview:btn];
    return cell;
}

// Set the identation for rows in UITableView
-(NSInteger) tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 5;
}

// Set the scroll in UITableView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 10;
    if (y > h + reload_distance)
    {
        [self.myTableView reloadData];
    }
}

// Set the cell click
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    rowNumber = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    str = cell.textLabel.text;
}

// Delete the data in each cell in UITableView
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [arrBarcode removeObjectAtIndex:indexPath.row];
        [self.myTableView reloadData];
    }
}

- (IBAction)btnScan:(id)sender {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    ZBarImageScanner *scanner = reader.scanner;
    [scanner    setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    [self presentViewController:reader animated:YES completion:nil];
}

- (IBAction)btnScanComputer:(id)sender {
    /*
    ZBarReaderController *reeader = [ZBarReaderController new];
    reeader.readerDelegate = self;
    if ([ZBarReaderController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        reeader.sourceType = UIImagePickerControllerSourceTypeCamera;
    [reeader.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    [self presentViewController:reeader animated:YES completion:nil];
     */
    if ([asyncSocket isConnected]){
        //[readData appendData:[GCDAsyncSocket CRLFData]];
        //[asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
        [asyncSocket readDataWithTimeout:-1 tag:0];
        NSLog(@"read button data read");
    }
    else{
        UIAlertView *alertConnect = [[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Not connected to the server" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertConnect show];
    }
}

- (void) imagePickerController:(UIImagePickerController *)reeader didFinishPickingMediaWithInfo:(NSDictionary *)info{
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for (symbol in results)
        break;
    //txtScannedBarcode.text = symbol.data;
    //str = txtScannedBarcode.text;
    str = symbol.data;
    if (symbol.data != nil){
        [arrBarcode addObject:str];
    }
    //resultImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.myTableView reloadData];
    [reeader dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnConnect:(id)sender {
    // Connect method goes here
    NSError *error = nil;
    if (![asyncSocket connectToHost:host onPort:port error:&error])
    {
       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not Connected" message:@"Could not connect to Server App, Try Again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
       [alertView show];
        UIImage *imgNotConnected = [UIImage imageNamed:@"button_selected.png"];
        [btnConnect setBackgroundImage:imgNotConnected forState:UIControlStateNormal];
        [btnConnect setTitle:@"Not Connected" forState:UIControlStateNormal];
    }
    // check if connection is made
    if ([asyncSocket isConnected]){
        [asyncSocket readDataWithTimeout:-1 tag:0];
        NSLog(@"connect button data read");
    }
     [asyncSocket readDataWithTimeout:-1 tag:0];
}

- (IBAction)btnSend:(id)sender {
    NSString *barcodeString = [[NSString alloc] initWithFormat:@"%@",str];
    //NSString *finalString = [string stringByAppendingString:ipAddress];
    NSString *finalString = [NSString stringWithFormat:@"%@|%@|%@", ipAddress, actionString, barcodeString];
    //NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    //[asyncSocket writeData:data withTimeout:-1 tag:0];
    [asyncSocket writeData:[finalString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}

//GCDAsync Delegate method
-(void)socket:(GCDAsyncSocket*)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    UIImage *imgConnect = [UIImage imageNamed:@"button_active.png"];
    [btnConnect setBackgroundImage:imgConnect forState:UIControlStateNormal];
    [btnConnect setTitle:@"Connected" forState:UIControlStateNormal];
    [btnConnect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnConnect setEnabled:NO];
    //[btnSend setEnabled:YES];
    [btnSend setHidden:NO];
    NSLog(@"did connect to host");
    //UIAlertView *alertConnect = [[UIAlertView alloc] initWithTitle:@"Not Connected" message:@"Could not connect to Server App, Try Again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //[alertConnect show];
}

-(void)socket:(GCDAsyncSocket*)sock didReadData:(NSData *)data withTag:(long)tag{
    //if data is read
    //txtReadData.text = [NSString stringWithFormat:@"%@", data];
    NSString *readString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    txtReadData.text = readString;
    //always keep a read in the queue
    [asyncSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"didReadData called");
    NSLog(@"%@", readString);
}

-(void)socket:(GCDAsyncSocket*) sock didWriteDataWithTag:(long)tag{
    NSLog(@" did write data with tag %ld", tag);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Data Sent" message:@"Barcode has been successfully sent" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

-(void)socket:(GCDAsyncSocket*)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSLog(@"did accept new socket");
}

-(void)socket:(GCDAsyncSocket*)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"did write partial data of length");
}

-(void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError *)err
{
    NSLog(@"socket did disconnect with %@", err);
    UIAlertView *discoAlert = [[UIAlertView alloc]initWithTitle:@"Connection Error" message:@"Connection to the server failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [discoAlert show];
    [btnSend setHidden:YES];
    UIImage *imgConnect = [UIImage imageNamed:@"button_selected.png"];
    [btnConnect setBackgroundImage:imgConnect forState:UIControlStateNormal];
    [btnConnect setTitle:@"Connect to Server" forState:UIControlStateNormal];
    [btnConnect setEnabled:YES];
}

-(void)socketDidSecure:(GCDAsyncSocket*)sock{
    NSLog(@"socket did secure");
}

- (IBAction)btnWrist:(id)sender {
    // do something
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [txtReadData resignFirstResponder];
    return true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
