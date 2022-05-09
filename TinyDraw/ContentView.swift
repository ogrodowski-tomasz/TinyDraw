//
//  ContentView.swift
//  TinyDraw
//
//  Created by Tomasz Ogrodowski on 09/05/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var drawing: Drawing
    @Environment(\.undoManager) var undoManager
    @State private var showingBrushOption: Bool = false

    var body: some View {
        Canvas { context, size in
            for stroke in drawing.strokes {
                var path = Path()
                path.addLines(stroke.points) //add all lines user draw

                var contextCopy = context // if we create a blur, it will sustain with future lines. Making copy of context lets us blur only this one, specific line.

                if stroke.blur > 0 {
                    contextCopy.addFilter(.blur(radius: stroke.blur))
                }

                contextCopy.stroke(
                    path, // path of drawn stroke
                    with: .color(stroke.color), // color of it (Can be also f.ex gradient)
                    style:
                        StrokeStyle(
                            lineWidth: stroke.width,
                            lineCap: .round,
                            lineJoin: .round,
                            dash: [1, stroke.spacing * stroke.width] // przerywana linia.
                            // 1: draw a dot, stroke.spacing * stroke.width: space between dots adaptive to the width of line and to spacing.
                        )
                )
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0) // activates with a very little drag
                .onChanged { value in // while dragging
                    drawing.add(point: value.location)
                }
                .onEnded { _ in // when finger lifted
                    drawing.finishedStroke()
                }
        )
        .ignoresSafeArea()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                undoButton
                redoButton
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                colorPicker
                brushEditButton
            }
        }
        .onAppear {
            drawing.undoManager = undoManager
        }
    }
}

extension ContentView {

    private var undoButton: some View {
        Button(action: drawing.undo) {
            Label("Undo", systemImage: "arrow.uturn.backward")
        }
        .disabled(undoManager?.canUndo == false)
    }

    private var redoButton: some View {
        Button(action: drawing.redo) {
            Label("Redo", systemImage: "arrow.uturn.forward")
        }
        .disabled(undoManager?.canRedo == false)
    }

    private var colorPicker: some View {
        ColorPicker("Color", selection: $drawing.foregroundColor)
            .labelsHidden()
    }

    private var brushEditButton: some View {
        Button("Brush") {
            showingBrushOption.toggle()
        }
        .sheet(isPresented: $showingBrushOption) {
            customBrushSheet
        }
    }

    private var customBrushSheet: some View {
        NavigationView {
            Form {
                Section {
                    HStack(spacing: 5) {
                        Text("Width: \(Int(drawing.lineWidth))")
                        Slider(value: $drawing.lineWidth, in: 1...100)

                    }
                } header: {
                    Text("Line width")
                }
                Section {
                    HStack(spacing: 5) {
                        Text("Softness: \(Int(drawing.blurAmount))")
                        Slider(value: $drawing.blurAmount, in: 0...50)
                    }
                } header: {
                    Text("Blur")
                }
                Section {
                    HStack(spacing: 5) {
                        Text("Spacing: \(drawing.lineSpacing, format: .percent)")
                        Slider(value: $drawing.lineSpacing, in: 0...5, step: 0.1)
                    }
                } header: {
                    Text("Spacing")
                }
            }
            .navigationTitle("Customize!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Drawing())
    }
}
