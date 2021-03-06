import Foundation

class POKEAPI {

    static let shared = POKEAPI()
    private init(){}
    
    static let endpoint = "https://pokeapi.co/api/v2/pokemon/"
    var searchResult: [Pokemon] = []
    var savedPokemon: [Pokemon] = []
    
    static func saveToPokedex(pokemon: Pokemon){
        //local
        var pokeArr = POKEAPI.shared.savedPokemon
        pokeArr.append(pokemon)
        
        //remote
        Firebase<Pokemon>.save(item: pokemon) { success in
            guard success else { return }
            //DispatchQueue.main.async { completion() }
        }
    }
    
    static func deleteFromPokedex(indexPath: IndexPath){
        //local
        let pokemon = POKEAPI.shared.savedPokemon[indexPath.row]
        POKEAPI.shared.savedPokemon.remove(at: indexPath.row)
        
        //remote
        Firebase<Pokemon>.delete(item: pokemon) { success in
            guard success else { return }
            //DispatchQueue.main.async { completion() }
        }
    }
    
    static func makeTypesString(for pokemon: Pokemon?) -> String {
        let types = pokemon?.types
        var typesArray: [String] = []
        for type in types! {
            //print(type.type?.name)
            typesArray.append((type.type?.name)!)
        }
        return typesArray.joined(separator: ", ")
    }
    
    static func makeAbilitiesString(for pokemon: Pokemon?) -> String {
        let abilities = pokemon?.abilities
        var abilitiesArray: [String] = []
        for abil in abilities! {
            //print(abil.ability?.name)
            abilitiesArray.append((abil.ability?.name)!)
        }
        return abilitiesArray.joined(separator: ", ")
    }
    
    static func searchForPokemon(with searchTerm: String, completion: @escaping (Pokemon?, Error?) -> Void) {
        let base = endpoint + "\(searchTerm.replacingOccurrences(of: " ", with: "-").lowercased())"
        //construct baseURL
        print(base)
        guard let baseURL = URL(string: base) else {fatalError("Unable to construct base URL from endpoint")}
        //Break baseURL into its components
        print(baseURL)
        guard let urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else { fatalError("Unable to resolve baseURL components")}
      
        // Re-compose the components back into a valid URL
        guard let searchURL = urlComponents.url else {
            NSLog("Error constructing a valid URL")
            completion(nil, NSError())
            return
        }
        // create the GET request
        var request = URLRequest(url: searchURL)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) {
            data, _, error in
            
            //Unwrap data
            guard error == nil, let data = data else {
                if let error = error {
                    NSLog("Could not unwrap data: \(error)")
                    completion(nil, error)
                }
                
                return
            }
            print("We Have Data! \(data.hashValue)")
            //Decode the data
            
            do {
                //instantiate a JSONDecoder
                let decoder = JSONDecoder()
                
                // decode into PokemonSearchResult
                let searchResults = try decoder.decode(Pokemon.self, from: data)
                completion(searchResults, nil) } catch {
                    NSLog("Unable to decode data")
                    completion(nil, error)
                
            }
        }
        
        dataTask.resume()
    }
}
