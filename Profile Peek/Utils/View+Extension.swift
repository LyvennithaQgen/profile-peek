//
//  View+Extension.swift
//  Profile Peek
//
//  Created by Lyvennitha on 17/11/25.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
