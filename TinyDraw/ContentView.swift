//
//  ContentView.swift
//  TinyDraw
//
//  Created by Tomasz Ogrodowski on 09/05/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var drawing: Drawing

    var body: some View {
        NavigationView {
            Canvas { context, size in
                for stroke in drawing.strokes {
                    var path = Path()
                    path.addLines(stroke.points) //add all lines user draw

                    context.stroke(
                        path, // path of drawn stroke
                        with: .color(stroke.color), // color of it (Can be also f.ex gradient)
                        style:
                            StrokeStyle(
                                lineWidth: stroke.width,
                                lineCap: .round,
                                lineJoin: .round
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
            .navigationTitle("TinyDraw")
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Drawing())
    }
}
