//
//  Drawing.swift
//  TinyDraw
//
//  Created by Tomasz Ogrodowski on 09/05/2022.
//

import SwiftUI
import UniformTypeIdentifiers // it describes a single data type. It gives access to all types are supported in Siwft (f.ex. JSON, JPEG)

// ObservableObject class that handles all the work of storing, processing and working with drawings as we go.
class Drawing: ObservableObject, ReferenceFileDocument {

    // MARK: Properties

    private var oldStrokes = [Stroke]() // stroke we've drawn already
    private var currentStroke = Stroke() // Currently drawn stroke

    // Managing 'undo'
    var undoManager: UndoManager?

    // We need to tell SwiftUI what data types our app is capable of reading.
    // In this case it’s only one, which is the “com.ogrodowski.tomasz.tinydraw” type added to project options earlier.
    // This is declared as a static propert:
    static var readableContentTypes = [UTType(exportedAs: "com.ogrodowski.tomasz.tinydraw")]

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

    // MARK: Initializers

    init() { }

    // Initializer that accepts some saved data to work with.
    // In this case we’re going to be saving all the strokes we created in our app, so we can decode an array of our Stroke struct or throw an error if it didn’t work for some reason:
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents { // if there is data
            oldStrokes = try JSONDecoder().decode([Stroke].self, from: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    // MARK: Methods

    // Being an iOS document means giving the system access to all our history, so users get built-in features such as iCloud syncing, version history, and more.
    // This means we need to tell the system every time the user makes any kind of change to our drawing – every single stroke they make – so it can add that to our version history.
    // We already did exactly this, with UndoManager. Every time we registered an undo action iOS automatically used that to track changes to our document, meaning that we already have support for version control and similar – we get it for free thanks to our UndoManager work.

    // We DO NEED TO add is a method that returns a snapshot of our document.
    // This will be called automatically by the system when it detects changes, and for this app all it needs to do is send back our stroke array:
    func snapshot(contentType: UTType) throws -> [Stroke] {
        oldStrokes
    }

    // The final part of saving is when we need to write a snapshot to permanent storage.
    // FileWrapper is a class able to handle individual files being written, but also whole directories if needed – it’s great for things like bundles.
    func fileWrapper(snapshot: [Stroke], configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(snapshot)
        return FileWrapper(regularFileWithContents: data)
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
