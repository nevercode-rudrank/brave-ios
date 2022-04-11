// Copyright 2022 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Client

class DebouncingResourceDownloaderTests: XCTestCase {
  func testSettingUpDownloaderAndCheckingURLs() throws {
    // Given
    // JSON data, a downloader and test urls
    let bundle = Bundle(for: Self.self)
    let resourceURL = bundle.url(forResource: "debouncing", withExtension: "json")
    let data = try Data(contentsOf: resourceURL!)
    let downloader = DebouncingResourceDownloader()
    let includedURLs = [
      // Honest urls (that actually exists)
      URL(string: "https://www.youtube.com/redirect?q=https://example.com")!,
      // Duplicated item in debounce list
      URL(string: "https://m.facebook.com/1.php?u=https://example.com")!,
      // First entry in a list
      URL(string: "https://www.leechall.com/redirect.php?url=https://example.com")!,
      // Last entry in a list and base64 encoded
      URL(string: "https://www.pixelshost.com/?url=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!,
      // Fixed subdomain
      URL(string: "https://goto.walmart.com/c/?u=https%3A%2F%2Fexample.com")!,
      // Middle entry in a list and base64 encoded
      URL(string: "https://foo.novicearea.com/some-path/?url=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!,
      // An example where the pattern doesn't have a host and is base64 encoded
      // Example: `*://*/descargar/index.php?url=*`
      URL(string: "https://example.com/descargar/index.php?url=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!,
      // Matchall rule
      URL(string: "https://example.com/?_custom=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!,
    ]

    let excludedURLs = [
      URL(string: "https://exclude.leechall.com/exclude.php?url=https://example.com")!,
      // Matchall rule
      URL(string: "https://exclude.com/?_custom=aHR0cHM6Ly9leGFtcGxlLmNvbQ==")!
    ]

    // When
    // Setting up downloader
    // Then
    // doesn't throw
    try downloader.setup(withRulesJSON: data)

    // Then
    // Returns valid debounced links
    let extractURL = URL(string: "https://example.com")!
    for includedURL in includedURLs {
      XCTAssertEqual(downloader.redirectURL(for: includedURL), extractURL)
    }

    // Then
    // Returns nil for excluded items
    for excludedURL in excludedURLs {
      XCTAssertEqual(downloader.redirectURL(for: excludedURL), nil)
    }
  }
}
