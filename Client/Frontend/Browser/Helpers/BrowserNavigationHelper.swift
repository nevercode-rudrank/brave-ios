// Copyright 2021 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Shared

/// Handles displaying controllers such as settings, bookmarks, etc. on top of
/// the browser.
class BrowserNavigationHelper {
  private weak var bvc: BrowserViewController?

  init(_ browserViewController: BrowserViewController) {
    bvc = browserViewController
  }

  private enum DoneButtonPosition { case left, right }
  private typealias DoneButton = (style: UIBarButtonItem.SystemItem, position: DoneButtonPosition)

  private func open(
    _ viewController: UIViewController, doneButton: DoneButton,
    allowSwipeToDismiss: Bool = true
  ) {
    let nav = SettingsNavigationController(rootViewController: viewController).then {
      $0.isModalInPresentation = !allowSwipeToDismiss
      $0.modalPresentationStyle =
        UIDevice.current.userInterfaceIdiom == .phone ? .pageSheet : .formSheet
    }

    let button = UIBarButtonItem(barButtonSystemItem: doneButton.style, target: nav, action: #selector(nav.done))

    switch doneButton.position {
    case .left: nav.navigationBar.topItem?.leftBarButtonItem = button
    case .right: nav.navigationBar.topItem?.rightBarButtonItem = button
    }

    dismissView()
    bvc?.present(nav, animated: true)
  }

  func openBookmarks() {
    guard let bvc = bvc else { return }
    let vc = BookmarksViewController(
      folder: bvc.bookmarkManager.lastVisitedFolder(),
      bookmarkManager: bvc.bookmarkManager,
      isPrivateBrowsing: PrivateBrowsingManager.shared.isPrivateBrowsing)
    vc.toolbarUrlActionsDelegate = bvc

    open(vc, doneButton: DoneButton(style: .done, position: .right))
  }

  func openDownloads(_ completion: @escaping (Bool) -> Void) {
    FileManager.default.openBraveDownloadsFolder(completion)
  }

  func openHistory() {
    guard let bvc = bvc else { return }
    let vc = HistoryViewController(
      isPrivateBrowsing: PrivateBrowsingManager.shared.isPrivateBrowsing,
      historyAPI: bvc.braveCore.historyAPI,
      tabManager: bvc.tabManager)
    vc.toolbarUrlActionsDelegate = bvc

    open(vc, doneButton: DoneButton(style: .done, position: .right))
  }

  func openShareSheet() {
    guard let bvc = bvc else { return }
    dismissView()

    func share(url: URL) {
      bvc.presentActivityViewController(
        url,
        tab: url.isFileURL ? nil : bvc.tabManager.selectedTab,
        sourceView: bvc.view,
        sourceRect: bvc.view.convert(bvc.topToolbar.menuButton.frame, from: bvc.topToolbar.menuButton.superview),
        arrowDirection: [.up]
      )
    }

    guard let tab = bvc.tabManager.selectedTab, let url = tab.url else { return }

    if let temporaryDocument = tab.temporaryDocument {
      temporaryDocument.getURL().uponQueue(
        .main,
        block: { tempDocURL in
          // If we successfully got a temp file URL, share it like a downloaded file,
          // otherwise present the ordinary share menu for the web URL.
          if tempDocURL.isFileURL {
            share(url: tempDocURL)
          } else {
            share(url: url)
          }
        })
    } else if url.isReaderModeURL, let readerSourceURL = url.decodeReaderModeURL {
      // We want to decode the underlying url that generated the reader mode file and share that instead
      // This way we avoid sharing a url of a local file
      share(url: readerSourceURL)
    } else {
      // Otherwise share the tab url
      share(url: url)
    }
  }

  func openPlaylist() {
    bvc?.openPlaylist(tab: nil, item: nil, playbackOffset: 0.0)
  }

  @objc private func dismissView() {
    guard let bvc = bvc else { return }
    bvc.presentedViewController?.dismiss(animated: true)
  }
}
