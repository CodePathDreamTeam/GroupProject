//
//  ToDoItem.swift
//  GroupProject
//
//  Created by Brandon Aubrey on 4/26/17.
//  Copyright © 2017 Brandon Aubrey. All rights reserved.
//

import UIKit

class ToDoItem: NSObject {
    // A text description of this item.
    var text: String
    
    // A Boolean value that determines the completed state of this item.
    var completed: Bool
    
    // Returns a ToDoItem initialized with the given text and default completed value.
    init(text: String) {
        self.text = text
        self.completed = false
    }
}
