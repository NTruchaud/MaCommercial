//
//  User.swift
//  MaCommercial
//
//  Created by iem on 03/06/2015.
//

import Foundation

//MARK: - TypeUser Enum
enum TypeUser{
    case CLIENT
    case COMMERCIAL
    case UNDEFINED
    static let allValues = [CLIENT, COMMERCIAL, UNDEFINED]
    
    var stringValue : String {
        switch self {
            // Use Internationalization, as appropriate.
        case .CLIENT: return "CLIENT";
        case .COMMERCIAL: return "COMMERCIAL";
        case .UNDEFINED: return "UNDEFINED";
        }
    }
}

//MARK: - User Class
class User : Entity {
    
    //MARK: - Variables
    var last_name :String
    var first_name :String
    var email :String
    var password :String
    var cell_number :String
    var company :String
    var job: String
    var picture: String
    var postal_address: String
    var home_number: String
    var birth_date: String
    var type: TypeUser
    
    //MARK: - Init
    convenience override init(){
        self.init(id: nil, last_name: "", first_name: "", email: "", password: "", cell_number: "", company :"", job: "", picture: "", postal_address: "", home_number: "", birth_date: "", type: .UNDEFINED)
    }
    
    convenience init(id: Int?, last_name: String, first_name: String, email: String, password: String, cell_number: String, type: TypeUser){
        self.init(id: id, last_name: last_name, first_name: first_name, email: email, password: password, cell_number: cell_number, company :"", job: "", picture: "", postal_address: "", home_number: "", birth_date: "", type: type)
    }
    
    init(id: Int?, last_name: String, first_name: String, email: String, password: String, cell_number: String, company :String, job: String, picture: String, postal_address: String, home_number: String, birth_date: String, type: TypeUser){
        
        self.last_name = last_name
        self.first_name = first_name
        self.email = email
        self.password = password
        self.cell_number = cell_number
        self.company = company
        self.job = job
        self.picture = picture
        self.postal_address = postal_address
        self.home_number = home_number
        self.birth_date = birth_date
        self.type = type
        
        //Super Init
        super.init()
        self.id = id
        
        //Set Keys
        self.Key = [
            kMCWsTableName: "users",
            kMCWsId: "id",
            kMCWsLastName: "last_name",
            kMCWsFirstName: "first_name",
            kMCWsEmail: "email",
            kMCWsPassword: "password",
            kMCWsCellNumber: "cell_number",
            kMCWsCompany: "company",
            kMCWsJob: "job",
            kMCWsPicture: "picture",
            kMCWsPostalAdress: "postal_adress",
            kMCWsHomeNumber: "home_number",
            kMCWsBirthDate: "birth_date",
            kMCWsType: "type"
        ]
    }
    
    func createClient(id: Int?, last_name: String, first_name: String, email: String, cell_number: String, job: String, picture: String, postal_address: String, home_number: String, birth_date: String){
        
        self.id = id
        self.last_name = last_name
        self.first_name = first_name
        self.email = email
        self.password = ""
        self.cell_number = cell_number
        self.job =  job
        self.picture = picture
        self.postal_address = postal_address
        self.home_number = home_number
        self.birth_date = birth_date
        self.type = .CLIENT
        
    }
    
    func createCommercial(id: Int?, last_name: String, first_name: String, email: String, password: String, cell_number: String){
        
        self.id = id
        self.last_name = last_name
        self.first_name = first_name
        self.email = email
        self.password = password
        self.cell_number = cell_number
        self.type = .COMMERCIAL
    }
        
    //MARK: - Override Functions
    override func fromJSON(data: JSON) -> User{
        self.id = data[self.Key[kMCWsId]!].intValue
        self.last_name = data[self.Key[kMCWsLastName]!].stringValue
        self.first_name = data[self.Key[kMCWsFirstName]!].stringValue
        self.email = data[self.Key[kMCWsEmail]!].stringValue
        self.cell_number = data[self.Key[kMCWsCellNumber]!].stringValue
        self.company = data[self.Key[kMCWsCompany]!].stringValue
        self.job = data[self.Key[kMCWsJob]!].stringValue
        self.picture = data[self.Key[kMCWsPicture]!].stringValue
        self.postal_address = data[self.Key[kMCWsPostalAdress]!].stringValue
        self.home_number = data[self.Key[kMCWsHomeNumber]!].stringValue
        self.birth_date = data[self.Key[kMCWsBirthDate]!].stringValue
        
        for type in TypeUser.allValues {
            if type.stringValue == data[self.Key[kMCWsType]!].stringValue {
                self.type = type
            }
        }
        
        return self
    }
    
    override func toDictionnary() -> [String : String] {
        var response = [String: String]()
        
        if let id = self.id {
            response[self.Key[kMCWsId]!] = "\(id)"
        }
        
        response[self.Key[kMCWsLastName]!] = self.last_name
        response[self.Key[kMCWsFirstName]!] = self.first_name
        response[self.Key[kMCWsEmail]!] = self.email
        response[self.Key[kMCWsCellNumber]!] = self.cell_number
        response[self.Key[kMCWsCompany]!] = self.company
        response[self.Key[kMCWsJob]!] = self.job
        response[self.Key[kMCWsPicture]!] = self.picture
        response[self.Key[kMCWsPostalAdress]!] = self.postal_address
        response[self.Key[kMCWsHomeNumber]!] = self.home_number
        response[self.Key[kMCWsBirthDate]!] = self.birth_date
        response[self.Key[kMCWsType]!] = "\(self.type.stringValue)"
        
        return response
    }
}
