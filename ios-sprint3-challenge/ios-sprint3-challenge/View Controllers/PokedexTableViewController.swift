import UIKit

class PokedexTableViewController: UITableViewController {

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//            tableView.reloadData()
//    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return POKEAPI.shared.savedPokemon.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PokedexTableViewCell.reuseIdentifier, for: indexPath) as! PokedexTableViewCell

        // Configure the cell...
        let result = POKEAPI.shared.savedPokemon[indexPath.row]
        cell.pokemonName.text = result.name
        cell.pokemonSprite.loadImageFrom(url: URL(string: result.sprites?.frontDefault ?? "https://via.placeholder.com/128x201?text=Cover%20Image%20Unavailable")!)

        return cell
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem?.isEnabled = false
        let activity = UIActivityIndicatorView()// for indeterminate waits
        activity.style = .gray
        activity.startAnimating()
        navigationItem.titleView = activity


        // Fetch records from Firebase and then reload the table view
        // Note: this may be significantly delayed.
        Firebase<Pokemon>.fetchRecords { savedPokemon in
            if let savedPokemon = savedPokemon {
                POKEAPI.shared.savedPokemon = savedPokemon  // breaks encapsulation, hacked it instead due to time constriants

                // Comment this out to show what it looks like while waiting
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.navigationItem.titleView = nil // important to be able to see custom title
                    self.title = ""
                }
            }
        }
    }
 
     //Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableViewPassedToUs: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            POKEAPI.deleteFromPokedex(indexPath: indexPath)
            //POKEAPI.shared.savedPokemon.remove(at: indexPath.row)
            print("deleted pokemon at indexPath: \(indexPath)")
            print(POKEAPI.shared.savedPokemon)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        }
        
        
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let destination = segue.destination as? PokedexDetailViewController else { return }
        // Pass the selected object to the new view controller.
        destination.savedPoke = POKEAPI.shared.savedPokemon[indexPath.row]
    }
    

}
