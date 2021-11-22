//
//  DrawerMove.swift
//  
//
//  Created by Wellington Soares on 11/20/21.
//

import SwiftUI
import Foundation

extension AnyTransition {
  static func drawerMove(
    direction: DrawerDirection,
    drawerLength: CGFloat,
    isFullscreen: Bool
  )
  -> AnyTransition {
    AnyTransition.modifier(
      active:
        DrawerMoveTransitionModifier(
          direction: direction,
          drawerOffset: drawerLength,
          isFullscreen: isFullscreen
        ),
      
      identity:
        DrawerMoveTransitionModifier(
          direction: direction,
          drawerOffset: 0,
          isFullscreen: isFullscreen
        )
    )
  }
  
  struct DrawerMoveTransitionModifier: ViewModifier {
    let direction: DrawerDirection
    let drawerOffset: CGFloat
    let isFullscreen: Bool
    
    var safeArea: CGFloat {
      guard let screen = UIApplication.shared.windows.first else {
        return 0
      }
      return direction == .top ? screen.safeAreaInsets.bottom : screen
        .safeAreaInsets.top
    }
    
    var fullscreenOffset: CGFloat {
      drawerOffset > 0 ? drawerOffset + safeArea : drawerOffset
    }
    
    func body(content: Content) -> some View {
      ZStack {
        if isFullscreen {
          content
            .offset(
              y: -1 * verticalOffsetForDirection(
                fullscreenOffset,
                direction
              )
            )
        } else {
          content
            .offset(
              y: -1 * verticalOffsetForDirection(
                drawerOffset,
                direction
              )
            )
            .clipped()
        }
      }
      .allowsHitTesting(drawerOffset == 0)
    }
  }
}
