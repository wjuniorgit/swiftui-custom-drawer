//
//  Util.swift
//  
//
//  Created by Wellington Soares on 11/20/21.
//

import SwiftUI
import Foundation

// Util //

extension View {
  func frameWithDirection(
    direction: DrawerDirection,
    lenght: CGFloat
  ) -> some View {
    modifier(FrameWithDirection(direction: direction, lenght: lenght))
  }
}

private struct FrameWithDirection: ViewModifier {
  let direction: DrawerDirection
  let lenght: CGFloat
  
  func body(content: Content) -> some View {
    content
      .frame(
        height: lenght,
        alignment: frameAlignmentForDirection(direction)
      )
  }
  
   func frameAlignmentForDirection(_ direction: DrawerDirection)
  -> Alignment {
    switch direction {
      case .bottom:
        return .bottom
      case .top:
        return .top
    }
  }
  
}


func zStackAlignmentForDirection(_ direction: DrawerDirection)
-> Alignment {
  switch direction {
    case .bottom:
      return .top
    case .top:
      return .bottom
  }
}


func verticalOffsetForDirection(
  _ offset: CGFloat,
  _ direction: DrawerDirection
) -> CGFloat {
  switch direction {
    case .bottom:
      return offset
    case .top:
      return -1 * offset
  }
}
