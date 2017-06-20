//
//  AuteursTableViewController.swift
//  Citations Kaamelott
//
//  Created by Mickael on 16/06/2017.
//  Copyright © 2017 Mickael Thibouret. All rights reserved.
//

import UIKit

protocol dataFromAuteursTableViewDelegate {
    func auteurSelectionne(auteur:String)
}

class AuteursTableViewController: UITableViewController {
    
    var auteurs:[[String]] = [["Tous"],[]]
    
    var delegate:dataFromAuteursTableViewDelegate? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        auteurs[1].sort()
        
        //print("Données reçues : \(self.auteurs)")
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return auteurs.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return auteurs[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = auteurs[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        
        // BackgroundSelected color
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = cellBGView

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Transmet le nom de l'auteur au delegate
            self.delegate?.auteurSelectionne(auteur: auteurs[indexPath.section][indexPath.row])

        navigationController?.popViewController(animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
