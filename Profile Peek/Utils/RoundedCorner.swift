//
//  RoundedCorner.swift
//  Profile Peek
//
//  Created by Lyvennitha on 17/11/25.
//

import SwiftUI

// Utility Shape to round selected corners only, used for the top card background in Screen 2.

struct RoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

