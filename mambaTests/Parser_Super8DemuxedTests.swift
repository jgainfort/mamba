//
//  Parser_Super8DemuxedTests.swift
//  mamba
//
//  Created by David Coufal on 3/13/19.
//  Copyright © 2019 Comcast Corporation.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License. All rights reserved.
//

import XCTest

@testable import mamba

class Parser_Super8DemuxedTests: XCTestCase {
    
    func testHLS_Super8_1() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "super8demuxed1_4242.m3u8")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let playlist = parseMasterPlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 27, "Misparsed the HLS")
        
        for i in 0..<4 {
            XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.EXT_X_MEDIA, "Tag did not parse properly")
        }
        for i in 4..<20 {
            if i % 2 == 0 {
                XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
            }
            else {
                XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
            }
        }
        for i in 20..<27 {
            XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.EXT_X_I_FRAME_STREAM_INF, "Tag did not parse properly")
        }
        
        // do some spot tests of the data
        XCTAssert(playlist.tags[3].value(forValueIdentifier: PantosValue.groupId) == "g147200", "Tag did not parse properly")
        XCTAssert(playlist.tags[14].value(forValueIdentifier: PantosValue.resolution) == "1280x720", "Tag did not parse properly")
        let test: String? = nil
        XCTAssert(playlist.tags[18].value(forValueIdentifier: PantosValue.resolution) == test, "Tag did not parse properly")
        XCTAssert(playlist.tags[24].value(forValueIdentifier: PantosValue.uri) == "IP_720p60_51_SAP_TS/4242/format-hls-track-iframe-bandwidth-1746000-repid-1746000.m3u8", "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(masterPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
    }
    
    func testHLS_Super8_2() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "super8demuxed2_IP_1080p24_51_TS.m3u8")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let playlist = parseMasterPlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 31, "Misparsed the HLS")
        
        for i in 0..<2 {
            XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.EXT_X_MEDIA, "Tag did not parse properly")
        }
        for i in 2..<22 {
            if i % 2 == 0 {
                XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
            }
            else {
                XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
            }
        }
        for i in 22..<31 {
            XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.EXT_X_I_FRAME_STREAM_INF, "Tag did not parse properly")
        }
        
        // do some spot tests of the data
        XCTAssert(playlist.tags[0].value(forValueIdentifier: PantosValue.language) == "en", "Tag did not parse properly")
        XCTAssert(playlist.tags[7].tagData == "IP_1080p24_51_TS/IP_1080p24_51_TS/format-hls-track-video-bandwidth-624674-repid-624674.m3u8", "Tag did not parse properly")
        let test: String? = nil
        XCTAssert(playlist.tags[20].value(forValueIdentifier: PantosValue.resolution) == test, "Tag did not parse properly")
        XCTAssert(playlist.tags[30].value(forValueIdentifier: PantosValue.codecs) == "avc1.640029", "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(masterPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")    }
    
    func testHLS_Super8_3() {
        
        let hlsLoadString = FixtureLoader.loadAsString(fixtureName: "super8demuxed3_1376214110461.m3u8")
        
        guard let hlsString = hlsLoadString else {
            XCTAssert(false, "Fixture is missing?")
            return
        }
        
        let playlist = parseMasterPlaylist(inString: hlsString)
        
        XCTAssert(playlist.tags.count == 28, "Misparsed the HLS")
        
        for i in 0..<2 {
            XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.EXT_X_MEDIA, "Tag did not parse properly")
        }
        for i in 2..<20 {
            if i % 2 == 0 {
                XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.EXT_X_STREAM_INF, "Tag did not parse properly")
            }
            else {
                XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.Location, "Tag did not parse properly")
            }
        }
        for i in 20..<28 {
            XCTAssert(playlist.tags[i].tagDescriptor == PantosTag.EXT_X_I_FRAME_STREAM_INF, "Tag did not parse properly")
        }
        
        // do some spot tests of the data
        XCTAssert(playlist.tags[0].value(forValueIdentifier: PantosValue.type) == "AUDIO", "Tag did not parse properly")
        XCTAssert(playlist.tags[4].value(forValueIdentifier: PantosValue.programId) == "1", "Tag did not parse properly")
        XCTAssert(playlist.tags[20].value(forValueIdentifier: PantosValue.resolution) == "320x180", "Tag did not parse properly")
        XCTAssert(playlist.tags[26].value(forValueIdentifier: PantosValue.bandwidthBPS) == "2850000", "Tag did not parse properly")
        
        let validationIssues = PlaylistValidator.validate(masterPlaylist: playlist)
        XCTAssert(validationIssues.count == 0, "Should be no issues in the HLS fixtures")
    }
}
