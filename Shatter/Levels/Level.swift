//
//  Level.swift
//  Scatter
//
//  Created by Shanti Mickens on 9/9/19.
//  Copyright © 2019 Shanti Mickens. All rights reserved.
//

import Foundation
import SpriteKit

class Level {
    
    private var blocks = [[Int]]()
    
    init(levelName: String) {
        // loads level data from json file
        //print("Level Data")
        loadData(fileName: levelName)
    }
    
    // reads json from local file
    func loadData(fileName: String) {
        let url = Bundle.main.url(forResource: fileName, withExtension: "json")
        guard let jsonData = url else { return }
        guard let data = try? Data(contentsOf: jsonData) else { return }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
        //print(json)
        
        if let dictionary = json as? [String: Any] {
            
            //print(dictionary["levelData"])
            
            //if let levelNumber = dictionary["levelNumber"] as? Int {
                //print("Level Number: \(levelNumber)")
            //}
            
            if let data = dictionary["levelData"] as? [String : Any] {
                //print("Data: \(data)")
                if let row1 = data["row1"] as? [Int] {
                    //print(row1)
                    blocks.append(row1)
                }
                if let row2 = data["row2"] as? [Int] {
                    //print(row2)
                    blocks.append(row2)
                }
                if let row3 = data["row3"] as? [Int] {
                    //print(row3)
                    blocks.append(row3)
                }
                if let row4 = data["row4"] as? [Int] {
                    //print(row4)
                    blocks.append(row4)
                }
                if let row5 = data["row5"] as? [Int] {
                    //print(row5)
                    blocks.append(row5)
                }
                if let row6 = data["row6"] as? [Int] {
                    //print(row6)
                    blocks.append(row6)
                }
                if let row7 = data["row7"] as? [Int] {
                    //print(row7)
                    blocks.append(row7)
                }
            }
            
            //print(blocks)
            
        }
    }
    
    func getBlocksArray() -> [[Int]] {
        return blocks
    }
    
}

