//
//  CitationViewController.swift
//  Citations Kaamelott
//
//  Created by Mickael on 16/06/2017.
//  Copyright © 2017 Mickael Thibouret. All rights reserved.
//

// A FAIRE :
//           Améliorer l'aspect de l'interface
//           En retour, afficher uniquement les citations du personnage choisi

import UIKit

class CitationViewController: UIViewController, dataFromAuteursTableViewDelegate {
    
    @IBOutlet weak var PersonnageLabel: UILabel!
    @IBOutlet weak var CitationTextView: UITextView!
    @IBOutlet weak var personnageSelectedLabel: UILabel!
    
    // Version de la BD locale
    var versionActuelle:Double = 0.0
    
    // Ensemble des citations de la BD
    var citations:[Citation] = []
    // Liste des auteurs de citations existants
    var auteurs:[String] = []
    
    var derniereCitation:Int = 0
    var auteurChoisi:String = "Tous"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personnageSelectedLabel.isHidden = true
        
        parseJSON()
        
        // Configure écran accueil
        PersonnageLabel.text = "Citations de Kaamelott"
        CitationTextView.text = "Tapez sur le bouton \"Citation aléatoire\" pour obtenir une citation extraite de l'univers de Kaamelott."
    }
    
    @IBAction func citationAleatoireAction(_ sender: UIButton) {
        
        var nombreAleatoire = Int(arc4random_uniform(UInt32(citations.count)))
        // print("Nombre aléatoire : \(nombreAleatoire)")
        
        // Changer si la citation est la même que la précédente
        while nombreAleatoire == derniereCitation {
            
            if nombreAleatoire == 0 {
                nombreAleatoire += 1
            } else {
                nombreAleatoire -= 1
            }
            // print("Nombre changé : nouveau nombre \(nombreAleatoire)")
        }
        
        let citationSelected = citations[nombreAleatoire]
        
        
        PersonnageLabel.text = citationSelected.auteur
        CitationTextView.text = citationSelected.texte
        
        derniereCitation = nombreAleatoire
        
    }
    
    func dataFromJson(_ file:String) -> Data {
        let path = Bundle.main.path(forResource: file, ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        
        return data
    }
    
    func parseJSON(){
        
        var json:[String:Any]?
        
        do {
            json = try JSONSerialization.jsonObject(with: dataFromJson("citationsKaamelott"), options: .mutableContainers) as? [String:Any]
        } catch {
            print("Erreur lors de la serialization")
        }
        
        
        // Numéro de version
        guard let docInfo = json?["docinfo"] as? [String:Any],
            let version = docInfo["version"] as? Double else {
                print("Erreur lecture json : Version")
                return
        }
        
        versionActuelle = version
        
        // Citations
        if let quotes = json?["citations"] as? [[String:Any]] {
            
            // Vider l'array
            citations.removeAll()
            
            for quote in quotes {
                
                if let auteur = quote["auteur"] as? String,
                    let texte = quote["texte"] as? String,
                    let id = quote["id"] as? Int {
                    
                    let nouvelleCitation = Citation(id: id, auteur: auteur, texte: texte)
                    citations.append(nouvelleCitation)
                    
                    //print("\(nouvelleCitation.auteur) a dit : \(nouvelleCitation.texte) (\(nouvelleCitation.id))")
                    
                    // Liste d'auteurs
                    if auteurs.contains(nouvelleCitation.auteur) == false {
                        auteurs.append(nouvelleCitation.auteur)
                        //print("\(nouvelleCitation.auteur) ajouté")
                    }
                    
                }
                
            }
            
            print("Nombre de citations chargées : \(citations.count)")
            print("Liste des auteurs : \(auteurs)")
            
        }
        
    }
    
    // Func appelée par le delegate
    func auteurSelectionne(auteur: String) {
        
        auteurChoisi = auteur
        
        if auteurChoisi == "Tous"{
            personnageSelectedLabel.isHidden = true
        } else {
            personnageSelectedLabel.isHidden = false
            personnageSelectedLabel.text = "\(auteur) uniquement"
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinationVC = segue.destination as! AuteursTableViewController
        
        if segue.identifier == "choisirPersonnage" {
            destinationVC.auteurs[1] = auteurs
            // Cette vue est le delegate de la vue modale
            destinationVC.delegate = self
        }
    }
    
}
