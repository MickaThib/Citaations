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
//           Prévoir le cas où aucune citation n'est disponible

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
    // Données issues du fichier json
    var json:[String:Any]?
    // Array contenant les infos filtrées
    var citationsFiltrees:[Citation] = []
    
    var derniereCitation:Int = 0
    var auteurChoisi:String = "Tous"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personnageSelectedLabel.isHidden = true
        
        parseJSON()
        versionActuelle = versionJSON()
        enregistrerCitations()
        
        // Configure écran accueil
        PersonnageLabel.text = "Citations de Kaamelott"
        CitationTextView.text = "Tapez sur le bouton \"Citation aléatoire\" pour obtenir une citation extraite de l'univers de Kaamelott."
    }
    
    @IBAction func citationAleatoireAction(_ sender: UIButton) {
        
        var citationSelected:Citation?
        var nombreAleatoire:Int = 0
        
        // Si tous les auteurs sont sélectionnés
        if auteurChoisi == "Tous" {
            
            nombreAleatoire = Int(arc4random_uniform(UInt32(citations.count)))
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
            
            citationSelected = citations[nombreAleatoire]
            
        } else { // Si la recherche est filtrée
            
            // On vide l'array de citations filtrées
            citationsFiltrees.removeAll()
            
            // On remplit le tableau citationsFiltrees avec les citations qui correspondent à la recherche
            for quote in citations {
                if quote.auteur == auteurChoisi {
                    citationsFiltrees.append(quote)
                }
                // print("Nombre de citations filtrées : \(citationsFiltrees.count)")
            }
            
            nombreAleatoire = Int(arc4random_uniform(UInt32(citationsFiltrees.count)))
            
            // S'il y a plus d'une citation, changer si la citation est la même que la précédente
            if citationsFiltrees.count > 1 {
                
            while nombreAleatoire == derniereCitation {
                
                    if nombreAleatoire == 0 {
                        nombreAleatoire += 1
                    } else {
                        nombreAleatoire -= 1
                    }
                    // print("Nombre changé : nouveau nombre \(nombreAleatoire)")
                }
            }
            
            citationSelected = citationsFiltrees[nombreAleatoire]
        }
        
        if citationSelected != nil {
            PersonnageLabel.text = citationSelected?.auteur
            CitationTextView.text = citationSelected?.texte
        }
        
        derniereCitation = nombreAleatoire
        
    }
    
    func dataFromJson(_ file:String) -> Data {
        let path = Bundle.main.path(forResource: file, ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        
        return data
    }
    
    func parseJSON(){
        
        do {
            json = try JSONSerialization.jsonObject(with: dataFromJson("citationsKaamelott"), options: .mutableContainers) as? [String:Any]
        } catch {
            print("Erreur lors de la serialization")
        }
    }
    
    // Retourne la version du fichier json
    func versionJSON() -> Double {
        
        guard let docInfo = json?["docinfo"] as? [String:Any],
            let version = docInfo["version"] as? Double else {
                print("Erreur lecture json : Version")
                return 0.0
        }
        return version
    }
    
    // Place les citations + les auteurs dans un array
    func enregistrerCitations() {
        
        if let quotes = json?["citations"] as? [[String:Any]] {
            
            // Vider l'array
            citations.removeAll()
            
            for quote in quotes {
                
                if let auteur = quote["auteur"] as? String,
                    let texte = quote["texte"] as? String,
                    let id = quote["id"] as? Int {
                    
                    let nouvelleCitation = Citation(id: id, auteur: auteur, texte: texte)
                    citations.append(nouvelleCitation)
                    
                    // Liste d'auteurs
                    if auteurs.contains(nouvelleCitation.auteur) == false {
                        auteurs.append(nouvelleCitation.auteur)
                        //print("\(nouvelleCitation.auteur) ajouté")
                    }
                    
                }
                
            }
            
            print("Nombre de citations chargées : \(citations.count)")
            // print("Liste des auteurs : \(auteurs)")
            
        }
        
    }
    
    // Func appelée par le delegate
    func auteurSelectionne(auteur: String) {
        
        auteurChoisi = auteur
        
        if auteurChoisi == "Tous"{
            // Cache le label du personnage choisi
            personnageSelectedLabel.isHidden = true
        } else {
            // Affiche le label du personnage choisi + personnalise le nom
            personnageSelectedLabel.isHidden = false
            personnageSelectedLabel.text = "\(auteur) uniquement"
            
            // Affiche la première citation
            for quote in citations {
                if quote.auteur == auteurChoisi {
                    PersonnageLabel.text = quote.auteur
                    CitationTextView.text = quote.texte
                    break
                }
            }
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
