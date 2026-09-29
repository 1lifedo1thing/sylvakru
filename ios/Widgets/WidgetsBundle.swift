//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by wuhangyu on 2026/9/29.
//

import SwiftUI
import WidgetKit

@main
struct WidgetsBundle: WidgetBundle {
  var body: some Widget {
    NowPlayingWidget()
    PlaylistsWidget()
  }
}
