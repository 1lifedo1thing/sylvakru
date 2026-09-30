//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by wuhangyu on 2026/9/29.
//

import ImageIO
import SwiftUI
import WidgetKit

@main
struct WidgetsBundle: WidgetBundle {
  var body: some Widget {
    NowPlayingWidget()
    PlaylistsWidget()
  }
}

// Premium state is written by the app on every launch and on purchase
// (config.dart syncWidgetPremium). A missing key means the app never ran yet
// (widget gallery, fresh install) - show the full design in that case.
func widgetIsPremium() -> Bool {
  UserDefaults(suiteName: "group.com.afalphy.sylvakru")?
    .object(forKey: "isPremium") as? Bool ?? true
}

// WidgetKit fails the timeline render when the decoded bitmap blows past
// the widget's memory/archive limits - a large cover killed the widget even
// with aspect-fit display. Decode straight to a bounded thumbnail with
// ImageIO instead of materializing the full-resolution image first: the
// aspect ratio is preserved, nothing is cropped, and EXIF orientation is
// applied.
func widgetImage(
  at path: String,
  maxPixels: CGFloat
) -> UIImage? {
  let options: [CFString: Any] = [
    kCGImageSourceCreateThumbnailFromImageAlways: true,
    kCGImageSourceCreateThumbnailWithTransform: true,
    kCGImageSourceShouldCacheImmediately: true,
    kCGImageSourceThumbnailMaxPixelSize: maxPixels,
  ]

  guard
    let source = CGImageSourceCreateWithURL(
      URL(fileURLWithPath: path) as CFURL,
      nil
    ),
    let cgImage = CGImageSourceCreateThumbnailAtIndex(
      source,
      0,
      options as CFDictionary
    )
  else {
    return nil
  }

  return UIImage(cgImage: cgImage)
}

// Overlay for sizes that require premium: NowPlaying above systemSmall,
// Playlists above systemMedium. The scrim keeps the hint readable over any
// cover. NOTE: covering the view does NOT disable widget buttons - they are
// handled by a native interaction layer above the rendered content - so the
// widgets render their controls as plain images while this overlay is shown.
struct PremiumOverlay: View {
  var background: Color
  var foreground: Color

  var body: some View {
    ZStack {
      background.opacity(0.85)

      VStack(spacing: 6) {
        Image(systemName: "lock.fill")
          .font(.system(size: 24, weight: .medium))
          .foregroundColor(foreground)

        Text(String(localized: "Unlock with Premium"))
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(foreground.opacity(0.7))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 12)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
    .contentShape(Rectangle())
  }
}
