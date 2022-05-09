//
//  Drawing.swift
//  TinyDraw
//
//  Created by Tomasz Ogrodowski on 09/05/2022.
//

import SwiftUI

// ObservableObject class that handles all the work of storing, processing and working with drawings as we go.
class Drawing: ObservableObject {
    private var oldStrokes = [Stroke]() // stroke we've drawn already
    private var currentStroke = Stroke() // Currently drawn stroke

    // Managing 'undo'
    var undoManager: UndoManager?

    init() { }

    // Adding current stroke to array of all strokes
    var strokes: [Stroke] {
        var all = oldStrokes
        all.append(currentStroke)
        return all
    }

    @Published var foregroundColor = Color.black {
        didSet {
            currentStroke.color = foregroundColor
        }
    }

    @Published var lineWidth = 3.0 {
        didSet {
            currentStroke.width = lineWidth
        }
    }

    @Published var lineSpacing = 0.0 {
        didSet {
            currentStroke.spacing = lineSpacing
        }
    }

    @Published var blurAmount = 0.0 {
        didSet {
            currentStroke.blur = blurAmount
        }
    }

    // Moving finger on screen (which means drawing a stroke)
    func add(point: CGPoint) {
        objectWillChange.send() // announcing that our drawing will cahnge
        currentStroke.points.append(point) // changing
    }

    // When user lift finger up (which means ending of drawing a stroke)
    func finishedStroke() {
        addStrokeWithUndo(currentStroke)
    }

    func newStroke() {
        currentStroke = Stroke( // new stroke prepared to be drawn
            color: foregroundColor,
            width: lineWidth,
            spacing: lineSpacing,
            blur: blurAmount
        )
    }

    func undo() {
        objectWillChange.send()
        undoManager?.undo()
    }

    func redo() {
        objectWillChange.send()
        undoManager?.redo()
    }

    // Support for "Undo" and "Redo"

    // adding a stroke but prepared to undo this adding
    private func addStrokeWithUndo(_ stroke: Stroke) {
        // preparing an "Undo Action" to remove the stroke
        undoManager?.registerUndo(withTarget: self, handler: { drawing in
            // This 'handler' method will not be done until User press 'undo' button
            drawing.removeStrokeWithUndo(stroke)
        })

        objectWillChange.send()
        oldStrokes.append(stroke)
        newStroke()
    }

    // removing a stroke but prepared to redo this and view that stroke again
    private func removeStrokeWithUndo(_ stroke: Stroke) {
        // User pressed 'remove'
        undoManager?.registerUndo(withTarget: self, handler: { drawing in
            // "Redo" = "Undo the undo"
            drawing.addStrokeWithUndo(stroke)
        })

        oldStrokes.removeLast()
    }
}
