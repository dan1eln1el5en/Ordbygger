//
//  ViewModel.swift
//  WordCraft
//
//  Created by Daniel Nielsen on 24/08/2024.
//

import SwiftUI

@Observable
class ViewModel {
	var columns = [[Tile]]()
	
	private var selected = [Tile]()
	private var usedWords = Set<String>()
	var score = 0
	
	private var targetLetter = "A"
	private var targetLength = 0
	
	var currentRule: Rule!
	
	let dictionary: Set<String> = {
		guard let url = Bundle.main.url(forResource: "ordbog", withExtension: "txt") else {fatalError( "couldn't locate dictionary.txt") }
		guard let contents = try? String(contentsOf: url, encoding: .utf8) else { fatalError("Couldnøt load ordbog.txt") }
		return Set(contents.components(separatedBy: .newlines))
	}()
	
	init(){
		#if os(iOS)
		for i in 0..<4 {
			var column = [Tile]()
			
			for _ in 0..<10 {
				let piece = Tile(column: i)
				column.append(piece)
			}
			
			columns.append(column)
		}
		#else
		for i in 0..<5 {
			var column = [Tile]()
			
			for _ in 0..<8 {
				let piece = Tile(column: i)
				column.append(piece)
			}
			
			columns.append(column)
		}
		#endif
		
		selectRule()
	}
	
	func select(_ tile: Tile) {
		if selected.last == tile && selected.count >= 3 {
			checkWord()
		} else if let index = selected.firstIndex(of: tile) {
			if selected.count == 1 {
				selected.removeLast()
			} else {
				selected.removeLast(selected.count - index - 1)
			}
		} else {
			selected.append(tile)
		}
	}
	
	func background(for tile: Tile) -> Color {
		if selected.contains(tile) {
			.white
		} else {
			.blue
		}
	}
	
	func foreground(for tile: Tile) -> Color {
		if selected.contains(tile) {
			.black
		} else {
			.white
		}
	}
	
	func remove(_ tile: Tile) {
		guard let position = columns[tile.column].firstIndex(of: tile) else { return }
		
		withAnimation{
			columns[tile.column].remove(at: position)
			columns[tile.column].insert(Tile(column: tile.column), at: 0)
		}
		
	}
	
	func checkWord() {
		let word = selected.map(\.letter).joined()
		
		guard usedWords.contains(word) == false else { return }
		guard dictionary.contains(word.lowercased()) else { return }
		guard currentRule.predicate(word) else { return }
		
		for tile in selected {
			remove(tile)
		}
		
		withAnimation {
			self.selectRule()
		}
		
		selected.removeAll()
		usedWords.insert(word)
		score += word.count * word.count
	}
	
	func startWithLetter(_ word: String) -> Bool {
		word.starts(with: targetLetter)
	}
	
	func containsLetter(_ word: String) -> Bool {
		word.contains(targetLetter)
	}
	
	func doesNotContainsLetter(_ word: String) -> Bool {
		word.contains(targetLetter) == false
	}
	
	func isLengthN(_ word: String) -> Bool {
		word.count == targetLength
	}
	
	func isAtLeastLengthN(_ word: String) -> Bool {
		word.count >= targetLength
	}
	
	func beginsAndEndsSame(_ word: String) -> Bool {
		word.first == word.last
	}
	
	func hasUniquieLetters(_ word: String) -> Bool {
		word.count == Set(word).count
	}
	
	func containsTwoAdjacentVowels(_ word: String) -> Bool {
		word.contains("AA") || word.contains("EE") || word.contains("II") || word.contains("OO") || word.contains("UU") || word.contains("ÆÆ") || word.contains("ØØ") || word.contains("ÅÅ")
	}
	
	func hasEqualVowelsAndConsonants(_ word: String) -> Bool {
		var vowles = 0
		var consonants = 0
		let vowelsSet: Set<Character> = ["A", "E", "I", "O", "U", "Æ", "Ø", "Å"]
		
		
		for letter in word {
			if vowelsSet.contains(letter) {
				vowles += 1
			} else {
				consonants += 1
			}
		}
		
		return vowles == consonants
	}
	
	func count(for letter: String) -> Int {
		var count = 0
		
		for column in columns {
			for tile in column {
				if tile.letter == letter {
					count += 1
				}
			}
		}
		
		return count
	}
	
	func selectRule() {
		let safeLetters = "ABCDEFGHIJKLMNOPRSTUWÆØÅ".map(String.init)
		targetLetter = safeLetters.filter { count(for: $0) >= 2 }.randomElement() ?? "A"
		targetLength = Int.random(in: 3...6)
		
		let rules = [
			Rule(name: "Starter med \(targetLetter)", predicate: startWithLetter),
			Rule(name: "Indeholder \(targetLetter)", predicate: containsLetter),
			Rule(name: "Indeholder ikke \(targetLetter)", predicate: doesNotContainsLetter),
			Rule(name: "Indeholder to ens vokaler ved siden af hinanden", predicate: containsTwoAdjacentVowels),
			Rule(name: "Har netop \(targetLength)", predicate: isLengthN),
			Rule(name: "Har mindst \(targetLength)", predicate: isAtLeastLengthN),
			Rule(name: "Begynder og slutter på samme bogstav", predicate: beginsAndEndsSame),
			Rule(name: "Brug hvert bogstav kun én gang", predicate: hasUniquieLetters),
			Rule(name: "Har samme antal vokaler og konsonanter", predicate: hasEqualVowelsAndConsonants)
		]
		
		let newRule = rules.randomElement()!
		
		if newRule.name.contains("har mindst") && targetLength == 3 {
			selectRule()
			return
		} else {
			currentRule = newRule
		}
		
	}
}
