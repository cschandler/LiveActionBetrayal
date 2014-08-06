//
//  MCManager.m
//  MCDemo
//
//  Created by Charles Chandler on 5/24/14.
//  Copyright (c) 2014 Charles Chandler. All rights reserved.
//

#import "MCManager.h"

@implementation MCManager

-(id)init{
    self = [super init];
    
    // Initial setup
    if (self) {
        _peerID = nil;
        _session = nil;
        _browser = nil;
        _advertiser = nil;
    }
    
    // Initialize arrays
    _arrConnectedDevices = [[NSMutableArray alloc] init];
    _sessions = [[NSMutableArray alloc] init];
    
    return self;
}

#pragma mark - Public method implementation

// Setup session with a given display name
-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName {
    _peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
    _session = [self availableSession];
    _session.delegate = self;
}

-(void)setupMCBrowser {
    _browser = [[MCBrowserViewController alloc] initWithServiceType:@"labahohh" session:_session];
}

// Setup advertiser
-(void)advertiseSelf {
    _advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"labahohh"
                                                           discoveryInfo:nil
                                                                 session:_session];
    [_advertiser start];
}

// setup automatic browser
-(void)setupMCNearbyServiceBrowser {
    _nearbyBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID
                                                      serviceType:@"labahohh"];
    
    _nearbyBrowser.delegate = self;
    [_nearbyBrowser startBrowsingForPeers];
}

// invite found peer to an available session
-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    MCSession *session = [self availableSession];
    
    [browser invitePeer:peerID
                     toSession:session
                   withContext:nil
                       timeout:30];
    
    NSLog(@"Found peer");
}

// performed on losing a peer
-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"Lost peer");
}

// assigns a peer to an available session
-(MCSession *)availableSession {
    for (MCSession *session in _sessions) {
        if ([session.connectedPeers count] < kMCSessionMaximumNumberOfPeers) {
            return session;
        }
    }
    
    MCSession *newSession = [self newSession];
    [_sessions addObject:newSession];
    
    return newSession;
}

// creates a new session
-(MCSession *)newSession {
    MCSession *session = [[MCSession alloc] initWithPeer:_peerID];
    session.delegate = self;
    
    return session;
}

// gathers all peers from all sessions
-(NSArray *)collectAllConnectedPeers {
    NSMutableArray *allConnectedPeers = [[NSMutableArray alloc] init];
    
    for (MCSession *session in _sessions) {
        [allConnectedPeers addObjectsFromArray:session.connectedPeers];
    }
    
    NSArray *returnArray = [NSArray arrayWithArray:allConnectedPeers];
    return returnArray;
}

#pragma mark - MCSession Delegate method implementation

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSDictionary *dict = @{@"peerID": peerID,
                           @"state" : [NSNumber numberWithInt:state]
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
                                                        object:nil
                                                      userInfo:dict];
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
                                                        object:nil
                                                      userInfo:dict];
}


-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
    NSDictionary *dict = @{@"resourceName"  :   resourceName,
                           @"peerID"        :   peerID,
                           @"progress"      :   progress
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidStartReceivingResourceNotification"
                                                        object:nil
                                                      userInfo:dict];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [progress addObserver:self
                   forKeyPath:@"fractionCompleted"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    });
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
    NSDictionary *dict = @{@"resourceName"  :   resourceName,
                           @"peerID"        :   peerID,
                           @"localURL"      :   localURL
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishReceivingResourceNotification"
                                                        object:nil
                                                      userInfo:dict];
    
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCReceivingProgressNotification"
                                                        object:nil
                                                      userInfo:@{@"progress": (NSProgress *)object}];
}

- (void) session:(MCSession*)session didReceiveCertificate:(NSArray*)certificate fromPeer:(MCPeerID*)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    if (certificateHandler != nil) { certificateHandler(YES); }
}


@end
