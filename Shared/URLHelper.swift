// Copyright 2022 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private struct ETLDEntry: CustomStringConvertible {
  let entry: String

  var isNormal: Bool { return isWild || !isException }
  var isWild: Bool = false
  var isException: Bool = false

  init(entry: String) {
    self.entry = entry
    self.isWild = entry.hasPrefix("*")
    self.isException = entry.hasPrefix("!")
  }

  fileprivate var description: String {
    return "{ Entry: \(entry), isWildcard: \(isWild), isException: \(isException) }"
  }
}

private typealias TLDEntryMap = [String: ETLDEntry]

public class URLHelper {
  public static let shared = URLHelper()

  private lazy var etldEntries: TLDEntryMap? = {
    return Self.loadEntriesFromDisk()
  }()

  init() {}

  /**
   *  The following algorithm breaks apart the domain and checks each sub domain against the effective TLD
   *  entries from the effective_tld_names.dat file.
   *
   * It works like this:
   *
   *  Example Domain: test.bbc.co.uk
   *  TLD Entry: bbc
   *
   *  1. Start off by checking the current domain (test.bbc.co.uk)
   *  2. Also store the domain after the next dot (bbc.co.uk)
   *  3. If we find an entry that matches the current domain (test.bbc.co.uk), perform the following checks:
   *    i. If the domain is a wildcard AND the previous entry is not nil, then the current domain matches
   *       since it satisfies the wildcard requirement.
   *    ii. If the domain is normal (no wildcard) and we don't have anything after the next dot, then
   *        currentDomain is a valid TLD
   *    iii. If the entry we matched is an exception case, then the base domain is the part after the next dot
   *
   *  On the next run through the loop, we set the new domain to check as the part after the next dot,
   *  update the next dot reference to be the string after the new next dot, and check the TLD entries again.
   *  If we reach the end of the host (nextDot = nil) and we haven't found anything, then we've hit the
   *  top domain level so we use it by default.
   */
  public func publicSuffix(fromHost host: String, withAdditionalParts additionalPartCount: Int = 1) -> String? {
    if host.isEmpty {
      return nil
    }

    // Check edge case where the host is either a single or double '.'.
    if host.isEmpty || NSString(string: host).lastPathComponent == "." {
      return ""
    }

    var currentHost = host
    // Hosts can have a trailing period after the tld
    if host.hasSuffix(".") {
      currentHost.removeLast()
    }

    let tokens = currentHost.components(separatedBy: ".")
    let tokenCount = tokens.count
    var suffix: String?
    var previousDomain: String?
    var currentDomain: String = currentHost

    for offset in 0..<tokenCount {
      // Store the offset for use outside of this scope so we can add additional parts if needed
      let nextDot: String? = offset + 1 < tokenCount ? tokens[offset + 1..<tokenCount].joined(separator: ".") : nil

      if let entry = etldEntries?[currentDomain] {
        if entry.isWild && (previousDomain != nil) {
          suffix = previousDomain
          break
        } else if entry.isNormal || (nextDot == nil) {
          suffix = currentDomain
          break
        } else if entry.isException {
          suffix = nextDot
          break
        }
      }

      previousDomain = currentDomain
      if let nextDot = nextDot {
        currentDomain = nextDot
      } else {
        break
      }
    }

    var baseDomain: String?
    if additionalPartCount > 0 {
      if let suffix = suffix {
        // Take out the public suffixed and add in the additional parts we want.
        let literalFromEnd: NSString.CompareOptions = [
          .literal,  // Match the string exactly.
          .backwards,  // Search from the end.
          .anchored,
        ]  // Stick to the end.
        let suffixlessHost = currentHost.replacingOccurrences(of: suffix, with: "", options: literalFromEnd, range: nil)
        let suffixlessTokens = suffixlessHost.components(separatedBy: ".").filter { $0 != "" }
        let maxAdditionalCount = max(0, suffixlessTokens.count - additionalPartCount)
        let additionalParts = suffixlessTokens[maxAdditionalCount..<suffixlessTokens.count]
        let partsString = additionalParts.joined(separator: ".")
        baseDomain = [partsString, suffix].joined(separator: ".")
      } else {
        return nil
      }
    } else {
      baseDomain = suffix
    }

    return baseDomain
  }

  private static func loadEntriesFromDisk() -> TLDEntryMap? {
    if let data = String.contentsOfFileWithResourceName("effective_tld_names", ofType: "dat", fromBundle: Bundle(identifier: "com.brave.Shared")!, encoding: .utf8, error: nil) {
      let lines = data.components(separatedBy: "\n")
      let trimmedLines = lines.filter { !$0.hasPrefix("//") && $0 != "\n" && $0 != "" }

      var entries = TLDEntryMap()
      for line in trimmedLines {
        let entry = ETLDEntry(entry: line)
        let key: String
        if entry.isWild {
          // Trim off the '*.' part of the line
          key = String(line[line.index(line.startIndex, offsetBy: 2)...])
        } else if entry.isException {
          // Trim off the '!' part of the line
          key = String(line[line.index(line.startIndex, offsetBy: 1)...])
        } else {
          key = line
        }
        entries[key] = entry
      }
      return entries
    }
    return nil
  }
}
