//
//  MCManager.h
//  MCDemo
//
//  Created by Charles Chandler on 5/24/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser *nearbyBrowser;
@property NSMutableArray *sessions;
@property NSMutableArray *arrConnectedDevices;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCNearbyServiceBrowser;
-(void)setupMCBrowser;
-(void)advertiseSelf;
-(MCSession *)availableSession;
-(MCSession *)newSession;
-(NSArray *)collectAllConnectedPeers;

@end
