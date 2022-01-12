//
//  JSONTests.swift
//  
//
//  Created by Vladislav Fitc on 11.01.2022.
//

import Foundation
import XCTest
@testable import AlgoliaSearchClient

class JSONTests: XCTestCase {
  

}


// Decoding
extension JSONTests {
  
  func testArrayDecoding() throws {
    let data = "[\"JSON string\"]".data(using: .utf8)!
    let json = try JSONDecoder().decode(JSON.self, from: data)
    XCTAssertEqual(json, ["JSON string"])
  }
  
  func testDictionaryDecoding() throws {
    let data = "{\"a\": 1}".data(using: .utf8)!
    let json = try JSONDecoder().decode(JSON.self, from: data)
    XCTAssertEqual(json, ["a": 1])
  }
  
  func testStringDecoding() throws {
    let data = "\"JSONString\"".data(using: .utf8)!
    let json = try JSONDecoder().decode(JSON.self, from: data)
    XCTAssertEqual(json, "JSONString")
  }
  
  func testBoolDecoding() throws {
    let data = "true".data(using: .utf8)!
    let json = try JSONDecoder().decode(JSON.self, from: data)
    XCTAssertEqual(json, true)
  }
  
  func testNumberDecoding() throws {
    let data = "2022".data(using: .utf8)!
    let json = try JSONDecoder().decode(JSON.self, from: data)
    XCTAssertEqual(json, 2022)
  }
  
  func testNullDecoding() throws {
    let data = "null".data(using: .utf8)!
    let json = try JSONDecoder().decode(JSON.self, from: data)
    XCTAssertEqual(json, .null)
  }
  
}


// Encoding
extension JSONTests {
  
  func testArrayEncoding() throws {
    let json = JSON.array(["a", "b", "c"])
    let data = try JSONEncoder().encode(json)
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
    XCTAssertEqual(jsonObject as? [String], ["a", "b", "c"])
  }
  
  func testDictionaryEncoding() throws {
    let json = JSON.dictionary(["a": 1])
    let data = try JSONEncoder().encode(json)
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
    XCTAssertEqual(jsonObject as? [String: Int], ["a": 1])
  }
  
  func testStringEncoding() throws {
    let json = JSON.string("json string")
    let data = try JSONEncoder().encode(json)
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    XCTAssertEqual(jsonObject as? String, "json string")
  }
  
  func testBoolEncoding() throws {
    let json = JSON.bool(true)
    let data = try JSONEncoder().encode(json)
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    XCTAssertEqual(jsonObject as? Bool, true)
  }
  
  func testNumberEncoding() throws {
    let json = JSON.number(2022)
    let data = try JSONEncoder().encode(json)
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    XCTAssertEqual(jsonObject as? NSNumber, 2022)
  }
  
  func testNullEncoding() throws {
    let json = JSON.string("null")
    let data = try JSONEncoder().encode(json)
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    XCTAssertEqual(String(describing: jsonObject), "null")
  }

}
