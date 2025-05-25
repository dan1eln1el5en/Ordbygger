//
//  ContentView.swift
//  WordCraft
//
//  Created by Daniel Nielsen on 24/08/2024.
//

import SwiftUI

struct ContentView: View {
	@State private var viewModel = ViewModel()
	
	var body: some View {
		VStack {
			HStack {
				Text(viewModel.currentRule.name)
					.contentTransition(.numericText())
				Spacer()
				Text("**Point:** \(viewModel.score)")
			}
			
			HStack(spacing: 2) {
				ForEach(0..<viewModel.columns.count, id: \.self) { i in
					VStack(spacing: 2) {
						let column = viewModel.columns[i]
						
						ForEach(column) { tile in
							Button {
								viewModel.select(tile)
							} label: {
								Text(tile.letter)
									.font(.largeTitle)
									.bold()
									.fontDesign(.rounded)
									.frame(width: 120, height: 50)
									.foregroundColor(viewModel.foreground(for: tile))
									.background(viewModel.background(for: tile).gradient)
							}
							.buttonStyle(.borderless)
							.transition(.push(from: .top))
						}
					}
				}
			}
		}
		.padding()
		.fixedSize()
	}
}

#Preview {
    ContentView()
}
