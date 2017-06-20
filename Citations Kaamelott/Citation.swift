//
//  Citation.swift
//  testsJSON
//
//  Created by Mickael Thibouret on 15/06/2017.
//  Copyright © 2017 Mickael Thibouret. All rights reserved.
//

import UIKit

class Citation: NSObject {
    
    var id:Int
    var auteur:String
    var texte:String
    
    init(id:Int, auteur:String, texte:String){
        self.id = id
        self.auteur = auteur
        self.texte = texte
    }

}
