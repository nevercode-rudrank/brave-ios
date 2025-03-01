/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import MobileCoreServices
import UIKit
import XCTest

class UIPasteboardExtensionsTests: XCTestCase {

  fileprivate var pasteboard: UIPasteboard!

  override func setUp() {
    super.setUp()
    pasteboard = UIPasteboard.withUniqueName()
  }

  override func tearDown() {
    super.tearDown()
    UIPasteboard.remove(withName: pasteboard.name)
  }

//  func testAddPNGImage() {
//    let path = Bundle(for: self.classForCoder).path(forResource: "image", ofType: "png")!
//    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
//    let url = URL(string: "http://foo.bar")!
//    pasteboard.addImageWithData(data, forURL: url)
//    verifyPasteboard(expectedURL: url, expectedImageTypeKey: kUTTypePNG)
//  }
//
//  func testAddGIFImage() {
//    let path = Bundle(for: self.classForCoder).path(forResource: "image", ofType: "gif")!
//    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
//    let url = URL(string: "http://foo.bar")!
//    pasteboard.addImageWithData(data, forURL: url)
//    verifyPasteboard(expectedURL: url, expectedImageTypeKey: kUTTypeGIF)
//  }
//
//  fileprivate func verifyPasteboard(expectedURL: URL, expectedImageTypeKey: CFString) {
//    XCTAssertEqual(pasteboard.items.count, 1)
//    XCTAssertEqual(pasteboard.items[0].count, 2)
//    XCTAssertEqual(pasteboard.items[0][kUTTypeURL as String] as? URL, expectedURL)
//    XCTAssertNotNil(pasteboard.items[0][expectedImageTypeKey as String])
//  }

}
