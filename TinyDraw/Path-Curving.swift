//
//  Path-Curving.swift
//  TinyDraw
//
//  Created by Tomasz Ogrodowski on 09/05/2022.
//

import SwiftUI

// Smoothing lines
extension Path {
    init(curving points: [CGPoint]) {
        self = Path { path in
            // if we have no points - escape
            guard let firstPoint = points.first else { return }

            path.move(to: firstPoint)
            var previous = firstPoint

            for point in points.dropFirst() { // because we already used that first point
                let middle = CGPoint(
                    x: (point.x + previous.x) / 2,
                    y: (point.y + previous.y) / 2
                )
                path.addQuadCurve(to: middle, control: previous)
                previous = point
            }

            path.addLine(to: previous)
        }
    }
}
