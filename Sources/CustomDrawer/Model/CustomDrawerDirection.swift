//
//  CustomDrawerDirection.swift
//  
//
//  Created by Wellington Soares on 11/20/21.
//

import Foundation

public enum DrawerDirection {
  case bottom
  case top
  
  var isTopLeading: Bool {
    switch self {
      case .top:
        return true
      default:
        return false
    }
  }
}
