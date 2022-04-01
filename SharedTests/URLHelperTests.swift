// Copyright 2022 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Shared

class URLHelperTests: XCTestCase {
  func testETLDExamplesWithPatterns() throws {
    // Given
    // Some patterns
    let host1 = "www.youtube.com"
    let host2 = "test.bbc.co.uk"

    // When
    // Extracting etld+1
    // Then
    // Should get the correct eTLD and eTLD+1
    XCTAssertEqual(
      URLHelper.shared.publicSuffix(fromHost: host1),
      "youtube.com"
    )
    XCTAssertEqual(
      URLHelper.shared.publicSuffix(fromHost: host2),
      "bbc.co.uk"
    )
    XCTAssertEqual(
      URLHelper.shared.publicSuffix(fromHost: host1, withAdditionalParts: 0),
      "com"
    )
    XCTAssertEqual(
      URLHelper.shared.publicSuffix(fromHost: host2, withAdditionalParts: 0),
      "co.uk"
    )
  }
}
