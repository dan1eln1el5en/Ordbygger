//
//  Rule.swift
//  Ordbygger
//
//  Created by Daniel Nielsen on 24/08/2024.
//

import Foundation

struct Rule {
	var name: String
	var predicate: (String) -> Bool
}
