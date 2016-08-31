//
//  OfflineIndexTests.swift
//  AlgoliaSearch
//
//  Created by Clément Le Provost on 26/08/16.
//  Copyright © 2016 Algolia. All rights reserved.
//

import AlgoliaSearch
import Foundation
#if false
import XCTest // disabled so far
#endif

// ----------------------------------------------------------------------
// WARNING
// ----------------------------------------------------------------------
// Could not find a way to have proper unit tests work for the offline
// mode. Even if we use Cocoapods to draw the dependency on the Offline
// Core, the build fails with a weird error.
// => I am emulating tests in an iOS app so far.
// ----------------------------------------------------------------------


class OfflineIndexTests /*: XCTestCase */ {

    var client: OfflineClient!
    var tests: [() -> ()]!

    init() {
        tests = [
            self.testAddGetDeleteObject,
            self.testAddWithIDGetDeleteObject,
            self.testAddGetDeleteObjects,
            self.testSearch,
            self.testGetSetSettings,
            self.testClear,
            self.testBrowse,
            self.testDeleteByQuery,
            self.testMultipleQueries
        ]
    }

    /* override */ func setUp() {
        // super.setUp()
        if client == nil {
            client = OfflineClient(appID: String(self.dynamicType), apiKey: "NEVERMIND")
            client.enableOfflineMode("AkUGAQH/3YXDBf+GxMAFABxDbJYBbWVudCBMZSBQcm92b3N0IChBbGdvbGlhKRhjb20uYWxnb2xpYS5GYWtlVW5pdFRlc3QwLgIVANNt9d4exv+oUPNno7XkXLOQozbYAhUAzVNYI6t/KQy1eEZECvYA0/ScpQU=")
        }
    }
    
    /* override */ func tearDown() {
        // super.tearDown()
    }

    let objects: [String: [String: AnyObject]] = [
        "snoopy": [
            "objectID": "1",
            "name": "Snoopy",
            "kind": "dog",
            "born": 1967,
            "series": "Peanuts"
        ],
        "woodstock": [
            "objectID": "2",
            "name": "Woodstock",
            "kind": "bird",
            "born": 1970,
            "series": "Peanuts"
        ],
    ]
    
    func test() {
        for aTest in tests {
            setUp()
            aTest()
            tearDown()
        }
    }
    
    func testAddGetDeleteObject() {
        let index = client.getOfflineIndex(#function)
        index.addObject(objects["snoopy"]!) { (content, error) in
            assert(error == nil)
            index.getObject("1") { (content, error) in
                guard let content = content else { assert(false); return }
                guard let name = content["name"] as? String else { assert(false); return }
                assert(name == "Snoopy")
                index.deleteObject("1") { (content, error) in
                    assert(error == nil)
                    index.getObject("1") { (content, error) in
                        assert(error != nil)
                        assert(error!.code == 404)
                        NSLog("[TEST] OK: \(#function)")
                    }
                }
            }
        }
    }
    
    func testAddWithIDGetDeleteObject() {
        let index = client.getOfflineIndex(#function)
        index.addObject(["name": "unknown"], withID: "xxx") { (content, error) in
            assert(error == nil)
            index.getObject("xxx") { (content, error) in
                guard let content = content else { assert(false); return }
                guard let name = content["name"] as? String else { assert(false); return }
                assert(name == "unknown")
                index.deleteObject("xxx") { (content, error) in
                    assert(error == nil)
                    index.getObject("xxx") { (content, error) in
                        assert(error != nil)
                        assert(error!.code == 404)
                        NSLog("[TEST] OK: \(#function)")
                    }
                }
            }
        }
    }
    
    func testAddGetDeleteObjects() {
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.getObjects(["1", "2"]) { (content, error) in
                guard let content = content else { assert(false); return }
                guard let items = content["results"] as? [[String: AnyObject]] else { assert(false); return }
                assert(items.count == 2)
                assert(items[0]["name"] as! String == "Snoopy")
                index.deleteObjects(["1", "2"]) { (content, error) in
                    assert(error == nil)
                    index.getObject("2") { (content, error) in
                        assert(error != nil)
                        assert(error!.code == 404)
                        NSLog("[TEST] OK: \(#function)")
                    }
                }
            }
        }
    }
    
    func testSearch() {
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            let query = Query(query: "snoopy")
            index.search(query) { (content, error) in
                guard let content = content else { assert(false); return }
                guard let nbHits = content["nbHits"] as? Int else { assert(false); return }
                assert(nbHits == 1)
                guard let hits = content["hits"] as? [[String: AnyObject]] else { assert(false); return }
                assert(hits.count == 1)
                guard let name = hits[0]["name"] as? String else { assert(false); return }
                assert(name == "Snoopy")
                NSLog("[TEST] OK: \(#function)")
            }
        }
    }
    
    func testGetSetSettings() {
        let index = client.getOfflineIndex(#function)
        let settings: [String: AnyObject] = [
            "attributesToIndex": ["foo", "bar"]
        ]
        index.setSettings(settings) { (content, error) in
            assert(error == nil)
            index.getSettings() { (content, error) in
                guard let content = content else { assert(false); return }
                assert(content["attributesToIndex"] as! NSObject == settings["attributesToIndex"] as! NSObject)
                assert(content["attributesToRetrieve"] as! NSObject == NSNull())
                NSLog("[TEST] OK: \(#function)")
            }
        }
    }
    
    func testClear() {
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.clearIndex() { (content, error) in
                assert(error == nil)
                index.browse(Query()) { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let nbHits = content["nbHits"] as? Int else { assert(false); return }
                    assert(nbHits == 0)
                    NSLog("[TEST] OK: \(#function)")
                }
            }
        }
    }
    
    func testBrowse() {
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.browse(Query(parameters: ["hitsPerPage": "1"])) { (content, error) in
                guard let content = content else { assert(false); return }
                guard let cursor = content["cursor"] as? String else { assert(false); return }
                index.browseFrom(cursor) { (content, error) in
                    guard let content = content else { assert(false); return }
                    assert(content["cursor"] == nil)
                    NSLog("[TEST] OK: \(#function)")
                }
            }
        }
    }
    
    func testDeleteByQuery() {
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.deleteByQuery(Query(parameters: ["numericFilters": "born < 1970"])) { (content, error) in
                assert(error == nil)
                index.browse(Query()) { (content, error) in
                    guard let content = content else { assert(false); return }
                    guard let nbHits = content["nbHits"] as? Int else { assert(false); return }
                    assert(nbHits == 1)
                    assert(content["cursor"] == nil)
                    NSLog("[TEST] OK: \(#function)")
                }
            }
        }
    }
    
    func testMultipleQueries() {
        let index = client.getOfflineIndex(#function)
        index.addObjects(Array(objects.values)) { (content, error) in
            assert(error == nil)
            index.multipleQueries([Query(query: "snoopy"), Query(query: "woodstock")]) { (content, error) in
                guard let content = content else { assert(false); return }
                guard let results = content["results"] as? [[String: AnyObject]] else { assert(false); return }
                assert(results.count == 2)
                for result in results {
                    guard let nbHits = result["nbHits"] as? Int else { assert(false); return }
                    assert(nbHits == 1)
                }
                NSLog("[TEST] OK: \(#function)")
            }
        }
    }
}
